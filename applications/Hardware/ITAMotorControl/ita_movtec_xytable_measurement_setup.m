function varargout = ita_movtec_xytable_measurement_setup(varargin)
%ITA_MOVTEC_XYTABLE_MEASSUREMENT_SETUP - this function prepares the
%   xy-table for measurement!
%   it triggers a reference-move first! afterwards its calibrating the
%   measurement middle (the point, where the mic is exactly positioned over
%   the source

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  29-Jan-2010
thisFuncStr  = [upper(mfilename) ':'];

% check serial-connection
global serial_movtec;
if isempty(serial_movtec)
    ita_movtec_init;
end

% check if xy-table is initalized
global ita_xytable_init;
if isempty(ita_xytable_init)
    disp([thisFuncStr 'Making referencemove first!']);
   ita_movtec_xytable_reference_move();
end

% initialize global calibration points
global ita_xytable_calibrated_x;
global ita_xytable_calibrated_y;
global ita_xytable_calibrated;
if isempty(ita_xytable_calibrated_x)
    ita_xytable_calibrated_x=0;
end
if isempty(ita_xytable_calibrated_y)
    ita_xytable_calibrated_y=0;
end
if isempty(ita_xytable_calibrated)
    ita_xytable_calibrated=false;
end

% TODO 
% go to the middle of the table and start fine-calibration gui
% make fine-calibration-gui x=112 y=321
% TODO Tisch genau ausmessen...
disp([thisFuncStr 'Please wait for calibration!']);

ita_movtec_xytable_measurement_setup_gui;

%EOF
end