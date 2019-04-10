function [h] = vol_hex_nbasis_fct_lin(r,s,t)
% Function gives derivations of basis function back and gets the supporting
% points (r,s,t).

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% numberation:
% h(x,:) derivations of the basisfunction x
% h(:,1) = dh/dr,  h(:,2) = dh/ds,  h(:,3) = dh/dt
% -------------------------------------------------------------------------
h(1,1) = -(1-s)*(1-t)/8;
h(1,2) = -(1-r)*(1-t)/8;
h(1,3) = -(1-r)*(1-s)/8;

h(2,1) = (1-s)*(1-t)/8;
h(2,2) = -(1+r)*(1-t)/8;
h(2,3) = -(1+s)*(1-s)/8;

h(3,1) = (1+s)*(1-t)/8;
h(3,2) = (1+r)*(1-t)/8;
h(3,3) = -(1+r)*(1-t)/8;

h(4,1) = -(1+s)*(1-t)/8;
h(4,2) = (1-r)*(1-t)/8;
h(4,3) = -(1-r)*(1+s)/8;

h(5,1) = -(1-s)*(1+t)/8;
h(5,2) = -(1-r)*(1+t)/8;
h(5,3) = (1-r)*(1-s)/8;

h(6,1) = (1-s)*(1+t)/8;
h(6,2) = -(1+r)*(1+t)/8;
h(6,3) = (1+r)*(1-s)/8;

h(7,1) = (1+s)*(1+t)/8;
h(7,2) = (1+r)*(1+t)/8;
h(7,3) = (1+r)*(1+s)/8;

h(8,1) = -(1+s)*(1+t)/8;
h(8,2) = (1-r)*(1+t)/8;
h(8,3) = (1-r)*(1+s)/8;

