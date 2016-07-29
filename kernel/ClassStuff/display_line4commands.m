function display_line4commands(givenCommands, audioObjName)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% This functions displays a line of links.
% 
% Usage:
%   display_line4commands({element_1, element_2, ..., element_n})
%   
%   element_x   can be a string for plain text
%                      a cell for a link
%
%   The links can be given by just the commmand, or by the command and a
%   description.
%
%   Example:
%       display_line4commands({'preText', {'Link'}, {'Link', 'Description'}})

for iCommand = 1:numel(givenCommands)
    commandElement = givenCommands{iCommand};
    if iscell(commandElement)
        command = commandElement{1};        
        iSpace = strfind(command, '__');
        for iPlace = numel(iSpace):-1:1
            iSpacePlace = iSpace(iPlace);
            command = [command(1:iSpacePlace-1) audioObjName command(iSpacePlace+2:end)];
        end
        % if the cell contains more than one element, the command and the
        % link name was given
        if numel(commandElement) == 2
            commandText = commandElement{2};
        else
            commandText = command;
        end
        fprintf(['<a href = "matlab: ' command '">' commandText '</a>'])
        fprintf('  ')
    else
        % it is not a link, just display it
        fprintf(commandElement)
        fprintf(' ')
    end    
end
fprintf('\n')

% function addInputname(audioObjName)

end