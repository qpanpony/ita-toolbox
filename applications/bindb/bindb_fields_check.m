function state = bindb_fields_check()
% Synopsis:
%   state = bindb_fields_check()
% Description:
%   Checks if the field tables are in a healty state.
% Returns:
%   (int) state
%	If the field tables are healthy, the state is 1 otherwise it is 0.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Get data
realdata = bindb_query('SHOW COLUMNS FROM `Measurements`');    
metadata = bindb_query('SELECT `Name`, `Description`, `Type` FROM `Fields`');    

% Remove system columns
cutdata = cell(0, 1);
for index = 1:size(realdata, 1)
    if strcmp(realdata{index, 3}, 'YES') && ~strcmp(realdata{index, 1}, 'Comment')  
        cutdata{end+1} = realdata{index, 1};
    end
end

% Prepare metadata
if length(metadata) == 1 && strcmp(metadata{1}, 'No Data')
    cutmetadata = cell(0, 1);
else
    cutmetadata = metadata(:, 1)';
end

% Compare data
errors = 0;
if size(cutdata, 1) ~= size(cutmetadata, 1)
    errors = 1;    
else
    for real = 1:size(cutdata, 1)
        found = 0;
        % Search corresponing name
        for meta = 1:size(cutmetadata, 1)
            if strcmp(cutdata{real, 1}, cutmetadata{meta, 1})
                found = 1;
            end
        end
        
        % Found name?
        if ~found
            errors = 1;
        end
    end
end

% found errors?
state = (errors == 0);