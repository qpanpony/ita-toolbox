function varargout = ita_butterFR(varargin)
% ITA_BUTTERFR - Creates FR of a Butterworth filter
% Creates frequency response (FR) of a Butterworth filter as itaAudioStruct
% If the function is called without an audioStruct to be filtered it returns the filter as an itaAudio
% in frequency domain. In this case you have to specify the number of
% Samples and the sampling frequency of the filter to be created.
% If the function is called with an itaAudio in the argument list, the
% function returns the filtered itaAudio
%
% Syntax: filterOnly    = ita_butterFR(nSamples, SamplingRate, cutOffFreq, passType, order)
%         filteredAudio = ita_butterFR(audio2BFiltered, cutOffFreq, passType, order) 
%         filteredAudio = ita_butterFR(audio2BFiltered, cutOffFreq, passType)
%         filteredAudio = ita_butterFR(audio2BFiltered, [20 2000], 'bandpass', 4) % Bandpass from 20Hz to 2kHz, with order 4
%
% Please see: http://en.wikipedia.org/wiki/Butterworth_filter
%             for more information on Butterworth filters
%
% Common orders for these filters are:
%
%   2nd order: -12 dB/octave
%   4th order: -24 dB/octave
%   8th order: -48 dB/octave
% 
% nSamples:         number of samples (Only has to be specified when called without audioData to be filtered)
% SamplingRate:     sampling rate (Only has to be specified when called without audioData to be filtered)
% audio2Bfiltered:  itaAudio with audio data to be filtered
% cutOffFreq:       cuttoff frequency of filter (-3dB)
% passType:         'low', 'high' or 'bandpass'
% order:            filter order (default = 8, if not specified)
%
% Author: Marc Aretz -- Email: mar@akustik.rwth-aachen.de
% Created:  21-Dec-2009

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



%% Initialization
% Number of Input Arguments
narginchk(3,5);

[audio2BFiltered, originalDomain, nSamples, SamplingRate, cutOffFreq, passType, order]=parseinput(varargin);

nBins=nSamples/2+1;
NyqFreq=SamplingRate/2;

[z,p,k] = butter(order, cutOffFreq./NyqFreq, passType);
[sos,g] = zp2sos(z,p,k);	     % Convert to SOS form
Hd = dfilt.df2tsos(sos,g);       % Create a dfilt object
[h,w] = freqz(Hd, nBins);        % return frequency response

butterFR=itaAudio();
butterFR.freqData=h;

if strcmpi(passType, 'low') == 1
    typeName = 'lowpass';
elseif strcmpi(passType, 'high') == 1
    typeName = 'highpass';
elseif strcmpi(passType, 'bandpass') == 1
    typeName = 'bandpass';
end

butterFR.comment=['butterworth ' typeName ' filter of order ' num2str(order) ' with cutoff ' num2str(cutOffFreq) ' Hz.' ];

butterFR.samplingRate=2*NyqFreq;
butterFR.signalType='energy';

if ~isempty(audio2BFiltered)
    if strcmp(originalDomain,'time')
        filteredAudio = ita_fft(audio2BFiltered) * butterFR;
    else
        filteredAudio = audio2BFiltered * butterFR;
    end
else
    filteredAudio = butterFR;
end

%% Output
%transforms into time domain if audio2Bfiltered was originally in time domain
if strcmpi(originalDomain,'time')
    varargout{1}=ita_ifft(filteredAudio);
else varargout{1}=filteredAudio;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [audio2BFiltered, originalDomain, nSamples, SamplingRate, cutOffFreq, passType, order]=parseinput(varargin)

%default values
audio2BFiltered = [];
originalDomain = 'frequency';
nSamples = [];
SamplingRate = [];
cutOffFreq = [];
passType = 'low';
order = 8;

varargin = varargin{:};

if isa(varargin{1}, 'itaAudio')
    % input 1: itaAudio to be filtered
    audio2BFiltered = varargin{1};
    
    if audio2BFiltered.isTime
        originalDomain = 'time';
    elseif audio2BFiltered.isFreq
        originalDomain = 'frequency';
    end
    
    nSamples = audio2BFiltered.nSamples;
    SamplingRate = audio2BFiltered.samplingRate;
    
    curIdx = 1;

else
    % input 1: nSamples of Filter to be created
    if ( isnumeric(varargin{1}) )               && ...
       ( isequal( size(varargin{1}), [1,1]) )   && ...
       ( varargin{1} > 0 )
    
        nSamples = varargin{1};
    else
        error('ita_butterFR: Input argument for nSamples is invalid.')
    end
    
    % input 2: samplingRate of Filter to be created
    if ( isnumeric(varargin{2}) )               && ...
       ( isequal( size(varargin{2}), [1,1]) )   && ...
       ( varargin{2} > 0 )
    
        SamplingRate = varargin{2};
    else
        error('ita_butterFR: Input argument for Sampling Rate is invalid.')
    end
    
    curIdx = 2;
end
    
% input 2/3: cutOffFreq
if ( isnumeric(varargin{curIdx+1}) ) && ...
   ( isnumeric(varargin{curIdx+1}) ) && ...
   ( all(varargin{curIdx+1} > 0) )   && ...
   ( all( varargin{curIdx+1} <= SamplingRate/2 ) )
    
    cutOffFreq = varargin{curIdx+1};
else
    error('ita_butterFR: Input argument for cutOffFrequency is invalid.')
end

% input 3/4: passType
if ( isa(varargin{curIdx+2}, 'char') )   && ...
   ( ( ( strcmpi(varargin{curIdx+2},'low') || strcmpi(varargin{curIdx+2},'high') ) && length(cutOffFreq)==1 ) || ...
       ( isequal(varargin{curIdx+2},'bandpass')                                          && length(cutOffFreq)==2 ) )
    
    passType = varargin{curIdx+2};
else
    error('ita_butterFR: Input argument for passType is invalid.')
end

% input 4/5: Filter order
if ( length(varargin)==(curIdx+3) )
    if ( isnumeric(varargin{curIdx+3}) ) && ...
            ( isequal(size(varargin{curIdx+3}),[1,1]) ) && ...
            ( varargin{curIdx+3} > 0 )
        
        order = round(varargin{curIdx+3});
    else
        error('ita_butterFR: Input argument for filter order is invalid.')
    end
end
        
