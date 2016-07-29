function ita_menucallback_Generate(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

result = ita_generate_gui;

fgh = ita_guisupport_getParentFigure(hObject);
setappdata(fgh, 'audioObj', result);
ita_guisupport_updateGUI(fgh);
end