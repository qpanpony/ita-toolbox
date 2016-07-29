function varargout = ita_vibro_moveTo(varargin)
%ITA_VIBRO_MOVETO - move laser to phi and theta positions
%  This function takes two angles as input and moves the laser accordingly.
%  Angles cannot be larger than 20.00 degrees!
%  Positive values go up, negative ones go down.
%
%  Syntax:
%   string = ita_vibro_moveTo(double,double)
%
%  Example:
%   sent = ita_vibro_moveTo(13.53,-7.45)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_vibro_moveTo">doc ita_vibro_moveTo</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  26-Jul-2013


%% Initialization and Input Parsing
sArgs        = struct('pos1_phi','double', 'pos2_theta', 'double');
[phi,theta] = ita_parse_arguments(sArgs,varargin);

%% send command to laser
command = 'ZB;'; % move the laser to the origin
% create the commands, maximum deflection angle is 10 degrees, split
% for larger values
if phi < 0
    if phi < -10
        command = [command 'DX10.00;DX' num2str(-phi-10,'%.2f') ';']; %#ok<*AGROW>
    else
        command = [command 'DX' num2str(-phi,'%.2f') ';'];
    end
elseif phi > 0
    if phi > 10
        command = [command 'IX10.00;IX' num2str(phi-10,'%.2f') ';'];
    else
        command = [command 'IX' num2str(phi,'%.2f') ';'];
    end
else
    command = [command 'ZX';];
end
if theta < 0
    if theta < -10
        command = [command 'DY10.00;DY' num2str(-theta-10,'%.2f')];
    else
        command = [command 'DY' num2str(-theta,'%.2f')];
    end
elseif theta > 0
    if theta > 10
        command = [command 'IY10.00;IY' num2str(theta-10,'%.2f')];
    else
        command = [command 'IY' num2str(theta,'%.2f')];
    end
else
    command = [command 'ZY';];
end

sent = ita_vibro_sendCommand(command,'interface');

%% Set Output
varargout(1) = {sent};

%end function
end