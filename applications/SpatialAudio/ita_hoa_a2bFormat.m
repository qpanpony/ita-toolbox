function [bformat] = ita_hoa_a2bFormat(FLU, FRD, BLD, BRU)
%ITA_HOA_A2BFORMAT Converts an A-Format recording to  B-Format
%   Detailed explanation goes here
% Back Right Up (BRU);
% Front Left Up (FLU);
% Front Right Down (FRD);
% Back Left Down (BLD);


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

