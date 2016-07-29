function ita_menucallback_EDC(hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% fetches the fractional octave band filtered result from Workspace 
result = ita_getfrombase('result_filtered'); 

if isempty(result)
    errordlg('Fehler beim Laden der gefilterten Messung. (Variable ''result_filtered'' nicht im Workspace gefunden. Wurde Filterung der Messung durchgeführt?)', 'Fehler', 'modal')
    return
end

% get cursors
x = ita_plottools_cursors;

if any(x([1 2])> 20)
    errordlg(sprintf('Cursor limits haben falsche Werte ([ %1.1f %1.1f]). Im Zeitbereich mit der Cursorn den Bereich zum Fenstern markieren.', x(1), x(2) ), 'Fehler', 'modal')
    return
end

result = ita_time_window(result,x([1 2]),'time','crop');

% calculates the EDC
EDCresult = ita_roomacoustics_EDC(result, 'method', 'noCut');

% saves the EDCcurves into the Workspace
ita_setinbase( 'EDCresult_EDC', EDCresult);

fgh = ita_guisupport_getParentFigure(hObject);
setappdata(fgh, 'audioObj', EDCresult);
ita_guisupport_updateGUI(fgh);
end