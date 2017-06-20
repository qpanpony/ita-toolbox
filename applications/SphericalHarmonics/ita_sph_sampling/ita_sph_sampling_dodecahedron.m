function s = ita_sph_sampling_dodecahedron
%ITA_SPH_SAMPLING_DODECAHEDRON - angles of a dodecahedron
% function gridData = ita_sph_grid_dodecahedron
% 
% calculates the normal angles of a dodecahedron
% (with two of its vertexes on north and south pole)
% 
% the angles theta and phi are stored in struct gridData
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany, 2008
% 02.09.2008
% Modified: 10.10.08 - mpo - struct output

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% % initialize
% data = zeros(2,12);

% http://en.wikipedia.org/wiki/Platonic_solid
% simplified for a = 2
dihedral = 2 * asin(cos(pi/3)/sin(pi/5));
R = tan(pi/3)*tan(dihedral/2);
%r = cot(pi/5)*tan(dihedral/2)
rho = cos(pi/5)/sin(pi/10);

% theta1: from (0,0) to 1st LS
theta1 = acos(cot(pi/5)/tan(pi/3));

% a2: from corner to corner
a2 = 2 * acos(rho/R);

theta2 = theta1 + a2;
theta3 = pi - theta2;
theta4 = pi - theta1;

phi1 = 0;
phi2 = 2*pi/3;
phi3 = 4*pi/3;

theta = [repmat(theta1,3,1); repmat(theta2,3,1); repmat(theta3,3,1); repmat(theta4,3,1)].';
phi = repmat([[phi1; phi2; phi3]; pi/3+[phi1; phi2; phi3]],2,1).';
r = ones(size(theta));

s = itaSamplingSph([r(:) theta(:) phi(:)],'sph');
s.nmax = floor(sqrt(s.nPoints)-1);

end