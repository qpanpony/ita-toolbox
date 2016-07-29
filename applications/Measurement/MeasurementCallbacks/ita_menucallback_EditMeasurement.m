function ita_menucallback_EditMeasurement(hObject, eventdata) %#ok<INUSD>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% gets variables from Workspace
editMS = ita_guisupport_measurement_get_global_MS;

editMS.edit;

end