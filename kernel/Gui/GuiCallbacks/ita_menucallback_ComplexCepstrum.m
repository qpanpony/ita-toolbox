function ita_menucallback_ComplexCepstrum(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');

result = ita_cepstrum(audioObj);

setappdata(fgh, 'audioObj', result);
ita_guisupport_updateGUI(fgh);
end