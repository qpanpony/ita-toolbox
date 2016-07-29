function [devStrIn, devIDsIn, devStrOut, devIDsOut] = ita_portaudio_menuStr()
% ita_portaudio_menuStr - get devicelist for input and output

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

if exist('ita_portaudio.m','file')
    hPlayRec = ita_playrec;
    try  %#ok<TRYNC>
        %in case this was open, we can force a reset, this lets newly connected
        %devices appear.
        hPlayRec('reset');
        disp('playrec reset succeeded!')
    end
    
    try
        devs = hPlayRec('getDevices');
        devs = sort_devs(devs);
        DevInfo = squeeze(struct2cell(devs));
        DevIds = cellfun(@(x) cat(1,x),DevInfo(1,:));
        
    catch %#ok<CTCH>
        ita_verbose_info('Could not get device list, will return empty data');
        devStrIn = ' ';
        devStrOut = ' ';
        devIDsIn = -1;
        devIDsOut = -1;
        return;
    end
    
    %% in devices
    devIDsIn = ita_preferences('recDeviceID');
    
    if devIDsIn ~= -1
        devStrIn = [ita_portaudio_deviceID2string(devIDsIn) ' (' DevInfo{3,DevIds == devIDsIn} ')'];
        devStrIn = [devStrIn '|noDevice'];
        devIDsIn = [devIDsIn -1];
    else
        devStrIn = 'noDevice';
    end
    
    for idx=1:length(devs)
        if ~(devIDsIn(1) == devs(idx).deviceID) %only if device is not already in list
            if devs(idx).inputChans
                devStrIn = [devStrIn '|' devs(idx).name ' (' DevInfo{3,idx} ')']; %#ok<AGROW>
                devIDsIn = [devIDsIn DevIds(idx)]; %#ok<AGROW>
            end
        end
    end
    
    %% out devices
    devIDsOut = ita_preferences('playDeviceID');
    
    if devIDsOut ~= -1
        devStrOut = [ita_portaudio_deviceID2string(devIDsOut) ' (' DevInfo{3,DevIds == devIDsOut} ')'];
        devStrOut = [devStrOut '|noDevice'];
        devIDsOut = [devIDsOut -1];
    else
        devStrOut = 'noDevice';
    end
    
    for idx=1:length(devs)
        if ~(devIDsOut(1) == devs(idx).deviceID) %only if device is not already in list
            if devs(idx).outputChans
                devStrOut = [devStrOut '|' devs(idx).name ' (' DevInfo{3,idx} ')']; %#ok<AGROW>
                devIDsOut = [devIDsOut DevIds(idx)]; %#ok<AGROW>
            end
        end
    end
else
    [devStrIn, devIDsIn, devStrOut, devIDsOut] = deal(['','','','']);
end
end

function devs = sort_devs(devs)
dev1 = [];
dev2 = [];
for idx = 1:numel(devs)
    if strcmpi(devs(idx).hostAPI,'asio') %sort ASIO first
        dev1 = [dev1 idx]; %#ok<AGROW>
    else
        dev2 = [dev2 idx]; %#ok<AGROW>
    end
end
dev_idx = [dev1 dev2];
devs = devs(dev_idx);

end
