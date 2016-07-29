function [command] = listTable(columnNames, tableName, sortBy)


% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

numOfColumns = length(columnNames);


command = 'select ';

for k = 1:numOfColumns
    if isempty(columnNames{k})
        command = [command char(39) char(39) 'AS' char(39) char(39) ' '];
    else
        command = [command columnNames{k} ' '];
    end
    if k ~= numOfColumns
        command = [command ','];
    end
end

command = [command 'from ', tableName, ' order by ', sortBy];