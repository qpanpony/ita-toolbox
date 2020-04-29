function varargout = ita_device_list_ITA(mode,token,varargin)
% ITA_DEVICE_LIST - the ITA device List
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  PLEASE BE VERY CAREFUL WHEN EDITING THE DEVICE LIST BY HAND, PLEASE 
%  CONSULT THE ITA-TOOLBOX DEVELOPER TEAM BEFORE MAKING ANY CHANGES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


if nargin == 3
    hwch = varargin{1};
else
    hwch = 0;
end
name = '';

if nargin >= 1 && isa(mode,'itaMeasurementChainElements')
    % measurement chain element is coming in. probably due to a name reset
    MCE = mode;
    devHandle = ita_device_list_handle;
    list = devHandle(); %get entire list
    [elementfound, idx]      = ismember(MCE.name,list(:,1)); %find element
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
        ita_verbose_info(['Element not found in the device list: ', MCE.name], 1);
    end
    
    
    varargout{1} = MCE;
    return
    
elseif nargin >= 1
    switch(lower(mode))
        case {'sensor','sensors'}
            ita_device = @ita_device_list_sensor;
        case 'ad'
            ita_device = @ita_device_list_ad;
        case {'preamp','preamp_robo_fix'}
            ita_device = @ita_device_list_preamp;
        case 'da'
            ita_device = @ita_device_list_da;
        case {'amp','amp_robo_fix'}
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
            name = token(start_idx+1:end_idx-1); %get the name
        else
            name = token;
        end
        for idx = 1:size(device,1)
            if strcmpi(name,device{idx,1})
                res = itaValue(device{idx,2});
                break
            end
        end
        if isempty(res)
            ita_verbose_info(['Element not found in the device list: ', token], 1)
            start_idx = strfind(token,'(');
            end_idx   = strfind(token,')');  
            if ~isempty(start_idx) && ~isempty(end_idx)
                res = itaValue(token(start_idx+1:end_idx-1));
            else
                res = itaValue(-1);
            end
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

device(end+1,:) = { 'MultiRoboFace1_hwch01','0.18134 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch02','0.19199 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch03','0.19065 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch04','0.19312 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch05','0.19094 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch06','0.19218 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch07','0.19115 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch08','0.19182 1/V','multiface',1};

device(end+1,:) = { 'MultiRoboFace3_hwch01','0.1913 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch02','0.1912 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch03','0.1921 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch04','0.1918 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch05','0.1925 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch06','0.1917 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch07','0.1922 1/V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch08','0.1915 1/V','multiface',1};

device(end+1,:) = { 'Multiface Rack_hwch01','0.2 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch02','0.2 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch03','0.2 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch04','0.2 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch05','0.2 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch06','0.2 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch07','0.2 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch08','0.2 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch11','1 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch12','1 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch13','1 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch14','1 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch15','1 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch16','1 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch17','1 1/V','multiface',1};
device(end+1,:) = { 'Multiface Rack_hwch18','1 1/V','multiface',1};

device(end+1,:) = { 'PreSonus Firebox PDI_hwch01-PotiLeft @ 2Hz','0.0897 1/V','firebox',1};
device(end+1,:) = { 'RME ADI-8 QS G1121 hwch01','0.5615 1/V','none',1};
device(end+1,:) = { 'RME ADI-8 QS G1121 hwch02','0.56044 1/V','none',1};
device(end+1,:) = { 'RME ADI-8 QS G1121 hwch03','0.56022 1/V','none',1};

device(end+1,:) = { 'FireRobo1_hwch03','0.12106 1/V','firebox',1};
device(end+1,:) = { 'FireRobo1_hwch04','0.12067 1/V','firebox',1};

device(end+1,:) = { 'FireRobo2_hwch03','0.11205 1/V','firebox',1};
device(end+1,:) = { 'FireRobo2_hwch04','0.11104 1/V','firebox',1};

device(end+1,:) = { 'FireRobo3_hwch03','0.111 1/V','firebox',1};
device(end+1,:) = { 'FireRobo3_hwch04','0.11131 1/V','firebox',1};

device(end+1,:) = { 'FireRobo4_hwch03','0.11924 1/V','firebox',1};
device(end+1,:) = { 'FireRobo4_hwch04','0.11889 1/V','firebox',1};

device(end+1,:) = { 'FireRobo5_hwch03','0.11084 1/V','firebox',1};
device(end+1,:) = { 'FireRobo5_hwch04','0.11194 1/V','firebox',1};

device(end+1,:) = { 'PreSonus FP10 hwch01','1 1/V','firebox',1};
device(end+1,:) = { 'PreSonus FP10 hwch02','1 1/V','firebox',1};
device(end+1,:) = { 'PreSonus FP10 hwch03','1 1/V','firebox',1};
device(end+1,:) = { 'PreSonus FP10 hwch04','1 1/V','firebox',1};
device(end+1,:) = { 'PreSonus FP10 hwch05','1 1/V','firebox',1};
device(end+1,:) = { 'PreSonus FP10 hwch06','1 1/V','firebox',1};
device(end+1,:) = { 'PreSonus FP10 hwch07','1 1/V','firebox',1};
device(end+1,:) = { 'PreSonus FP10 hwch08','1 1/V','firebox',1};

device(end+1,:) = { 'Hoertnix Fireface_hwch01','0.285 1/V','fireface',1};
device(end+1,:) = { 'Hoertnix Fireface_hwch02','0.285 1/V','fireface',1};
device(end+1,:) = { 'Hoertnix Fireface_hwch03','0.199 1/V','fireface',1};
device(end+1,:) = { 'Hoertnix Fireface_hwch04','0.199 1/V','fireface',1};
device(end+1,:) = { 'Hoertnix Fireface_hwch05','0.201 1/V','fireface',1};
device(end+1,:) = { 'Hoertnix Fireface_hwch06','0.201 1/V','fireface',1};
device(end+1,:) = { 'Hoertnix Fireface_hwch07','0.201 1/V','fireface',1};
device(end+1,:) = { 'Hoertnix Fireface_hwch08','0.201 1/V','fireface',1};
end

%% PREAMP
function device = ita_device_list_preamp()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};

device(end+1,:) = { 'BK Type 2610','1 ','preamp_var',1};
device(end+1,:) = { 'BK Type 2610 @ 2Hz +40 dB  SN:1501530 hwch01','31.2','bk_pressure',1};

device(end+1,:) = { 'Aurelio hwch01','0.72306 1/V','aurelio',1};
device(end+1,:) = { 'Aurelio hwch02','0.71748 1/V','aurelio',1};
device(end+1,:) = { 'Aurelio hwch03','0.72258 1/V','aurelio',1};
device(end+1,:) = { 'Aurelio hwch04','0.72022 1/V','aurelio',1};

device(end+1,:) = { 'ModulITA RAR3 hwch01','0.72306 1/V','modulita',1};
device(end+1,:) = { 'ModulITA RAR3 hwch02','0.71748 1/V','modulita',1};
device(end+1,:) = { 'ModulITA RAR3 hwch03','0.72258 1/V','modulita',1};
device(end+1,:) = { 'ModulITA RAR3 hwch04','0.72022 1/V','modulita',1};

device(end+1,:) = { 'ModulITA HALL1 hwch01','0.72426 1/V','modulita',1};
device(end+1,:) = { 'ModulITA HALL1 hwch02','0.72515 1/V','modulita',1};
device(end+1,:) = { 'ModulITA HALL1 hwch03','0.72535 1/V','modulita',1};
device(end+1,:) = { 'ModulITA HALL1 hwch04','0.72433 1/V','modulita',1};

device(end+1,:) = { 'MultiRoboFace1_Preamp_hwch01','4.5103 ','robo',1};
device(end+1,:) = { 'MultiRoboFace1_Preamp_hwch02','4.4894 ','robo',1};

device(end+1,:) = { 'MultiRoboFace3_Preamp_hwch01','4.3195 ','robo',1};
device(end+1,:) = { 'MultiRoboFace3_Preamp_hwch02','4.3094 ','robo',1};

device(end+1,:) = { 'FireRob1_Preamp_hwch01_Poti30','28.4491 ','firebox',1};
device(end+1,:) = { 'FireRob1_Preamp_hwch02_Poti30','28.7118 ','firebox',1};
device(end+1,:) = { 'FireRobo1_Preamp_hwch03','4.4682 ','robo',1};
device(end+1,:) = { 'FireRobo1_Preamp_hwch04','4.3907 ','robo',1};

device(end+1,:) = { 'FireRob2_Preamp_hwch01_Poti30','25.1647 ','firebox',1};
device(end+1,:) = { 'FireRob2_Preamp_hwch02_Poti30','25.1058 ','firebox',1};
device(end+1,:) = { 'FireRobo2_Preamp_hwch03','4.4166 ','robo',1};
device(end+1,:) = { 'FireRobo2_Preamp_hwch04','4.3855 ','robo',1};

device(end+1,:) = { 'FireRob3_Preamp_hwch01_Poti30','25.5466 ','firebox',1};
device(end+1,:) = { 'FireRob3_Preamp_hwch02_Poti30','25.5138','firebox',1};
device(end+1,:) = { 'FireRobo3_Preamp_hwch03','4.3116 ','robo',1};
device(end+1,:) = { 'FireRobo3_Preamp_hwch04','4.3406 ','robo',1};

device(end+1,:) = { 'FireRob4_Preamp_hwch01_Poti30','26.4287 ','firebox',1};
device(end+1,:) = { 'FireRob4_Preamp_hwch02_Poti30','26.4438','firebox',1};
device(end+1,:) = { 'FireRobo4_Preamp_hwch03','4.3755 ','robo',1};
device(end+1,:) = { 'FireRobo4_Preamp_hwch04','3.9835 ','robo',1};

device(end+1,:) = { 'FireRob5_Preamp_hwch01_Poti30','24.6022 ','firebox',1};
device(end+1,:) = { 'FireRob5_Preamp_hwch02_Poti30','24.8596 ','firebox',1};
device(end+1,:) = { 'FireRobo5_Preamp_hwch03','4.5012 ','robo',1};
device(end+1,:) = { 'FireRobo5_Preamp_hwch04','4.3953 ','robo',1};

device(end+1,:) = { 'Robo Rack hwch01','4.4876 ','robo',1};
device(end+1,:) = { 'Robo Rack hwch02','4.4742 ','robo',1};

device(end+1,:) = { 'Robo G1051 iCH01','4.4948 ','robo',1};
device(end+1,:) = { 'Robo G1051 iCH02','4.4852 ','robo',1};

device(end+1,:) = { 'BK Nexus G0932 - ID: 2049653 iCH1','','nexus',0};
device(end+1,:) = { 'BK Nexus G0932 - ID: 2049653 iCH2','','nexus',0};
device(end+1,:) = { 'BK Nexus G0933 - ID: 2172853 iCH1','','nexus',0};
device(end+1,:) = { 'BK Nexus G0933 - ID: 2172853 iCH2','','nexus',0};
device(end+1,:) = { 'BK Nexus G0933 - ID: 2172853 iCH3','','nexus',0};
device(end+1,:) = { 'BK Nexus G0933 - ID: 2172853 iCH4','','nexus',0};
device(end+1,:) = { 'BK Nexus G0934 - ID: 2192235 iCH1','','nexus',0};
device(end+1,:) = { 'BK Nexus G0934 - ID: 2192235 iCH2','','nexus',0};
device(end+1,:) = { 'BK Nexus G0934 - ID: 2192235 iCH3','','nexus',0};
device(end+1,:) = { 'BK Nexus G0934 - ID: 2192235 iCH4','','nexus',0};
device(end+1,:) = { 'BK Nexus G1098 - ID: 2645327 iCH1','','nexus',0};
device(end+1,:) = { 'BK Nexus G1098 - ID: 2645327 iCH2','','nexus',0};
device(end+1,:) = { 'BK Nexus G1098 - ID: 2645327 iCH3','','nexus',0};
device(end+1,:) = { 'BK Nexus G1098 - ID: 2645327 iCH4','','nexus',0};

device(end+1,:) = { 'Hoertnix Preamp_hwch01','7.81 V/V','none',1};
device(end+1,:) = { 'Hoertnix Preamp_hwch02','7.80 V/V','none',1};
device(end+1,:) = { 'Hoertnix Preamp_hwch03','9.54 V/V','none',1};
device(end+1,:) = { 'Hoertnix Preamp_hwch04','9.52 V/V','none',1};
device(end+1,:) = { 'Hoertnix Preamp_hwch05','9.28 V/V','none',1};
device(end+1,:) = { 'Hoertnix Preamp_hwch06','9.28 V/V','none',1};
device(end+1,:) = { 'Hoertnix Preamp_hwch07','9.33 V/V','none',1};
device(end+1,:) = { 'Hoertnix Preamp_hwch08','9.30 V/V','none',1};

device(end+1,:) = { 'OctaMic Rack_hwch01','0.30197 1/V','none',1};
device(end+1,:) = { 'OctaMic Rack_hwch02','5.9516 1/V','none',1};
device(end+1,:) = { 'OctaMic Rack_hwch03','5.6644 1/V','none',1};
device(end+1,:) = { 'OctaMic Rack_hwch04','4.4929 1/V','none',1};
device(end+1,:) = { 'OctaMic Rack_hwch05','5.399 1/V','none',1};
device(end+1,:) = { 'OctaMic Rack_hwch06','4.9983 1/V','none',1};
end


%% SENSOR
function device = ita_device_list_sensor()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};
device(end+1,:) = { 'empty','1 V/1','group',1};

device(end+1,:) = { 'BK mic 1/2 4190 SN 2522103','0.047 V/Pa','bk_pressure',1};

device(end+1,:) = { 'BK Mic 1/2 4190 G1064','0.051367 V/Pa','bk_pressure',1};
device(end+1,:) = { 'BK Mic 1/2 4190 SN2152127','0.0558 V/Pa','bk_pressure',1};

device(end+1,:) = { 'BK mic 1/1 4146 SN256882 @2 Hz','0.0043683 V/Pa','bk_pressure',1};
device(end+1,:) = { 'BK mic 1/1 4145 SN271115','0.060237 V/Pa','bk_pressure',1};
device(end+1,:) = { 'BK mic 1/1 4145 SN565104','0.07 V/Pa','bk_pressure',1};
device(end+1,:) = { 'BK mic 1/1 4131 SN191435','0.039016 V/Pa','bk_pressure',1};
device(end+1,:) = { 'BK mic 1/1 4131 SN49250','0.0666 V/Pa','bk_pressure',1};

device(end+1,:) = { 'GRAS Mic 1/4 40BF SN113026','0.0034 V/Pa','none',1};
device(end+1,:) = { 'GRAS Mic 1/4 40BF SN113028','0.0035 V/Pa','none',1};
device(end+1,:) = { 'GRAS Mic 1/4 40BF SN141768','0.0033 V/Pa','none',1};
device(end+1,:) = { 'GRAS Mic 1/4 40BP SN20033','0.00158 V/Pa','none',1};

device(end+1,:) = { 'GRAS Mic 1/2 40HL SN192584','0.9373 V/Pa','none',1};

device(end+1,:) = { 'Laser Doppler Vibrometer','1 V s/m','vibrometer',0};

device(end+1,:) = { 'F8200 SN75','4.11e-3 V/N','force',1};
device(end+1,:) = { 'F8200 SN71','3.82e-3 V/N','force',1};
device(end+1,:) = { 'F8200 SN84','3.73e-3 V/N','force',1};
device(end+1,:) = { 'F8200 SN60','3.83e-3 V/N ','force',1};

device(end+1,:) = { 'A4397 SN14','0.001009 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4397 SN41','0.0009939 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4397 SN42','0.0009898 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4397 SN53','0.001008 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4507 SN73','0.00989 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4508 SN14','0.01015 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4344 57','0.0002244 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4344 77','0.0002 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4506 X','0.01033 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4506 Y','0.01032 V s^2/m','acceleration',1};
device(end+1,:) = { 'A4506 Z','0.01019 V s^2/m','acceleration',1};

device(end+1,:) = { 'KE4-S04-001','0.0084578 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-002','0.009953 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-003','0.009744 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-004','0.011052 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-005','0.010305 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-006','0.011208 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-007','0.010856 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-008','0.010199 V/Pa','ke4',1};

device(end+1,:) = { 'KE4-S04-009','0.010204 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-010','0.0094113 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-011','0.010603 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-012','0.010827 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-013','0.010805 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-014','0.009572 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-015','0.011261 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-016','0.012421 V/Pa','ke4',1};

device(end+1,:) = { 'KE4-S04-017','0.011847 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-018','0.007800 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-019','0.0098405 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-020','0.0097724 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-021','0.010889 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-022','0.011227 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-023','0.010242 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-024','0.01151 V/Pa','ke4',1};

device(end+1,:) = { 'KE4-S04-025','0.011392 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-026','0.0088155 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-027','0.011807 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-028','0.011216 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-029','0.0127 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-030','0.011527 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-031','0.012397 V/Pa','ke4',1};
device(end+1,:) = { 'KE4-S04-032','0.0093325 V/Pa','ke4',1};

device(end+1,:) = { 'KE4 S04-034','0.0050569 V/Pa','ke4',1};

device(end+1,:) = { 'KE4 v2 mic1','0.0081 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 v2 mic2','0.0067 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 v2 mic3','0.0080 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 v2 mic4','0.008 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 v2 mic5','0.0078 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 v2 mic6','0.0069 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 v2 mic7','0.0068 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 v2 mic8','0.0078 V/Pa','ke4',1};

device(end+1,:) = { 'KE4 reverberation chamber yellow','0.01099 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 reverberation chamber orange','0.01353 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 reverberation chamber green','0.01177 V/Pa','ke4',1};
device(end+1,:) = { 'KE4 reverberation chamber blue','0.01107 V/Pa','ke4',1};

device(end+1,:) = { 'In Ear KE4 left','0.01238 V/Pa','ke4',1};
device(end+1,:) = { 'In Ear KE4 right','0.01110 V/Pa','ke4',1};

% the following values are measured using the B&K type 4231 sound
% calibrator in combination with the adapter suitable for the Schoeps CCM 2 H capsules
device(end+1,:) = { 'ITA-KK Analog left - calibrator','0.014864 V/Pa','schoeps',1};
device(end+1,:) = { 'ITA-KK Analog right - calibrator','0.016071 V/Pa','schoeps',1};

% the following values are based on free-field measurements in the semi-anechoic
% chamber @2m distance using the substitution method (K&H O110 D -> Schoeps CCM 2 H / B&K free field microphone)
device(end+1,:) = { 'ITA-KK Analog left - free-field meas','0.014646 V/Pa','schoeps',1};
device(end+1,:) = { 'ITA-KK Analog right - free-field meas','0.01548 V/Pa','schoeps',1};

device(end+1,:) = { 'ITA-KK Digital left','0.015 V/Pa','schoeps',1};
device(end+1,:) = { 'ITA-KK Digital right','0.015 V/Pa','schoeps',1};

device(end+1,:) = { 'ITA-KK KE4 ScienceTruck left','1 ','ke4',0};
device(end+1,:) = { 'ITA-KK KE4 ScienceTruck right','1 ','ke4',0};

device(end+1,:) = { 'ITA-KK KE4 Child left','0.0091581 V/Pa','ke4',0};
device(end+1,:) = { 'ITA-KK KE4 Child right','0.0098573 V/Pa','ke4',0};

device(end+1,:) = { 'Neumann-KK left','1 V/Pa','schoeps',1};
device(end+1,:) = { 'Neumann-KK right','1 V/Pa','schoeps',1};

% values are taken from calibration sheets by DKD (Deutscher
% Kalibrierdienst)
device(end+1,:) = { 'GRAS Headphone Testfixture Left','0.01211 V/Pa','RA0401',1};
device(end+1,:) = { 'GRAS Headphone Testfixture Right','0.0124 V/Pa','RA0401',1};

device(end+1,:) = { 'HEAD HMS III with ear simulator - IEC 711','0.01165 V/Pa','none',0};

device(end+1,:) = { 'Hoertnix BTE right front_hwch01','0.0159 V/Pa','none',1};
device(end+1,:) = { 'Hoertnix BTE right back_hwch02','0.0160 V/Pa','none',1};
device(end+1,:) = { 'Hoertnix ITC right back_hwch03','0.0173 V/Pa','none',1};
device(end+1,:) = { 'Hoertnix ITC right front_hwch04','0.0180 V/Pa','none',1};
device(end+1,:) = { 'Hoertnix BTE left front_hwch05','0.0140 V/Pa','none',1};
device(end+1,:) = { 'Hoertnix BTE left back_hwch06','0.0146 V/Pa','none',1};
device(end+1,:) = { 'Hoertnix ITC left back_hwch07','0.0156 V/Pa','none',1};
device(end+1,:) = { 'Hoertnix ITC left front_hwch08','0.0164 V/Pa','none',1};

device(end+1,:) = { 'AKG C451 E - CK4 No310 707G','0.005 V/Pa','none',0};

end

%% DA
function device = ita_device_list_da()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};

device(end+1,:) = { 'MultiRoboFace1_hwch01','4.8427 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch02','4.8210 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch03','4.8540 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch04','4.8450 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch05','4.8357 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch06','4.8422 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch07','4.8271 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace1_hwch08','4.8441 V','multiface',1};

device(end+1,:) = { 'MultiRoboFace3_hwch01','4.8543 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch02','4.8697 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch03','4.8820 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch04','4.8711 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch05','4.8805 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch06','4.8646 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch07','4.8577 V','multiface',1};
device(end+1,:) = { 'MultiRoboFace3_hwch08','4.8748 V','multiface',1};

device(end+1,:) = { 'Multiface Rack hwch01','4.8156 V','multiface',1};
device(end+1,:) = { 'Multiface Rack hwch02','4.7919 V','multiface',1};
device(end+1,:) = { 'Multiface Rack hwch03','4.8105 V','multiface',1};
device(end+1,:) = { 'Multiface Rack hwch04','4.8188 V','multiface',1};
device(end+1,:) = { 'Multiface Rack hwch05','4.8206 V','multiface',1};
device(end+1,:) = { 'Multiface Rack hwch06','4.8014 V','multiface',1};
device(end+1,:) = { 'Multiface Rack hwch07','4.8171 V','multiface',1};
device(end+1,:) = { 'Multiface Rack hwch08','1.3468 V','multiface',1}; % check this

device(end+1,:) = { 'Behringer ADA8000 Rack hwch11','6.5753 V','multiface',1};
device(end+1,:) = { 'Behringer ADA8000 Rack hwch12','6.5816 V','multiface',1};
device(end+1,:) = { 'Behringer ADA8000 Rack hwch13','6.5805 V','multiface',1};
device(end+1,:) = { 'Behringer ADA8000 Rack hwch14','6.6103 V','multiface',1};
device(end+1,:) = { 'Behringer ADA8000 Rack hwch15','6.5407 V','multiface',1};
device(end+1,:) = { 'Behringer ADA8000 Rack hwch16','6.5915 V','multiface',1};
device(end+1,:) = { 'Behringer ADA8000 Rack hwch17','6.5821 V','multiface',1};
device(end+1,:) = { 'Behringer ADA8000 Rack hwch18','6.6138 V','multiface',1};

device(end+1,:) = { 'Multiface G1049_hwch01','4.8706 V','multiface',1};
device(end+1,:) = { 'Multiface G1049_hwch02','4.8722 V','multiface',1};
device(end+1,:) = { 'Multiface G1049_hwch03','4.8479 V','multiface',1};
device(end+1,:) = { 'Multiface G1049_hwch04','4.8986 V','multiface',1};
device(end+1,:) = { 'Multiface G1049_hwch05','4.8502 V','multiface',1};
device(end+1,:) = { 'Multiface G1049_hwch06','4.8744 V','multiface',1};
device(end+1,:) = { 'Multiface G1049_hwch07','4.8352 V','multiface',1};
device(end+1,:) = { 'Multiface G1049_hwch08','4.8647 V','multiface',1};

device(end+1,:) = { 'FireRobo1_hwch01','8.2200 V','firebox',1};
device(end+1,:) = { 'FireRobo1_hwch02','8.1672 V','firebox',1};
device(end+1,:) = { 'FireRobo1_hwch03','8.1428 V','firebox',1};
device(end+1,:) = { 'FireRobo1_hwch04','8.1672 V','firebox',1};
device(end+1,:) = { 'FireRobo1_hwch05','8.1740 V','firebox',1};
device(end+1,:) = { 'FireRobo1_hwch06','8.1082 V','firebox',1};

device(end+1,:) = { 'FireRobo2_hwch01','8.9498 V','firebox',1};
device(end+1,:) = { 'FireRobo2_hwch02','8.8656 V','firebox',1};
device(end+1,:) = { 'FireRobo2_hwch03','8.9248 V','firebox',1};
device(end+1,:) = { 'FireRobo2_hwch04','8.9239 V','firebox',1};
device(end+1,:) = { 'FireRobo2_hwch05','8.9486 V','firebox',1};
device(end+1,:) = { 'FireRobo2_hwch06','8.9078 V','firebox',1};

device(end+1,:) = { 'FireRobo3_hwch01','9.039 V','firebox',1};
device(end+1,:) = { 'FireRobo3_hwch02','9.0431 V','firebox',1};
device(end+1,:) = { 'FireRobo3_hwch03','8.9764 V','firebox',1};
device(end+1,:) = { 'FireRobo3_hwch04','8.9316 V','firebox',1};
device(end+1,:) = { 'FireRobo3_hwch05','8.9303 V','firebox',1};
device(end+1,:) = { 'FireRobo3_hwch06','8.8936 V','firebox',1};

device(end+1,:) = { 'FireRobo4_hwch01','8.4538 V','firebox',1};
device(end+1,:) = { 'FireRobo4_hwch02','8.4566 V','firebox',1};
device(end+1,:) = { 'FireRobo4_hwch03','8.4571 V','firebox',1};
device(end+1,:) = { 'FireRobo4_hwch04','8.4233 V','firebox',1};
device(end+1,:) = { 'FireRobo4_hwch05','8.4049 V','firebox',1};
device(end+1,:) = { 'FireRobo4_hwch06','8.4729 V','firebox',1};

device(end+1,:) = { 'FireRobo5_hwch01','8.9333 V','firebox',1};
device(end+1,:) = { 'FireRobo5_hwch02','8.9493 V','firebox',1};
device(end+1,:) = { 'FireRobo5_hwch03','8.9474 V','firebox',1};
device(end+1,:) = { 'FireRobo5_hwch04','8.9077 V','firebox',1};
device(end+1,:) = { 'FireRobo5_hwch05','8.8638 V','firebox',1};
device(end+1,:) = { 'FireRobo5_hwch06','8.8825 V','firebox',1};

device(end+1,:) = { 'RME FireFace','1 V','fireface',1};

device(end+1,:) = { 'ModulITA RAR3 hwch01 iCh1','10.7034 V','modulita',1};
device(end+1,:) = { 'ModulITA RAR3 hwch02 iCh2','10.7816 V','modulita',1};
device(end+1,:) = { 'ModulITA RAR3 hwch03 iCh3','10.8603 V','modulita',1};
device(end+1,:) = { 'ModulITA RAR3 hwch04 iCh4','10.9072 V','modulita',1};

device(end+1,:) = { 'ModulITA HALL1 hwch01 iCh1','10.8556 V','modulita',1};
device(end+1,:) = { 'ModulITA HALL1 hwch02 iCh2','10.8913 V','modulita',1};
device(end+1,:) = { 'ModulITA HALL1 hwch03 iCh3','10.8932 V','modulita',1};
device(end+1,:) = { 'ModulITA HALL1 hwch04 iCh4','10.8990 V','modulita',1};

device(end+1,:) = { 'RME ADI-8 QS G1121 hwch01','1 V','none',1};
device(end+1,:) = { 'RME ADI-8 QS G1121 hwch02','1 V','none',1};
device(end+1,:) = { 'RME ADI-8 QS G1121 hwch03','1 V','none',1};

end

%% AMP
function device = ita_device_list_amp()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};

device(end+1,:) = { 'Robo Rack hwch01','1.3304','robo',1};
device(end+1,:) = { 'Robo Rack hwch02','1.3092','robo',1};

device(end+1,:) = { 'MultiRoboFace1_ampOut 0dBU_hwch01','1.4034 ','robo',1};
device(end+1,:) = { 'MultiRoboFace1_ampOut 0dBU_hwch02','1.3348 ','robo',1};

device(end+1,:) = { 'MultiRoboFace3_ampOut 0dBU_hwch01','1.4174 ','robo',1};
device(end+1,:) = { 'MultiRoboFace3_ampOut 0dBU_hwch02','1.3463 ','robo',1};

device(end+1,:) = { 'FireRobo1_ampOut 0dBU_hwch03','2.3133 ','robo',1};
device(end+1,:) = { 'FireRobo1_ampOut 0dBU_hwch04','2.3093 ','robo',1};

device(end+1,:) = { 'FireRobo2_ampOut 0dBU_hwch03','2.3322 ','robo',1};
device(end+1,:) = { 'FireRobo2_ampOut 0dBU_hwch04','2.3076 ','robo',1};

device(end+1,:) = { 'FireRobo3_ampOut 0dBU_hwch03','2.3159 ','robo',1};
device(end+1,:) = { 'FireRobo3_ampOut 0dBU_hwch04','2.3245 ','robo',1};

device(end+1,:) = { 'FireRobo4_ampOut 0dBU_hwch03','2.2778 ','robo',1};
device(end+1,:) = { 'FireRobo4_ampOut 0dBU_hwch04','2.3009 ','robo',1};

device(end+1,:) = { 'FireRobo5_ampOut 0dBU_hwch03','2.2892 ','robo',1};
device(end+1,:) = { 'FireRobo5_ampOut 0dBU_hwch04','2.3002 ','robo',1};

device(end+1,:) = { 'Robo G1051 ampOut 0dBU_iCH1','2.15 ','robo',1};
device(end+1,:) = { 'Robo G1051 ampOut 0dBU_iCH2','2.15 ','robo',1};

device(end+1,:) = { 'Robo G1139 ampOut 0dBU_iCH1','2.1685 ','robo',1};
device(end+1,:) = { 'Robo G1139 ampOut 0dBU_iCH2','2.1696 ','robo',1};

device(end+1,:) = { 'Aurelio hwch01','34.6992 V','aurelio',1};
device(end+1,:) = { 'Aurelio hwch02','34.6992 V','aurelio',1};

device(end+1,:) = { 'ModulITA RAR3 hwch01','1.0049','modulita',1};
device(end+1,:) = { 'ModulITA RAR3 hwch02','1','modulita',1};

device(end+1,:) = { 'ModulITA HALL1 hwch01','1.0172','modulita',1};
device(end+1,:) = { 'ModulITA HALL1 hwch02','1.0077','modulita',1};

device(end+1,:) = { 'HK VC2400 G913 hwch01','1','hk_amp',1};
device(end+1,:) = { 'HK VC2400 G913 hwch02','1','hk_amp',1};

device(end+1,:) = { 'HK VC1200 G914 hwch01','1','hk_amp',1};
device(end+1,:) = { 'HK VC1200 G914 hwch02','1','hk_amp',1};

end

function device = ita_device_list_actuator()
device = {};
device(end+1,:) = { 'NONE','1 ','none',0};
device(end+1,:) = { 'UNKNOWN','1 ','none',1};

device(end+1,:) = { 'ITAdodeGKB','2.1135 Pa m/V','ita_dode',1};
device(end+1,:) = { 'ITA Dode TT ','1 Pa m/V','ita_dode',1};
device(end+1,:) = { 'ITA Dode MT ','1 Pa m/V','ita_dode',1};
device(end+1,:) = { 'ITA Dode HT ','1 Pa m/V','ita_dode',1};
device(end+1,:) = { 'MMT cube ','1 Pa m/V','loudspeaker',1};
device(end+1,:) = { 'BK Shaker mini ','1 Pa m/V','shaker',1};
device(end+1,:) = { 'BK Shaker big ','1 Pa m/V','shaker',1};
device(end+1,:) = { 'KH O300 ','1 Pa m/V','loudspeaker',1};

end
