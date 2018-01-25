function [ CS_L CS_R ] = ita_ctc_channelSeparation(HRTF_real, CTCFilter, varargin)
%ITA_CTC_CHANNELSEPARATION Returns and plots channelseparation for ctc
%systems
%   HRTF_real represent the real HRTFs that will occure in the CTC system,
%   either as multi-instance itaAudio or coded in channels
%   HRTF.ch(1) = HRTF_LS1_Left;
%   HRTF.ch(2) = HRTF_LS1_Right;
%   HRTF.ch(3) = HRTF_LS2_Left;
%   HRTF.ch(4) = HRTF_LS2_Right;
%   HRTF.ch(5) = HRTF_LS3_Left;
%
%   CTC has to be multi-instance itaAudio:
%   [LS1_left_CTCFilter LS1_right_CTCFilter]
%   [LS2_left_CTCFilter LS2_right_CTCFilter]
%   [LS3_left_CTCFilter LS3_right_CTCFilter]
%   ...
%

opts.plot = true;

opts=ita_parse_arguments(opts, varargin);

hrtf=ita_merge(HRTF_real(:));

L=itaAudio;
helper=ita_convolve(hrtf.ch(1),CTCFilter(1));
numSamples=helper.nSamples;

%% Left channel input
L.time=zeros(numSamples,hrtf.nChannels/2);
R=L;
for k=1:size(CTCFilter,1)
    L=L+ita_convolve(hrtf.ch(2*k-1),CTCFilter(k,1));
    R=R+ita_convolve(hrtf.ch(2*k),CTCFilter(k,1));
end
CS_L = ita_merge(L,R);

%% Right channel input
L.time=zeros(numSamples,hrtf.nChannels/2);
R=L;
for k=1:size(CTCFilter,1)
    L=L+ita_convolve(hrtf.ch(2*k-1),CTCFilter(k,2));
    R=R+ita_convolve(hrtf.ch(2*k),CTCFilter(k,2));
end
CS_R = ita_merge(L,R);

%% Plot
if opts.plot
    CS_L.pf;  CS_R.pf;
end