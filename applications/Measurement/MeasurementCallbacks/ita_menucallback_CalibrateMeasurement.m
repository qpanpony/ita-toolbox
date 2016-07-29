function ita_menucallback_CalibrateMeasurement(hObject, eventdata) %#ok<INUSD>
% gets variables from Workspace

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

editMS = ita_guisupport_measurement_get_global_MS;

editMS.calibrate; %handle class, no write back required

warndlg('Calibration finished! You can run a measurement now','Calibration finished!');
end