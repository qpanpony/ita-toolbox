function bindb_fields_store()
% Synopsis:
%   bindb_fields_store()
% Description:
%   Save all fields in the localdata folder.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;
    

% Get fields
fields_data = bindb_data.Fields;

if ~isempty(fields_data)
    % Save to localdata
    save(bindb_filepath('localdata', 'fields.mat'), 'fields_data');

    % Add log entry
    bindb_addlog('fields store', [num2str(length(fields_data)) ' fields stored'], 0);
else
    % Add log entry
    bindb_addlog('fields store', 'no fields stored', 0);
end