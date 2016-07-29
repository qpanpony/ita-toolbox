function[] = ita_movtec_xytable_wait(varargin)
%ITA_MOVTEC_XY-TABLE_WAIT - this function should be used to wait for
%   completion of a move-command (see ita_movtec_xy-table_move).
%   You can wait for a specific motor or even both.
%
%   Syntax:   ita_movtec_xy-table_wait()
%             ita_movtec_xy-table_wait('motor1')
%             ita_movtec_xy-table_wait('motor2')
%   instead of 'motor1' or 'motor2' you can also use '2','x' or 'X'
%   (equals Motor2) and '1', 'y' or 'Y' (equals Motor1)

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  28-Jan-2010
thisFuncStr  = [upper(mfilename) ':'];

% check serial-connection
global serial_movtec;
if isempty(serial_movtec)
    ita_movtec_init;
end

% check input arguments
narginchk(0,2);
checkX = 0;
checkY = 0;
if nargin == 1
    if strcmp(varargin{1},'motor1') || strcmp(varargin{1},'1') || ...
            strcmp(varargin{1},'y') || strcmp(varargin{1},'Y')
        checkY = 1;
    end
    if strcmp(varargin{1},'motor2') || strcmp(varargin{1},'2') || ...
            strcmp(varargin{1},'x') || strcmp(varargin{1},'X')
        checkX = 1;
    end
else
    checkX = 1;
    checkY = 1;
end

fclose(serial_movtec);
fopen(serial_movtec);

idx = 1;
ita_verbose_info([thisFuncStr 'Waiting for table to reach position...'],1);

if checkX
    % checks moving of Motor2 (x-direction)
    X_status = '0000000';
    while ~strcmp(X_status, '10001111') && ~strcmp(X_status, '10001011') 
        pause(0.3)
        idx = idx +1;
        fwrite(serial_movtec,hex2dec('31'));
        pause(0.1);
        X_status=ita_angle2str(dec2bin(fread(serial_movtec,1)),8);
        ita_verbose_info([thisFuncStr 'x-motor answered with:   ' X_status],2);
    end
end
if checkY
    % checks moving of Motor1 (y-direction)
    Y_status = '0000000';
    while ~strcmp(Y_status, '10001111') && ~strcmp(Y_status, '10001011')
        pause(0.3)
        idx = idx +1;
        fwrite(serial_movtec,hex2dec('11'));
        pause(0.1);
        Y_status=ita_angle2str(dec2bin(fread(serial_movtec,1)),8);
        ita_verbose_info([thisFuncStr 'y-motor answered with:   ' Y_status],2);
    end
end
ita_verbose_info([thisFuncStr 'Table position is reached'],1);
%pause(0.3);
%ita_movtec_xytable_getPosition;
%EOF
end