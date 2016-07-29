function ita_menucallback_Add(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');


ele = 1;
pList{ele}.description = 'First itaAudio';
pList{ele}.helptext    = 'Current Object in GUI figure';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = audioObj;

ele = 2;
pList{ele}.description = 'Second itaAudio';
pList{ele}.helptext    = 'This is the second itaAudio for merge';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';

ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Add two itaAudio objects']);

if ~isempty(pList)
    
    result = ita_add(pList{1},pList{2});
    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end
end