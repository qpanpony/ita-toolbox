function bindb_room_get()
% Synopsis:
%   bindb_room_get()
% Description:
%   Load all rooms into the global data struct.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

if bindb_isonline()
    % Reset rooms
    bindb_data.Rooms = struct('ID', {}, 'Name', {}, 'Description', {}, 'Layout', {});
    
    % Get room data
    rooms_data = bindb_query('SELECT `O_ID`, `Name`, `Description`, `Layout` FROM `Rooms` ORDER BY `Name`');

    % No results
    if strcmp(rooms_data, 'No Data')  
        % Add log entry
        bindb_addlog('room get', 'no rooms loaded', 0);             
    else    
        % Update rooms
        for index = 1:size(rooms_data, 1)
            room.ID = rooms_data{index, 1};
            room.Name = rooms_data{index, 2};
            room.Description = rooms_data{index, 3};
            room.Layout = rooms_data{index, 4};
            bindb_data.Rooms(end+1) = room;
        end
        
        % Add log entry
        bindb_addlog('room get', [num2str(size(rooms_data, 1)) ' rooms loaded'], 0);
    end
end