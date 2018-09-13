function [ele_DEG] = ita_polar2elevationDEG(polar_DEG)
%ELEVATION2POLAR Converts elevation angle to polar angle
%   To Elevation angle, where frontal direction is 0°, from polar angle, where
%   above direction is 0°

ele_DEG=90-polar_DEG;

end

