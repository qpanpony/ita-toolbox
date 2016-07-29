function ita_menucallback_DivideSpectrum(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');

ele = 1;
pList{ele}.description = 'Numerator';
pList{ele}.helptext    = 'This is the first itaAudio for the numerator';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = audioObj;

ele = length(pList) + 1;
pList{ele}.description = 'Denominator';
pList{ele}.helptext    = 'This is the second itaAudio for the denominator';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';

ele = length(pList) + 1;
pList{ele}.datatype    = 'line';

ele = length(pList) + 1;
pList{ele}.datatype    = 'text';
pList{ele}.description = 'Regularization';

ele = length(pList) + 1;
pList{ele}.description = 'Use Regularization';
pList{ele}.helptext    = 'This is a method to maintain the frequency range of the numerator spectrum and get good IR behavior.';
pList{ele}.datatype    = 'bool';
pList{ele}.default     = false;

ele = length(pList) + 1;
pList{ele}.description = 'Low Cutoff Frequency';
pList{ele}.helptext    = 'Low Frequency for regularization';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 20;

ele = length(pList) + 1;
pList{ele}.description = 'High Cuttoff Frequency';
pList{ele}.helptext    = 'High Frequency for regularization';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 20000;

ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Divide two itaAudio Objects']);
if ~isempty(pList)
    
    if pList{3} %with regularization
        result = ita_divide_spk(pList{1},pList{2},'regularization',[pList{4} pList{5}]);
    else %without
        result = ita_divide_spk(pList{1},pList{2});
    end
    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end

end