function MS = ita_guisupport_measurement_get_global_MS()

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

actMS = ita_getfrombase('actMS');   % first need to load the ActMS cell to extract tthe string out of it

if isempty(actMS)
    ita_menucallback_NewMeasurementSetup;
    actMS = ita_getfrombase('actMS');   % first need to load the ActMS cell to extract tthe string out of it
end

MS = ita_getfrombase(actMS); % interprets the string out of the cell

end