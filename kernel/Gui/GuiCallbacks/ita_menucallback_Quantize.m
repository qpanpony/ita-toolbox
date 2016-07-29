function ita_menucallback_Quantize(hObject, eventdata)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');

ele = 1;
pList{ele}.datatype = 'itaAudioFix';
pList{ele}.description = 'Audio to quntize';
pList{ele}.default = audioObj;
pList{ele}.helptext = '';


ele = ele + 1;
pList{ele}.datatype = 'double';
pList{ele}.description = 'bits';
pList{ele}.default = 24;
pList{ele}.helptext = 'Number of bits used';

ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI

pList = ita_parametric_GUI(pList,'Quantize');
if ~isempty(pList)
   
    result = ita_quantize(pList{1},'bits',pList{2});
    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end






end