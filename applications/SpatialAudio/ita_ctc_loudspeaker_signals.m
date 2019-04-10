function LSSignals = ita_ctc_loudspeaker_signals(CTCFilter, binauralInput)
%ITA_CTC_LOUDSPEAKER_SIGNALS Combines binaural input and ctc filter to
%calculate the loudspeaker signals
% 
%   CTCFilter a multi-instance of itaAudio [ CTC-1L CTC-1R; CTC-2L CTC-2R; ...] 
%   binauralInput has to be itaAudio with 2 channels
%  
% 
%   Example: loudspeakerSignals=ita_ctc_loudspeaker_signals(CTCFilters_Calculated, BinauralSignalInput)


%% Initialization
if nargin < 2
    error('CTC:InputArguments','This function requires two input arguments.')
end

binauralInput=ita_merge(binauralInput(:));

if ~isa(binauralInput,'itaAudio') || ~isa(CTCFilter,'itaAudio')
    error('CTC:InputArguments','The input variable must be itaAudio objects.')
end


% Frequency vectors for the binaural input
if binauralInput.nChannels ~= 2
    error('CTC:InputArguments','The binaural signal must contain two channels.')
else
    inL = binauralInput.ch(1);
    inR = binauralInput.ch(2);
end

% Frequency vectors for the CTC filters.
% e.g.: CTC_LR -> transfer function for the filter from the left signal to
% the right loudspeaker.
if size(CTCFilter,2) ~= 2
    error('CTC:InputArguments','The CTC filter must contain two rows.')
end

%% CTC filtering
LSSignals=itaAudio(size(CTCFilter,1),1);
for k=1:size(CTCFilter,1)
    LSSignals(k)=ita_convolve(inL,CTCFilter(k,1))+ita_convolve(inR,CTCFilter(k,2));
    LSSignals(k).channelCoordinates=CTCFilter(k,1).channelCoordinates;
end

%% Return in time domain as multichannel audio
LSSignals=ita_merge(LSSignals(:))';
end





