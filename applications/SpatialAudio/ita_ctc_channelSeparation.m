function [ CS_L CS_R CS_L_singleSpectrum CS_R_singleSpectrum ] = ita_ctc_channelSeparation(HRTF_real, CTCFilter, varargin)
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
% TODO: Frequency ranges

opts.naturalCS      = false;
opts.doubleSpectrum = true;
opts.singleSpectrum = true;
opts.plot           = true;

opts=ita_parse_arguments(opts, varargin);

hrtf=ita_merge(HRTF_real(:));
hrtf.signalType='energy';
L=itaAudio;
L.signalType='energy';
helper=ita_convolve(hrtf.ch(1),CTCFilter(1));
numSamples=helper.nSamples;

%% Left channel input
L.time=zeros(numSamples,1);
R=L;
for k=1:size(CTCFilter,1)
    L=L+ita_convolve(hrtf.ch(2*k-1),CTCFilter(k,1));
    R=R+ita_convolve(hrtf.ch(2*k),CTCFilter(k,1));
end
CS_L = ita_merge(L,R);

%% Right channel input
L.time=zeros(numSamples,1);
R=L;
for k=1:size(CTCFilter,1)
    L=L+ita_convolve(hrtf.ch(2*k-1),CTCFilter(k,2));
    R=R+ita_convolve(hrtf.ch(2*k),CTCFilter(k,2));
end
CS_R = ita_merge(L,R);

%% Bruno Diss p 83 (5-11)
if opts.singleSpectrum
    CS_L_singleSpectrum = ita_divide_spk(CS_L.ch(1),CS_L.ch(2));
    CS_R_singleSpectrum = ita_divide_spk(CS_R.ch(2),CS_R.ch(1));
end

%% Natural channel separation
if opts.naturalCS
    [ natCS_L natCS_R ] =ita_ctc_channelSeparation_naturalOptimum(hrtf);
end

%% Plot
if opts.plot
    if opts.doubleSpectrum
        CS_L.pf; legend({'Left in, left ear' 'Left in, right ear'});
        title('Channel separation - left ear');
        set(gcf,'name','Channel separation - left ear');
        CS_R.pf; legend({'Right in, left ear' 'Right in, right ear'});
        title('Channel separation - right ear');
        set(gcf,'name','Channel separation - right ear');
    end
    if opts.singleSpectrum && opts.naturalCS
        merged_CS_L=ita_merge(natCS_L,CS_L_singleSpectrum);
        merged_CS_R=ita_merge(natCS_R,CS_R_singleSpectrum);
        merged_CS_L.pf; legend({'Optimal natural CS for left in' 'CTC CS for left in' });
        title('Channel separation - left ear (natural vs CTC)');
        set(gcf,'name','Channel separation - left ear');
        merged_CS_R.pf; legend({'Optimal natural CS for right in' 'CTC CS for right in' });
        title('Channel separation - right ear (natural vs CTC)');
        set(gcf,'name','Channel separation - right ear');
    elseif opts.singleSpectrum
        merged_CS = ita_merge(CS_L_singleSpectrum, CS_R_singleSpectrum);
        merged_CS.pf;
        legend({'CS for left in' 'CS for right in' });
        title('Channel separation');
        set(gcf,'name','Channel separation');
    elseif opts.naturalCS
        merged_CS = ita_merge(natCS_L, natCS_R);
        merged_CS.pf;
        legend({'Optimal natural CS for left in' 'Optimal natural CS for right in'});
        title('Channel separation');
        set(gcf,'name','Channel separation');
    end
end