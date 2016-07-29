function [dA, h] = sur_hex_basis_fct(r_vec,coord)
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
r= r_vec(1); s= r_vec(2); nh=zeros(8,2);
% Derivations basisfunctions
%--------------------------------------------------------------------------
% d/dr                          d/ds
nh(1,1)= -1/4*(1+s)*(-2*r+s);  nh(1,2)=  1/4*(1-r)*(2*s-r);
nh(2,1)= -r*(1+s);             nh(2,2)=  1/2*(1-r^2);
nh(3,1)=  1/4*(1+s)*(2*r+s);   nh(3,2)=  1/4*(1+r)*(2*s+r);
nh(4,1)=  1/2*(1-s^2);         nh(4,2)= -s*(1+r);   
nh(5,1)=  1/4*(1-s)*(2*r-s);   nh(5,2)= -1/4*(1+r)*(-2*s+r); 
nh(6,1)= -r*(1-s);             nh(6,2)= -1/2*(1-r^2); 
nh(7,1)= -1/4*(1-s)*(-2*r-s);  nh(7,2)= -1/4*(1-r)*(-2*s-r);
nh(8,1)= -1/2*(1-s^2);         nh(8,2)= -s*(1-r);
dr=nh(:,1)'; ds=nh(:,2)';      % derivations
dxdr=dr*x;dydr=dr*y;dzdr=dr*z;
dxds=ds*x;dyds=ds*y;dzds=ds*z;

dA = sqrt((dydr*dzds-dyds*dzdr)^2 + (dxds*dzdr-dxdr*dzds)^2 +...
    (dxdr*dyds-dydr*dxds)^2);

% Basisfunctions
%--------------------------------------------------------------------------
h=zeros(8,1);
h(1)= 1/4*(1-r)*(1+s)*(-r+s-1);
h(2)= 1/2*(1-r^2)*(1+s);
h(3)= 1/4*(1+r)*(1+s)*(r+s-1);
h(4)= 1/2*(1-s^2)*(1+r);              
h(5)= 1/4*(1+r)*(1-s)*(r-s-1);
h(6)= 1/2*(1-r^2)*(1-s);
h(7)= 1/4*(1-r)*(1-s)*(-r-s-1);
h(8)= 1/2*(1-s^2)*(1-r);


