function ita_menucallback_NewMeasuringStation(hObject, eventdata) %#ok<INUSD>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% new Measuring Station
MS = itaMeasuringStation;
MS.write2disk;

%set the variables into the workspace
ita_setinbase('MeasuringStation',MS);
end