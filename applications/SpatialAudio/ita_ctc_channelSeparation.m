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
opts.naturalCS      = true;
opts.doubleSpectrum = true;
opts.singleSpectrum = true;
opts.plot           = true;

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

%% Bruno Diss p 83 (5-11)
CS_L_singleSpectrum = ita_divide_spk(CS_L.ch(1),CS_L.ch(2));
CS_R_singleSpectrum = ita_divide_spk(CS_R.ch(2),CS_R.ch(1));

CS_L_value

%% Natural channel separation
if opts.naturalCS
    for k=1:2:hrtf.nChannels
        if hrtf.ch(k).rms>hrtf.ch(k+1).rms
            naturalCS(ceil(k/2))=ita_divide_spk(hrtf.ch(k),hrtf.ch(k+1));
        else
            naturalCS(ceil(k/2))=ita_divide_spk(hrtf.ch(k+1),hrtf.ch(k));
        end
    end
end

%% Plot
if opts.plot
    if opts.singleSpectrum
        CS_L.pf;  CS_R.pf;
    end
    if opts.doubleSpectrum
        CS_L_singleSpectrum.pf;
        CS_R_singleSpectrum.pf;
    end
end