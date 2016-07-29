function ita_menucallback_TimeShift(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');



ele =  1;
pList{ele}.description = 'Selected audio object';
pList{ele}.helptext    = 'Current Object in GUI figure';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = audioObj;

ele = length(pList) + 1;
pList{ele}.description = 'Shifting Time';
pList{ele}.helptext    = 'Cyclic shift in time domain by this value' ;
pList{ele}.datatype    = 'int';
pList{ele}.default     = 0;

ele = length(pList) + 1;
pList{ele}.description = 'Unit';
pList{ele}.helptext    = 'shift samples or seconds' ;
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = 'time';
pList{ele}.list        = 'time|samples';

ele = length(pList) + 1;
pList{ele}.datatype    = 'line';

ele = length(pList) + 1;
pList{ele}.datatype    = 'text';
pList{ele}.description    = 'Advanced Settings';

ele = length(pList) + 1;
pList{ele}.description = 'Mode';
pList{ele}.helptext    = 'Normal mode just shifts by the time specified. Auto tries to get the maximum to 0 seconds. Threshold get the point x dBs before the maximum to 0 seconds.' ;
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = 'normal';
pList{ele}.list        = 'normal|auto|threshold';

ele = length(pList) + 1;
pList{ele}.description = 'Threshold [dB]';
pList{ele}.helptext    = 'only used if threshold mode is choosen.' ;
pList{ele}.datatype    = 'int';
pList{ele}.default     = '30';

pList{ele}.default     = false;

ele = length(pList) + 1;
pList{ele}.datatype    = 'line';


ele = length(pList) + 1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI


%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Time Shifting for itaAudio objects']);
if ~isempty(pList)
    if pList{2} ~= 0; pList{4} = 'normal'; end
    switch lower(pList{4})
        case 'normal'
            result = ita_time_shift(pList{1},pList{2}, pList{3});
        case 'auto'
            result = ita_time_shift(pList{1});
        case 'threshold'
            result = ita_time_shift(pList{1},pList{5});
    end
    setappdata(fgh, 'audioObj', result);
    
    % change to time domain
    if isempty(strfind(getappdata(fgh, 'ita_domain'), 'time'))
        setappdata(fgh, 'ita_domain', 'time in db')
    end
    
    ita_guisupport_updateGUI(fgh);
    
end