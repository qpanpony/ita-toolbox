function [h dA]=sur_tri_basis_fct_lin(r_vec, coord)
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

x = coord(:,1); y = coord(:,2); z = coord(:,3);
l1= r_vec(1); r= r_vec(2); s= r_vec(3);
nh=zeros(3,2);
% derivations of basisfunctions 
%--------------------------------------------------------------------------
% l1=1-r-s-t;
% d/dr               d/ds           
nh(1,1) = -1;       nh(1,2) =-1;
nh(2,1) = 1;        nh(2,2) =0;   
nh(3,1) = 0;        nh(3,2) = 1;


dr=nh(:,1)'; ds=nh(:,2)';     % derivations
dxdr=dr*x;dydr=dr*y;dzdr=dr*z;
dxds=ds*x;dyds=ds*y;dzds=ds*z;

dA = sqrt((dydr*dzds-dyds*dzdr)^2 + (dxds*dzdr-dxdr*dzds)^2 +...
    (dxdr*dyds-dydr*dxds)^2);

% Basisfunctions
%--------------------------------------------------------------------------
h(1) =l1;
h(2) =r;
h(3) =s;

