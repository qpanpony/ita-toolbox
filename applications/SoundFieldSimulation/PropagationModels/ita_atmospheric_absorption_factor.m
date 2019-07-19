function dAirAbsorptionFactor = ita_atmospheric_absorption_factor( dFrequency, dDistance, vargin )
    if( nargin == 5 )
        dAirAbsorptionDecibel = ita_atmospheric_absorption_level_dB( dFrequency, dDistance, vargin{1}, vargin{2}, vargin{3} );
    elseif( nargin == 2 )
        dAirAbsorptionDecibel = ita_atmospheric_absorption_level_dB( dFrequency, dDistance );
    else
        error('Incorrect number of parameters supplied. Supported function calls: ita_atmospheric_absorption_factor( Frequency, Distance ), ita_atmospheric_absorption_factor( Frequency, Distance, temperature, humidity, pressure. In the first case, default values for the temperature, humidity and pressure are used )');
    end

	%Factor of absorbed signal energy [0:1]
	dAirAbsorptionFactor = 1 -  10.^( -dAirAbsorptionDecibel / 10.0 );
end