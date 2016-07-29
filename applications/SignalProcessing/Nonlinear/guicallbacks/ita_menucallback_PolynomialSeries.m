function ita_menucallback_PolynomialSeries(hObject, eventData)

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');

ele = 1;
pList{ele}.description = 'Input Data';
pList{ele}.helptext    = 'This is the itaAudio as input data';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = audioObj;

ele = ele + 1;
pList{ele}.description = 'Polynomial Vector';
pList{ele}.helptext    = 'This is the vector with the frequency independent coefficients for the power series.';
pList{ele}.datatype    = 'double';
pList{ele}.default     = [1 0.1 0.1 0.1];

ele = ele + 1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Polynomial Series']);

if ~isempty(pList)
    
    result = ita_nonlinear_power_series(pList{1},pList{2});
    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end

end