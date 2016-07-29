function s = ita_sph_sampling_mic32berlin(nmax)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% d = 4.17; % inner diameter array (from tops of mics to tops on other side)
% r = d/2 * ones(size(theta));
%
% update 20.06.2012
% diameter is dependent on configuration
% 5er: 4.17m, 6er: 4.12m
r = [4.12/2 .* ones(20,1); 4.17/2 .* ones(12,1)];

% dihedral angle (between two adjacent pentagons)
dihedral = 2*asin(cos(pi/3) ./ sin(pi/5));

phi = pi/5 * [1 3 5 7 9 1 3 5 7 9 2 4 6 8 0 2 4 6 8 0 ...
    0 ...
    0 2 4 6 8 3 5 7 9 1 ...
    0];

% theta_01 = 180 - 90 - dihedral/2;
% theta_01 = pi/2 - 52.62/360*2*pi;
theta_01 = pi/2 - 52.62264/360*2*pi;
theta_02 = 2 * (pi - pi/2 - dihedral/2);
theta_04 = theta_01 + 2*(pi/2 - dihedral/2);
theta_03 = pi - theta_04;
theta_05 = pi - theta_02;
theta_06 = pi - theta_01;

theta = [theta_01 theta_01 theta_01 theta_01 theta_01 ...
    theta_03 theta_03 theta_03 theta_03 theta_03 ...
    theta_04 theta_04 theta_04 theta_04 theta_04 ...
    theta_06 theta_06 theta_06 theta_06 theta_06 ...
    0 ...    
    theta_02 theta_02 theta_02 theta_02 theta_02 ...
    theta_05 theta_05 theta_05 theta_05 theta_05 ...
    pi];

s = itaSamplingSph([r(:) theta(:) phi(:)],'sph');

if nargin < 1
    nmax = 4;
    disp('setting nmax = 4');
end

s.nmax = nmax;
nSH = size(s.Y,2);
s.weights = real(pinv(s.Y).' * [sqrt(4*pi); zeros(nSH-1,1)]);
