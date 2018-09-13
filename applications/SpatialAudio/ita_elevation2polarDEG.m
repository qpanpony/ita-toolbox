function [polar_DEG] = ita_elevation2polarDEG(ele_DEG)
%ELEVATION2POLAR Converts elevation angle to polar angle
%   Elevation angle, where frontal direction is 0°, to polar angle, where
%   above direction is 0°

polar_DEG=90-ele_DEG;

end

