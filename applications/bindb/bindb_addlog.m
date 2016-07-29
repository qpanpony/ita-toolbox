function bindb_addlog( source, message, open )
% Synopsis:
%   bindb_addlog( source, message, open )
% Description:
%   Creates a log entry and updates the log window.
% Parameters:
%   (string) source
%       The source of the message. Usually the current gui.
%   (string) message
%       The message of the log entry.
%   (int) open
%       If true, the log window is opened. Only for important
%       entries.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


global bindb_data;
bindb_data.Log = [{datestr(now, 'HH:MM:SS'), source, message}; bindb_data.Log];

% Update log if opened
global bindb_logtable
if open
    bindb_gui_log;
elseif ishandle(bindb_logtable)
    set(bindb_logtable, 'Data', bindb_data.Log);
end

