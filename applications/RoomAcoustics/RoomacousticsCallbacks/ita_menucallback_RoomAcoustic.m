function ita_menucallback_RoomAcoustic(hObject, event)

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');


raRes = ita_roomacoustics(audioObj);

setappdata(fgh, 'audioObj', raRes);
setappdata(fgh, 'ita_domain', 'barspectrum');
ita_guisupport_updateGUI(fgh);
end