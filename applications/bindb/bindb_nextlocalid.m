function id = bindb_nextlocalid( type )
% Synopsis:
%   id = bindb_nextlocalid( type )
% Description:
%   Returns the next unsued local id for an item of a certain type.
% Parameters:
%   (string) type
%	Specifies the type which the new id will be standing for. Can have 2
%	values, 'room' for an entry of type room, and 'measurement' for an
%	entry of type measurement.
% Returns:
%   (int) id
%	The next unused id for the given type.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Declare globals
global bindb_data;

% Initialize id
id = 0;

if strcmp(type, 'room')
    % Find next free room id
    for index = 1:length(bindb_data.Rooms_Outbox)
        if bindb_data.Rooms_Outbox(index).ID < id
            id = bindb_data.Rooms_Outbox(index).ID;
        end
    end
else
    % Find next free measurement id
    for index = 1:length(bindb_data.Measurements_Outbox)
        if bindb_data.Measurements_Outbox{index}.ID < id
            id = bindb_data.Measurements_Outbox{index}.ID;
        end
    end
end

% Next id
id = id - 1;

