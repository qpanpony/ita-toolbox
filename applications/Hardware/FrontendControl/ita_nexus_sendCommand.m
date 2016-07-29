function varargout = ita_nexus_sendCommand(varargin)
%ITA_NEXUS_SENDCOMMAND - creates a serial object, takes a command and sends it to one or more Nexus units.
%  Please get sure the "ECHO"-Mode is switched on on your Nexus Devices:
%  ...->Home->Serial Interface->Echo
%
%  To use this function you need to call ita_nexus_setup at first.
%  Parameters(values): 'OutputSens'(e.g. 31.6, 100), 'Filter'(e.g. {'10', '1K'}),
% 'TransducerSens'(1.000E-15 to 999.999, default: 1.000, charge: 1.000E-12),
% 'refGenerator'('O', 'OF'), 'DeltaTronVoltage'('O', 'OF')
%  For further information on valid values see ita_nexus_checkCommand
%  If you want to send a query (..read out values) set 'value' = '?'. Your answer will be displayed in the Matlab commandwindow.
%  default serial port settings are: 'BaudRate',9600,'DataBits',8,'StopBits',1;
%
% EXAMPLE:
% Call: first use ita_nexus_setup to initialize your Nexus devices and get
% the right Comport (written to ita_preferences)
% Call with 'param' and 'value':
%        ita_nexus_sendCommand('comport','COM16','device',2,'channel',2,'param','OutputSens','value',[-31.6]);
%        ita_nexus_sendCommand('comport','COM16','device',1,'channel',2,'param','Filter','value',{{'10' '1K'}});
%        ita_nexus_sendCommand('comport','COM16','device',1,'channel',2,'param','TransducerSens','value','?');
% Call with 'message':
%        ita_nexus_sendCommand('comport','COM16','message','NEXUS02 I_C_3:L_F_L F_10');
%        ita_nexus_sendCommand('comport','COM15','message','NEXUS01 I_C_1:R_G O'); %switch on signal generator
%        ita_nexus_sendCommand('comport','COM12','message','NEXUS01 P_H_R?'); %reset peak hold
% Call with 'channelStruct':
%        ita_nexus_sendCommand('comport','COM16','channelStruct',Nexus);
% The channelstruct "Nexus" can look like this:
% SensitivityList.Sensor        = [100                100                100               -31.6                ]  *  1e-3;% enter sensitivity in mV of microphone or sensitivity shown on nexus amplifier
% Nexus.Device                  = {1                  2                  3                  4                   };
% Nexus.Channel                 = [4                  3                  2                  1                   ];
% Nexus.TransducerSens          = [9.89               10.15              ?                  9.89                ]  *  1e-3; % enter sensitivity in mV of microphone or sensitivity shown on nexus amplifier
% Nexus.OutputSens              = SensitivityList.Sensor(1:4);
% Nexus.Filter                  = {{'10' '1K'}        {'0_1' '22_4K'}    {'0_1' '30K'}      {'0_1' '22_4K'}     };
% Nexus.DeltaTronVoltage        = {'O',               'OF'               'O',               'O'                 };
%
% !!
% (If you already have sent a Struct like this and want to change
% something,
% the function compares the old struct (saved as persistent) with the new
% one and just sends the values that have been changed...)
% !!
% diff_channelStruct = is used to resend the data to the nexus if the amount of channels was changed
% oldStruct = is loaded out of persistent
% channelStruct = is the input struct to be transfered to the nexus
%
%  See also: ita_vibro_sendCommand; ita_nexus_checkCommand;
%  ita_nexus_setup; ita_measurement_setup; ita_measurement_run;
%   Reference page in Help browser
%        <a href="matlab:doc ita_nexus_sendCommand">doc ita_nexus_sendCommand</a>

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Christian Haar -- Email: christian.haar@akustik.rwth-aachen.de
% Created:  02-Jul-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Save Channelstruct data
% mlock
persistent oldNexus;
persistent old_fieldnames;
persistent s

%% Initialization (GUI)
% Number of Input Arguments
% if nargin == 0
%     pList = [];
%     %     if exist(evalin('base','NI'),'var')
%     %         NI = ita_nexus_setup();
%     %         if isempty(NI)
%     %             return;
%     %         end
%     %     else
%     NI = evalin('base','NI');
%     %     end
%     if ~isstruct(NI)
%         error('ITA_NEXUS_SENDCOMMAND:Oh Lord. Where is my Nexus initialization struct?')
%     end
%     ele = numel(pList)+1;
%     pList{ele}.datatype    = 'text';
%     pList{ele}.description = 'Device/Channel Settings';
%
%     ele = numel(pList)+1;
%     pList{ele}.description = 'Nexus Device';
%     pList{ele}.helptext    = 'Nexus Device to which the command is send';
%     pList{ele}.datatype    = 'int';
%     pList{ele}.default     = '1';
%
%     ele = numel(pList)+1;
%     pList{ele}.description = 'Channel [1:4]';
%     pList{ele}.helptext    = 'Channel of Nexus Device to which the data is written ';
%     pList{ele}.datatype    = 'int_popup';
%     pList{ele}.list        = [1 2 3 4];
%     pList{ele}.default     =  1;
%
%     ele = numel(pList)+1;
%     pList{ele}.datatype    = 'line';
%
%     ele = numel(pList)+1;
%     pList{ele}.datatype    = 'text';
%     pList{ele}.description = 'Parameter Settings';
%
%     ele = numel(pList)+1;
%     pList{ele}.description = 'Output Sensitivity';
%     pList{ele}.helptext    = 'output sensitivity value';
%     pList{ele}.datatype    = 'char_popup';
%     pList{ele}.list        = '?|O_S_1F|O_S_3_16F|O_S_10F|O_S_31_6F|O_S_100F|O_S_316F|O_S_1P|O_S_3_16P|O_S_10P|O_S_31_6P|O_S_100P|O_S_3l6P|O_S_lN|O_S_3_16N|O_S_10N|O_S_31_6N|O_S_100N|O_S_316N|O_S_1U|O_S_3_16U|O_S_10U|O_S_31_6U|O_S_100U|O_S_3l6U|O_S_1M|O_S_3_16M|O_S_10M|O_S_31_6M|O_S_100M|O_S_3l6M|O_S_1|O_S_3_16|O_S_10|O_S_31_6|O_S_100|O_S_316|O_S_1K|O_S_3_16K|O_S_10K|O_S_31_6K|O_S_100K|O_S_316K|O_S_1MA|O_S_3_16MA|O_S_10MA|O_S_31_6MA|O_S_100MA|O_S_316MA|O_S_1G|O_S_3_16G';
%     pList{ele}.default     = '';
%
%     ele = numel(pList)+1;
%     pList{ele}.description = 'Transducer Sensitivity';
%     pList{ele}.helptext    = 'transducer sensitivity value';
%     pList{ele}.datatype    = 'double';
%     pList{ele}.default     = '';
%
%     ele = numel(pList)+1;
%     pList{ele}.datatype    = 'text';
%     pList{ele}.description = 'Filter';
%
%     ele = numel(pList)+1;
%     pList{ele}.description = 'lower frequency limit';
%     pList{ele}.helptext    = 'lower/upper frequency value';
%     pList{ele}.datatype    = 'char_popup';
%     pList{ele}.list        = '?|F_0_1|F_1|F_10|F_20|F_A_F';
%     pList{ele}.default     = '';
%
%     ele = numel(pList)+1;
%     pList{ele}.description = 'upper frequency limit';
%     pList{ele}.helptext    = 'lower/upper frequency value';
%     pList{ele}.datatype    = 'char_popup';
%     pList{ele}.list        = '?|F_100|F_1K|F_3K|F_10K|F_22_4K|F_30K|F_100K|F_K';
%     pList{ele}.default     = '';
%
%     ele = numel(pList)+1;
%     pList{ele}.description = 'DeltaTron Voltage';
%     pList{ele}.helptext    = 'DeltaTron Voltage';
%     pList{ele}.datatype    = 'char_popup';
%     pList{ele}.list        = '?|on|off'
%     pList{ele}.default     = '';
%
%     ele = numel(pList)+1;
%     pList{ele}.datatype    = 'line';
%
%     ele = numel(pList)+1;
%     pList{ele}.description = 'Message'; %this text will be shown in the GUI
%     pList{ele}.helptext    = 'If you want to read data from Nexus this is your answer';
%     pList{ele}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
%     pList{ele}.default     = ['msg_' mfilename];
%
%     CH.Nexus.Device = {pList{1}};
%     CH.Nexus.Channel = [pList{2}];
%
%     CH.Nexus.OutputSens = [pList{3}];
%     CH.Nexus.TransducerSens = [pList{4}];
%     CH.Nexus.Filter = {{pList{5} pList{6}}};
%     CH.Nexus.DeltaTronVoltage = pList{7};
%
%     %call gui
%     pList = ita_parametric_GUI(pList,[mfilename ' - Send command / write data to B&K Nexus Device']);
%     if ~isempty(pList)
%         msg = ita_nexus_sendCommand('comport',{NI.Com},'channelStruct',CH);
%         if nargout == 1
%             varargout{1} = msg;
%         end
%         ita_setinbase(pList{8}, msg);
%     end
%     return;
% else
%     narginchk(2,14);
% end

%% Initialization and Input Parsing
% assignin('base','NI.Comport',ita_preferences('comport'))
% if isempty(evalin('base','NI')) % TO DO: VERNÜNFTIGE IMPLEMENTIERUNG - NI im caller-WORKSPACE? !!!
%     NI = ita_nexus_setup();
%     if isempty(NI)
%         return;
%     end
% else
%     NI = evalin('base','NI');
% end
% if ~isstruct(NI)
%     error('ITA_NEXUS_SENDCOMMAND:Oh Lord. Where is my Nexus setup struct?')
% end

narginchk(1,15);
sArgs        = struct('device',1,'channel',1,'param','','value','','message','','channelStruct',[],'pause',0,'serialObject',[]);
[sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>
%% Close open connections and create new serial object if it is not in the input arguments (fopen takes long)
if isempty(sArgs.serialObject) && isempty(s)
    s = serial(ita_preferences('nexusComPort'),'Baudrate',9600,'Databits',8,'Stopbits',1,'OutputBufferSize',3072); % create serial object;
    try
        fopen(s);
        
    catch
        
        varargout{1} = [];
        return;
    end
elseif ~isempty(s)
    if strcmp(s.Status, 'closed')
        fopen(s);
    end
else
    s = sArgs.serialObject; % use serialobject from input
    if strcmp(s.Status, 'closed')
        fopen(s);
    end
end

%% Prepare Message
% create correct string as shown in the Nexus manual
data_in = prepare_msg(sArgs);
%% SEND COMMAND
if ~isempty(data_in)
    if ~isempty(sArgs.message)
        ita_write_data_in_blocks(s,data_in(1),sArgs.pause)
        ita_get_data_out(s,sArgs.value)
    else
        for i=1 : length(data_in) % parameter Filter is a cell with 2 values (lower/upper frequency limit)
            if ita_nexus_checkCommand(data_in(i))                                % this function compares the input message to all valid messages and returns a boolean, if 0 message won't be send
                ita_write_data_in_blocks(s,data_in(i),sArgs.pause)
                if iscell(sArgs.value)                                                  % for Filter (&DTV) values can be cells, if you send a query, value has to be changed because it's used in 245...
                    if strcmp(sArgs.value{1}(1),'?') && strcmp(sArgs.value{1}(end),'?')
                        sArgs.value = '?';
                    end
                end
                ita_get_data_out(s,sArgs.value)
                if ~isempty(s.BytesAvailable) % is there still something written in s?
                    ita_get_data_out(s,sArgs.value)
                end
            else
                ita_verbose_info([thisFuncStr '  Invalid command or error while sending.  ' data_in(i)],0)
            end
        end
    end
    % ERROR HANDLING
    % 	avoidErr = {[data_in{1}(1:7), ' ', 'ERR?']};
    % 	ita_write_data_in_blocks(s,avoidErr,sArgs.pause);
    % 	ita_get_data_out(s,'?')
end
%% Struct as input
if  ~isempty(sArgs.channelStruct)
    old = ita_send_channelStruct(sArgs.channelStruct,oldNexus,old_fieldnames,s);
    oldNexus = old{1}; %overwrite oldNexus with new values
    old_fieldnames = old{2}; %overwrite old_fieldnames with new fieldnames
end
% fclose(s)
%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
else
    % Write Data
    varargout(1) = {msg}; %reply from nexus
end
%end function
end
%% Prepare Message
% fits the Command into the format NEXUS can read
function message = prepare_msg(input)
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
if ~isempty(input.device)
    device = ['NEXUS0', num2str(input.device)];
end
if ~isempty(input.channel)
    channel = ['I_C_', num2str(input.channel)];
end
message = {}; %initialize message as empty cell
if (~isempty(input.param) && ~isempty(input.value))
    if strcmp(input.param, 'OutputSens')
        message = 'O_S';
        if strcmp(input.value,'?')
            message = {[device, ' ', channel, ':', message, input.value]};
        else
            if ischar(input.value)
                message = {[device, ' ', channel, ':', message, ' ', message, '_', char(input.value)]};
            else
                message = {[device, ' ', channel, ':', message, ' ', message, '_', ita_nexus_outputsensitivity_converter(input.value)]};
            end
        end
    end
    if strcmp(input.param, 'TransducerSens')
        message = 'T_S';
        if strcmp(input.value,'?')
            message = {[device, ' ', channel, ':', message, input.value]};
        else
            message = {[device, ' ', channel, ':', message, ' ', num2str(input.value)]};
        end
    end
    if strcmp(input.param, 'Filter') % Lower Frequency Limit
        message = {'L_F_L' 'U_F_L'};
        if strcmp(input.value{1}{1},'?') && strcmp(input.value{1}{2},'?')
            message = {[device, ' ', channel, ':', message{1}, input.value{1}{1}] [device, ' ', channel, ':', message{2}, input.value{1}{2}]};
        else
            message = {[device, ' ', channel, ':', message{1}, ' ', 'F_', input.value{1}{1}] [device, ' ', channel, ':', message{2}, ' ', 'F_', input.value{1}{2}]};
        end
    end
    if strcmp(input.param, 'DeltaTronVoltage')
        message = 'D_T_V';
        if strcmp(input.value,'?')
            message = {[device, ' ', channel, ':', message, char(input.value)]};
        else
            message = {[device, ' ', channel, ':', message, ' ', char(input.value)]};
        end
    end
    if strcmp(input.param, 'refGenerator')
        message = 'R_G';
        if strcmp(input.value,'?')
            message = {[device, ' ', channel, ':', message, input.value]};
        else
            message = {[device, ' ', channel, ':', message, ' ', input.value]};
        end
    end
else
    if isempty(input.message) && isempty(input.channelStruct)
        if verboseMode, disp([thisFuncStr '  No message to send to Nexus.  ']), end;
    end
end
if ~isempty(input.message) % if message is given as input.param, it already is(or should be) a valid string
    message = {input.message};
    if strcmp(input.message(end),'?')
        input.value = '?'; % this is written for the send routine...
    end
else
    if isempty(input.param) && isempty(input.channelStruct)
        if verboseMode, disp([thisFuncStr '  No message to send to Nexus.  ']), end;
    end
end
end

%% Channelstruct as Input
function oldStruct = ita_send_channelStruct(channelStruct, oldStruct, oldFields, s)
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
fieldnames = fields(channelStruct);

if ~isempty(oldStruct)
    if ~isempty(oldStruct.Device) %if ~isempty(oldStruct.(strcat(fieldnames{1})))
        diff_channelStruct = channelStruct;
        for idx = 1 : numel(fieldnames)
            diff_channelStruct.(strcat(fieldnames{idx})) = [] ; %empty fields in diff_channelStruct
        end
        if (length(oldStruct) == length(channelStruct)) %compare length of old and new input struct
            count = 0; % count the number of equal fieldnames in old and new input struct
            for idxFields = 1 : numel(fields(channelStruct))
                for idxOldFields = 1 : numel(fields(oldStruct))
                    if strcmp(fieldnames{idxFields},oldFields{idxOldFields}) %compare parameters to changed/changed before
                        if (idxFields ~= idxOldFields) % if order is not the same, switch order in old struct
                            temp = oldStruct{idxFields};
                            oldStruct(idxFields) = oldStruct(idxOldFields);
                            oldStruct(idxOldFields) = temp;
                        end
                        count = count+1;
                    else
                        continue;
                    end
                end
            end
            if (count ~= numel(fields(oldStruct)))
                if verboseMode, disp([   ' ITA_NEXUS_SENDCOMMAND: Old and new channelstruct have not the same types of Parameters. I''ll send the whole new one ', msg   ]), end;
                diff_channelStruct = channelStruct;
                
            else
                if length(channelStruct.Device) == length(oldStruct.Device) % same length? -> parameters have the same number of values
                    for idx = 1 : length(oldStruct.Device)
                        if ((oldStruct.Device{idx} ~= channelStruct.Device{idx}) || (oldStruct.Channel(idx) ~= channelStruct.Channel(idx))) % any changes in Device or Channel struct? -> change every(!) parameter!
                            for idxFields = 1 : numel(fieldnames)
                                if ~strcmp(fieldnames(idxFields),'Device') && ~strcmp(fieldnames(idxFields),'Channel')
                                    ita_nexus_sendCommand('device',channelStruct.Device{idx},'channel',channelStruct.Channel(idx),'serialObject',s,'param',fieldnames(idxFields),'value',channelStruct.(strcat(fieldnames{idxFields}))(idx));
                                end
                                %                                 end
                            end
                        end
                    end
                    for idx = 1 : length(oldStruct.Device) % any changes in other parameters than 'Device' or 'Channel'?
                        for idxFields = 1 : numel(fieldnames)
                            if ~strcmp(fieldnames{idxFields},'Channel') && ~strcmp(fieldnames{idxFields},'Device')
                                if iscell(oldStruct.(strcat(fieldnames{idxFields}))) % Parametervalues are saved in cell (Device,Filter,DeltaTronVoltage)
                                    if isnumeric(oldStruct.(strcat(fieldnames{idxFields})){idx}) % (cell)Parametervalue is numeric (Device)
                                        if (oldStruct.(strcat(fieldnames{idxFields})){idx} ~= channelStruct.(strcat(fieldnames{idxFields})){idx})
                                            ita_nexus_sendCommand('device',channelStruct.Device{idx},'channel',channelStruct.Channel(idx),'serialObject',s,'param',fieldnames(idxFields),'value',channelStruct.(strcat(fieldnames{idxFields})){idx});
                                        end
                                    end
                                    if iscell(oldStruct.(strcat(fieldnames{idxFields})){idx}) % (cell)Parametervalue is cell (Filter)
                                        if ~strcmp( oldStruct.(strcat(fieldnames{idxFields})){idx}{1},channelStruct.(strcat(fieldnames{idxFields})){idx}{1}) || ~strcmp(oldStruct.(strcat(fieldnames{idxFields})){idx}{2},channelStruct.(strcat(fieldnames{idxFields})){idx}(2))
                                            ita_nexus_sendCommand('device',channelStruct.Device{idx},'channel',channelStruct.Channel(idx),'serialObject',s,'param',fieldnames(idxFields),'value',channelStruct.(strcat(fieldnames{idxFields}))(idx));
                                        end
                                    end
                                    if ischar(oldStruct.(strcat(fieldnames{idxFields})){idx}) % (cell)Parametervalue is string (DeltaTronVoltage)
                                        if ~strcmp(oldStruct.(strcat(fieldnames{idxFields})){idx}, channelStruct.(strcat(fieldnames{idxFields})){idx})
                                            ita_nexus_sendCommand('device',channelStruct.Device{idx},'channel',channelStruct.Channel(idx),'serialObject',s,'param',fieldnames(idxFields),'value',channelStruct.(strcat(fieldnames{idxFields}))(idx));
                                        end
                                    end
                                else % Parametervalues are saved in array
                                    if isnumeric(oldStruct.(strcat(fieldnames{idxFields}))(idx)) % (array)Parametervalue is numeric (Channel,OutputSens,TransducerSens)
                                        if (oldStruct.(strcat(fieldnames{idxFields}))(idx) ~= channelStruct.(strcat(fieldnames{idxFields}))(idx))
                                            ita_nexus_sendCommand('device',channelStruct.Device{idx},'channel',channelStruct.Channel(idx),'serialObject',s,'param',fieldnames(idxFields),'value',channelStruct.(strcat(fieldnames{idxFields}))(idx));
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if verboseMode, disp([   ' ITA_NEXUS_SENDCOMMAND: Old and new channelstruct''s Elements have not the same length. I''ll send the whole new one ', msg   ]), end;
                    diff_channelStruct = channelStruct;
                end
            end
        else
            if verboseMode, disp([   ' ITA_NEXUS_SENDCOMMAND: Old and new channelstruct have not the same length. I''ll send the whole new one ', msg   ]), end;
            diff_channelStruct = channelStruct;
        end
    else
        diff_channelStruct = channelStruct;
    end
else
    diff_channelStruct = channelStruct;
end

% Send diff_CH
if ~isempty(diff_channelStruct)
    if ~isempty(diff_channelStruct.Device) %if ~isempty(diff_channelStruct.(strcat(fieldnames{1})))
        diff_fieldnames = fields(diff_channelStruct);
        for idx = 1 : length(diff_channelStruct.Device)
            channel = diff_channelStruct.Channel(idx); % set channel & device by index
            device = diff_channelStruct.Device{idx};
            for idxFields = 1 : numel(diff_fieldnames)
                if strcmp(diff_fieldnames{idxFields},'Channel') % channel is already determined -> skip
                    continue;
                end
                if strcmp(diff_fieldnames{idxFields},'Device') % channel is already determined -> skip
                    continue;
                end
                if iscell(diff_channelStruct.(strcat(diff_fieldnames{idxFields}))) % cell as input? (Filter)
                    if ~isempty(diff_channelStruct.(strcat(diff_fieldnames{idxFields}))(idx))
                        value = diff_channelStruct.(strcat(diff_fieldnames{idxFields}))(idx);
                        ita_nexus_sendCommand('device',device,'channel',channel,'param',diff_fieldnames(idxFields),'value',value,'serialObject',s)  %use ita_nexus_sendCommand as recursive function with values read from inputstruct
                        %                     ita_nexus_sendCommand('NI',sArgs.NI,'device',device,'channel',channel,'param',diff_fieldnames(idxFields),'value',value,'serialobject',s)  %use ita_nexus_sendCommand as recursive function with values read from inputstruct
                    end
                else
                    if ~isempty(diff_channelStruct.(strcat(diff_fieldnames{idxFields}))(idx))
                        value = diff_channelStruct.(strcat(diff_fieldnames{idxFields}))(idx);
                        ita_nexus_sendCommand('device',device,'channel',channel,'param',diff_fieldnames(idxFields),'value',value,'serialObject',s)  %use ita_nexus_sendCommand as recursive function with values read from inputstruct
                        %                     ita_nexus_sendCommand('NI',sArgs.NI,'device',device,'channel',channel,'param',diff_fieldnames(idxFields),'value',value,'serialobject',s)  %use ita_nexus_sendCommand as recursive function with values read from inputstruct
                    end
                end
            end
        end
    end
end

% Output
oldStruct = {}; % refresh persistent variable
oldStruct{1} = channelStruct;
oldStruct{2} = fieldnames;
end
%% Outputsensitivity Converter
% This integrated function modifies numerical values from OutputSens-input
% into valid strings for the command you want to send to the Nexus
function out = ita_nexus_outputsensitivity_converter(in)
in = double(in);
power = log10(in);

if      9<=power & power<12
    out = [num2str(abs(in*1e-9)),'G'];
elseif 6<=power & power<9
    out = [num2str(abs(in*1e-6)),'MA'];
elseif 3<=power & power<6
    out = [num2str(abs(in*1e-3)),'K'];
elseif 0<=power & power<3
    out = [num2str(abs(in))];
elseif -3<=power & power<0
    out = [num2str(abs(in*1e3)),'M'];
elseif -6<=power & power<-3
    out = [num2str(abs(in*1e6)),'U'];
elseif -9<=power & power<-6
    out = [num2str(abs(in*1e9)),'P'];
else   -12<=power & power<-9
    out = [num2str(abs(in*1e12)),'F'];
end

out = regexprep(out,'\.','_');
end

%% Send Data
% Here the above created and proofed command is send to the Nexus in blocks
% of variable size
function  ita_write_data_in_blocks(s,data_in,itapause)
data_in = double(data_in{1});
data_in = [data_in 10]; % add Terminator <Te>
blocklength = 4;
restlength = rem(length(data_in),blocklength);                                                 % divide into blocks and find out the rest length
for i = 1:length(data_in)/blocklength;                                                        % write blocks
    fwrite(s, data_in([i*blocklength-(blocklength-1):i*blocklength]))
    pause(max(itapause,0.01))
end
if ~isempty(data_in([end-restlength+1:end])), fwrite(s, data_in([end-restlength+1:end])), end % write rest
end

%% Echoe/Answer from Nexus Device
function ita_get_data_out(s,value)
% read out data, the nexus has sent back to the serial object
if strcmp(value, '?')                                               %query-message
    pause(0.02)
    [msg,count] = fscanf(s,'%c',s.BytesAvailable/8);                 % read out sent message and number of signs
    % 	msg = fscanf(s);                                                     % read out value you want to know
    if s.BytesAvailable ~= 0                                                  % if there's still something written in the serialobj., msg is not what you want -> overwrite
        msg = fscanf(s);
    end
    if s.BytesAvailable ~= 0
        msg = fscanf(s);
    end
    msg = regexprep(msg,'\s$','');                                      % delete empty space at end of string
    ita_verbose_info([   ' returned message: ', msg   ],1);
else
    if s.BytesAvailable ~= 0
        pause (0.02)
        data_out = fscanf(s,'%c',s.BytesAvailable);
        data_out = regexprep(data_out,'\s$',''); % delete empty space at end of string
        ita_verbose_info(['ITA_NEXUS_SENDCOMMAND: ', num2str(data_out)  ],1)
    end
end
end
