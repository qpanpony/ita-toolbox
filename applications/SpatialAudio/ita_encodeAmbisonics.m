function [ Bformat ] = ita_encodeAmbisonics( sourcePos, varargin )
%ITA_ENCODEAMBISONICS Summary of this function goes here
%   Detailed explanation goes here
if nargin<1
    error('Source position is needed as itaCoordiantes!');
end

if ~isa(sourcePos,'itaCoordinates')
    error('First input data has to be an itaCoordinates!')
elseif isempty(sourcePos.cart)
    error('First input data has to be an itaCoordinates WITH inputdata!')
end

opts.order=1;           %Ambisonics truncation order
opts.audioSource='';    %Signal of the source (itaAudio or filename)

opts = ita_parse_arguments(opts, varargin);

% Encode Source
Bformat = ita_sph_base(sourcePos, opts.order, 'Williams', false);

if ~isempty(opts.audioSource)
    if isa(opts.audioSource,'char')
        audioIn = ita_read(opts.audioSource);
    elseif isa(opts.audioSource,'itaAudio')
        audioIn = opts.audioSource;
    elseif ~isa(audioIn,'itaAudio')
        error('Audio input must eihter be itaAudio or valid filename (see ita_read)');
    end
    audioOut=audioIn*Bformat(1);
    for k=2:numel(Bformat)
        audioOut=ita_merge(audioOut,audioIn*Bformat(k));
    end
    Bformat=audioOut;
end
end

