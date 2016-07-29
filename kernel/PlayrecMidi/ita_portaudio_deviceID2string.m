function varargout = ita_portaudio_deviceID2string(varargin)
%ITA_PORTAUDIO_DEVICEID2STRING - TODO HUHU Documentation
%
%  Syntax: deviceName = ita_portaudio_deviceID2string(deviceID)
%       [deviceName deviceInfo] = ita_portaudio_deviceID2string(deviceID)
%
%   See also ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_portaudio_deviceID2string">doc ita_portaudio_deviceID2string</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  22-Apr-2009 

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_deviceID','numeric');
[deviceID,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<ASGLU>
hPlayRec = ita_playrec; %work with handle instead of directly calling playrec

%% ID2str
%tic
persistent Devices
if isempty(Devices)
    Devices = hPlayRec('getDevices');
end

DevInfo = squeeze(struct2cell(Devices));
DevIds = cellfun(@(x) cat(1,x),DevInfo(1,:));

if ~isempty(DevIds) && deviceID > -1 && deviceID <= max(DevIds)
    deviceInfo = Devices(DevIds == deviceID);
    deviceName = DevInfo{2,DevIds == deviceID};
else % empty device
    deviceInfo = [];
    deviceName = 'noDevice';
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    disp(['deviceName: ' deviceName]);
else
    varargout(1) = {deviceName};
    if nargout > 1
        varargout{2} = deviceInfo;
    end
end
%toc
%end function
end