%% ITA propagation default values

ita_propagation_defaults = struct();


%% Literals

ita_propagation_defaults.air.density = 1.2041; % kg / m^3
ita_propagation_defaults.air.temperature = 20.0; % Degree Celsius
ita_propagation_defaults.humidity = 80; % Percentage
ita_propagation_defaults.static_pressure = 101325; % Pa



%% Dependent variables

ita_propagation_defaults.air.speed_of_sound = ...
    ita_propagation_speed_of_sound_air_approx( ita_propagation_defaults.air.temperature ); % m / s

ita_propagation_defaults.air.wave_impedance = ...
    ita_propagation_wave_impedance( ita_propagation_defaults.air.speed_of_sound, ita_propagation_defaults.air.density ); % kg / ( s \cdot m^2 )
