function ita_menucallback_OrtskurveHoheResonanz(hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


choice = questdlg('Do you like to calibrate your system (reference resistant)?', ...
 'Lab V5 - Calibration', ...
 'Yes','No','Yes');
if strcmp(choice,'Yes')
    ita_preferences;
    uiwait();
    MS = ita_measurement;
    MS.calibrate;
    assignin('base', 'MS', MS);
end
MS = evalin('base', 'MS');
Z = MS.run;
ita_laboratory_v5_nyquistplot(Z, 'Ortskurve bei hoher Resonanz');
end