function samplingCoords = ita_generateSampling_equiangular(az,el)

% equiangular sampling in MF style
%
%   az: azimuth angle step or phi angles (both in degrees)
%   el: elevation angle step or theta angles (both in degrees)
%
%   Examples:
%       s = ita_generateSampling_equiangular(5,5)
%                % 5°/5° sampling
%       s = ita_generateSampling_equiangular(0:5:355,0:5:180)
%                % as above, long syntax

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if numel(az) == 1 && numel(el) == 1
    az = 0:az:(360-0.1);
    el = 0:el:180;
end 

[AZ,EL] = meshgrid(az,el);

samplingCoords = itaCoordinates(numel(AZ));
samplingCoords.r = 1;
samplingCoords.theta = EL(:) *pi/180;
samplingCoords.phi = AZ(:) *pi/180;


samplingCoords.weights = ita_spherical_weights_equiangular(samplingCoords);