function [ audioOut ] = ita_3da_encodeAmbisonics( audioIn, order, sourcePos )
%ITA_ENCODEAMBISONICS Encodes a itaAudio with channel coordinates or a
% itaCoordinate with source positions into ambisonics channels
%
%   Detailed explanation goes here

%% Init
if isa(audioIn, 'itaAudio')
    aud=true;
elseif isa(audioIn, 'itaCoordinates')
    aud=false;
    sourcePos=audioIn;
    if nargin>2
        error('For itaCoordinates no additional source positions can be given!');
    end
else
    error('itaAudio or itaCoordinates has to be the first input!');
end

if nargin<2
    warning('SH Truncation order missing, assuming order of one');
    order=1;
end

if nargin<3 && aud
    sourcePos=audioIn.channelCoordinates;
    if sourcePos.nPoints<1 || ~isa(sourcePos,'itaCoordinates')
        error('No sourcePos found or it is not itaCoordinates! Add channelCoordinates to itaAudio!')
    end
end

%% Encode Source
if ~aud
    audioOut=ita_sph_base(sourcePos, order, 'real');
end

%% Applying audio data
if aud
    audioOut=itaAudio;
    audioOut_temp=itaAudio;
    for idxCh=1:audioIn.nChannels
        Bformat = ita_sph_base(sourcePos(idxCh), order, 'real');
        for idxCoeff=1:numel(Bformat)
            audioOut_temp(idxCoeff)=audioIn.ch(idxCh)*Bformat(idxCoeff);
        end
        if idxCh==1
            audioOut=ita_merge(audioOut_temp);
        else
            audioOut=audioOut+ita_merge(audioOut_temp);
        end
    end
end