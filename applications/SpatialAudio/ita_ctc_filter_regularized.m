function [ CTC ] = ita_ctcFilter_regularized( varargin )
%ITA_3DA_CTCFILTER_REGULARIZED Generates a set of CTC Filter for a
%loudspeaker system with an arbitrary number of loudspeaker.

%   The first input has to be a set of HRTF for each loudspeaker as
%   multi-instance of itaAudio: [LS1_HRTF LS2_HRTF ... LSN_HRTF]
%   or as one itaAudio containing:
%   ch(1) = LS1 Left Ear
%   ch(2) = LS1 Right Ear
%   ch(3) = LS2 Left Ear
%   ch(4) = LS2 Right Ear
%   ch(5) = LS3 Left Ear
%   ...
%   Make sure that the HRTFs compensate for irregular loudspeaker arrays or
%   off-centered listeners.
% 
%   The calculation algorithm is a simple inversion. Pre- and
%   Postprocessing options can be found below
%
%   For smoothing of HRTF or CTC filters use the functions provided by
%   ita_ctc_smoothHRTF


%% Options
% Calculation
opts.beta            = 0.001; % regularization parameter
opts.thresholdStartIR       = -1; % threshold for ita_start_IR() to cut out the start delay, -1 will disable the feature
opts.filterLength    = -1; % resulting filter lengt if set to -1: maximum of 4096 and nSamples*2
opts.winLim          = [.7 85]; % limits for windowing (suppress artifacts at the end of HRIR caused by time shifting), needed for ita_start_ir
opts.postProcessing  = true; % Indicates if a time shift and windowing operation is performed on the calculated filter. WARNING: May lead to non-causal filters (echo effect)

%% Init
hrtf=varargin{1};
H=ita_merge(hrtf(:));

if ~isa(hrtf,'itaAudio')
    error('First input (HRTF) has to be itaAudio')
end

if (H.nChannels<4)
    error('At least two loudspeaker with two channels to each ear are needed!');
end

if ~strcmpi(H.signalType,'energy')
    warning('HRTFs are not energy signals! Changing them to energy');
    H.signalType='energy';
end
opts=ita_parse_arguments(opts,varargin(2:end));

%% Preprocessing
if (opts.filterLength==-1)
    H = ita_extend_dat(H,max(2*H.nSamples,2^12),'forceSamples');
else
    H = ita_extend_dat(H,opts.filterLength,'forceSamples');
end

if (opts.thresholdStartIR~=-1)
    ind = zeros(size(H));
    for idx = 1:numel(H)
        ind(idx) = ita_start_IR(H(idx),'threshold',opts.threshold);
    end
    
    IND = min(ind(:))-1;
    for idx = 1:numel(H)
        H(idx) = ita_time_shift(H(idx),-ind(idx),'samples');
        H(idx) = ita_time_window(H(idx),opts.winLim*H(idx).trackLength,'time');
        H(idx) = ita_time_shift(H(idx),ind(idx)-IND,'samples');
    end
end



%% Calculation
N = H.nSamples;
hm=2;
hn=H.nChannels/2;
f = H.nBins;
hfq = H.freqData;
c = zeros(hn,hm,f);
CTC = itaAudio(hn,hm);
for fdx = 1:f
    hh = reshape(hfq(fdx,:),hm,hn);
    c(:,:,fdx) = hh'/(hh*hh' + opts.beta*eye(hm));
end
aux = H(1,1);
for idx = 1:hn
    for jdx = 1:hm
        aux.freqData = squeeze(c(idx,jdx,:));
        CTC(idx,jdx) = aux;
    end
end


%% Postprocessing
if opts.postProcessing
    FilterWindow = itaAudio;
    FilterWindow.time = hann(H.nSamples);
    FilterWindow.samplingRate = CTC(1).samplingRate;
    for idx = 1 : numel(CTC)
        CTC(idx) = ita_time_shift(CTC(idx), H.nSamples/2, 'samples');
        CTC(idx) = CTC(idx) .* FilterWindow;
    end
end

%% Metadata
[Cm Cn]=size(CTC);
for idx=1:Cm
    CTC(idx,1).channelNames = {['CTC-' num2str(idx) 'L''']};
    CTC(idx,1).channelCoordinates = H.channelCoordinates.n(idx*Cn-1);
    CTC(idx,2).channelNames = {['CTC-' num2str(idx) 'R''']};
    CTC(idx,2).channelCoordinates = H.channelCoordinates.n(idx*Cn);
end
end

