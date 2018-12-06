function [bformat] = ita_hoa_a2bFormat(varargin)
%ITA_HOA_A2BFORMAT Converts an A-Format recording to  B-Format
%FLU,FRD,BLD,BRU
%   Detailed explanation goes here
% Back Right Up (BRU);
% Front Left Up (FLU);
% Front Right Down (FRD);
% Back Left Down (BLD);
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

bformat = ita_merge(W,X,Y,Z);
end

