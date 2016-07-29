function ita_menucallback_ExportToWorkspace()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

% fgh        = ita_guisupport_getParentFigure(hObject);
fgh = gcf; % no input variable due to strange call from ita_menu
audioObj = getappdata(fgh, 'audioObj');


ele = 1;
pList{ele}.description = 'First itaAudio';
pList{ele}.helptext    = 'Current Object in GUI figure';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = audioObj;


ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Variable Name';
pList{ele}.helptext    = 'Chose variable name to export to workspace';
pList{ele}.datatype    = 'char';
pList{ele}.default     = 'objectFromFigure';

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Export current object to workspace']);

if ~isempty(pList)
    
    assignin('base', pList{2}, pList{1})
end
end