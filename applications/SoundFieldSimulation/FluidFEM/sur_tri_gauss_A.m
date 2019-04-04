function A = sur_tri_gauss_A(A,coord,nodes)
% Produces sufaceements with gaussintegration (A). gaussintegration is
% implemented with 4 supporting points.
% The function gets the admittance matrix (A), coordinates (coord) and the
% nodes (nodes) from the current surface element.
% -------------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

r=[1/3  1/3  1/3;...
    3/5  1/5  1/5;...
    1/5  3/5  1/5;...
    1/5  1/5  3/5];                  % supporting points
alpha =[-9/16 25/48 25/48 25/48]';  % weights
l_r=length(r(:,1));                 %  5
Ae = 1/2;                           % surface standard element
l_a=length(coord(:,1));


% Gaussintegration
% -------------------------------------------------------------------------
for i1=1:l_r
    [h dA]= sur_tri_basis_fct(r(i1,:),coord);
    for k1=1:l_a
        for k2=k1:l_a
            A(nodes(k1),nodes(k2))=A(nodes(k1),nodes(k2))+Ae*h(k1)*h(k2)*alpha(i1)*dA;   %A_Fij-Matrix        
            if k1~=k2
                A(nodes(k2),nodes(k1))= A(nodes(k1),nodes(k2));
            end
        end
    end
end