function result = ita_spk2level(varargin)
%ITA_SPK2LEVEL - Level of Spectra - Added (SPL)
%  This function calculates band levels out of time or frequency data.
%  The output variable can be the values of sound pressure level in Pascal
%  or dB and the respective center frequencies (for band filters) or the
%  data_struct with this values added to the header.
%
%  Syntax: [itaAudio] = ita_spk2level(itaAudio,fraction,method,options)
%  Syntax: [SPL,Fc] = ita_spk2level(itaAudio,fraction,method,options)
%
%  fraction: 0 = whole spectrum, 1 = octave bands, 3 = 1/3 octave bands, etc
%  method: 'added' (correct for power signals) or 'averaged' (correct for energy signals)
%   
%  Options(default): filtertype ('rectangular') - 'rectangular', 'Class 0', 'Class 1', 'Class 2', 'A' or 'C' weightned 
%                    order (6) - filter order
%
%   See also ita_get_value, ita_mean, ita_rms, ita_mpb_filter.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_spk2level">doc ita_spk2level</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-Jun-2008 


%% Verbose and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     
warning([thisFuncStr ' please check me!']);

%% Initialization and Input Parsing
narginchk(1,5)

%find audio data
sArgs   = struct('pos1_data','itaAudioFrequency','pos2_fraction','integer',...
                 'pos3_method','anything');
[data, fraction, method, sArgs] = ita_parse_arguments(sArgs,varargin(1:3)); 

if nargin<5
    order = 6;
else
    order = varargin{5};
    if rem(order,2) == 1
        order = order + 1;
    end
end

if nargin<4
    filtertype = 'rectangular';
else
    filtertype = varargin{4};
end

% if nargin<3
%     method = 'added';5993,2
% else
%     method = varargin{3};
% end
% 
% if nargin<2
%     fraction = 3;
% else
%     fraction = varargin{2};
    if fraction == 0 && ~(strcmpi(filtertype,'a') || strcmpi(filtertype,'c'))
        filtertype = 'rectangular';
    end
% end

if strcmpi(data.signalType ,'energy') && strcmpi(method,'added')
    warning('ITA_SPK2LEVEL:Averaged method is suggested for energy signals.') %#ok<WNTAG>
elseif strcmpi(data.signalType ,'power') && strcmpi(method,'averaged')
    warning('ITA_SPK2LEVEL:Added method is suggested for power signals.') %#ok<WNTAG>
end

%% Do calculation
switch lower(filtertype)
    case 'rectangular'
        [level,f_m] = local_rectangular(data,fraction,method);
        
    case {'class 0','class 1','class 2',0,1,2}
        if ischar(filtertype)
            filtertype = str2double(filtertype(end));
        end
        [level,f_m] = local_normiert(data,fraction,method,filtertype,order);   
        
    case {'a','c'}
        [level,f_m] = local_weightned(data,method,filtertype);   
        
    otherwise
        error('ITA_SPK2LEVEL: I don''t know this filter type.')
end

%% Update Header
% data.comment = [method ' SPL - ' data.comment];

% ref = ones(size(level));
% ChannelUnits = cell(1,data.nChannels);
% for idx  = 1:data.nChannels
%     ChannelUnits{idx} = data.channelUnits{idx};
% end
% ref(ismember(ChannelUnits,'Pa'),:) = 20e-5;
% SPL = 20.*log10(level./ref);

%% Find output parameters
if fraction == 1
    b = [];
else
    b = ['1/' num2str(fraction)];
end
result = itaResult;
result.freqVector = f_m.';
result.freqData = level.';
result.resultType = ['Sound Pressure Level in ' b ' octave bands'];
result.comment = data.comment;
result.channelNames = data.channelNames;
result.channelUnits = data.channelUnits;

function [result,f_m] = local_rectangular(data,fraction,method)
if fraction == 0
    lower_limit_idx = 1;
    upper_limit_idx = data.nBins;
    nBands = 1;
    f_m = 'linear';
    
else
	bin_vector = data.freqVector;
    bin_dist = bin_vector(2) - bin_vector(1);
    
    %% frequency bands according to DIN EN 61260    %BMA: now REALLY
    %% according to the norm
    b = fraction;
    G = 10^(3/10);
    f_r = 1000;

    bandwidth = G^(1/b);
    HalfSamplingRate = data.samplingRate/2;
    % Define limits of filter sequence. Upper limit is given by the sampling
    % frequency and the lower my be set by the user.
    f_low = 20; %Hz
    f_high = HalfSamplingRate * G^(-1/2/b); %Hz

    low = round(log(f_low/f_r)/log(bandwidth));
    if f_r*bandwidth^low < f_low, low = low+1; end
    high = round(log(f_high/f_r)/log(bandwidth));
%     if f_r*bandwidth^high > f_high, high = high-1; end

    x = low:high;
    nBands = length(x);

    if rem(b,2) == 1
        f_m = (G.^(x/b))*f_r;
    else
        f_m = (G.^((2*x+1)/(2*b)))*f_r;
    end

    bandLowerLimit = f_m * G^(-1/2/b);
    bandUpperLimit = f_m * G^(1/2/b);
    
    %BMA: Allow a last non-complete interval to be calculated.
    if any(bandUpperLimit > HalfSamplingRate)
        idx = find(bandUpperLimit > HalfSamplingRate,1,'first');
        f_m(idx+1:end) = [];
        bandLowerLimit(idx+1:end) = [];
        bandUpperLimit(idx) = HalfSamplingRate;
        bandUpperLimit(idx+1:end) = [];
    end
    %% Calculate Level values
    result = zeros(data.nChannels,nBands);
    lower_limit_idx = ceil(bandLowerLimit/bin_dist + 1);
    upper_limit_idx = floor(bandUpperLimit/bin_dist + 1);
end

for idx = 1:nBands

    switch lower(method)
        case 'added'
                result(:,idx) = sqrt(sum((abs(data.spk(:,lower_limit_idx(idx):upper_limit_idx(idx)))).^2,2)); %steps added
        case 'averaged'
                result(:,idx) = sqrt(mean((abs(data.spk(:,lower_limit_idx(idx):upper_limit_idx(idx)))).^2,2)); %steps added
        otherwise
            error('ITA_SPK2LEVEL: Unknown method!')
    end
end


function [result,f_m] = local_normiert(data,fraction,method,filtertype,order)
aux = ita_mpb_filter(data.samplingRate,'octave',fraction,'class',filtertype,'order',order);
f_m = aux.CenterFreq;
imp = aux.impulseResponse;
size_f_m = length(f_m);
% imp.dat = impulse.dat;
% imp.header = impulse.header;
% imp = ita_metainfo_check(imp);
result = zeros(data.nChannels,size_f_m);
for idx = 1:size_f_m
    filter = ita_split(imp,idx);
    filter = ita_fft(ita_extend_dat(filter,data.nSamples));
    filter.spk = abs(filter.spk);
    FData = ita_multiply_spk(filter,data);
    
    switch lower(method)
        case 'added'
            result(:,idx) = sqrt(sum((abs(FData.spk)).^2,2)); %steps added
            
        case 'averaged'
            result(:,idx) = sqrt(mean((abs(FData.spk)).^2,2)); %steps added
            
        otherwise
            error('ITA_SPK2LEVEL: Unknown method!')
    end
end


function [result,f_m] = local_weightned(data,method,filtertype)
data = ita_mpb_filter(data,filtertype);
switch lower(method)
    case 'added'
        result = sqrt(sum((abs(data.spk)).^2,2)); %steps added

    case 'averaged'
        result = sqrt(mean((abs(data.spk)).^2,2)); %steps added

    otherwise
        error('ITA_SPK2LEVEL: Unknown method!')
end
f_m = upper(filtertype);

% function value = local_filtercorrection(filter)
% f_m = filter.freqvec;
% f = ita_make_frequencyvector(filter).';
% [junk,low] = min(abs(f-f_m(1)));
% [junk,high] = min(abs(f-f_m(end)));
% FILTER = ita_fft(filter);
% SUM_F = sum(FILTER.spk.*conj(FILTER.spk),1);
% value = mean(SUM_F(low:high));
