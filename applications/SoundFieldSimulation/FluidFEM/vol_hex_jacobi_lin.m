function [Ja] = vol_hex_jacobi_lin(r,s,t,coord)
% calculating jacobimatrix and determinante for a hexagonal element.
% function gets supporting points (r,s,t) and current coordinates of the
% objects (coord).
% function gives a struct (Ja) with the determinante (J_det), derivations
% of the basisfunctions (h) and jacobimartix back.
%--------------------------------------------------------------------------
% Initialization
%--------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

h=vol_hex_nbasis_fct_lin(r,s,t);   %get derivations of basisfunctions
dr=h(:,1)'; ds=h(:,2)'; dt=h(:,3)';
X=coord(:,1);       %global coordinates
Y=coord(:,2);
Z=coord(:,3);

J=[ dr*X,  dr*Y,  dr*Z;...
    ds*X,  ds*Y,  ds*Z;...
    dt*X,  dt*Y,  dt*Z];
J_det = det(J);

if J_det <=0
    error('Mapping is not unique');
end 
Ja.J_det = J_det;
Ja.h     = h;
Ja.J     = J;