function varargout = ita_movtec_xytable_steps2mm(varargin)
%ITA_MOVTEC_XYTABLE_STEPS2MM - this function calculates the displacement in
% mm to a number of steps have to be done by the specified motor or other
% way.
%
%   Syntax:   steps = ita_movtec_xytable_steps2mm('motor', num, options)
%   Example:  steps = ita_movtec_xytable_steps2mm('x', 100, 'backwards',true);
%   Arguments:
%           'motor' could be 'x','X','2' or 'motor2' or 'y','Y','1' or
%               'motor1'
%           num is the number of steps or the displacement in mm
%   Options (default):
%           'backwards' (false)     : true or false, true means calculation from steps to mm
%           'VST' ('01')            : pitch, '01'=1, '02'=2, '04'=4, '08'=8, '10'=16, ... (see documentation)

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  03-Feb-2010
thisFuncStr  = [upper(mfilename) ':'];

sArgs=struct('pos1_motor', 'string', 'pos2_num', 'numeric', 'backwards', false, 'VST', '01');
sArgs=ita_parse_arguments(sArgs, varargin);

motor1=0;
motor2=0;

% important to know which motor is going to move!
if strcmp(sArgs.motor,'motor1') || strcmp(sArgs.motor,'1') || ...
        strcmp(sArgs.motor,'y') || strcmp(sArgs.motor,'Y')
    motor1= 1;
elseif strcmp(sArgs.motor,'motor2') || strcmp(sArgs.motor,'2') || ...
        strcmp(sArgs.motor,'x') || strcmp(sArgs.motor,'X')
    motor2 = 1;
end

if motor1           % 963 steps = 10mm; VST step-pitch
   if sArgs.backwards    % mm to steps
       varargout = {ceil(sArgs.num/10*963 * hex2dec(sArgs.VST))};
   else             % steps to mm
       varargout = {round(100*sArgs.num*10/963 / hex2dec(sArgs.VST))/100};
   end
elseif motor2       % 800 steps = 10mm; VST step-pitch
   if sArgs.backwards    % mm to steps
       varargout = {ceil(sArgs.num/10*800 * hex2dec(sArgs.VST))};
   else             % steps to mm
       varargout = {round(100*sArgs.num*10/800 / hex2dec(sArgs.VST))/100};
   end
else
    error([thisFuncStr 'Which motor you wanna  get moved?']);
end

%EOF
end