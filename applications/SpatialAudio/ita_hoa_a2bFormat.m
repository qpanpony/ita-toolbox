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
if nargin == 4
    FLU=varargin{1};
    FRD=varargin{2};
    BLD=varargin{3};
    BRU=varargin{4};
elseif nargin == 1
    FLU=varargin{1}.ch(1);
    FRD=varargin{1}.ch(2);
    BLD=varargin{1}.ch(3);
    BRU=varargin{1}.ch(4);
    assert( varargin{1}.nChannels == 4 )
else
    error('Need 4 channel input or 4 inputs');
end

    
type=1; % type 2 is for DPA-4 Mics

switch type
    case 1
        W = FLU + FRD + BLD + BRU;
        X = FLU + FRD - BLD - BRU;
        Y = FLU - FRD + BLD - BRU;
        Z = FLU - FRD - BLD + BRU;
    case 2
        W = FLD+FRU+BLU+BRD;
        X = FLD+FRU-BLU-BRD;
        Y = FLD-FRU+BLU-BRD;
        Z = -FLD+FRU+BLU-BRD;
end

if nargout == 1
    varargout{ 1 } = ita_merge(W,X,Y,Z);
else
    varargout{ 1 } = W;
    varargout{ 2 } = X;
    varargout{ 3 } = Y;
    varargout{ 4 } = Z;
end

