function varargout = ita_vibro_getPosition(varargin)
%ITA_VIBRO_GETPOSITION - gets the current laser position
%  This function gets the current laser position
%
%  Syntax:
%   audioObjOut = ita_vibro_getPosition()
%%
%  Example:
%   position = ita_vibro_getPosition()
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_vibro_getPosition">doc ita_vibro_getPosition</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-Jul-2013 


%% Initialization

global interface_serial;
if isempty(interface_serial)
    ita_vibro_init;
end

%% get the position and return it
resp = ita_vibro_sendCommand('PQ','interface');
parts = regexp(resp,',','split'); % split the angle values
phi = str2double(parts{1}(3:end));
theta = str2double(parts{2}(1:end-1));

output = [phi,theta];

%% Set Output
varargout(1) = {output};

%end function
end