function [command] = searchTableWildcard(stringCell, columnNames, tableName, sortBy)


% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

numOfStrings = length(stringCell);
numOfColumns = length(columnNames);

sqlConnection = 0;

%SELECT ... FROM ...
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
command = [command 'from ', tableName, ' where '];

%Conditions
for j = 1:numOfStrings
    command = [command, '('];
    for k = 1:numOfColumns-4
        %ignore empty columns
       if ~isempty(columnNames{k})
            command = [command, columnNames{k}, ' like ', char(39),'%', stringCell{j}, '%',char(39)];
       end
       %last column or next column empty?
       if k ~= numOfColumns-4 && ~isempty(columnNames{k+1})
          command = [command, ' or '];
       end
    end
    
    %last searchkey?
    if j ~= numOfStrings
        command = [command, ') and '];
    else
        command = [command, ')'];        
    end
end
%Order
command = [command, ' order by ', sortBy];