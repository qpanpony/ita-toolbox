function [ varargout ] = ita_3da_ctcFilter_regularized( varargin )
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
%
%   The calculation algorithm is a simple inversion. Pre- and
%   Postprocessing options can be found below
%
%   For smoothing of HRTF or CTC filters use the functions provided by
%   ita_3da_smoothing


%% Options
opts.beta            = 0.001; % regularization parameter
opts.delay           = 400; % required delay to allow for causal filter
opts.threshold       = 20; % threshold for ita_start_IR()
opts.useStartIr      = false;
opts.filterlength    = -1;

%% Init
hrtf=varargin(1);
H=merge(hrtf);

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
if (opts.filterlength==-1)
    H = ita_extend_dat(H,max(2*H.nSamples,2^12),'forceSamples');
else
    H = ita_extend_dat(H,opts.filterLength,'forceSamples');
end

if opts.


%% Calculation
N = H.nSamples;
[hm,hn] = size(H);
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




end

