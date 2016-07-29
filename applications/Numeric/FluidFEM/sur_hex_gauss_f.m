function [f]=sur_hex_gauss_f(f,coord,nodes)
% Produces sufaceements with gaussintegration (f). gaussintegration is
% implemented with 3 supporting points.
% The function gets the weight vector(f), coordinates (coord) and the 
% nodes (nodes) from the current surface element.
% -------------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

l_a=length(coord(:,1));         % 6
r=[sqrt(3/5) -sqrt(3/5) 0];     % supporting points
alpha = [5/9 5/9 8/9];          % weights
l_r =length(r);                 % 3

% Integration
% -------------------------------------------------------------------------
% Select basisfunctions for f

for i1=1:l_r
    for i2=1:l_r
        [dA, h]= sur_hex_basis_fct([r(i1) r(i2)],coord);
        for k1=1:l_a
            f(nodes(k1))=f(nodes(k1))+h(k1)*alpha(i1)*alpha(i2)*dA;%f_Fi-Matrix
        end
    end
end