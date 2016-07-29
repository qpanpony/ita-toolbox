function ita_menucallback_OktavenUndSchalleistung(hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%Variables to use in this function:
RT = ita_getfrombase('RT');         % Reverberationtime from measurement before
resultSPL = ita_getfrombase('resultSPL'); % Result of the Sound Power meausuring
V = 124;                          % volume, ita hall-room in m^3
S = 181;                           % room surface area in m^2

SPL = ita_spk2frequencybands(resultSPL);
SPLmean = mean(SPL);

% Mittelwert der 4 Nachhallzeitmessungen
RTmean = mean(RT);

P = SPLmean^2 / itaValue(414,'kg/s m^2') / 4 * (itaValue(0.163,'s/m') * itaValue(V,'m^3') / RTmean);

ita_setinbase('SPLmean', SPLmean);
ita_setinbase('P', P);

fgh = ita_guisupport_getParentFigure(hObject);
setappdata(fgh, 'audioObj', P);
setappdata(fgh, 'ita_domain', 'barspectrum')
ita_guisupport_updateGUI(fgh);


end