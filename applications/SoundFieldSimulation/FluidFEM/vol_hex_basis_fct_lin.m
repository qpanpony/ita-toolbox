function [h]=vol_hex_basis_fct_lin(r,s,t)
% Basisfunctions for volume hexaeder
%                                           node | ri| si| ti
%----------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

h(1) = (1-r)*(1-s)*(1-t)/8;     %1      -1  -1  -1         
h(2) = (1+r)*(1-s)*(1-t)/8;     %2       1  -1  -1
h(3) = (1-r)*(1+s)*(1-t)/8;     %3       1   1  -1
h(4) = (1-r)*(1+s)*(1-t)/8;     %4      -1   1  -1 
h(5) = (1-r)*(1-s)*(1+t)/8;     %5      -1  -1   1
h(6) = (1+r)*(1-s)*(1+t)/8;     %6       1  -1   1
h(7) = (1+r)*(1+s)*(1+t)/8;     %7       1   1   1
h(8) = (1-r)*(1+s)*(1+t)/8;     %8      -1   1   1

%           8------------------7      
%           |                  |
%   5-----------------6        |
%   |       |         |        |
%   |       |         |        |
%   |       |         |        |
%   |       |         |        |
%   |       4---------|--------3
%   |                 |   
%   1-----------------2