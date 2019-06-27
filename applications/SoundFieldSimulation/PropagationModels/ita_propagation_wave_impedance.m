function Z = ita_propagation_wave_impedance( speed_of_sound, medium_density )
%ita_propagation_wave_impedance Determines the wave impedance of medium
%(speed_of_sound x speed_of_sound) with validation
% Input: speed_of_sound Sound speed in medium
%        medium_density Density of medium
%
% For default values of medium 'air', execute ita_propagation_load_defaults ->
% ita_propagation_defaults.air.XXX is available in workspace.
%

if speed_of_sound <= 0
    error 'Speed of sound cannot be zero or negative'
end

if medium_density <= 0
    error 'Medium density cannot be zero or negative'
end

Z = speed_of_sound .* medium_density;
