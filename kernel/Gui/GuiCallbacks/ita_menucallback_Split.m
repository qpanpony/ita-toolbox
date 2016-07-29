function ita_menucallback_Split (hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

fgh = ita_guisupport_getParentFigure(hObject);

ele = 1;
pList{ele}.description = 'Selected audio object';
pList{ele}.helptext    = 'Current Object in GUI figure';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = getappdata(fgh, 'audioObj');


ele = 2;
pList{ele}.datatype    = 'line';

ele = 3;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI


%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Merge two itaAudio objects']);
if ~isempty(pList)
    result = pList{1};
    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end

end