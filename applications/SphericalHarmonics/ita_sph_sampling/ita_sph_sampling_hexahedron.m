function s = ita_sph_sampling_hexahedron(varargin)
%ITA_SPH_SAMPLING_DODECAHEDRON - angles of a hexahedron
% function gridData = ita_sph_sampling_hexahedron
% 
% calculates the normal angles of a hexahedron
% 
% the angles theta and phi are stored in struct gridData
%
% Martin Kunkemoeller (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany, 2011
%% 02.02.2011

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


sArgs = struct('edge_is_bottom','true');
if nargin
   sArgs = ita_parse_arguments(sArgs, varargin); 
end
r     = ones(6,1) * 0.06;
theta = [0 ones(1,4)*pi/2 pi].';
phi   = [0 0 pi/2 pi 3*pi/2 0].'; 

s = itaSamplingSph([r theta phi],'sph');

if sArgs.edge_is_bottom
    s = rot_z(s, pi/4);
    s = rot_y(s, atan(sqrt(2)));
end
end
 
function data = rot_z(data, a)
    data.cart = ([cos(a) -sin(a) 0; sin(a) cos(a) 0; 0 0 1] * data.cart.').';
end

function data = rot_y(data, a)
    data.cart = ([cos(a) 0 sin(a); 0 1 0; -sin(a) 0 cos(a)] * data.cart.').';
end
