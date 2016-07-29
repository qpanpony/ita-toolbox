function varargout = ita_nexus_checkCommand(varargin)
%ITA_NEXUS_CHECKCOMMAND - checks if input string is a valid serial-command for B&K Nexus devices
%  This function is easily expandable and is used to prevent errors while
%  sending data to Nexus Devices.
%  Example: ita_nexus_checkCommand('NEXUS02 I_C_3:O_S O_S_31_6M')
%  See also: ita_nexus_sendCommand
% 
%   Reference page in Help browser
%        <a href="matlab:doc ita_nexus_checkCommand">doc ita_nexus_checkCommand</a>

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Christian Haar -- Email: christian.haar@akustik.rwth-aachen.de
% Created:  02-Jul-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_command','');
[data,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% Output Sensitivity
outputSensitivity = {
    'O_S_1F'
    'O_S_3_16F'
    'O_S_10F'
    'O_S_31_6F'
    'O_S_100F'
    'O_S_316F'
    'O_S_1P'
    'O_S_3_16P'
    'O_S_10P'
    'O_S_31_6P'
    'O_S_100P'
    'O_S_316P'
    'O_S_1N'
    'O_S_3_16N'
    'O_S_10N'
    'O_S_31_6N'
    'O_S_100N'
    'O_S_316N'
    'O_S_1U'
    'O_S_3_16U'
    'O_S_10U'
    'O_S_31_6U'
    'O_S_100U'
    'O_S_316U'
    'O_S_1M'
    'O_S_3_16M'
    'O_S_10M'
    'O_S_31_6M'
    'O_S_100M'
    'O_S_316M'
    'O_S_1'
    'O_S_3_16'
    'O_S_10'
    'O_S_31_6'
    'O_S_100'
    'O_S_316'
    'O_S_1K'
    'O_S_3_16K'
    'O_S_10K'
    'O_S_31_6K'
    'O_S_100K'
    'O_S_316K'
    'O_S_1MA'
    'O_S_3_16MA'
    'O_S_10MA'
    'O_S_31_6MA'
    'O_S_100MA'
    'O_S_316MA'
    'O_S_1G'
    'O_S_3_16G'
    '?'
    };

%% FILTER
% Lower Frequency Limit
lowerFRQlimit = {
    'F_0_1'
    'F_1'
    'F_10'
    'F_20'
    'F_A_F'
    '?'
    };

% Upper Frequency Limit
upperFRQlimit = {
    'F_100'
    'F_1K'
    'F_3K'
    'F_10K'
    'F_22_4K'
    'F_30K'
    'F_100K'
    'F_K'
    '?'
    };

%% Transducer Sensitivity
transducerSensitivity = {
    'C/M/S2'
    'C/G'
    'C/N'
    'V/M/S2'
    'V/G'
    'V/PA'
    'V/U'
    'V/V'
    'C/PA'
    'C/U'
    '?'
    };

%% check first part of command: 'NEXUSXX I_C_X:'
check = true;
if ~strcmp(sArgs.command{1}(1:6),'NEXUS0')
    check = false;
    if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 121. Message was not sent.  ']), end;
end

for deviceNum = 1 : 9
    nDev = num2str(deviceNum);
    if strcmp(sArgs.command{1}(7),nDev)
        checkDev = true;
        break;
    else
        checkDev = false;
        continue;
    end
end
if checkDev == false
    check = false;
    ita_verbose_info([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 136. Message was not sent.  '],0)
end

if ~strcmp(sArgs.command{1}(8:12),' I_C_')
    check = false;
    ita_verbose_info([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 141. (Channel) Message was not sent.  '],0)
end
for channelNum = 1 : 4
    chNum = num2str(channelNum);
    if (strcmp(sArgs.command{1}(13),chNum))
        checkCh = true;
        break
    else
        checkCh = false;
        continue;
    end
end
if checkCh == false
    check = false;
    if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 155. Message was not sent.  ']), end;
end

if ~strcmp(sArgs.command{1}(14),':')
    check = false;
    if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 160. Message was not sent.  ']), end;
end

if ~strcmp(sArgs.command{1}(end),'?')
    %% check Output Sensitivity
    if strcmp(sArgs.command{1}(15:17),'O_S')
        checkOS = sum(ismember(outputSensitivity,sArgs.command{1}(19:end))); % checkOS = 0 or 1
        if checkOS == false
            check = false;
            if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 169. (Output Sensitivity) Message was not sent.  ']), end;
        end
    end
    %% check Filter
    % Lower Frequency limit
    if strcmp(sArgs.command{1}(15:19),'L_F_L')
        checkLFL = sum(ismember(lowerFRQlimit,sArgs.command{1}(21:end))); % checkLFL = 0 or 1
        if checkLFL == false
            check = false;
            if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 178. (Lower Frequency Limit) Message was not sent.  ']), end;
        end
    end
    % Upper Frequency limit
    if strcmp(sArgs.command{1}(15:19),'U_F_L')
        checkUFL = sum(ismember(upperFRQlimit,sArgs.command{1}(21:end))); % checkUFL = 0 or 1
        if checkUFL == false
            check = false;
            if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 186. (Upper Frequency Limit) Message was not sent.  ']), end;
        end
    end
    %% check Transducer Sensitivity
    if strcmp(sArgs.command{1}(15:17),'T_S')
        if ((double(sArgs.command{1}(19:end)) > 999.999)) % if ((str2double(sArgs.command{1}(19:end)) > 999.999))
            checkTS = false;
            if verboseMode, disp([thisFuncStr '  Invalid Input for Transducer Sensitivity. Message was not sent.  ']), end;
        elseif (double(sArgs.command{1}(19:end)) < (1.000E-15))
            checkTS = false;
            if verboseMode, disp([thisFuncStr '  Invalid Input for Transducer Sensitivity. Message was not sent.  ']), end;
            if checkTS == false;
                check = false;
                if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 199. (Transducer Sensitivity) Message was not sent.  ']), end;
            end
        end
    end
    %% check Delta Tron Voltage
    if strcmp(sArgs.command{1}(15:19),'D_T_V')
        if (~strcmp(sArgs.command{1}(21:end),'O') && ~strcmp(sArgs.command{1}(21:end),'OF'))
            check = false;
            if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 207. (DeltaTron Voltage) Message was not sent.  ']), end;
        end
    end
    %% check Reference Generator
    if strcmp(sArgs.command{1}(15:17),'R_G')
        if (~strcmp(sArgs.command{1}(19:end),'O') && ~strcmp(sArgs.command{1}(21:end),'OF'))
            check = false;
            if verboseMode, disp([thisFuncStr '  Error in ==> ita_nexus_checkCommand at 214. (Reference Generator) Message was not sent.  ']), end;
        end
    end
else
    paramList = {
        'O_S'
        'T_S'
        'D_T_V'
        'R_G'
        'L_F_L'
        'U_F_L'
    };
    if ~ismember(paramList,sArgs.command{1}(15:end-1))
        if verboseMode, disp([thisFuncStr '  Error in ==>  ita_nexus_checkCommand at 227. (Query) Message was not sent.  ']), end;
    else
        check = true;
    end
end
%% Add history line
% result.header = ita_metainfo_add_historyline(result.header,mfilename,varargin);

%% Find output parameters
varargout(1) = {check};
%end function
end