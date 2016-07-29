function s = ita_sph_sampling_V000H000(az,el)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% equiangular sampling in MF style
%
%   az: azimuth angle step or phi angles (both in degrees)
%   el: elevation angle step or theta angles (both in degrees)
%
%   Examples:
%       s = ita_sph_sampling_V000H000(5,5)
%                % 5°/5° sampling
%       s = ita_sph_sampling_V000H000(0:5:355,0:5:180)
%                % as above, long syntax


if numel(az) == 1 && numel(el) == 1
    az = 0:az:(360-0.1);
    el = 0:el:180;
end 

[AZ,EL] = meshgrid(az,el);

s = itaSamplingSph(numel(AZ));
s.r = 1;
s.theta = EL(:) *pi/180;
s.phi = AZ(:) *pi/180;
