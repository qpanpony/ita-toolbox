function bindb_fields_get()
% Synopsis:
%   bindb_room_get()
% Description:
%   Load all fields into the global data struct.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;
    
% Get fields data
if bindb_isonline()
    % Check if db is in healthy state
    if bindb_fields_check() ~= 1
        bindb_addlog('fields get', 'fields tables are not in healty state, database maintenance is required', 1);
        return;
    end
    
    % Reset fields
    bindb_data.Fields = struct('Name', {}, 'Description', {}, 'Type', {}, 'Values', {});
    
    % Get data
    fields_data = bindb_query('SELECT `Name`, `Description`, `Type`, `Values` FROM `Fields` ORDER BY `Name` DESC');

    if ~strcmp(fields_data, 'No Data')  
        for index = 1:size(fields_data, 1)
            field.Name = fields_data{index, 1};
            field.Description = fields_data{index, 2};
            field.Type = fields_data{index, 3};
            field.Values = fields_data{index, 4};
            bindb_data.Fields(end+1) = field;
        end    
        
        % Add log entry
        bindb_addlog('fields get', [num2str(length(bindb_data.Fields)) ' fields loaded'], 0);
    else        
        % Add log entry
        bindb_addlog('fields get', 'no fields found', 0);  
    end
end

