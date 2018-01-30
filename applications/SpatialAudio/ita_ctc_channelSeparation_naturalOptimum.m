function [ natCS_L natCS_R ] = ita_ctc_channelSeparation_naturalOptimum(ls_HRTF)
%ITA_CTC_CHANNELSEPARATION_NATURALOPTIMUM Summary of this function goes here
%   Detailed explanation goes here
hrtf=ita_merge(ls_HRTF(:));
hrtf.signalType='energy';

for idxLS=1:(hrtf.nChannels/2)
    L(idxLS)=ita_divide_spk(hrtf.ch(idxLS*2-1),hrtf.ch(idxLS*2));
    R(idxLS)=ita_divide_spk(hrtf.ch(idxLS*2),hrtf.ch(idxLS*2-1));
end
L=ita_merge(L(:));
R=ita_merge(R(:));

natCS_L=L.ch(1);
natCS_R=R.ch(1);

for idxF=1:numel(L.ch(1).freqData)
    natCS_L.freqData(idxF)=max(abs(L.freqData(idxF,:)));
    natCS_R.freqData(idxF)=max(abs(R.freqData(idxF,:)));
end

