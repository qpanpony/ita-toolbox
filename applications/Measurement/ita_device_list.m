function varargout = ita_device_list(mode,token,varargin)
% ITA_DEVICE_LIST - the ITA device List
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  PLEASE BE VERY CAREFUL WHEN EDITING THE DEVICE LIST
%   BY HAND, CONSULT PDI OR MMT BEFORE MAKING CHANGES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Syntax:
%   res = ita_device_list() returns all devices in a cell
%   res = ita_device_list(mode) returns all devices of this mode
%   res = ita_device_list(mode,'guilist') returns all string for GUIs
%   res = ita_device_list(mode,device_name) returns the sensitivity for
%   this device as itaValue
%
%   Options (default):
%           'mode' : ad / sensor / preamp
%
%  Example:
%   ita_device_list('sensor','guilist')
%   ita_device_list('ad','Multiface G1097_1')
%
%   Reference page in Help browser
%        <a href="matlab:doc itaTemplate">doc itaTemplate</a>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich - pdi@akustik.rwth-aachen.de

if nargin == 3
    hwch = varargin{1};
else
    hwch = 0;
end
name = '';

if nargin >= 1 && isa(mode,'itaMeasurementChainElements')
    % measurement chain element is coming in. probably due to a name reset
    MCE = mode;
    list = ita_device_list(); %get entire list
    [elementfound idx]      = ismember(MCE.name,list(:,1)); %find element
    if elementfound
        sens         = list{idx,2};
%         picModel     = ita_model2picture(list{idx,3});
        calibratable = list{idx,4};
        if calibratable == 0
            MCE.calibrated = -1;
        end
        oldCalib = MCE.calibrated;
        if ~any(strfind(MCE.type,'var'))
            MCE.sensitivity = sens;
            MCE.calibrated = oldCalib;
%             MCE.picModel    = picModel;
        end
    else
        ita_verbose_info('Element not in list',1);
    end
    
    
    varargout{1} = MCE;
    return
    
elseif nargin >= 1
    switch(lower(mode))
        case {'sensor','sensors'}
            ita_device = @ita_device_list_sensor;
        case 'ad'
            ita_device = @ita_device_list_ad;
        case {'preamp'}
            ita_device = @ita_device_list_preamp;
        case 'da'
            ita_device = @ita_device_list_da;
        case {'amp'}
            ita_device = @ita_device_list_amp;
        case 'actuator'
            ita_device = @ita_device_list_actuator;
            
        otherwise
            varargout{1} = []; %just return empty
            return
    end
    res = ita_device();
    res = ita_hwch(res,hwch);
else
    res = [ita_device_list_ad(); ita_device_list_preamp(); ita_device_list_sensor();...
        ita_device_list_da(); ita_device_list_amp(); ita_device_list_actuator()];
end

if nargin >= 2
    if strcmpi(token,'guilist') % generate a list for GUIs with '|'
        device = res;
        res = [];
        for idx = 1:size(device,1)
            res = [res '|[' device{idx,1} '] (' device{idx,2} ')']; %#ok<AGROW>
        end
        res = res(2:end);
    else % search for this element
        device = res;
        res    = [];
        start_idx = strfind(token,'[');
        end_idx   = strfind(token,']');
        if ~isempty(start_idx) && ~isempty(end_idx)
            token     = token(start_idx+1:end_idx-1); %get the name
        end
        name = token;
        for idx = 1:size(device,1)
            if strcmpi(token,device{idx,1})
                res = itaValue(device{idx,2});
                break
            end
        end
        start_idx = strfind(token,'(');
        end_idx   = strfind(token,')');
        if ~isempty(start_idx) && ~isempty(end_idx)
            res = itaValue(token(start_idx+1:end_idx-1));
        end
        if isempty(res)
            res = itaValue(-1);
            %             disp(['element not in list: ' token '.'])
        end
    end
end
varargout{1} = res;
if nargout == 2
    varargout{2} = name;
end
end %function

%% subfunction
function res_out = ita_hwch(res,hwch)
res_out = [];
if hwch %search for hwch in name string, only return reasonable objects
    for idx=1:size(res,1)
        token = res{idx,1};
        if any(strfind(token,['hwch' ita_angle2str(hwch,2)])) ||  ~any(strfind(token,'hwch'))
            res_out = [res_out; res(idx,:)]; %#ok<AGROW>
        end
    end
else
    res_out = res;
end

end

%% AD
function device = ita_device_list_ad()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};
end

%% PREAMP
function device = ita_device_list_preamp()
device = {};
device(end+1,:) = {'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};
end

%% SENSOR
function device = ita_device_list_sensor()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};
end

%% DA
function device = ita_device_list_da()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};
end

%% AMP
function device = ita_device_list_amp()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};
end

%% ACTUATORS
function device = ita_device_list_actuator()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};
end
