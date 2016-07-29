function ita_menucallback_PeakFilter(hObject, event)
%TODO input arguments

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');


ele = 1;
pList{ele}.description = 'Audio object to filter';
pList{ele}.helptext    = 'This is the first itaAudio';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = audioObj;



ele = ele+1;
pList{ele}.description = 'Center frequnecy';
pList{ele}.helptext    = 'fc';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 1000;


ele = ele+1;
pList{ele}.description = 'Gain in dB';
pList{ele}.helptext    = 'gain';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 20;

ele = ele+1;
pList{ele}.description = 'Q';
pList{ele}.helptext    = 'Q';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 2;

ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - peak filter']);
if ~isempty(pList)
    
    result = ita_filter_peak(pList{1}, 'Q', pList{4},'fc',pList{2},'gain',pList{3});
    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end

end
