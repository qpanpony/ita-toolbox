function ita_menucallback_TimeCrop(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');




%     if ita_preferences('plotcursors')
%         vec = ita_plottools_cursors();
%         start_time = vec(1);
%         end_time = vec(2);
%     else
start_time = 0;
end_time = min(1, audioObj.trackLength/2);
%     end

ele = 1;
pList{ele}.description = 'First itaAudio';
pList{ele}.helptext    = 'This is the first itaAudio for addition';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = audioObj;

ele = 2;
pList{ele}.description = 'Beginning [s]';
pList{ele}.helptext    = 'start cropping here';
pList{ele}.datatype    = 'double';
pList{ele}.default     = start_time;

ele = 3;
pList{ele}.description = 'End [s]';
pList{ele}.helptext    = 'end cropping here';
pList{ele}.datatype    = 'double';
pList{ele}.default     = end_time;

ele = 4;
pList{ele}.datatype    = 'line';

ele = 5;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Add two itaAudio objects']);
if ~isempty(pList)
    result = ita_time_crop(pList{1},[pList{2} pList{3}],'time');
    
    setappdata(fgh, 'audioObj', result);

    ita_guisupport_updateGUI(fgh);
end




end