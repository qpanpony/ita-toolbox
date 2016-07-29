function ita_menucallback_ListenDAOnly(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>
fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');

if isa(audioObj, 'itaAudio')
    ita_portaudio(ita_normalize_dat(audioObj)*0.99,'keepsamplingrate'); 
else
    errordlg('Only itaAudios can be played.')
end

end