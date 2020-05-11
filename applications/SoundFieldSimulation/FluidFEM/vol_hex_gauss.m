function [M,S] = vol_hex_gauss(M,S,coord, nodes)
% Gives mass- (M) and compressibility matrix (S) back by using a 
% gaussintegration over basisfunctions or derivations of the basisfunctions. 
% Gets mass- (M) and compressibility matrix (S) as well as the current
% coordinates (coord) and nodes (nodes).
% The gaussintegration uses xx supporting points.
% -------------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

r=[sqrt(3/5) -sqrt(3/5) 0];     %supporting points
alpha = [5/9 5/9 8/9];          %weights
l_r =length(r);                 % 3
l_a= length(coord);             %20


% Integration
% -------------------------------------------------------------------------
% Select basisfunctions

% Gaussintegration over x,y,z with 3 supporting points
for i1=1:l_r
    for i2=1:l_r
        for i3=1:l_r
            Jacobi = vol_hex_jacobi(r(i1),r(i2),r(i3),coord);
            basis = vol_hex_basis_fct(r(i1),r(i2),r(i3));
            %M_Fij-Matrix
            for k1=1:l_a
                for k2=k1:l_a
                    sort1 =nodes(k1);
                    sort2 =nodes(k2);                
                    M(sort1,sort2)=M(sort1,sort2)+basis(k1)*basis(k2)...
                        *alpha(i1)*alpha(i2)*alpha(i3)...
                        *Jacobi.J_det;
                    %S_Fij-Martix
                    nbasis=Jacobi.h;
                    nbasis1 = Jacobi.J\nbasis(k1,:)';
                    nbasis2 = Jacobi.J\nbasis(k2,:)';

                    S(sort1,sort2)= S(sort1,sort2)+nbasis1'*nbasis2...
                        *alpha(i1)*alpha(i2)*alpha(i3)...
                        *Jacobi.J_det;
                    if k1~=k2
                       M(sort2,sort1)=M(sort1,sort2);
                       S(sort2,sort1)=S(sort1,sort2);
                    end
                end
            end
        end
    end
end
