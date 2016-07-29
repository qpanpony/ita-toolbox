function ita_menucallback_Read(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

audioObject = ita_read;
if ~ isempty(audioObject)
    [junk,name,junk] = fileparts(audioObject(1).fileName);
    
    % save in workspace
    assignin('base',name,audioObject);
    
    % save data in figure and plot
    fgh = ita_guisupport_getParentFigure(hObject);
    setappdata(fgh, 'audioObj', audioObject);
    ita_guisupport_updateGUI(fgh)
end
end