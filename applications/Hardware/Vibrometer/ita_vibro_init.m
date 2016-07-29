function ita_vibro_init(varargin)
%ITA_VIBRO_INIT - initialize laser com port
%  This function creates two global variables, one for each serial object
%  to communicate with the laser vibrometer.
%  The ports are taken from the preferences.
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_vibro_init">doc ita_vibro_init</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  17-Feb-2010 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions
sArgs        = struct('controller_comport',ita_preferences('laserControllerComPort'),'interface_comport',ita_preferences('laserInterfaceComPort'));
sArgs        = ita_parse_arguments(sArgs,varargin); 

%% check input arguments
narginchk(0,2);
global controller_serial;
global interface_serial;

if isempty(controller_serial)
    if strcmp(sArgs.controller_comport,'noDevice')
        error([thisFuncStr 'no controller comport available']);
    end
    insts = instrfind;         %show existing serial objects
    for i = 1:numel(insts)
        if strcmp(insts(i).Port,sArgs.controller_comport)
            delete(insts(i)); %delete used serial port
        end
    end
    % init serial object
    controller_serial = serial(sArgs.controller_comport,'Baudrate',9600,'Databits',8,'Stopbits',1);
    % check serial connection
    if ~strcmp(controller_serial.Status,'open')
        fopen(controller_serial);
    end
    if ~strcmp(controller_serial.Status,'open')
        error([thisFuncStr 'controller serial connection could not be opened']);
    end
end

if isempty(interface_serial)
    if strcmp(sArgs.interface_comport,'noDevice')
        error([thisFuncStr 'no interface comport available']);
    end
    insts = instrfind;         %show existing serial objects
    for i = 1:numel(insts)
        if strcmp(insts(i).Port,sArgs.interface_comport)
            delete(insts(i)); %delete used serial port
        end
    end
    % init serial object
    interface_serial = serial(sArgs.interface_comport,'Baudrate',9600,'Databits',8,'Stopbits',1);
    % check serial connection
    if ~strcmp(interface_serial.Status,'open')
        fopen(interface_serial);
    end
    if ~strcmp(interface_serial.Status,'open')
        error([thisFuncStr 'interface serial connection could not be opened']);
    end
end

%% try to determine whether the correct com ports were chosen
try
    tmp = ita_vibro_getLaserSensitivity(); %#ok<NASGU>
catch %#ok<CTCH>
    % maybe it's just reversed
    tmpSerial = interface_serial;
    interface_serial = controller_serial;
    controller_serial = tmpSerial;
    try
        tmp = ita_vibro_getLaserSensitivity(); %#ok<NASGU>
    catch %#ok<CTCH>
        error([thisFuncStr 'your comport configuration does not seem to work, please check it!']);
    end
end

%end function
end