function varargout=ita_crossfade(varargin)
%ITA_CROSSFADE - Crossfades two frequency responses into each other
% This function reads in audioStructs and returns a struct containing the
% crossfaded frequency response.
%
% Syntax:  audioStruct = ita_crossfade(audioStruct_low, audiostruct_high, crossFrequency, options )
%
%    Options (default): 
%     'filter' ('mpcomb'):              filterMethods are MPcomb, MPsep, MPfilt with a filter order of 8
%                                       'MPcomb' (default):     applies low and high pass butterworth filter using
%                                                               crossFrequency as -3dB edge frequency and subsequently sums up
%                                                               both parts
%                                       'MPfilt':               applies filter seperately for magnitude and
%                                                               phase and therefore makes use of Linkwitz-Riley filter
%                                       'MPsep':                filter magnitude using LiRi filters and sticks
%                                                               together unwrapped phases
%     'interpolation' ('linear'):       interpolation methods are either 'nearest', 'linear' (default) or 'spline'. Please
%                                       read the Matlab help file for the interp1 function for any further information.
%     'samplingRate' (max(low.samplingRate,high.samplingRate)): samplingRate
%     'nSamples' (round(max(low.nSamples,high.nSamples))):      if mod(nSamples,2), nSamples=nSamples+1, end;

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%
%audioStruct_low and audiostruct_high should be an itaAudioStruct in
%Matlab. Choosing 'getui' for audioStruct_low or audioStruct_high will open the
%Matlab get file ui and calls the ita_read function.
%
% 
%

%
%If you choose a new 'samplingRate', this string must be followed by a
%real numeric value. Both input signals are interpolated to the new
%sampling rate.
%
%If you choose a new number of samples 'nSamples', this string must be
%followed by a even real numeric value. Both signals are interpolated to the new
%number of samples.
%
%Except audioStruct_low, audioStruct_high and crossfrequency all inputs are
%optional. If no new sampling rate or number of samples is chosen, this
%function interpolates to the higher value of both audioStructs.
%
% Author: Lucas Jauer -- Email: lucas.jauer@akustik.rwth-aachen.de
% Created:  12-Jan-2010


%% Initialization
% Number of Input Arguments
narginchk(3,11);

[data_low,data_high,cfFrequency,filter,SamplingRate,interpolation,nSamples]=parseinput(varargin);

%% Check input files
%check FFTnorm. should be energy
if ~strcmp(data_low.signalType,'energy')
    data_low.signalType='energy';
    warning('ITA_CROSSFADE: Oh Lord. Low input is non energy signal. Changed FFTnorm to energy.')
end

if ~strcmp(data_high.signalType,'energy')
    data_high.signalType='energy';
    warning('ITA_CROSSFADE: Oh Lord. High input is non energy signal. Changed FFTnorm to energy.')
end

%% interpolation and extrapolation

[data_low,data_high]=interp_extrap(data_low,data_high,interpolation,SamplingRate,nSamples);

%% Starts filter process
%default filter order
cfFilterOrder=8;


switch filter
    case 'mpcomb'
        crossfadedFR = MPcomb(data_low, data_high, cfFrequency, cfFilterOrder);
        CF_data=crossfadedFR;
    case 'mpfilt'
        crossfadedFR = MPfilt(data_low, data_high, cfFrequency, cfFilterOrder);
        CF_data=crossfadedFR;
        
    case 'mpsep'
        freqradius=0;
        crossfadedFR = MPsep(data_low, data_high, cfFrequency, cfFilterOrder,freqradius);
        CF_data=crossfadedFR;
        
end

%% Output
varargout{1}=CF_data;


function [low,high,crossfrequency,filter,SamplingRate,interpolation,nSamples]=parseinput(varargin)

%default values

varargin = varargin{:};

low  = varargin{1};
high = varargin{2};
%ita_read if 'getui' is chosen
if strcmp(low,'getui')
    [input_file,pathname] = uigetfile({'*.*', 'all files (*.*)';'*.ita*' , ...
        'Ita Audiostruct (*.ita)'}, ... 
        'Please select Data for low pass filtering', 'MultiSelect' , 'off');
    if pathname==0
        error('ITA_CROSSFADE: Oh Lord. Please select data for low pass filtering.')
    end
    low=ita_read(fullfile(pathname,input_file));
end
if strcmp(high,'getui')
    [input_file,pathname] = uigetfile({'*.*', 'all files (*.*)';'*.ita*' , ...
        'Ita Audiostruct (*.ita)'}, ... 
        'Please select Data for high pass filtering', 'MultiSelect' , 'off');
    if pathname==0
        error('ITA_CROSSFADE: Oh Lord. Please select data for high pass filtering.')
    end
    high=ita_read(fullfile(pathname,input_file));
end

crossfrequency = varargin{3};
%check real numeric value of crossfrequency
if ~isnumeric(crossfrequency) && ~isreal(crossfrequency)
    error('ITA_CROSSFADE: Oh Lord. Please give me a real numeric value as crossfade frequency.');
end

SamplingRate  = max(low.samplingRate,high.samplingRate);
filter        = 'mpcomb';
interpolation = 'linear';
nSamples      = round(max(low.nSamples,high.nSamples));
if mod(nSamples,2)
    nSamples=nSamples+1;
end

attributes   = {'filter','samplingRate','interpolation','nsamples'};
filterattr   = {'mpcomb','mpfilt','mpsep'};
interpolattr = {'linear','nearest','spline'};

stringoptions = lower(varargin(cellfun('isclass',varargin,'char')));
attributeindexesinoptionlist = ismember(stringoptions,attributes);
newinputform = any(attributeindexesinoptionlist);
if newinputform
% parse values to functions parameters
    i = 4;
        while (i <= length(varargin))
            %Check to make sure that there is a pair to go with
            %this argument.
            if length(varargin) < i + 1 && ismember(varargin{i},attributes)
                error('ITA_CROSSFADE:AttributeList', ...
                    'Attribute %s requires a matching value', varargin{i})
            end
            if     strcmpi(varargin{i},'filter')
                if ismember(lower(varargin{i+1}),filterattr)
                    filter = lower(varargin{i+1});
                else error('ITA_CROSSFADE: no valid filter')                   
                end
            elseif strcmpi(varargin{i},'samplingRate')
                if isnumeric(varargin{i+1})
                    SamplingRate = varargin{i+1};                    
                else error('ITA_CROSSFADE: no valid samplingrate')
                end
            elseif strcmpi(varargin{i},'interpolation')
                if ismember(lower(varargin{i+1}),interpolattr)
                    interpolation = lower(varargin{i+1});
                else error ('ITA_CROSSFADE: no valid interpolation method')
                end
            elseif strcmpi(varargin{i},'nsamples')
                if isnumeric(varargin{i+1}) && ~mod(varargin{i+1},2)
                    nSamples = varargin{i+1};                    
                else error ('ITA_CROSSFADE: no valid number of samples (e.g. not even).')
                end
            else
                error('ITA_CROSSFADE:Attribute',...
                    'Invalid attribute tag: %s', varargin{i})
            end
            i = i+2;
        end
end

function [interp_low,interp_high]=interp_extrap(low,high,interpolation,SamplingRate,nSamples)

%data frequency vector
fvec_low  = low.freqVector;
fvec_high = high.freqVector;

interp_low  = low;
interp_high = high;

%set bins
nBins = nSamples/2+1;

%set new frequencyvector
bin_dist = SamplingRate/(2 * (nBins - 1)); % get distance between bins
fvec_new = (0:nBins-1).' .* bin_dist; % in Hz

%interpolation
interp_low.freq  = interp1(fvec_low,low.freq,fvec_new,interpolation);
interp_high.freq = interp1(fvec_high,high.freq,fvec_new,interpolation);

%header settings
interp_high.samplingRate = SamplingRate;
interp_low.samplingRate  = SamplingRate;


function crossfadedFR=MPcomb(Data_low, Data_high, coFreq, filterOrder)
% combines the given frequency responses at crossfade frequency by use of
% butterworth high and lowpass filter

% apply low pass to audioStruct_low
Data_low  = ita_butterFR(Data_low, coFreq, 'low', filterOrder);

% apply high pass to audioStruct_high
Data_high = ita_butterFR(Data_high, coFreq, 'high', filterOrder);

%combine frequency responses
crossfadedFR = Data_low + Data_high;

function crossfadedFR = MPfilt(Data_low, Data_high, coFreq, filterOrder)
% combines the given frequency responses at crossfade frequency by use of Linkwitz-Riley high and lowpass filter (for both magnitude and phase)

%ita_plot_spk(ita_merge(Data_low, Data_high));
% apply low pass to audioStruct_low
Data_low  = ita_liriFR(Data_low, coFreq, 'low', filterOrder);

% apply high pass to audioStruct_high
Data_high = ita_liriFR(Data_high, coFreq, 'high', filterOrder);

%combine frequency responses
crossfadedFR_magn = abs(Data_low.freq) + abs(Data_high.freq);
crossfadedFR_phase = angle(Data_low.freq + Data_high.freq);
crossfadedFR = Data_low;
crossfadedFR.freq = crossfadedFR_magn .* exp(1i*crossfadedFR_phase);


function crossfadedFR = MPsep(Data_low, Data_high, coFreq, filterOrder,freqRadius)
% filters magnitude using LiRi filters and sticks together unwrapped phases

% apply low pass to audioStruct_low
Data_low  = ita_liriFR(Data_low, coFreq, 'low', filterOrder);

% apply high pass to audioStruct_high
Data_high = ita_liriFR(Data_high, coFreq, 'high', filterOrder);

% phase crossover
frequencySerie = Data_low.freqVector;
% find index for nearest frequency smaller than coFreq
fcIdx = find((frequencySerie < coFreq), 1, 'last');
% determine phase difference at this frequency
P_FEsimFR = unwrap(angle(Data_low.freq));
P_RTsimFR = unwrap(angle(Data_high.freq));
P_diff = P_FEsimFR(fcIdx) - P_RTsimFR(fcIdx);
% fit phase of RT to FE at this frequency
P_RTsimFR = P_RTsimFR + P_diff;
P_mixedFR = zeros(length(frequencySerie),1);
if (freqRadius == 0)
    P_mixedFR(1:fcIdx) = P_FEsimFR(1:fcIdx);
    P_mixedFR(fcIdx+1:end) = P_RTsimFR(fcIdx+1:end);
else
    fStep = frequencySerie(2) - frequencySerie(1);
    fcIdxRadius = floor(freqRadius / fStep);
    fcIdxLow = fcIdx - fcIdxRadius;
    fcIdxHigh = fcIdx + fcIdxRadius;
    P_mixedFR(1:fcIdxLow-1) = P_FEsimFR(1:fcIdxLow-1);
    P_mixedFR(fcIdxHigh+1:end) = P_RTsimFR(fcIdxHigh+1:end);
    sizeOfCrossover = fcIdxHigh - fcIdxLow + 1;
    crossoverWeights = [0:sizeOfCrossover-1]/(sizeOfCrossover-1);
    crossoverWeights = crossoverWeights';
    P_mixedFR(fcIdxLow:fcIdxHigh) = (1 - crossoverWeights) .* P_FEsimFR(fcIdxLow:fcIdxHigh) + crossoverWeights .* P_RTsimFR(fcIdxLow:fcIdxHigh);    
end

%combine impulse responses
crossfadedFR_magn = abs(Data_low.freq) + abs(Data_high.freq);
crossfadedFR_phase = P_mixedFR;
crossfadedFR = Data_low;
crossfadedFR.freq = crossfadedFR_magn .* exp(1i*crossfadedFR_phase);