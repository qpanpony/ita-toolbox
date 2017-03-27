function varargout = ita_microflown_calibration(varargin)
%ITA_MICROFLOWN_CALIBRATION - calibrate ITA Microflown
%  This function 
%
%  Syntax:
%   audioObjOut = ita_microflown_calibration(audioObj1, audioObj2, options)
%
%   Options (default):
%           'gain' ('high')         : description
%           'correction' ('off')    : description
%
%  Example:
%   audioObjOut = ita_microflown_calibration(audioObjIn)
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_microflown_calibration">doc ita_microflown_calibration</a>

% <ITA-Toolbox>
% This file is part of the application MicroflownImpedanceProcessor for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  13-Apr-2010

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_p','itaAudio', 'pos2_v','itaAudio','gain','high','correction','off');
[p,u,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% compensation
f = p.freqVector;
pCalib = itaAudio();
pCalib.samplingRate = p.samplingRate;
uCalib = itaAudio();
uCalib.samplingRate = p.samplingRate;

% Pressure Sensor calibration
% ---------------------------------------------------------------------
Sp_1kHz = 60.6e-3; % [V/Pa]
f_c1p   = 27;      % [Hz]
f_c2p   = 10;      % [Hz]
f_c3p   = 5945;    % [Hz]
C_1p    = 24;      % [Hz]
C_2p    = 15;      % [Hz]
C_3p    = 21826;   % [Hz]


S_p   = Sp_1kHz .* ( sqrt(1 + (f.^2./f_c3p.^2)) ) ./ ...
    ( sqrt(1 + (f_c1p.^2./f.^2)) .* sqrt(1 + (f_c2p.^2./f.^2)) );

phi_p = atan(C_1p./f) + atan(C_2p./f) + atan(f./C_3p);

% pressure sensitivity curve
pCalib.freqData = S_p .* exp(1i.*phi_p);

% Velocity Sensor calibration
% ---------------------------------------------------------------------
if strcmpi(sArgs.gain, 'high')
    Su_250Hz = 65.15;  % [V/(m/s)]
elseif strcmpi(sArgs.gain, 'low')
    Su_250Hz = 0.5175; % [V/(m/s)]
end

f_c1u   = 6;       % [Hz]
f_c2u   = 891;     % [Hz]
f_c3u   = 9979;    % [Hz]
f_c4u   = 25;      % [Hz]
C_1u    = 1;       % [Hz]
C_2u    = 820;     % [Hz]
C_3u    = 14430;   % [Hz]
C_4u    = 25;      % [Hz]

if ~(sArgs.correction)
    S_u   = Su_250Hz ./ ( sqrt(1 + (f_c1u.^2./f.^2)) .* sqrt(1 + (f.^2./f_c2u.^2)) .* ...
        sqrt(1 + (f.^2./f_c3u.^2)) .* sqrt(1 + (f_c4u.^2./f.^2)) );
    phi_u = atan(C_1u./f) - atan(f./C_2u) - atan(f./C_3u) + atan(C_4u./f);
else
    S_u   = Su_250Hz ./ ( sqrt(1 + (f_c1u.^2./f.^2)) .* sqrt(1 + (f_c4u.^2./f.^2)) );
    phi_u = atan(C_1u./f) + atan(C_4u./f);
end

% velocity sensitivity curve
uCalib.freqData = S_u .* exp(1i.*phi_u);
pCalib = pCalib * itaValue(1,'V')/ itaValue(1,'Pa');
uCalib = uCalib * itaValue(1,'V')/ itaValue(1,'m/s');

%% Set Output
varargout{1} = p/pCalib; 
varargout{2} = u/uCalib; 

%end function
end