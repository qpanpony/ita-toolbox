function ita_menucallback_MessungStarten(hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% fetches the measurementresult from workspace
MS = ita_getfrombase('MS');

if isempty(MS)
    errordlg('Noch kein Messsetup erstellt!','Messsetupfehler');
else
    % measurement:
    result = MS.run;
    result = ita_time_shift(result);
    % save the measurement results into the workspace
    assignin('base','result',result);   
    fgh = ita_guisupport_getParentFigure(hObject);
    setappdata(fgh, 'audioObj', result);
    ita_guisupport_updateGUI(fgh);
end
