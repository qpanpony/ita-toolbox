function[varargout] = ita_movtec_xytable_reference_move()
%ITA_MOVTEC_XY-TABLE_REFERENCE_MOVE - this function moves the table in to
%   the reference-position
%
%   Syntax: ita_movetec_xytable_reference_move()

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  28-Jan-2010
% Edited May-2016 by Fabian Peckert -- E-mail: fabian.peckert@rwth-aachen.de

thisFuncStr  = [upper(mfilename) ':'];

global serial_movtec;
if isempty(serial_movtec)
    chk = ita_movtec_init;
    if chk == 0;
        varargout(1) = {0};
        ita_verbose_info([thisFuncStr ' Reference move unsuccesful'],0);
        return
    else serial_movtec = chk;
    end
end
global ita_xytable_init;
global ita_xytable_reference_x;
global ita_xytable_reference_y;

move_refx=['55';'0D';'0D';...
    % Motor 2 (x-direction)
    '28';'01';...               % microsteps
    '23';'01';...               % Ramp-acceleration (min, max) = (0F, 00)
    '26';'01';...               % Ramp internal(00) or external(01) (external recommended!)
    '36';'50';...               % Velocity: 50h -> 37.5% speed (max speed without running into emergency switch ;)
    '22';'01';...               % Velocity range
];

move_decx=hex2dec(move_refx);
fclose(serial_movtec);
fopen(serial_movtec);
fwrite(serial_movtec,hex2dec('35'));        % Kill old motor-commandos
%fwrite(s,hex2dec('55'));
pause(0.2); % prev: 0.3
fwrite(serial_movtec,move_decx);
pause(0.3); % prev: 0.5

move_refy=['55';'0D';'0D';...
    % Motor 1 (y-direction)
    '02';'01';...               % Velocity range
    '08';'01';...               % microsteps
    '03';'0F';...               % Ramp-acceleration (min, max) = (0F, 00)
    '06';'01';...               % Ramp internal(00) or external(01) (external recommended!)
    '16';'60';...               % Velocity: 60h -> 25% speed (max speed without running into emergency switch ;)
];

move_decy=hex2dec(move_refy);
fclose(serial_movtec);
fopen(serial_movtec);
fwrite(serial_movtec,hex2dec('15'));    % Kill old commandos
%fwrite(s,hex2dec('55'));
pause(0.2); % prev: 0.3
fwrite(serial_movtec,move_decy);
pause(0.3); % prev: 0.5
ita_movtec_xytable_wait('1');
ita_movtec_xytable_wait('2');

% to tell all the others, that finally... we are ready!
ita_xytable_init=true;
ita_xytable_reference_x=0;
ita_xytable_reference_y=0;
varargout(1) = {1};

% open setup GUI
% ita_movtec_xytable_measurement_setup_gui

%EOF
end
