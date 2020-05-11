function f = sur_tri_gauss_f(f,coord,nodes)
% Produces sufaceements with gaussintegration (f). gaussintegration is
% implemented with 3 supporting points.
% The function gets the weight vector(f), coordinates (coord) and the
% nodes (nodes) from the current surface element.
%--------------------------------------------------------------------------
% Initialization
%--------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

r=[1/3  1/3  1/3;...
    3/5  1/5  1/5;...
    1/5  3/5  1/5;...
    1/5  1/5  3/5];                 % supporting points h(o^4)
alpha =[-9/16 25/48 25/48 25/48]';  % weights
l_r=length(r(:,1));                 %  5
Ae = 1/2;                           % surface standard element
l_a=length(coord(:,1));             % number of nodes per element

% Gaussintegration
%--------------------------------------------------------------------------
for i1=1:l_r
    [h dA]= sur_tri_basis_fct(r(i1,:),coord);
    for k1=1:l_a
        f(nodes(k1))=f(nodes(k1))+Ae*h(k1)*alpha(i1)*dA;   %f_Fi-Matrix
    end
end