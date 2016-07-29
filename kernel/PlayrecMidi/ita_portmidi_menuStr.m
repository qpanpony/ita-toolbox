function [devStrIn, devIDsIn, devStrOut, devIDsOut] = ita_portmidi_menuStr()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


%% Init
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% try to close output first
try %#ok<TRYNC>
    mmidi('close_output')
    ita_verbose_info([thisFuncStr 'midi output has been closed.'],1);
end

%% get midi devices
try
    if ismac
        thisdir = cd;
        cd(fileparts(which('mmidi_old')));
        devs = mmidi_old('show_devices');
        cd(thisdir);
        disp('Using old mmidi.mex')
    else
        devs = mmidi('show_devices');
    end
catch %#ok<CTCH>
    ita_verbose_info([thisFuncStr 'MMidi Error or nothing found'],1)
    devStrIn  = 'noDevice';
    devStrOut = 'noDevice';
    devIDsIn  = -1;
    devIDsOut = -1;
    return;
end

%% in devices
InputDevID = ita_preferences('in_midi_DeviceID');
devIDsIn   = []; %init
devStrIn   = [];
for idx=1:size(devs,1)
    if devs{idx,1} == InputDevID && strcmpi(devs{idx,3},'input')
        devIDsIn = InputDevID;
        devStrIn = devs{idx,2};
        break;
    end
end
if isempty(devIDsIn)
    devStrIn = 'noDevice';
    devIDsIn = -1;
else
    devStrIn = [devStrIn '|noDevice'];
    devIDsIn = [devIDsIn -1];
end
for idx=1:size(devs,1)
    if InputDevID ~= devs{idx,1} %only if not already in list
        if strcmpi(devs{idx,3},'input') 
            devStrIn = [devStrIn '|' devs{idx,2}]; %#ok<AGROW>
            devIDsIn = [devIDsIn devs{idx,1}]; %#ok<AGROW>
        end
    end
end

%% in devices
OutputDevID = ita_preferences('out_midi_DeviceID');

devIDsOut   = []; %init
devStrOut   = [];
for idx=1:size(devs,1)
    if devs{idx,1} == OutputDevID && strcmpi(devs{idx,3},'output')
        devIDsOut = OutputDevID;
        devStrOut = devs{idx,2};
        break;
    end
end
if isempty(devIDsOut)
    devStrOut = 'noDevice';
    devIDsOut = -1;
else
    devStrOut = [devStrOut '|noDevice'];
    devIDsOut = [devIDsOut -1];
end
for idx=1:size(devs,1)
    if OutputDevID ~= devs{idx,1} %only if not already in list
        
        if strcmpi(devs{idx,3},'output')
            devStrOut = [devStrOut '|' devs{idx,2}]; %#ok<AGROW>
            devIDsOut = [devIDsOut devs{idx,1}]; %#ok<AGROW>
        end
    end
end