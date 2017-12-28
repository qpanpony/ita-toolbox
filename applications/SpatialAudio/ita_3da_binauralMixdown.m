function [ binOut ] = ita_3da_binauralMixdown( lsSignals, varargin )
%ITA_3DA_BINAURALMIXDOWN Produces a 2-Channel binaural stream out of
%loudspeaker signal(s) and coordinates (given as optional coordinates or
%better: encoded in the itaAudio channel coordinates
%   Detailed explanation goes here
opts.HRTF='D:\DATA\sciebo\MKOScripts\HRTFs\2015_ITA-Kunstkopf_HRIR_2ch_D186_1x1_256_v17.daff';
opts.LSPos=itaCoordinates;

if nargin>1
    opts=ita_parse_arguments(opts,varargin);
end
if ~(isa(lsSignals, 'itaAudio')&&(lsSignals.nChannels>0))
    error('First input must be itaAudio with at least one channel')
end

if opts.LSPos.nPoints<1
    opts.LSPos=lsSignals.channelCoordinates;
    if opts.LSPos.nPoints<1
        error('We need some channel coordinates!');
    end
end

hrtfSet=itaHRTF('DAFF',opts.HRTF);

binOut=itaAudio;

for k=1:lsSignals.nChannels
    hrtf=hrtfSet.findnearestHRTF(opts.LSPos.n(k));
    convolved=ita_convolve(lsSignals.ch(k),hrtf);
    if k==1
        binOut=convolved;
    else
        binOut=binOut+convolved
    end
end
