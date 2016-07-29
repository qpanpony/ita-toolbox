function varargout = ita_vibro_findGoodSpot(varargin)
%ITA_VIBRO_FINDGOODSPOT - emulates the microsteps of newer laser-vibrometers
%  This function takes two serial objects as input arguments and searches
%  the vicinity of the current laser position until a stable signal level
%  is achieved.
%  The first serial object is the one that commmunicates with the laser
%  controller (the "big box" with the buttons), the second is for the
%  interface and moves the laser.
%  The function returns an error message if no acceptable position could be
%  found. Otherwise an empty string is returned.
%
%  default serial port settings: ('BaudRate',9600,'DataBits',8,'StopBits',1)
%  Call: errmessage = ita_vibro_findGoodSpot(controllerSerial,interfaceSerial)
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_unv2unv, ita_readunv58, ita_readunv2414, ita_writeunv58, ita_writeunv2414, ita_plot_surface, ita_deal_units, ita_impedance2apparementmass, ita_measurement_setup, ita_measurement_run, ita_RS232_ITAlian_init, ita_measurement_polar, ita_vibro_sendInterfaceCommand, ita_vibro_getSignalLevel.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_vibro_findGoodSpot">doc ita_vibro_findGoodSpot</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 25-Nov-2008 

%% Initialization
global controller_serial;
global interface_serial;
if isempty(controller_serial) || isempty(interface_serial)
    ita_vibro_init;
end

%% RS232 stuff
% try to open both serial ports if they're not open yet
if ~strcmp(controller_serial.Status,'open')
    fopen(controller_serial);
end

if ~strcmp(interface_serial.Status,'open')
    fopen(interface_serial);
end

if ~strcmp(controller_serial.Status,'open') || ~strcmp(interface_serial.Status,'open')
    error('ita_vibro_findGoodSpot::serial connections could not be opened');
end

%% Body
howLong  = 10; % #of recorded signal levels
levelVec = zeros(howLong,1);
for i=1:howLong % get the signal level every 0.1 seconds
    levelVec(i) = getSignalLevel();
    pause(0.1);
end
j = 0;
k = 1;
% the deviation of the signal levels should be smaller than 6 and
% the final level should at least be 5
while ((max(diff(levelVec(end-5:end)))>5) || (min(levelVec(end-5:end))<5)) && (j<5)
    j = j + 1;
    % move the laser to the four compass directions around the original spot
    commands = {['IX' num2str(k*0.01)],['DX' num2str(k*0.02)],['IX' num2str(k*0.01) ';IY' num2str(k*0.01)],['DY' num2str(k*0.02)],['IY' num2str(k*0.01)]};
    resp = ita_vibro_sendCommand(commands{j},'interface');
    if strcmp(resp(1),'*')
        for i=1:howLong % record the signal levels
            levelVec(i) = getSignalLevel();
            pause(0.1);
        end
    end
end
% if the final level is still too low, return error
if getSignalLevel() < 5
    result = 'could not find a good spot';
else
    result = '';
end
varargout(1) = {result}; 

%end function
end

%% subfunctions
% read out the signal level
function lev = getSignalLevel()
global controller_serial;
sent = ita_vibro_sendCommand('LEV','controller');
if sent
    lev = str2double(fgetl(controller_serial));
else
    lev = 0;
end
end