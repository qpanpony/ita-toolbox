function ita_menucallback_varselect(hObject, eventdata)
% Callback routine for click on a var in the menu list

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

varname = get(hObject,'UserData');

audio = evalin('base', varname);
audio.fileName = varname;

fgh = ita_guisupport_getParentFigure(hObject);
setappdata(fgh, 'audioObj', audio)
ita_guisupport_updateGUI(fgh)
end

