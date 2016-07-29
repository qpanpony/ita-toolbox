function varargout = ita_guisupport_audiolistdialog(varargin)
%ITA_GUISUPPORT_AUDIOLISTDIALOG - Dialog to select ITA objects
%  This function displays a dialog with a list of all the ITA objects from 
%  the workspace to select from
%
%  Syntax:
%   audioObj = ita_guisupport_audiolistdialog(audioObj)
%
%  Example:
%   audioObj = ita_guisupport_audiolistdialog(audioObj)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_guisupport_audiolistdialog">doc ita_guisupport_audiolistdialog</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  23-Jun-2009

%% get worksapce list and display in dialog to select
[List, varStruct ,CellList] = ita_guisupport_getworkspacelist; %#ok<ASGLU>

[index, ok] = listdlg('Name','Select Object(s)',...
    'PromptString','Select object(s):',...
    'SelectionMode','multiple',...
    'ListString',CellList(:,2),'InitialValue',[],'ListSize',[400 400]);

if ok
    for idx = 1:numel(index)
        result(idx) = ita_getfrombase(CellList{index(idx),1}); %#ok<AGROW>
    end
else
    result = [];
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
else
    % Write Data
    varargout(1) = {result};
end

%end function
end