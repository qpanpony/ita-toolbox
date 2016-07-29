function bindb_disconnect()
% Synopsis:
%   bindb_disconnect()
% Description:
%    Disconnect from the database.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Declare globals
global bindb_data;

% Close connections
if ~isempty(bindb_data.sqlConn)
    close(bindb_data.sqlConn);
end

% Add log entry
bindb_addlog('manual disconnect');
