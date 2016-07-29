function varargout = ita_movtec_init(varargin)
%ITA_MOVTEC_INIT - this function looks for a defined com-port in
%   ita_preferences or use the assigned one to connect to the movtec. So
%   the easiest way is to make sure that ita_preferences('movtecComPort')
%   is defined (if not, just toggle ita_preferences one the commandprompt).
%   A call without an output argument will create a global variable
%   serial_movtec !
%
%  Syntax: serialObj = ita_movtec_init()
%        serialObj = ita_movtec_init('com_port')
%        ita_movtec_init()          % creates a globale serial-object
%        ita_movtec_init('com_port')
%

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  28-Jan-2010

thisFuncStr  = [upper(mfilename) ':'];
com_port = [];

% check input arguments
error(nargchk(0,1,nargin,'string'));
if nargin == 0
    if ~strcmp(ita_preferences('movtecComPort'), 'noDevice')
        com_port = ita_preferences('movtecComPort');
        disp([thisFuncStr 'Trying '  com_port ', defined in ita_preferences...'])
        varargout(1) = {true};
    else
        ita_verbose_info([thisFuncStr ' There is no com_port available!'],0);
        varargout(1) = {false};
    end
elseif ischar(varargin{1})
    com_port = varargin{1};
    varargout(1) = {true};
else
    error([thisFuncStr 'Com Port must be a string.']);
end

if ~isempty(com_port)
    %% Init RS232 and return handle
    insts = instrfind;         %show existing terminals using serial interface
    delete(insts);             %delete used serial ports
    s = serial(com_port,'Baudrate',9600,'Databits',8,'Stopbits',1,'OutputBufferSize',3072);
    
    % check serial connection
    if ~strcmp(s.Status,'open')
        fopen(s);
    end
    if ~strcmp(s.Status,'open')
        error([thisFuncStr 'serial connection could not be opened']);
    end
    
    fwrite(s,hex2dec('15'));               % Kill old commandos Motor 1
    fwrite(s,hex2dec('35'));               % Kill old commandos Motor 2
    fwrite(s,hex2dec('55'));               % Freigabe-Kommando senden (Motor)
    
    %% Find output parameters
    if nargout == 0 %User has not specified a variable
        global serial_movtec;
        serial_movtec= s;
        ita_verbose_info([thisFuncStr 'global variable serial_movtec defined successfully!'],0);
    else
        varargout(1) = {s};
    end
end
%EOF
end