%% ITA propagation default values

ita_popagation_defaults = struct();


%% Literals

ita_popagation_defaults.air.density = 1.2041; % kg / m^3
ita_popagation_defaults.air.temperature = 20.0; % Degree Celsius


%% Dependent variables

ita_popagation_defaults.air.speed_of_sound = ...
    ita_propagation_speed_of_sound_air_approx( ita_popagation_defaults.air.temperature ); % m / s

ita_popagation_defaults.air.wave_impedance = ...
    ita_propagation_wave_impedance( ita_popagation_defaults.air.speed_of_sound, ita_popagation_defaults.air.density ); % kg / ( s \cdot m^2 )
