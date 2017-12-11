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
%           'p_s' (101325)      :  Static pressure in Pa
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
% Re-write to conform with ISO 3741: Markus Mueller-Trapet -- Email: markus.mueller-trapet@nrc.ca
% Modified: 28-Nov-2017

%% Initialization and Input Parsing
sArgs        = struct('pos1_spl', 'itaSuper', 'pos2_T_empty', 'itaSuper', 'room_volume', 124,'room_surface',181,'T',20,'RH',0.5,'p_s',101325, 'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsPerOctave'), 'bandMode','fft');
[spl,T_empty,sArgs] = ita_parse_arguments(sArgs,varargin); 

% acoustic constants
c = 20.05*sqrt(273 + sArgs.T);
Z_0 = itaValue(400,'kg/(m^2*s)'); % this is the fixed value to get the reference for 1pW right
% correction factors for the meteorological conditions (not in dB!)
C1 = 101325./double(sArgs.p_s).*sqrt((273.15 + sArgs.T)/314);
C2 = 101325./double(sArgs.p_s).*sqrt((273.15 + sArgs.T)/296).^3;

%% calculate sound pressure level data
% first third-octaves then average
spl = ita_spk2frequencybands(spl, 'freqRange',sArgs.freqRange , 'bandsPerOctave',sArgs.bandsPerOctave,'mode',sArgs.bandMode);
spl_m = sqrt(mean(spl^2));
spl_m = itaResult(spl_m,T_empty.freqVector);

%% calculate equivalent absorption area
A = 55.26*itaValue(double(sArgs.room_volume)/c,'s*m^2')/T_empty;

%% calculate sound power (Eq 20 in ISO 3741)
sound_power = spl_m^2 * A /(4*Z_0);
% apply exponent and frequency-dependent corrections
sound_power.freq =  C1.*C2.*sound_power.freq.*exp(A.freq./double(sArgs.room_surface)).*(1 + double(sArgs.room_surface)*c./(8*double(sArgs.room_volume).*sound_power.freqVector));

%% Add history line
sound_power = ita_metainfo_add_historyline(sound_power,mfilename,varargin);

%% Set Output
varargout(1) = {sound_power}; 

%end function
end