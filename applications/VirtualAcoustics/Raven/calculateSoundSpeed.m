function soundspeed = calculateSoundSpeed(temperature, humidity, pressure)
%  Give temperature in degree celsius, relative humidity in percent and
%  pressure in Pa. Defaults are 20 degree celcius, 50% humidity and 101325 Pa
%  The exact solution is valid from 0 to 30 degrees celcius.
%  Taken from:
%  http:%resource.npl.co.uk/acoustics/techguides/speedair/:
%  "The calculator presented here computes the zero-frequency speed of sound
%  in humid air according to Cramer (J. Acoust. Soc. Am., 93, p2510, 1993),
%  with saturation vapour pressure taken from Davis, Metrologia, 29, p67, 1992,
%  and a mole fraction of carbon dioxide of 0.0004.
%  [...]

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    if nargin<2
        humidity = 50;
        pressure = 101325;
    end
    
    if nargin<3
        pressure = 101325;
    end


    Kelvin = 273.15;

    % Measured ambient temp
	T_kel = Kelvin + temperature;

    % Molecular concentration of water vapour calculated from Rh using Giacomos method by Davis (1991) as implemented in DTU report 11b-1997
	ENH = 3.14 * .00000001 * pressure + 1.00062 + temperature*temperature * 5.6 * .0000001;

    % These commented lines correspond to values used in Cramer (Appendix)
    % PSV1 = sqr(T_kel)*1.2811805*Math.pow(10,-5)-1.9509874*Math.pow(10,-2)*T_kel ;
    % PSV2 = 34.04926034-6.3536311*Math.pow(10,3)/T_kel;	
    PSV1 = ( T_kel*T_kel * 1.2378847 * 0.00001 ) - ( 1.9121316 * 0.01 * T_kel );
    PSV2 = 33.93711047 - 6.3431645 * 1000 / T_kel;
    PSV  = exp(PSV1) * exp(PSV2);
    H    = humidity * ENH * PSV / pressure;
    Xw   = H / 100.0;
    % Xc   = 314.0 * 10^-6;
    Xc   = 400.0 * .000001;

    % Speed calculated using the method of Cramer from JASA vol 93 pg 2510
	C1 = 0.603055  * temperature +  331.5024 - temperature*temperature * 5.28 / 10000 ...
				+ (0.1495874 * temperature + 51.471935 - temperature*temperature * 7.82 / 10000)   * Xw;
	C2 =(-1.82 / 10000000 + 3.73 / 100000000 * temperature - temperature*temperature * 2.93 / 10000000000) * pressure ...
				+ (-85.20931 - 0.228525 * temperature + temperature*temperature * 5.91 /  100000 ) * Xc;
    C3 = Xw*Xw * 2.835149 + pressure*pressure * 2.15 / 10000000000000 ...
				- Xc*Xc * 29.179762 - 4.86 / 10000 * Xw * pressure * Xc;

    soundspeed = C1 + C2 - C3;

end
