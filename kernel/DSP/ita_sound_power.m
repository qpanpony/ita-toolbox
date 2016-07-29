function varargout = ita_sound_power(varargin)
%ITA_SOUND_POWER - calculate the sound power of a source in a specific room
%  This function takes spl-data and RT of the empty room to calculate the
%  equivalent absorption area of the tested room. This is used to calculate
%  and give back the source's sound power.
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


%% calculate sound power
spl_m = sqrt(mean(abs(spl)^2));
spl_m = ita_spk2frequencybands(spl_m, 'freqRange',sArgs.freqRange , 'bandsPerOctave',sArgs.bandsPerOctave);
% T_empty = mean(T_empty(3));
spl_m = itaResult(spl_m',T_empty.freqVector);
[c,rho_0,m] = ita_constants({'c','rho_0','m'},'f',T_empty.freqVector,'T',sArgs.T,'phi',sArgs.RH);
alpha = ita_sabine('c',c,'m',m,'t60',T_empty,'v',sArgs.room_volume,'s',sArgs.room_surface); 
A = itaValue(double(sArgs.room_surface),'m^2')*alpha;
sound_power = (spl_m^2 / (4*rho_0*c)) * A;

% sound_power.bar

%% Add history line
sound_power = ita_metainfo_add_historyline(sound_power,mfilename,varargin);

%% Set Output
varargout(1) = {sound_power}; 

%end function
end