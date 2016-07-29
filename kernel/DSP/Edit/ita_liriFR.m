function varargout = ita_liriFR(varargin)
% ITA_LIRIFR - Creates frequency response (FR) of a Linkwitz-Riley filter as itaAudioStruct
% This function creates the frequency response (FR) of a Linkwitz-Riley
% filter as itaAudioStruct.
% If the function is called without an audioStruct to be filtered it returns the filter as an itaAudio
% in frequency domain. In this case you have to specify the number of
% Samples and the sampling frequency of the filter to be created.
% If the function is called with an itaAudio in the argument list, the
% function returns the filtered itaAudio
%
% Please see: http://en.wikipedia.org/wiki/Linkwitz-Riley_filter for more
%             information on Linkwitz Riley filters
%
% Common orders for these filters are:
%
%   2nd order: -12 dB/octave
%   4th order: -24 dB/octave
%   8th order: -48 dB/octave
%
% Syntax:   filterOnly    = ita_liriFR(nSamples, SamplingRate, cutOffFreq, passType, order)
%           filteredAudio = ita_liriFR(audio2BFiltered, cutOffFreq, passType, order) 
%           filteredAudio = ita_liriFR(audio2BFiltered, cutOffFreq, passType)
%           filteredAudio = ita_liriFR(audio2BFiltered, [20 2000], 'bandpass', 4) % Bandpass from 20Hz to 2kHz, with order 4
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

butterorder = order/2; % LiRi-Filter order is twice the butter order
[z,p,k] = butter(butterorder, cutOffFreq/NyqFreq, passType);
[sos,g] = zp2sos(z,p,k);	     % Convert to SOS form
Hd = dfilt.df2tsos(sos,g);   % Create a dfilt object
[butterFilt,w] = freqz(Hd, nBins);        % return frequency response

liriFilt = butterFilt .* butterFilt;

liriFR=itaAudio();
liriFR.freqData = liriFilt;

if strcmpi(passType, 'low') == 1
    typeName = 'lowpass';
elseif strcmpi(passType, 'high') == 1
    typeName = 'highpass';
elseif strcmpi(passType, 'bandpass') == 1
    typeName = 'bandpass';
end

liriFR.comment=['LiRi ' typeName ' filter of order ' num2str(order) ' with cutoff ' num2str(cutOffFreq) ' Hz.' ];

liriFR.samplingRate=2*NyqFreq;
liriFR.signalType='energy';

if ~isempty(audio2BFiltered)
    if strcmp(originalDomain,'time')
        filteredAudio = ita_fft(audio2BFiltered) * liriFR;
    else
        filteredAudio = audio2BFiltered * liriFR;
    end
else
    filteredAudio = liriFR;
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
        error('ita_liriFR: Input argument for nSamples is invalid.')
    end
    
    % input 2: samplingRate of Filter to be created
    if ( isnumeric(varargin{2}) )               && ...
       ( isequal( size(varargin{2}), [1,1]) )   && ...
       ( varargin{2} > 0 )
    
        SamplingRate = varargin{2};
    else
        error('ita_liriFR: Input argument for Sampling Rate is invalid.')
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
    error('ita_liriFR: Input argument for cutOffFrequency is invalid.')
end

% input 3/4: passType
if ( isa(varargin{curIdx+2}, 'char') )   && ...
   ( ( ( strcmpi(varargin{curIdx+2},'low') || strcmpi(varargin{curIdx+2},'high') ) && length(cutOffFreq)==1 ) || ...
       ( isequal(varargin{curIdx+2},'bandpass')                                          && length(cutOffFreq)==2 ) )
    
    passType = varargin{curIdx+2};
else
    error('ita_liriFR: Input argument for passType is invalid.')
end

% input 4/5: Filter order
if ( length(varargin)==(curIdx+3) )
    if ( isnumeric(varargin{curIdx+3}) ) && ...
            ( isequal(size(varargin{curIdx+3}),[1,1]) ) && ...
            ( varargin{curIdx+3} > 0 )
        
        order = round(varargin{curIdx+3});
    else
        error('ita_liriFR: Input argument for filter order is invalid.')
    end
end
