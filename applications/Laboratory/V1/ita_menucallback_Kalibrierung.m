function ita_menucallback_Calibrate (hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

MS = ita_getfrombase('MS');
MS.calibrate;
ita_setinbase('MS',MS);
end