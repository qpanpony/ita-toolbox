function varargout = ita_sph_sampling_icosahedron()
%ITA_SPH_SAMPLING_ICOSAHEDRON - Icosahedron sampling
%  This function generates a spherical sampling based on the 
%  face center points of an icosahedron.
%
%  Syntax:
%   sampling = ita_sph_sampling_icosahedron()
%
%  Example:
%   sampling = ita_sph_sampling_icosahedron()
%
%  See also:
%	ita_sph_sampling, ita_sph_base
%   
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_sampling_icosahedron">doc ita_sph_sampling_icosahedron</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  09-Nov-2016 


gammaRr = acos(cos(pi/3)/sin(pi/5));
gammaRrho = acos(1/(tan(pi/5)*tan(pi/3)));

theta = repmat([pi-gammaRrho,pi-gammaRrho-2*gammaRr,2*gammaRr+gammaRrho,gammaRrho],5,1);
phi = (0:2*pi/5:(2*pi-2*pi/5));
phi = [repmat(phi,2,1);repmat(phi+pi/5,2,1)].';
r = ones(20,1);
positions = [r,sort(theta(:)),phi(:)];

sampling = itaSamplingSph(positions,'sph');
sampling.nmax = 3;

varargout{1} = sampling;


end
