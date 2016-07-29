function ita_menucallback_GenerateSweep(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>





ele = 1;
pList{ele}.description = 'Type of sweep';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'char_popup';
pList{ele}.list     = 'exponential|linear';
pList{ele}.default     = 'exponential';

ele = 2;
pList{ele}.description = 'fftDegree';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'int';
pList{ele}.default     = ita_preferences('fftDegree');

ele = 3;
pList{ele}.description = 'Sampling rate';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'int';
pList{ele}.default     = ita_preferences('samplingRate');


ele = 4;
pList{ele}.description = 'Stop margin';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'char_long';
pList{ele}.default     = '0.1';


ele = 5;
pList{ele}.description = 'Freq Range';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'int_long';
pList{ele}.default     = '5   20000';

ele = 6;
pList{ele}.description = 'Bandwidth';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'char_long';
pList{ele}.default     = '2/12';

ele = 7;
pList{ele}.description = 'Novak';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'bool';
pList{ele}.default     = false;


ele = 8;
pList{ele}.datatype    = 'line';

ele = 9;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI


%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Merge two itaAudio objects']);
if ~isempty(pList)
    result = ita_generate_sweep('mode',pList{1}, 'fftDegree', pList{2}, 'samplingRate',pList{3},...
        'stopMargin',ita_str2num(pList{4}) ,'freqRange',ita_str2num(pList{5}),'bandwidth',ita_str2num(pList{6}),'novak',pList{7},'gui',false);
    fgh = ita_guisupport_getParentFigure(hObject);
    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end


end