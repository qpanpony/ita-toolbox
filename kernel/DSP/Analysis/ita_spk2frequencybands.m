function varargout = ita_spk2frequencybands(varargin)
%ITA_SPK2FREQUENCYBANDS - calculates a band spectrum
%  This function sums or averages power in frequency bands out of time or
%  frequency data. The input must not be squared. The output will not be squared.
%
%   Syntax: out = ita_spk2frequencybands(audioObj,'bandsperoctave',3,'method','added','freqRange',[10 500])
%           - calculates the added energy from 10-500Hz in 3rd octave bands without filtering
%
%   Options (default):
%           'mode' ('fft')          : 'fft'
%                                     'filter' - calculates a band spectrum using frequency filters (ita_mpb_filter),
%                                     sums power in frequency bands out of filtered data
%           'freqRange'   (ita_preferences('freqRange'))      : extract only frequncybands within
%                                     these limit-frequencies (give center frequencies)
%           'bandsperoctave' (ita_preferences('bandsPerOctave'))    : 3=1/3 octave bands, 12=1/12 octave bands
%           'weighting'('')         : 'A' or 'C' (according to DIN 61672-1)
%
%   fft-mode specific Options (default):
%           'method' (added)        : 'added' or 'averaged' ('averaged' method works only for 'mode' = 'fft')
%           'squared_input' (false) : if the INPUT is already a squared field variable e.g. squared pressure
%
%   filter-mode specific Options (default):
%           'order' (10)            : filterorder 4, 6, 8 or 10 (only for 'mode' = 'filter')
%           'class' (0)             : 0, 1 or 2 (only for 'mode' = 'filter')
%
%
%   Example:
%   sine = ita_generate('sine',1,900,44100,12);
%   out = ita_spk2frequencybands(sine,'mode','filter');
%   out = ita_spk2frequencybands(sine,'mode','fft');
%
%   See also: ita_power
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_spk2frequencybands">doc ita_spk2frequencybands</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Matthias Lievens -- Email: mli@akustik.rwth-aachen.de
% Created:  13-Aug-2009

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];    % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,13);
sArgs   = struct('pos1_spk','itaSuper','bandsperoctave',ita_preferences('bandsperoctave'),'method','added','freqRange',ita_preferences('freqRange'),'weighting','','squared_input',false,'mode','fft','order',10,'class',0);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

mode = sArgs.mode;
if strcmp(mode,'filter')
    sArgs.method = 'added'; % only sum for filter-mode
    sArgs.squared_input = false;  % no squared input for filter-mode
end

if isa(input,'itaResult')
    mode = 'fft';
elseif strcmpi(input.signalType, 'energy')
    ita_verbose_info('method set to averaged for energy signals',1); % only average for energy signals
    sArgs.method = 'averaged';
end

% find upper and lower limit for freqRange, considering the signal
f    = input.freqVector;
sArgs.freqRange(1) = max(sArgs.freqRange(1),min(f));
sArgs.freqRange(2) = min(sArgs.freqRange(2),max(f));

if isa(input,'itaAudio')
    samplingRate = input.samplingRate;
elseif isa(input,'itaResult')
    samplingRate = 2*max(input.freqVector);
else
    error('What kind of input is this (neither itaAudio nor itaResult)?');
end

[fmView, fmExact] = ita_ANSI_center_frequencies(sArgs.freqRange,sArgs.bandsperoctave,samplingRate);

% if the input is squared, don't do it again
if sArgs.squared_input
    exponent = 1;
else
    exponent = 2;
end

bw_desgn = 2*sArgs.bandsperoctave;

%% Filter
% apply filter and reorganize data
if strcmp(mode,'filter') %mli version
    result  = ita_mpb_filter(input,'oct',sArgs.bandsperoctave,'class',sArgs.class,'order',sArgs.order, 'octavefreqrange', sArgs.freqRange); % apply mpb filter
    if input.nChannels > 1 % if input has more channels than 1, rearrange result
        tmp = reshape(result.freq,[result.nBins, input.nChannels, result.nChannels/input.nChannels]); % [dim1=result.nBins, dim2=input.nChannels, dim3=result.nChannels/input.nChannels]
        result.freq = permute(tmp,[1 3 2]); % exchange dim2 and dim3
    end
    
    % sum the squared values
    band_values = squeeze(sum(abs(result.freq).^exponent,1));
    if input.nChannels == 1
        band_values = band_values(:);
    end
    
    % for energy signals:
    % to get average passband response, compare to filter response
    if strcmpi(sArgs.method,'averaged')
        Beff = ita_mpb_filter(ita_generate('flat',1,input.samplingRate,input.fftDegree),'oct',sArgs.bandsperoctave,'class',sArgs.class,'order',sArgs.order, 'octavefreqrange', sArgs.freqRange); % apply mpb filter
        Beff = sum(abs(Beff.freq).^exponent,1).';
        band_values = band_values./Beff;
    end
    
    % FFT Mode
    % center frequencies and band limits
    % frequency bands according to DIN EN 61260
elseif strcmp(mode,'fft') %fast version
    bandUpperLimit = fmExact*(2^(1/bw_desgn)); % upper limit for every center frequency
    bandLowerLimit = fmExact/(2^(1/bw_desgn)); % lower limit for every center frequency
    
    %% calculate band values
    linespectrum_values = input.freqData;
    
    number_of_lines_in_band = zeros(length(fmExact),1);
    band_values = zeros(length(fmExact),input.nChannels);
    for idx_fm = 1:length(fmExact) %loop through centre frequencies and create upper and lower limit of that band
        upper_limit_idx = find(f < bandUpperLimit(idx_fm),1,'last');
        lower_limit_idx = find(f >= bandLowerLimit(idx_fm),1);
        sel_idx = lower_limit_idx:upper_limit_idx; %selected indices
        number_of_lines_in_band(idx_fm) = numel(sel_idx); % elements include number of frequency lines for every band
        if numel(sel_idx) > 0
            switch lower(sArgs.method)
                case 'added'
                    band_values(idx_fm,:) = sum(abs(linespectrum_values(sel_idx,:)).^exponent, 1); %added field quantity squared
                case 'averaged'
                    band_values(idx_fm,:) = mean(abs(linespectrum_values(sel_idx,:)).^exponent, 1); %averaged field quantity squared
                otherwise
                    disp('unknown method!')
            end
        else
            band_values(idx_fm,:)  = NaN;
        end
    end
    if any(any(isnan(band_values)))
        ita_verbose_info([thisFuncStr ': Careful, there are NaNs in your result'],1)
    end
end

%% take root for proper output
% use same output as input
if ~sArgs.squared_input
    band_values = sqrt(band_values); % output will not be a squared figure
end

% extract result
result = itaResult(input',fmView); % copy audio struct information from input struct
result.freqData = band_values;

%% apply weighting
if ~isempty(sArgs.weighting)
    result = ita_filter_weighting(result,'type',sArgs.weighting);
end

%% Update Meta Data
switch lower(sArgs.method)
    case 'added'
        if isempty(sArgs.weighting)
            result.comment = ['Added power in frequency bands - ' input.comment];
        else
            result.comment = ['Added ',upper(sArgs.weighting),'-weighted power in frequency bands - ' input.comment];
        end
    case 'averaged'
        if isempty(sArgs.weighting)
            result.comment = ['Averaged power in frequency bands - ' input.comment];
        else
            result.comment = ['Averaged ',upper(sArgs.weighting),'-weighted power in frequency bands - ' input.comment];
        end
end

if strcmp(mode,'fft')
    tmp = struct('spk2frequencybands_number_of_lines_in_band',number_of_lines_in_band);
    if iscell(result.userData)
        result.userData = [result.userData(:); {tmp}];
    else
        result.userData = {result.userData; tmp};
    end
end
%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
end