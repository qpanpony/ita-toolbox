function varargout = ita_sound_power(varargin)
%ITA_SOUND_POWER - calculate the sound power of a source in a specific room
%  This function takes spl-data and RT of the empty room to calculate the
%  equivalent absorption area of the tested room. This is used to calculate
%  the sound power of the source according to ISO 3741.
%
%  Syntax:
%   audioObjOut = ita_sound_power(audioObjIn, T_empty, options)
%
%   Options (default):
%           'room_volume' (124) :  default value fits ITA reverberation
%                                  chamber
%           'room_surface' (181):  default value fits ITA reverberation
%                                  chamber 
%           'T' (20)            :  Temperature in deg Celsius
%           'RH' (0.5)          :  Relative Humidity
%
%  Example:
%   audioObjOut = ita_sound_power(audioObjIn)
%
%  See also:
%   ita_sabine
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sound_power">doc ita_sound_power</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

% Author: Christian Haar -- Email: christian.haar@akustik.rwth-aachen.de
% Created:  24-Jun-2010 

%% Initialization and Input Parsing
sArgs        = struct('pos1_spl', 'itaSuper', 'pos2_T_empty', 'itaSuper', 'room_volume', 124,'room_surface',181,'T',20,'RH',0.5, 'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsPerOctave') );
[spl,T_empty,sArgs] = ita_parse_arguments(sArgs,varargin); 

% acoustic constants
c = 20.05*sqrt(273 + sArgs.T);
% correction factors for the meteorological conditions (not in dB!)
% (assumes static pressure is the reference value)
C1 = sqrt((273.15 + sArgs.T)/314);
C2 = sqrt((273.15 + sArgs.T)/296).^3;

%% calculate sound pressure level data
spl_m = sqrt(mean(abs(spl')^2));
spl_m = ita_spk2frequencybands(spl_m, 'freqRange',sArgs.freqRange , 'bandsPerOctave',sArgs.bandsPerOctave);
spl_m = itaResult(spl_m,T_empty.freqVector);

%% calculate equivalent absorption area
A = 55.26*itaValue(double(sArgs.room_volume)/c,'s*m^2')/T_empty;

%% calculate sound power (Eq 20 in ISO 3741)
sound_power = spl_m^2 * A * 0.5 * C1 * C2;
% exponent and frequency-dependent part
sound_power.freq = sound_power.freq.*exp(A.freq./double(sArgs.room_surface)).*(1 + double(sArgs.room_surface)*c./(8*double(sArgs.room_volume).*sound_power.freqVector));
% getting the reference values right
sound_power = sound_power*itaValue(1e-12,'W')/itaValue(20e-6,'Pa')^2/itaValue(1,'m^2');

% or the straight-forward way: 
% sound_power = spl_m^2 * A/(2*itaValue(c,'m/s')*itaValue(1.2,'kg/m^3'));

%% Add history line
sound_power = ita_metainfo_add_historyline(sound_power,mfilename,varargin);

%% Set Output
varargout(1) = {sound_power}; 

%end function
end