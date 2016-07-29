function varargout = ita_nexus_setup(varargin)
%ITA_NEXUS_SETUP - adresses B&K Nexus devices with number(s) (by creating a
%  serial object), closes currently opened serial objects ('reset') and
%  finds the Comport the Nexus devices are connected to ('detectComport').
%
%  This function is used to initialize one or more Nexus devices. You can
%  also use it for resetting all serial objects or switching Remote-Mode on
%  or off. Using additional function ita_get_available_comports, it finds the
%  Comport, your Nexus device is connected to automatically, if not given.
%  If a working Comport is found, it's written to ITA_PREFERENCES.
%  default serial port settings ('BaudRate',9600,'DataBits',8,'StopBits',1);
% 
%  Call: ita_nexus_setup('detectComport',true);
%  Call: ita_nexus_setup('numberOfDevices',4);
%  Call: ita_nexus_setup('comport','COM16','numberOfDevices',2);
%  Call: ita_nexus_setup('comport','COM16','numberOfDevices',2);
%  Call: ita_nexus_setup('numberOfDevices',2);
%  Call: ita_nexus_setup('reset','on');
%  Syntax:
%  Example:
%   audioObj = ita_nexus_setup(audioObj)
%   Reference page in Help browser
%        <a href="matlab:doc ita_nexus_setup">doc ita_nexus_setup</a>

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Christian Haar -- Email: christian.haar@akustik.rwth-aachen.de
% Created:  02-Jul-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions
%% Save Nexus ID
persistent NexusSetup
%% GUI if called without arguments
if (nargin == 0)
    pList = [];
    %GUI Init
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Nexus Serial Interface Settings';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Initialize Nexus Device(s)';
    pList{ele}.helptext    = 'Detect Comport, Nexus-IDs, Remote-Status Information and establish serial Connection';
    pList{ele}.datatype    = 'simple_button';
    pList{ele}.buttonname    = 'Initialize';
    pList{ele}.default     = '';
    pList{ele}.color       = [0 0 0];
    pList{ele}.callback    = 'ita_nexus_setup(''numberOfDevices'',4);close;ita_nexus_setup();';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'REMOTE-Mode';
    pList{ele}.helptext    = 'Remote-Control is switched on/off. While Remote-Control is on, you can''t use any Push-Buttons on the device except for ''Power''';
    pList{ele}.datatype    = 'simple_button';
    pList{ele}.buttonname    = 'switch on/off';
    pList{ele}.default     = '';
    pList{ele}.color       = [0 0 0];
    if ~isempty(NexusSetup)
        if isfield(NexusSetup,'Remote')
            if strcmpi(NexusSetup.Remote{1},'on')
                pList{ele}.callback    = 'ita_nexus_setup(''remote'',''off'');close;ita_nexus_setup();';
            else
                pList{ele}.callback    = 'ita_nexus_setup(''remote'',''on'');close;ita_nexus_setup();';
            end
        else
            pList{ele}.callback    = 'ita_nexus_setup(''remote'',''on'');close;ita_nexus_setup();';
        end
    else
        pList{ele}.callback    = 'ita_nexus_setup(''remote'',''on'');close;ita_nexus_setup();';
    end
    
    ele = numel(pList)+1; % Status is shown for the first(!) device in a daisy chain
    if ~isempty(NexusSetup)
        if isfield(NexusSetup,'Remote')
            pList{ele}.description = ['Status(for switching press button): ' NexusSetup.Remote{1}];
        else
            pList{ele}.description = 'Status(for switching press button): ';
        end
    else
        pList{ele}.description = 'Status(for switching press button): --';
    end
    pList{ele}.helptext    = 'Remote-Control Status';
    pList{ele}.datatype    = 'text';
    pList{ele}.color       = [0.1 0.6 0.2];
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Reset';
    pList{ele}.helptext    = 'Close all serial objects, delete all NexusSetup(persistent) Information';
    pList{ele}.datatype    = 'simple_button';
    pList{ele}.default     = '';
    pList{ele}.color       = [0 0 0];
    pList{ele}.callback    = 'ita_nexus_setup(''reset'',true);close;ita_nexus_setup();';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Preferences';
    pList{ele}.helptext    = 'Call ita_preferences()';
    pList{ele}.datatype    = 'simple_button';
    pList{ele}.default     = '';
    pList{ele}.color       = [0 0 0];
    pList{ele}.callback    = 'ita_preferences();';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'COM-Port';
    pList{ele}.helptext    = 'COM-Port your Nexus device(s) is(are) connected to';
    pList{ele}.datatype    = 'simple_button';
    pList{ele}.buttonname    = 'detect';
    pList{ele}.color       = [0 0 0];
    pList{ele}.callback    = 'ita_nexus_setup(''detectComport'',true);close;ita_nexus_setup()';
    
    ele = numel(pList)+1;
    if ~isempty(NexusSetup)
        pList{ele}.description = NexusSetup.ComPort;
    else
        pList{ele}.description = 'COMxx';
    end
    pList{ele}.helptext    = 'COM-Port your Nexus device(s) is(are) connected to';
    pList{ele}.datatype    = 'text';
    pList{ele}.color       = [0.1 0.6 0.2];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Connected Devices';
    
    ele = numel(pList)+1;
    if ~isempty(NexusSetup)
        if isfield(NexusSetup, 'Devices')
            if (length(NexusSetup.Devices) >= 1)
                pList{ele}.description = ['1 Dev:' NexusSetup.Devices{1} ' ID:' NexusSetup.IDs{1}];
            else
                pList{ele}.description = '1 no Device';
            end
        else
            pList{ele}.description = '1 no Device';
        end
    else
        pList{ele}.description = '1 no Device';
    end
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'simple_text';
    pList{ele}.color       = [0 0 0];
    
    ele = numel(pList)+1;
    if ~isempty(NexusSetup)
        if isfield(NexusSetup, 'Devices')
            if (length(NexusSetup.Devices) >= 2)
                pList{ele}.description = ['2 Dev:' NexusSetup.Devices{2} ' ID:' NexusSetup.IDs{2}];
            else
                pList{ele}.description = '2 no Device';
            end
        else
            pList{ele}.description = '2 no Device';
        end
    else
        pList{ele}.description = '2 no Device';
    end
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'simple_text';
    pList{ele}.color       = [0 0 0];
    
    ele = numel(pList)+1;
    if ~isempty(NexusSetup)
        if isfield(NexusSetup, 'Devices')
            if (length(NexusSetup.Devices) >= 3)
                pList{ele}.description = ['3 Dev:' NexusSetup.Devices{3} ' ID:' NexusSetup.IDs{3}];
            else
                pList{ele}.description = '3 no Device';
            end
        else
            pList{ele}.description = '3 no Device';
        end
    else
        pList{ele}.description = '3 no Device';
    end
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'simple_text';
    pList{ele}.color       = [0 0 0];
    
    ele = numel(pList)+1;
    if ~isempty(NexusSetup)
        if isfield(NexusSetup, 'Devices')
            if (length(NexusSetup.Devices) >= 4)
                pList{ele}.description = ['4 Dev:' NexusSetup.Devices{4} ' ID:' NexusSetup.IDs{4}];
            else
                pList{ele}.description = '4 no Device';
            end
        else
            pList{ele}.description = '4 no Device';
        end
    else
        pList{ele}.description = '4 no Device';
    end
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'simple_text';
    pList{ele}.color       = [0 0 0];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Configurate B&K Nexus Device']);
    pause(0.02) %wait for GUI to close first
    if ~isempty(NexusSetup)
        if ~isfield(NexusSetup,'Devices')
            [NexusSetup, s] = ita_nexus_setup('numberOfDevices',4);
            %         ita_verbose_info([thisFuncStr ' Your Nexus setup information "NS" and serial Object "s" have been exported to your workspace.'],1)
            assignin('base','NS',NexusSetup);
            assignin('base','s',s);
        else
            %         ita_verbose_info([thisFuncStr ' Your Nexus setup information "NS" and serial Object "s" have been exported to your workspace.'],1)
            assignin('base','NS',NexusSetup);
        end
    end
    %exit and shut up
    return;
    
end
%% Initialization and Input Parsing
narginchk(1,8);
sArgs        = struct('comport',ita_preferences('nexusComPort'),'comportList','','numberOfDevices',4,'detectComport',false,'reset',false,'remote','','pause',0.02);
[sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>
%% Initialize Serial Object
if isempty(sArgs.remote)
    if ~isempty(instrfind) % close any open serial connections
        fclose(instrfind);
    end
    if ~isempty(sArgs.comportList)
        comportList = sArgs.comportList; %this is used for the recursive call...
    else
        comportList = ita_get_available_comports();
        i = strmatch ('noDevice', comportList);
        if ~isempty(i)
            comportList(i) = [];
        end
    end
    if ~isempty(sArgs.comport)
        if ismember(sArgs.comport,comportList)
            comport = sArgs.comport;
            findCom = strmatch(comport,comportList,'exact');
            comportList(findCom) = [];
        else
            ita_verbose_info([thisFuncStr '  Wrong Comport as input. I''ll take another one...  '],1)
            if length(comportList) > 1
                comport = comportList(end-1);
                comportList(end-1) = [];
            else
                comport = comportList(1);
                comportList = [];
            end
        end
    else
        if length(comportList) > 1
            comport = comportList(end-1);
            comportList(end-1) = [];
        else
            comport = comportList(1);
            comportList = [];
        end
    end
    s = serial(comport,'Baudrate',9600,'Databits',8,'Stopbits',1,'OutputBufferSize',3072,'InputBufferSize',3072,'Terminator',10); % create serial object;
    fopen(s);

    % Enables communication with all connected Nexus units
    data_in = 'NEXUS00 DATEND';
    ita_write_data_in_blocks(s,data_in,sArgs.pause)
    %     ita_write_data_to_nexus(s,data_in,sArgs.pause)
    if s.BytesAvailable ~= 0
        data_out = fscanf(s,'%c',s.BytesAvailable);%#ok<NASGU> % read out sent data
    end
    
    % Reset previously assigned numbers to unassigned status
    data_in = 'NEXUS00 IDRESET';
    ita_write_data_in_blocks(s,data_in,sArgs.pause)
    % ita_write_data_to_nexus(s,data_in,sArgs.pause)
    if s.BytesAvailable ~= 0
        data_out = fscanf(s,'%c',s.BytesAvailable); %#ok<NASGU>
    end
end
%% Renumber
if ~isempty(sArgs.numberOfDevices) && ~sArgs.reset && isempty(sArgs.remote)
    %     if ~isempty(sArgs.comport)
    for idx=1 : sArgs.numberOfDevices
        data_in = ['NEXUS00 IDNUM0',num2str(idx)];
        data_in = uint8(data_in); % send command as numeric
        for i=1 : length(data_in);
            fwrite(s, data_in(i)) % send each particular element and insert a little delay
            pause(0.02)
        end
        if s.BytesAvailable == 0
            if ~exist('holdComport','var')
                if isempty(comportList)
                    error([thisFuncStr, 'I could not find a device on the available COM ports. Check the connection and restart matlab to update the comports'])
                else
                    new_comport = comportList(end);
                    ita_nexus_setup('comport',new_comport,'comportList',comportList,'numberOfDevices',sArgs.numberOfDevices,'remote',sArgs.remote)
                    return;
                end
            end
        end
        pause(sArgs.pause)
        if (s.BytesAvailable ~= 0)
            data_out = fscanf(s,'%c',s.BytesAvailable);
            msg = data_out(16:end); % 'NEXUS00 IDNUM0idx' (sent command) are the first 15 signs
            data_in = msg;
            data_in = uint8(msg);
            for i = 1:length(data_in)
                fwrite(s, data_in(i))
                pause(0.02)
            end
            if s.BytesAvailable == 0
                status = 'ERROR';
            else
                status = fscanf(s,'%c',s.BytesAvailable); % OK?
                status = status(8:end);
                status = regexprep(status,'\s$','');
            end
            if s.BytesAvailable ~= 0
                data_out = fscanf(s,'%c',s.BytesAvailable); %#ok<NASGU>
            end
        else
            status = 'ERROR';
        end
        if strcmp(status,'OK') % if status is 'OK' the Nexus is adressed and the right Comport was used
            holdComport = 1; % found right Comport, don't search anymore
            fwrite(s,s.Terminator); % Send Terminator <Te>
            pause(sArgs.pause);
            data_out = fscanf(s);
            NexusSetup.ComPort = comport;
            if (sArgs.detectComport == true) % just return the Comport
                if (s.BytesAvailable ~= 0)
                    data_out = fscanf(s,'%c',s.BytesAvailable); %read out any rest data...
                end
                if (s.BytesAvailable ~= 0)
                    data_out = fscanf(s,'%c',s.BytesAvailable); %read out any rest data...
                end
                fclose(instrfind);
                ita_verbose_info([thisFuncStr 'Nexus Comport detected. Devices are connected to ' char(comport) '.'],1);
                
                varargout{1} = comport;
                return;
            end
            NexusSetup.IDs{idx} = msg;
            if strcmp(msg,'2172853')
                NexusSetup.Devices{idx} = 'G0933';
            elseif strcmp(msg,'2192235')
                NexusSetup.Devices{idx} = 'G0934';
            elseif strcmp(msg,'2049653')
                NexusSetup.Devices{idx} = 'G0932';
            end
            ita_verbose_info([thisFuncStr 'Status: device ' num2str(idx) '(Nexus-ID: ' NexusSetup.IDs{idx} ')' ' OK'],1);
            if ~isempty(comportList)
                comportList = []; %empty comportList, right Comport already found
            end
        else %status != OK... wrong Comport?...
            if ~exist('holdComport','var')
                if ~isempty(comportList)
                    if s.BytesAvailable ~= 0
                        data_out = fscanf(s,'%c',s.BytesAvailable); %read out any rest data...
                    end
                    %                 fclose(s);
                    new_comport = comportList(end);
                    ita_nexus_setup('comport',new_comport,'comportList',comportList,'numberOfDevices',sArgs.numberOfDevices,'remote',sArgs.remote) %funciton is called recursively with new Comportlist
                else
                    error(['        All available Comports have been checked. Initialization of Nexus Device ',num2str(idx),' failed. Please ensure the cable is connected correctly.    '])
                end
            else
                break;
            end
        end
        
        %Detect Remote-Status
        msg = 0;
        data_in = ['NEXUS0',num2str(idx),' REM?']; %             ERROR: I/O E 15 means 'unexpected Byte detectet' but you can ignore it (function still works).
        ita_write_data_to_nexus(s,data_in,sArgs.pause)
        if s.BytesAvailable ~= 0
            [sent,count] = fscanf(s,'%c',s.BytesAvailable);
            data_out = fscanf(s); %Remote Status
            pause(0.2) % this pause is needed (to ensure that the puffer s.BytesAvailable is read correctly)
            if s.BytesAvailable ~= 0 %sometimes s is not read out correctly...
                msg = fscanf(s,'%c',s.BytesAvailable);
            else
                if msg == 0
                    msg = data_out;
                end
            end
            if strcmpi(msg(end-2:end-1),'on')
                NexusSetup.Remote{idx} = 'on';
            else
                NexusSetup.Remote{idx} = 'off';
            end
        end
    end
    fclose(s);
end

% Remote-Mode (switch on/off)
if ~isempty(sArgs.remote)
    if ~isempty(NexusSetup) && exist('s','var')
        if strcmp (s.Status,'closed')
            fopen(s);
        end
        if s.BytesAvailable ~= 0
            data_out = fscanf(s,'%c',s.BytesAvailable);
        end
        for idx=1:length(NexusSetup.Devices)
            msg = 0;
            data_in = ['NEXUS0',num2str(idx),' REM?']; %             ERROR: I/O E 15 means 'unexpected Byte detectet' but you can ignore it (function still works).
            %             ita_write_data_in_blocks(s,data_in,sArgs.pause)
            ita_write_data_to_nexus(s,data_in,sArgs.pause)
            if s.BytesAvailable ~= 0
                [sent,count] = fscanf(s,'%c',s.BytesAvailable);
                data_out = fscanf(s); %Remote Status
                pause(0.2) % this pause is needed (to ensure that the buffer s.BytesAvailable is read correctly)
                if s.BytesAvailable ~= 0 %sometimes s is not read out correctly...
                    msg = fscanf(s,'%c',s.BytesAvailable);
                else
                    if msg == 0
                        msg = data_out;
                    end
                end
                
                if strcmpi(msg(end-2:end-1),'on') % if REMOTE is set 'on' and given as 'off' it will be changed...
                    if ~sArgs.remote
                        data_in = ['NEXUS0',num2str(idx),' REM OF'];
                        ita_write_data_in_blocks(s,data_in,sArgs.pause)
                        if s.BytesAvailable ~= 0
                            data_out = fscanf(s,'%c',s.BytesAvailable);
                        end
                        NexusSetup.Remote{idx} = 'off';
                        ita_verbose_info([thisFuncStr 'B&K Nexus, Device: ', NexusSetup.Devices{idx}, ' Remote-Control has been switched OFF.'], 1)
                    else
                        NexusSetup.Remote{idx} = 'on';
                    end
                else
                    if sArgs.remote % if REMOTE is set 'off' and given as 'on' it will be switched on...
                        data_in = ['NEXUS0',num2str(idx),' REM O'];
                        ita_write_data_in_blocks(s,data_in,sArgs.pause)
                        data_out = fscanf(s,'%c',s.BytesAvailable);
                        NexusSetup.Remote{idx} = 'on';
                        ita_verbose_info([thisFuncStr 'B&K Nexus, Device: ', NexusSetup.Devices{idx}, ' Remote-Control has been switched ON.'], 1)
                    else
                        NexusSetup.Remote{idx} = 'off';
                    end
                end
            else
                ita_verbose_info([thisFuncStr 'Switching on/off Remote-Control failed. Please try again'], 1)
                break;
            end
        end
        fclose(s);
    else
        ita_verbose_info([thisFuncStr 'For switching Remote-Control on/off first initialize Nexus-Devices.'], 1)
    end
end
%% Reset
if sArgs.reset
    if ~isempty(comport)
        if s.BytesAvailable ~= 0
            data_out = fscanf(s,'%c',s.BytesAvailable);
        end
        clear s;
    end
    if ~isempty(instrfind)
        fclose(instrfind);
    end
    NexusSetup = {}; % reset persistent variable
    varargout{1} = [];
    ita_verbose_info([thisFuncStr 'Reset was successful.'], 1)
end

%% write comport to preferences
if exist('status','var')
    %     if strcmp(status,'OK')
    ita_preferences('nexusComPort',char(comport)); %write comport to preferences
    %% Add history line
    % result.header = ita_metainfo_add_historyline(result.header,mfilename,varargin);
    
    %% Find output parameters
    if nargout == 0 && ~sArgs.reset %User has not specified a variable
        % Do plotting?
        ita_verbose_info([thisFuncStr 'Your Nexus setup information "NS" and serial Object "s" have been exported to your workspace.'],1)
        assignin('base','s',s);
        assignin('base','NS',NexusSetup);
    else % Write Data
        if ~sArgs.reset
            %             varargout(1) = {s};
            varargout(1) = {NexusSetup};
            varargout(2) = {s};
            ita_verbose_info([thisFuncStr 'Your Nexus setup information "NS" and serial Object "s" have been exported to your workspace.'],1)
        end
    end
    %end function
    %     end
end
end

%% Send Data
% Here the above created and proofed command is send to the Nexus
function  ita_write_data_in_blocks(s,data_in,itapause)
data_in = uint8(data_in);
data_in = [data_in s.Terminator]; % add Terminator <Te>
blocklength = 4;
restlength = rem(length(data_in),blocklength);                                                 % divide into blocks and find out the rest length
for i = 1:length(data_in)/blocklength;                                                        % write blocks
    fwrite(s, data_in([i*blocklength-(blocklength-1):i*blocklength]))
    pause(itapause)
end
if ~isempty(data_in([end-restlength+1:end]))
    fwrite(s, data_in([end-restlength+1:end]))
end % write rest
end

function  ita_write_data_to_nexus(s,data_in,itapause)
data_in = uint8(data_in);
% data_in = [data_in s.Terminator]; % add Terminator <Te>                                               % divide into blocks and find out the rest length
for i = 1:length(data_in);                                                        % write blocks
    fwrite(s, data_in(i))
    pause(itapause)
end
pause(itapause)
fwrite(s, s.Terminator)
end

%% Echoe/Answer from Nexus Device
function response = ita_get_data_out(s,data_in)
% read out data, the nexus has sent back to the serial object
if strcmp(data_in(end),'?')                                               %query-message
    pause(0.02)
    [msg,count] = fscanf(s,'%c',s.BytesAvailable/8);                 % read out sent message and number of signs
    % 	msg = fscanf(s);                                                     % read out value you want to know
    % 	if s.BytesAvailable ~= 0                                                  % if there's still something written in the serialobj., msg is not what you want -> overwrite
    % 		msg = fscanf(s);
    % 	end
    % 	if s.BytesAvailable ~= 0
    % 		msg = fscanf(s);
    % 	end
    while s.BytesAvailable ~= 0
        msg = fscanf(s);
        pause(0.02)
    end
    msg = regexprep(msg,'\s$','');                                      % delete empty space at end of string
    ita_verbose_info([   ' returned message: ', msg   ],1);
else
    if s.BytesAvailable ~= 0
		pause (0.02)
		data_out = fscanf(s,'%c',s.BytesAvailable);
		data_out = regexprep(data_out,'\s$',''); % delete empty space at end of string
		ita_verbose_info(['ITA_NEXUS_SETUP: ', num2str(data_out)  ],1)
    end
end
end
