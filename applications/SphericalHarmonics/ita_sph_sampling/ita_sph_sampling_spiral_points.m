function varargout = ita_sph_sampling_spiral_points(varargin)
%ITA_SPH_SAMPLING_SPIRAL_POINTS - Spiral points sampling
%  This function calculates a spherical sampling based on a spiral distribution over the sphere
%  from north to south pole as introduces in
%	Rakhmanov,Saff,Zhou - Minimal Discrete Energy on the Sphere 
%
%  In order to ensure a feasible SHT the number of sampling points is 
%  increased until the condition number of the SH basis matrix is sufficiently small.
%  For high SH orders it is recommended to start with a higher number of sampling points
%  than (Nmax+1)^2 in order to save computation time.
%  In order to ignore the feasibility criterion, use 'condSHT', inf
%
%  Syntax:
%   sampling = ita_sph_sampling_spiral_points()
%
%  Example:
%   sampling = ita_sph_sampling_spiral_points(Nmax,'condSHT',2,'nPoints',(Nmax+1)^2)
%
%  See also:
%   ita_sph_sampling, ita_sph_base
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_sampling_spiral_points">doc ita_sph_sampling_spiral_points</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  09-Nov-2016 



sArgs = struct('pos1_Nmax','integer',...
               'condSHT',2.5,...
			   'nPoints',[]);
[Nmax,sArgs] = ita_parse_arguments(sArgs,varargin);

if isempty(sArgs.nPoints)
	sArgs.nPoints = (Nmax+1)^2;
else
	if Nmax > 15
		ita_verbose_info('You may want to consider setting a number of points higher than (Nmax+1)^2 as starting point.',1);
	end
end

% find a sampling with a feasible SHT transform as this may not be the case
% for every set of sampling points resulting from the spiral points
% use while true to exec the loop at least once
while true
    coordsCart = calculate_spiral_points(sArgs.nPoints);
    sampling = itaSamplingSph(coordsCart,'sph');
    Y = ita_sph_base(sampling,Nmax);
    if sArgs.condSHT ~= inf
        condNum = cond(Y);
        if condNum < sArgs.condSHT
            break;
        end
    else
        break;
    end
    sArgs.nPoints = sArgs.nPoints+1;
end

sampling.nmax = Nmax;

varargout{1} = sampling;

end

function sp = calculate_spiral_points(nPoints)
% algorithm based on 
% Rakhmanov,Saff,Zhou - Minimal Discrete Energy on the Sphere 
% improved by Hobbs

% init
r = zeros(1,nPoints-2);
h = zeros(1,nPoints-2);
theta = zeros(1,nPoints);
phi = zeros(1,nPoints);

p = 1/2;
a = 1 - 2*p/(nPoints-3);
b = p*(nPoints+1)/(nPoints-3);
r(1) = 0;
theta(1) = pi;
phi(1) = 0;
% Then for k stepping by 1 from 2 to n-1:
for k = 2:nPoints-1
    kStrich = a*k + b;
    h(k) = -1 + 2*(kStrich-1)/(nPoints-1);
    r(k) = sqrt(1-h(k)^2);
    theta(k) = acos(h(k));
    phi(k) = mod((phi(k-1) + 3.6/sqrt(nPoints)*2/(r(k-1)+r(k))),2*pi);
end
% Finally:
theta(nPoints) = 0;
phi(nPoints) = 0;

sp = [ones(nPoints,1),theta.',phi.'];
end
