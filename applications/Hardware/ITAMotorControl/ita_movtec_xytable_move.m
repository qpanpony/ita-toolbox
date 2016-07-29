function varargout = ita_movtec_xytable_move(varargin)
%ITA_MOVTEC_XYTABLE_MOVE - this function move the table either in x- or in
%   y-direction for a specified displacement.
%   You also can specify the speed, the VST, the speedRange and if you want
%   to wait for reaching the position.
%
%   Syntax:   ita_movtec_xytable_move(motor, displacment, options)
%
%   arguments:  motor = 'motor2', 'x', 'X' or 'motor1', 'y', 'Y'
%               displacment = 1000 (in mm)
%
%  Options (default):  // Input always in pairs of ...('argumentString', value)
%               'wait' (false)  : false or true
%               'speed' (25)    : speed in percent from 0.1 to 100           
%               'speedR' ('00') : speedrange - '00'=0-20.2kHz , '01'=0-10.1kHz , '02'=0-6.7kHz ... (see documentation)
%               'VST' ('01')    : pitch, '01'=1, '02'=2, '04'=4, '08'=8, '10'=16, ... (see documentation)
%               'ramp' ('00')   : acceleration time, '00'=50ms, '01'=180ms, '02'=300ms, '03'=435ms, '04'=570ms, '05'=690ms, '06'=820ms,
%                                 '07'=950ms, '08'=1080ms ... (see documentation)
% 
% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  28-Jan-2010
% Edited May-2016 by Fabian Peckert -- E-mail: fabian.peckert@rwth-aachen.de

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

thisFuncStr  = [upper(mfilename) ':'];

%% check serial-connection
global serial_movtec;
if isempty(serial_movtec)
    ita_movtec_init;
end
%% check if initalized
global ita_xytable_init;
if isempty(ita_xytable_init)
   error([thisFuncStr 'Please execute a reference-move first!']); 
end
%% load global position variables
global ita_xytable_reference_x;
global ita_xytable_reference_y;

%% check input arguments
sArgs=struct('pos1_motor', 'string', 'pos2_displacement','numeric',...
    'wait',false, 'speed', 25, 'VST','01','speedR','01', 'ramp','01','check_posibility','true', 'steps',false);
[motor displacement sArgs] = ita_parse_arguments(sArgs,varargin);

%% determine if there should be a x- or y-movement
moveX=0;
moveY=0;
if strcmp(motor,'motor1') || strcmp(motor,'1') || ...
        strcmp(motor,'y') || strcmp(motor,'Y')
    moveY = 1;
elseif strcmp(motor,'motor2') || strcmp(motor,'2') || ...
        strcmp(motor,'x') || strcmp(motor,'X')
    moveX = 1;
else
    error([thisFuncStr 'Which motor should be moved?']);
end

%% calculate the displacment (mm to motor-steps)
if ~sArgs.steps
    if moveX
        steps = ita_movtec_xytable_steps2mm('x', displacement, ...
            'backwards',true, 'VST', sArgs.VST);
        % sArgs.speed='5'; WHY??
    end
    if moveY
        steps = ita_movtec_xytable_steps2mm('y', displacement, ...
            'backwards',true, 'VST', sArgs.VST);
        % sArgs.speed='5'; WHY??
    end
else
    steps=displacement;
end

%% calculate the ramp ~ speed
if moveY
    if sArgs.speed < 5
        sArgs.ramp = '00';
    elseif sArgs.speed < 10
        sArgs.ramp = '01';
    elseif sArgs.speed < 15
        sArgs.ramp = '02';
    elseif sArgs.speed < 25
        sArgs.ramp = '03';
    elseif sArgs.speed < 40
        sArgs.ramp = '04';
    elseif sArgs.speed < 60
        sArgs.ramp = '05';
    elseif sArgs.speed < 80
        sArgs.ramp = '06';
    else
        sArgs.ramp = '07';
    end
end
if moveX
   if sArgs.speed > 50
       sArgs.ramp = '02';
   end
end

%% set the displacment hex (motor-steps to hex)
if steps>0
    d = '00'; % positive Richtung
    stepsHex=dec2hex(steps,4);
elseif steps<0
    d = 'ff';   % negative Richtung
    stepsHex = dec2hex(2^16 + round(steps),4);
else
    ita_verbose_info([thisFuncStr 'Please specify a displacement!'],1);
    stepsHex=dec2hex(0,4);
    d = '00';
end

%% set the speed hex (speed [0-100%] to speedHex[0-128dec])
speedHex = dec2hex(ceil((sArgs.speed/100 * 127)+127));

%% setup connection to movtec
fclose(serial_movtec); %better to close first
fopen(serial_movtec);  %open port

%% set hex-command for x-movement
if moveX
    data_hex_V=['55';'0D';'0D';...
        % Motor 2
        %'24';'40';...                % Motor current
        '22';sArgs.speedR;...         % Velocity range
        '23';sArgs.ramp;...           % Ramp-acceleration
        '28';sArgs.VST;...            % Microsteps
        '33';speedHex;...             % Velocity
        %'2b';'04';...                % Einzelschrittvorgabe
        '32';stepsHex(3:4);stepsHex(1:2);d;...% n-Umdrehungen
        ];
    fwrite(serial_movtec,hex2dec('35'));    % kill old motorcommands
end

%% set hex-command for y-movement
if moveY
    data_hex_V=['55';'0D';'0D';...
        % Motor 1
        %'24';'40';...          % Einstellung des Motorstroms macht erstmal keinen Unterschied
        '02';sArgs.speedR;...         % Geschwindigkeitsbereich
        '03';sArgs.ramp;...           % Rampe-, Beschleunigungs-, Bremszeit
        '08';sArgs.VST;...            % Vollschrittteilung f. vorg. Soll-Position
        '13';speedHex;...       % Positioniergeschwindigkeit
        %'0b';'04';...          % Einzelschrittvorgabe
        '12';stepsHex(3:4);stepsHex(1:2);d;...
        ];
    fwrite(serial_movtec,hex2dec('15'));    % kill old motorcommands
end
data_dec_V = hex2dec(data_hex_V);

%% checks if movement could be done...
if sArgs.check_posibility
    x=ita_xytable_reference_x;
    y=ita_xytable_reference_y;
    if moveX
        if x+steps < 0 || x+steps > 17920
            ita_verbose_info([thisFuncStr 'This move would exceed Table dimensions'],0);
            varargout = {0};
            possible = 0;
        else
            ita_xytable_reference_x = ita_xytable_reference_x + steps;
            varargout = {1};
            possible = 1;
        end
    elseif moveY
        if y+steps < 0 || y+steps > 61826
            ita_verbose_info([thisFuncStr 'This move would exceed Table dimensions'],0);
            varargout = {0};
            possible = 0;
        else
            ita_xytable_reference_y = ita_xytable_reference_y + steps;
            varargout = {1};
            possible = 1;
        end
    end
end

%% execute move?!

if possible
    % sending the command to the movtec
    fwrite(serial_movtec,hex2dec('55'));
    pause(0.3)
    fwrite(serial_movtec,data_dec_V); %write to RS232
    
    % waiting to reach the position
    if sArgs.wait
        if moveX
            ita_movtec_xytable_wait('x')
        else
            ita_movtec_xytable_wait('y')
        end
    end
end
%EOF
end