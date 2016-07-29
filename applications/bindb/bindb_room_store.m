function bindb_room_store()
% Synopsis:
%   bindb_room_store()
% Description:
%   Store all rooms in localdata folder.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Get room
rooms_data = bindb_data.Rooms;

% Get rooms outbox
rooms_outbox_data = bindb_data.Rooms_Outbox;

% Save to localdata
save(bindb_filepath('localdata', 'rooms.mat'), 'rooms_data', 'rooms_outbox_data');

% Add log entry
if isempty(rooms_outbox_data)
    bindb_addlog('room store', [num2str(length(rooms_data)) ' rooms stored'], 0);
else
    bindb_addlog('room store', [num2str(length(rooms_data)) '(+' num2str(length(rooms_outbox_data)) ') rooms stored'], 0);
end