function varargout = ita_movtec_getPosition(varargin)
%ITA_MOVTEC_GETPOSITION - returns the position of motor1 and motor2 in
%   steps.
%
%   Syntax: [stepsMotor1, stepsMotor2]= ita_movtec_getPosition
%           [y, x]= ita_movtec_getPosition
%           stepsMotor1 = ita_movtec_xytable_getPosition('getPos1', true,...
%                           'getPos2',false)
%           stepsMotor2 = ita_movtec_xytable_getPosition('getPos2', true,...
%                           'getPos1',false)
%   optional arguments:
%           'serial_obj', serial_obj    % if not given, try to use a global
%           serial_obj (global serial_movtec, created by func:ita_movtec_init)
%           'getPos1', bool             % defaultvalue: true
%           'getPos2', bool             % defaultvalue: true

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  02-Feb-2010
thisFuncStr  = [upper(mfilename) ':'];

% check input arguments
sArgs=struct('getPos1',true,'getPos2',true, 'serial_movtec', 'anything');
sArgs=ita_parse_arguments(sArgs,varargin);
if ischar(sArgs.serial_movtec)
    global serial_movtec;
    if isempty(serial_movtec)
        ita_movtec_init;
    end
else
    serial_movtec=sArgs.serial_movtec;
end

if sArgs.getPos2
    fwrite(serial_movtec,hex2dec('30'));    % command to get position from motor2
    pause(0.2)
    fwrite(serial_movtec,hex2dec('30'));    % have to be send twice
    pause(0.5)
    pos2=fread(serial_movtec,2);
    pos2= hex2dec([dec2hex(pos2(2)) dec2hex(pos2(1))]);
end
% between the commands a small pause is required
if sArgs.getPos1 && sArgs.getPos2
    pause(0.5)
end

if sArgs.getPos1
    fwrite(serial_movtec,hex2dec('10'));    % command to get position from motor1
    pause(0.1)
    fwrite(serial_movtec,hex2dec('10'));    % have to be send twice
    pause(0.2)
    pos1=fread(serial_movtec,2);
    pos1= hex2dec([dec2hex(pos1(2)) dec2hex(pos1(1))]);
end

if sArgs.getPos1 && sArgs.getPos2
    if (nargout==1) || nargout > 2 
        error([thisFuncStr 'Check number of your output arguments!']);
    elseif nargout == 2 
        varargout= [{pos1} {pos2}];
    else
        disp(['The x-position is: ' num2str(pos2)]);
        disp(['The y-position is: ' num2str(pos1)]); 
    end
elseif sArgs.getPos1
    if nargout > 1
        error([thisFuncStr 'Check number of your output arguments!']);
    elseif nargout == 1
        varargout = {pos1};
    else
        disp(['The y-position is: ' num2str(pos1)]);
    end
elseif sArgs.getPos2
    if nargout > 1
        error([thisFuncStr 'Check number of your output arguments!']);
    elseif nargout == 1
        varargout= {pos2};
    else
        disp(['The x-position is: ' num2str(pos2)]);
    end
end

%EOF
end