function bindb_store()
% Synopsis:
%   bindb_store()
% Description:
%   Stores all information from the global data struct in the root
%   directory using a MAT file.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Declare globals
global bindb_data;

% Make copy
data = bindb_data;

% Remove connections/fields/rooms/measurements
data.sqlConn = [];
data.ImpulseResponsePath = [];
data.Fields = [];
data.Rooms = [];
data.Rooms_Outbox = [];
data.Measurements = [];
data.Measurements_Outbox = [];

% Remove log if wanted
if ~data.Settings.KeepLog
    data.Log = [];
end

% Save data
save(bindb_filepath('localdata', 'system.mat'), 'data');

end

