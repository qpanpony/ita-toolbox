function ita_menucallback_FractionalOctaveBands(hObject, event)

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
pList{ele}.description = 'Bands per octave';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'int';
pList{ele}.default     = ita_preferences('bandsPerOctave');

ele = ele+1;
pList{ele}.description = 'Freq Range';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'int_long';
pList{ele}.default     = ita_preferences('freqRange');


ele = ele+1;
pList{ele}.description = 'zerophase';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'bool';
pList{ele}.default     = true;

ele = ele+1;
pList{ele}.description = 'Filter Order';
pList{ele}.helptext    = '';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 10;

ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Fractional octave band filter']);
if ~isempty(pList)
   
    result = ita_filter_fractional_octavebands(pList{1}, 'bandsperoctave', pList{2}, 'freqRange', pList{3},'zerophase', pList{4} ,'order',pList{5});

    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end

end