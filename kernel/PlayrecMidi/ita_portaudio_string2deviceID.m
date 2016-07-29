function varargout = ita_portaudio_string2deviceID(varargin)
%ITA_PORTAUDIO_STRING2DEVICEID - Return AudioDeviceID and DeviceInfos for a device name
%
%  Syntax: deviceID = ita_portaudio_string2deviceID(deviceName)
%       [deviceID deviceInfo] = ita_portaudio_string2deviceID(deviceName)
%
%   See also ita_portaudio, ita_portaudio_deviceID2struct, ita_preferences
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_portaudio_string2deviceID">doc ita_portaudio_string2deviceID</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  22-Apr-2009

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_string','char');
[string,sArgs] = ita_parse_arguments(sArgs,varargin); 

hPlayRec = ita_playrec; %work with handle instead of directly calling playrec

%% get Device list
persistent Devices
if isempty(Devices)
    Devices = hPlayRec('getDevices');
end

DevInfo = squeeze(struct2cell(Devices));
DevNames = DevInfo(2,:);
foundIds = find(cellfun(@(x) strcmpi(x,string),DevNames));

if ~isempty(foundIds)
    if numel(foundIds) > 1
        error('Multiple devices found, please be more specific');
    else
        deviceInfo = Devices(foundIds);
        deviceID = DevInfo{1,foundIds};
    end
else
    deviceID   = -1;
    % Warning
    ita_verbose_info('No device with that name found',0);
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    disp(['deviceID: ' int2str(deviceID)]);
else
    varargout(1) = {deviceID};
    if nargout > 1
        varargout{2} = deviceInfo;
    end
end

%end function
end