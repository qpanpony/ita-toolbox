function varargout = ita_vibro_getLaserSensitivity()
%ITA_VIBRO_GETLASERSENSITIVITY - determine laser sensitivity
%  This function takes a serial object as input and returns an object of
%  type itaValue as the sensitivity with unit V/V.
%
%  Syntax:
%   itaValue = ita_vibro_getLaserSensitivity()
%
%  Example:
%   s = ita_vibro_getLaserSensitivity()
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_vibro_getLaserSensitivity">doc ita_vibro_getLaserSensitivity</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  08-Jan-2010 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialize
global controller_serial;
if isempty(controller_serial)
    ita_vibro_init;
end

%% 'sens' is an itaValue and is given back
% send a command to the laser controller and get the response
sent = ita_vibro_sendCommand('VELO?','controller');
if sent
    resp = fgetl(controller_serial);
    switch length(resp)
        case 1
%             resp = '8';
            velo = resp;
        case 5
%             resp = 'VELO8';
            velo = resp(5);
        otherwise
            error([thisFuncStr 'got no response from the laser controller']);
    end
else
    error([thisFuncStr 'could not send the command to the laser controller']);
end

% range setting
switch velo
    case '1' % 50 mm/s
        range = 0.05;
    case '6' % 100 mm/s
        range = 0.1;
    case '7' % 250 mm/s
        range = 0.25;
    case '8' % 1250 mm/s
        range = 1.25;
    otherwise
        error([thisFuncStr 'incorrect range value']);
end
% 10 Volt is the full scale value
vFullScale = 10;
sens = vFullScale/range;

%% Set Output
varargout(1) = {sens}; 

%end function
end