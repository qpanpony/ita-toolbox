function ita_menucallback_MessungSchallleistung(hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Variables to use in this measurement:
MS = ita_getfrombase('MS');   % only if it exits allready

resultSPL = MS.run_backgroundNoise;
resultSPL.comment = 'Staubsauger';

ita_setinbase('resultSPL', resultSPL);
SPL = ita_spk2frequencybands(resultSPL);

filename = [resultSPL.comment 'SPL.csv'];
ita_setinbase('SPL', SPL);


fgh = ita_guisupport_getParentFigure(hObject);
setappdata(fgh, 'audioObj', SPL);
setappdata(fgh, 'ita_domain', 'barspectrum')
ita_guisupport_updateGUI(fgh);

dlmwrite(fullfile(ita_preferences('DataPath') , filename), [SPL.freqVector , SPL.freqData_dB], '\t');
winopen(fullfile(ita_preferences('DataPath'), filename));

end