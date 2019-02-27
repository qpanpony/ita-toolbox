function [ varargout ] = ita_hoa_a2bFormat(varargin)
%ITA_HOA_A2BFORMAT Converts an A-Format recording to B-Format
%
% Input and requested output can be four-track multi-channel itaAudio or 4 single-channel
% itaAudio objects.
%
% Channel assignment incoming: FLU, FRD, BLD, BRU
% Back Right Up (BRU);
% Front Left Up (FLU);
% Front Right Down (FRD);
% Back Left Down (BLD);
%
% Channel assignment outgoing: W, X, Y, Z
%
opts.type=1; % type 2 is for DPA-4 Mics, then channel assignment: FLD, FRU, BLU, BRD

if nargin < 2 || ~isa(varargin{2},'itaAudio')
    assert( varargin{1}.nChannels == 4 )
    varargin{1}=merge(varargin{1}(:));
    FLU=varargin{1}.ch(1);
    FRD=varargin{1}.ch(2);
    BLD=varargin{1}.ch(3);
    BRU=varargin{1}.ch(4);
    opts=ita_parse_arguments(opts,varargin{2:end});
elseif ( isa(varargin{1},'itaAudio') && isa(varargin{2},'itaAudio') && isa(varargin{3},'itaAudio') && isa(varargin{4},'itaAudio'))
    FLU=varargin{1};
    FRD=varargin{2};
    BLD=varargin{3};
    BRU=varargin{4};
    opts=ita_parse_arguments(opts,varargin{5:end});
else
    error('Need 4 channel input or at least 4 itaAudio inputs');
end

switch opts.type
    case 1
        W =  FLU + FRD + BLD + BRU;
        X =  FLU + FRD - BLD - BRU;
        Y =  FLU - FRD + BLD - BRU;
        Z =  FLU - FRD - BLD + BRU;
    case 2
        W =  FLD + FRU + BLU + BRD;
        X =  FLD + FRU - BLU - BRD;
        Y =  FLD - FRU + BLU - BRD;
        Z = -FLD + FRU + BLU - BRD;
end

W.channelNames = {'W'};
X.channelNames = {'X'};
Y.channelNames = {'Y'};
Z.channelNames = {'Z'};

if ~nargout || nargout == 1
    varargout{ 1 } = ita_merge(W,X,Y,Z);
else
    varargout{ 1 } = W;
    varargout{ 2 } = X;
    varargout{ 3 } = Y;
    varargout{ 4 } = Z;
end

