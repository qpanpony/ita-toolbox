function ita_menucallback_Bandfiltern(hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

freqRange       = [63 8000];
bandsPerOctave  = 1;

% fetches the measurement result from workspace
result = ita_getfrombase('result');

if isempty(result)
    errordlg('Fehler beim Laden der Messung. (Variable ''result'' nicht im Workspace gefunden. Wurde Messung durchgefuehrt?)', 'Fehler', 'modal')
    return
end

% calls the ita filter function
result_filtered = ita_mpb_filter(result,'oct',bandsPerOctave, 'octaveFreqRange', freqRange);
ita_setinbase('result_filtered',result_filtered);

fgh = ita_guisupport_getParentFigure(hObject);
setappdata(fgh, 'audioObj', result_filtered);
ita_guisupport_updateGUI(fgh);

end