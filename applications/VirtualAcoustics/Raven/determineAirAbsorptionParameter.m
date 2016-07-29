function airAbsorptionCoeffs = determineAirAbsorptionParameter(temperature, pressure, humidity)

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

	% temperature in °C
	% pressure in Pascal
	% humidity in %

    % init frequency bands
	frequencies(1) = 20;	frequencies(2) = 25;	frequencies(3)  = 31.5; 
	frequencies(4) = 40;	frequencies(5) = 50;	frequencies(6)  = 63;	 
	frequencies(7) = 80;	frequencies(8) = 100;	frequencies(9)  = 125;	
	frequencies(10) = 160;	frequencies(11)= 200;	frequencies(12) = 250;   
	frequencies(13)= 315;	frequencies(14)= 400;	frequencies(15) = 500;	 
	frequencies(16)= 630;	frequencies(17)= 800;	frequencies(18) = 1000;  
	frequencies(19)= 1250;	frequencies(20)= 1600;	frequencies(21) = 2000;	 
	frequencies(22)= 2500;	frequencies(23)= 3150;	frequencies(24) = 4000;	 
	frequencies(25)= 5000;	frequencies(26)= 6300;	frequencies(27) = 8000;	 
	frequencies(28)= 10000;	frequencies(29)= 12500;	frequencies(30) = 16000; 
	frequencies(31)= 20000;

	roomTemperatureKelvin = temperature + 273.16;
	referencePressureKPa = 101.325;
	pressureKPa = pressure/1000.0;

	% determine molar concentration of water vapor
	tmp =	(10.79586 * (1.0 - (273.16/roomTemperatureKelvin) )) - ...
			(5.02808 * log10((roomTemperatureKelvin/273.16)) ) + ...
			(1.50474 * 0.0001 * ( 1.0 - 10.0 ^ (-8.29692*( (roomTemperatureKelvin/273.16) - 1.0)))) + ...
			(0.42873 * 0.001 * ( -1.0 + 10.0 ^ (-4.76955*( 1.0 - (273.16/roomTemperatureKelvin))))) - ...
			2.2195983;

	molarConcentrationWaterVaporPercent = (humidity * 10.0 ^ tmp) / (pressureKPa/referencePressureKPa);

	% determine relaxation frequencies of oxygen and nitrogen
	relaxationFrequencyOxygen = (pressureKPa/referencePressureKPa) * ...
								( 24.0 + (4.04 * 10000.0 *  molarConcentrationWaterVaporPercent * ...
								((0.02 + molarConcentrationWaterVaporPercent) / (0.391 + molarConcentrationWaterVaporPercent))));

	relaxationFrequencyNitrogen =	(pressureKPa/referencePressureKPa) * ...
									( (roomTemperatureKelvin / 293.16) ^ (-0.5) ) * ...
									(9.0 + 280.0 * molarConcentrationWaterVaporPercent * ...
										exp(-4.17 * (( (roomTemperatureKelvin / 293.16) ^ (-0.3333333)) - 1.0)));

	% calculate for 31 one-third octaves
	for i = 1 : 31
		airAbsorptionCoeffs(i) = ((frequencies(i)^2) * ...
                                    ((1.84 * 10.0^(-11.0) * (referencePressureKPa / pressureKPa) * (roomTemperatureKelvin/293.16)^0.5) + ...
                                    ((roomTemperatureKelvin/293.16)^(-2.5) * ( ...
                                        ((1.278 * 0.01 * exp( (-2239.1/roomTemperatureKelvin))) / ...
                                        (relaxationFrequencyOxygen + ((frequencies(i)^2)/relaxationFrequencyOxygen))) + ...
                                    ((1.068 * 0.1 * exp((-3352.0/roomTemperatureKelvin))/ ...
                                    (relaxationFrequencyNitrogen + ((frequencies(i)^2)/relaxationFrequencyNitrogen))))))) ...
                                    )* (20.0 / log(10.0)) / ((log10(exp(1.0))) * 10.0); % Neper/m -> dB/m
    end

end

