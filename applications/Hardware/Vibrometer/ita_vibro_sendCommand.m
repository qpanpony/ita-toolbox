function varargout = ita_vibro_sendCommand(varargin)
%ITA_VIBRO_SENDCOMMAND - send a command via RS232 to the polytec laser-vibrometer
%  This function takes a command, a serial object and a string specifying
%  the destination device as input arguments and sends the command to the
%  device. The function returns a boolean value whether the command was
%  sent to the device, where the device is either 'controller' or
%  'interface'.
%  This function is also called from ITA_VIBRO_LASERGUI, which is why
%  it is also possible to give a handle structure instead of the serial
%  object.
%
%  default serial port setings ('BaudRate',9600,'DataBits',8,'StopBits',1);
%  Call: sent = ita_vibro_sendCommand(command,serialObject,'controller'/'interface')
%  Call: sent = ita_vibro_sendCommand(command,handles,'controller'/'interface')
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_plot_surface, ita_deal_units, ita_impedance2apparementmass, ita_measurement_setup, ita_measurement_run, ita_RS232_ITAlian_init, ita_measurement_polar
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_vibro_sendInterfaceCommand">doc ita_vibro_sendInterfaceCommand</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 25-Nov-2008

%% Initialization
% Number of Input Arguments
narginchk(2,3);
global controller_serial;
global interface_serial;

if ischar(varargin{1}) % first argument is the command
    command = varargin{1};
    % second argument handle structure
    if nargin > 2 && isstruct(varargin{2})
        handles = varargin{2};
        mode = 'handles';
        % third argument is 'controller' or 'interface'
        if ischar(varargin{3})
            type = varargin{3};
        else
            error('ita_vibro_sendCommand::Oh Lord. Where should I send the command?');
        end
    elseif nargin == 2 && ischar(varargin{2})
        mode = 'serial';
        type = varargin{2};
        if strcmpi(type,'controller')
            if isempty(controller_serial)
                ita_vibro_init;
            end
            serialObject = controller_serial;
        elseif strcmpi(type,'interface')
            if isempty(interface_serial)
                ita_vibro_init;
            end
            serialObject = interface_serial;
        else
            error('ita_vibro_sendCommand: wrong type, must be ''controller'' or ''interface''!');
        end
    else
        error('ita_vibro_sendCommand:Oh Lord. I need a serial object or handles.')
    end
else
    error('ita_vibro_sendCommand:Oh Lord. I need a command.')
end

%% Body
% split the commands
comParts = regexp(command,';','split');
if isempty(comParts{end})
    nCommands = length(comParts)-1;
else
    nCommands = length(comParts);
end

% if called from ITA_VIBRO_LASERGUI
if strcmp(mode,'handles')
    resp = '';
    if strcmp(type,'interface')
        % for controller and interface mode, serial object is stored in
        % handles.interfaceSo
        if strcmp(handles.mode,'CI')
            serialObject = handles.interfaceSo;
        else
            % if in controller mode, commands to the interface don't make
            % sense
            if strcmp(handles.mode,'C')
                resp = 'C';
            end
            serialObject = handles.so;
        end
    else
        serialObject = handles.so;
    end
end

% RS232 init
% try to open the serial port if not open yet
if ~strcmp(serialObject.Status,'open')
    fopen(serialObject);
end
if ~strcmp(serialObject.Status,'open')
    error('ita_vibro_testScan::serial connection could not be opened');
end

% where to send the command
if strcmp(type,'interface')
    fwrite(serialObject,sprintf([command '\n']));
    % the interface should return something
    if nCommands == 1
        [sent,count,msg] = fgetl(serialObject);
        if ~isempty(msg)
            ita_verbose_info(['ita_vibro_sendCommand::warning, problem occurred while reading from serial port -> ' msg],1);
            fclose(serialObject);
            fopen(serialObject);
            sent = ita_vibro_sendCommand(varargin{:});
        end
    else % if more than one command get answer for every command
        sent = '';
        for i=1:nCommands
            [tmp,count,msg] = fgetl(serialObject);
            if ~isempty(msg)
                ita_verbose_info(['ita_vibro_sendCommand::warning, problem occurred while reading from serial port -> ' msg],1);
                fclose(serialObject);
                fopen(serialObject);
                tmp = ita_vibro_sendCommand(varargin{:});
            end
            sent = [sent tmp];
        end
        condition = ~isempty(findstr(sent,'E1')) || ~isempty(findstr(sent,'E2')) || ~isempty(findstr(sent,'E3')) || ~isempty(findstr(sent,'E4'));
        if condition
            sent = 'E2';
        else
            sent = '*';
        end
    end
    if strcmp(mode,'handles')
        if strcmp(sent(1),'*')
            sent = [command ' <-> OK'];
        elseif strcmp(resp,'C')
            sent = 'controller mode!';
        elseif strcmp(sent(1:2),'E1')
            sent = 'syntax incorrect';
        else
            sent = 'bad command';
        end
    end
    % the controller does not return anything, usually
elseif strcmp(type,'controller')
    % again, controller commands in interface mode don't make sense
    if strcmp(mode,'handles') && strcmp(handles.mode,'I')
        sent = false;
    else
        fwrite(serialObject,sprintf([command '\n']));
        sent = true;
    end
end
ita_verbose_info(['ita_vibro_sendCommand::' num2str(nCommands) ' commands sent.'],2);

% if something went wrong, sent will be empty
if isempty(sent)
    ita_verbose_info('ita_vibro_sendCommand::warning, response is empty, probably a serial port error; inserting E2 as response',1);
    sent = 'E2';
end
varargout(1) = {sent};
%end function
end