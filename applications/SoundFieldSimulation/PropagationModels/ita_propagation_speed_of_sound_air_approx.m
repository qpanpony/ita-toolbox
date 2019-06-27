function c = ita_propagation_speed_of_sound_air_approx( temperature_degree_celsius )
%ita_propagation_speed_of_sound_air_approx Calculates sound speed in air
% based on the approximation c = 331.3 + \theta \cdot 0.606 ) [m/s]
% Input: temperature_degree_celsius, defaults to 20 degree -> ita_propagation_defaults.air.temperature
% Output: speed of sound (c) in meter per second

if nargin < 1
    ita_propagation_load_defaults
    T = ita_propagation_defaults.air.temperature;
else
    T = temperature_degree_celsius;
end
absolute_temperature_min = -273.15; % 0 Kelvin in Celsius degree
assert( T > absolute_temperature_min )

c = 331.3 + T * 0.606;
