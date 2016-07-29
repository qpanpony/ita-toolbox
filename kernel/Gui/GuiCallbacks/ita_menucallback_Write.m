function ita_menucallback_Write(hObject, ~)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


fgh = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');

if isempty(audioObj) % call gui to chose file in workspace
    ita_write()
else                 % save audio 
%     audioObj.fileName = getappdata(fgh, 'VarInUse');
    ita_write(audioObj, '');
end

end