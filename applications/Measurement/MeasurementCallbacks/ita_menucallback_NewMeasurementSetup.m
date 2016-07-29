function ita_menucallback_NewMeasurementSetup(hObject, eventdata) %#ok<INUSD>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% gets variables from Workspace
count = ita_getfrombase('count');

if isempty(count)
    count = 1;
else
    count = count +1;
end

filename = ['MS' num2str(count)];

MS = ita_measurement();

%set the variables into the workspace
ita_setinbase(filename, MS);
ita_setinbase('count', count);
ita_setinbase('actMS', filename);
end