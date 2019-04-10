function A=sur_hex_gauss_A(A,coord,nodes)
% Produces sufaceements with gaussintegration (A). gaussintegration is
% implemented with 3 supporting points.
% The function gets the admittance matrix (A), coordinates (coord) and the 
% nodes (nodes) from the current surface element.
% -------------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

l_a=length(coord(:,1));         % 8
r=[sqrt(3/5) -sqrt(3/5) 0];     % supporting points
alpha = [5/9 5/9 8/9];          % weights
l_r =length(r);                 % 3

% Integration
% -------------------------------------------------------------------------
% Select basisfunctions for A
for i1=1:l_r
    for i2=1:l_r
        [dA, h]= sur_hex_basis_fct([r(i1) r(i2)],coord);
        for k1=1:l_a
            for k2=k1:l_a
                A(nodes(k1),nodes(k2))= A(nodes(k1),nodes(k2)) + ...
                    h(k1)*h(k2)*alpha(i1)*alpha(i2)*dA;%A_Fij-Matrix
                if k1~=k2
                    A(nodes(k2),nodes(k1))=A(nodes(k1),nodes(k2));
                end
            end
        end
    end
end
