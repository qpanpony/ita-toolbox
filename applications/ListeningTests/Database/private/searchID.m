function [command] = searchID(stringCell, columnNames, tableName)


% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

numOfStrings = length(stringCell);
numOfColumns = length(columnNames);

%SELECT ... FROM ...
command = ['select ID from ', tableName, ' where '];

%Conditions
for j = 1:numOfStrings
    command = [command, '('];
    for k = 1:numOfColumns-4
        %ignore emtpy columns
        if ~isempty(columnNames{k})
            command = [command, columnNames{k}, ' in (', char(39), stringCell{j}, char(39), ')'];
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
command = [command, ' order by ', columnNames{1}];