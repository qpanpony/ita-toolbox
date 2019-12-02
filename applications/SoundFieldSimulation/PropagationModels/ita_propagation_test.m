%% General
ita_propagation_load_defaults

a = itaAudio( 1 );
a.fftDegree = 12;

f0 = a.freqVector;
f = f0( 2:end );


%% Transmission through panels
material_mass = 742.4; % kg / m^3 (MDF)
material_thickness = 25e-3; % 25mm
material_mass_per_area = material_mass * material_thickness;
T = ita_propagation_transmission( material_mass_per_area, 100, ita_propagation_defaults.air.wave_impedance );

if fix( db( T ) ) == -23 % approx -23 dB transmitted (23 dB insertion loss)
    disp( 'Transmission calculated correctly, found 23 dB insertion loss for given parameters' )
end
