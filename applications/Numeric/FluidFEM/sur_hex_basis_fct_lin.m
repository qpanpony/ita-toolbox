function [dA, h] = sur_hex_basis_fct_lin(r_vec,coord)
% gets supporting points (r_vec), temporary coordinates (coord) and
% basisfunction number (k)
% gives an infinitesima small surface element (dA) and the basisfunctions 
% h(k) back
%--------------------------------------------------------------------------
% Initialization
%--------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

x=coord(:,1);    y=coord(:,2);    z=coord(:,3);
r= r_vec(1); s= r_vec(2); nh=zeros(4,2);
% Derivations basisfunctions
%--------------------------------------------------------------------------
% d/dr                          d/ds
nh(1,1) = -(1-s)/4;              nh(1,2) = -(1-r)/4;    
nh(2,1) = (1-s)/4;               nh(2,2) = -(1+r)/4;    
nh(3,1) = (1+s)/4;               nh(3,2) = (1+r)/4;     
nh(4,1) = -(1+s)/4;              nh(4,2) = (1-r)/4;

dr=nh(:,1)'; ds=nh(:,2)';      % derivations
dxdr=dr*x;dydr=dr*y;dzdr=dr*z;
dxds=ds*x;dyds=ds*y;dzds=ds*z;

dA = sqrt((dydr*dzds-dyds*dzdr)^2 + (dxds*dzdr-dxdr*dzds)^2 +...
    (dxdr*dyds-dydr*dxds)^2);

% Basisfunctions
%--------------------------------------------------------------------------
h=zeros(4,1);
h(1) = (1-r)*(1-s)/4;
h(2) = (1+r)*(1-s)/4;
h(3) = (1-r)*(1+s)/4;
h(4) = (1-r)*(1+s)/4;


