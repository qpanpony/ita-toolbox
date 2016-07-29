function varargout = ita_airflowResistance(varargin)
%ITA_AIRFLOWRESISTANCE - Calculates airflow resistance from input parameters
%  This function is called by ita_airflowResistance_measurementGUI. See
%  example below for usage without GUI.
%
%  Syntax:
%   R        = ita_airflowResistance(machineParamter, thickness, pressure)
%   [R R_S]  = ita_airflowResistance(machineParamter, thickness, pressure)
%   [R R_S r]= ita_airflowResistance(machineParamter, thickness, pressure)
%
%   Input:
%           machineParamter     struct with machine parameter, see example
%           thickness           thickness of probe [itaValue]
%           pressure            rms pressure [itaValue]
% 
%   Output:
%           R       airflow resistance
%           R_S     specific airflow resistance
%           r       lengthrelated airflow resistance
% 
% %  Example:
%             itaAirFlowMachine.S_piston      =   itaValue(0.01^2 * pi, 'm^2'); %surface of piston
%             itaAirFlowMachine.S_probe       =   itaValue(0.05^2 * pi, 'm^2'); %surface of probe
%             itaAirFlowMachine.frequency     =   itaValue(2, 'Hz');            %frequency of piston
%             itaAirFlowMachine.x_hat         =   itaValue(2.5e-3, 'm');        %  piston stroke length (peak length - NOT peak-to-peak)
%             d   =   itaValue(10e-3,'m');
%             p   =   itaValue(0.2,'Pa');
% 
%            [R R_S r] = ita_airflowResistance(itaAirFlowMachine, d , p )
%
%  See also:
%   ita_airflowResistance_measurementGUI, ita_airflowResistance_makeMeasurementSetup
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_airflowResistance">doc ita_airflowResistance</a>

% <ITA-Toolbox>
% This file is part of the application AirflowResistance for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  03-Jan-2011 


%% Initialization and Input Parsing

if nargin ~= 3
    error('Wrong input parameter.')
end

itaAirFlowMachine   = varargin{1};
d_probe             = varargin{2}; % thickness of probe
p_rms               = varargin{3}; % soundpressure


if ~isstruct(itaAirFlowMachine)|| ~isequal(d_probe.unit, 'm') ||  ~isequal(p_rms.unit, 'Pa')
    error('Wrong input parameter.')
end

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 
q_v_rms     = sqrt(2) * pi * itaAirFlowMachine.x_hat * itaAirFlowMachine.frequency * itaAirFlowMachine.S_piston;

u_rms       = q_v_rms / itaAirFlowMachine.S_probe;    % [m/s]     effective flow velocity
if (u_rms.value < 0.5e-3)  || (u_rms.value > 4e-3) 
    ita_verbose_info(['Check your x_hat!  DIN specifies: 0.5e-3 < u_rms < 4e-3'],0);
end


R   = p_rms / q_v_rms;  %TODO: delta_p auch effektiv !?!
R_S = R * itaAirFlowMachine.S_probe;
r   = R_S / d_probe;

% sample use of the ita warning/ informing function



%% Add history line
% input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
switch nargout 
    case 1
        varargout(1) = {R}; 
    case 2
        varargout(1) = {R};
        varargout(2) = {R_S};
    case 3
        varargout(1) = {R};
        varargout(2) = {R_S};
        varargout(3) = {r};
    otherwise
        R
        
end
%end function
end