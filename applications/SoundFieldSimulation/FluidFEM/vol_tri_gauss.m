function [M S]= vol_tri_gauss(M,S,coord,nodes)
% Gives mass- (M) and compressibility matrix (S) back by using a
% gaussintegration over basisfunctions or derivations of the basisfunctions.
% Gets mass- (M) and compressibility matrix (S) as well as the current
% coordinates (coord) and nodes (nodes).
% The gaussintegration uses xx supporting points.

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% -------------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------------
Ve=1;
g1= 0.500000000000000000;
g2= 0.100526765225204467;
g3= 0.314372873493192195;
w1= 0.0031746031746031745;
w2= 0.0147649707904967828;
w3= 0.0221397911142651221;

r =[g1, g1, 0, 0;
    g1, 0, g1, 0;
    g1, 0, 0, g1;
    0, g1, g1, 0;
    0, g1, 0, g1;
    0, 0, g1, g1;
    1.0-3.0*g2, g2, g2, g2;
    g2, 1.0-3.0*g2, g2, g2;
    g2, g2, 1.0-3.0*g2, g2;
    g2, g2, g2, 1.0-3.0*g2;
    1.0-3.0*g3, g3, g3, g3;
    g3, 1.0-3.0*g3, g3, g3;
    g3, g3, 1.0-3.0*g3, g3;
    g3, g3, g3, 1.0-3.0*g3];
alpha=[w1 w1 w1 w1 w1 w1  w2 w2 w2 w2  w3 w3 w3 w3]';


l_r=length(r(:,1));               % number of supporting points
l_a=length(coord(:,1));             % 10

% Integration
%--------------------------------------------------------------------------
% Select basisfunctions
for i1=1:l_r
    [J,nbasis]=vol_tri_nbasis(r(i1,:),coord);
    det_J=det(J);
    basis = vol_tri_basis(r(i1,:));             
    for k1=1:l_a
        for k2=k1:l_a
            sort1 =nodes(k1);
            sort2 =nodes(k2);
            nbasis1 = J\nbasis(k1,:)'; 
            nbasis2 = J\nbasis(k2,:)';
            M(sort1,sort2)=M(sort1,sort2)+Ve*det_J*alpha(i1)*basis(k1)*basis(k2); % M
            S(sort1,sort2)=S(sort1,sort2)+Ve*det_J*nbasis1'*nbasis2*alpha(i1); % S 
            if k1~=k2
            M(sort2,sort1)=M(sort1,sort2);
            S(sort2,sort1)=S(sort1,sort2);
            end
        end
    end
end


function [J,nh]=vol_tri_nbasis(r_vec, coord)
% create derivation of basisfunctions (nh) and jacobi matrix (J) from local 
% coordinates (coord) and sampling points (r_vec).

% -------------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------------
x = coord(:,1); y = coord(:,2); z = coord(:,3);
l1= r_vec(1); r= r_vec(2); s= r_vec(3); t= r_vec(4);

% Basisfunction derivations
%--------------------------------------------------------------------------
nh= sparse(10,3);
%   d/dr                d/ds                d/dt
nh(1,1) =-4*l1+1;   nh(1,2) =-4*l1+1;   nh(1,3) =-4*l1+1;
nh(2,1) = 4*(l1-r); nh(2,2) =-4*r;      nh(2,3) =-4*r;
nh(3,1) = 4*r-1;
nh(4,1) = 4*s;      nh(4,2) = 4*r;
nh(5,2) = 4*s-1;
nh(6,1) =-4*s;      nh(6,2) = 4*(l1-s); nh(6,3) =-4*s;
nh(7,1) =-4*t;      nh(7,2) =-4*t;      nh(7,3) = 4*(l1-t);
nh(8,1) = 4*t;                          nh(8,3) = 4*r;
nh(9,2) = 4*t;      nh(9,3) = 4*s;
nh(10,3)= 4*t-1;

% Jacobi matrix
%--------------------------------------------------------------------------
dxdr = nh(:,1)'*x; dxds = nh(:,2)'*x; dxdt = nh(:,3)'*x;
dydr = nh(:,1)'*y; dyds = nh(:,2)'*y; dydt = nh(:,3)'*y;
dzdr = nh(:,1)'*z; dzds = nh(:,2)'*z; dzdt = nh(:,3)'*z;

J=[ dxdr dydr dzdr;...
    dxds dyds dzds;...
    dxdt dydt dzdt];

function h = vol_tri_basis(r_vec)
% creates basis functions (h) for sampling points (r_vec)
% -------------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------------
l1= r_vec(1); r= r_vec(2); s= r_vec(3); t= r_vec(4);
% Basisfunctions
%--------------------------------------------------------------------------
h(1) = (2*l1-1)*l1;
h(2) = 4*r*l1;
h(3) = (2*r-1)*r;
h(4) = 4*r*s;
h(5) = (2*s-1)*s;
h(6) = 4*l1*s;
h(7) = 4*l1*t;
h(8) = 4*t*r;
h(9) = 4*t*s;
h(10) = (2*t-1)*t;
