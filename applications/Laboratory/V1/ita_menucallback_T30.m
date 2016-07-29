function ita_menucallback_T30 (hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

freqRange       = [63 8000];
bandsPerOctave  = 1;

% fetches the EDCresult from workspace
result = ita_getfrombase('EDCresult_EDC');

if isempty(result)
    errordlg('Fehler beim Laden der EDC. (Variable ''EDCresult_EDC'' nicht im Workspace gefunden. Wurde EDC berechnet?)', 'Fehler', 'modal')
    return
end

% calculates the T30 out of the EDCresult
h       = msgbox('Nachhallzeiten werden berechnet. Dieser Vorgang kann bis zu 30 sec. dauern','T30', 'help', 'modal' );
nFreqs  = numel(unique(result.channelNames));
nMics = result.nChannels / nFreqs;

% stupid workaround because RT function is private
comeFrom = pwd;
cd([ita_toolbox_path filesep 'applications' filesep 'RoomAcoustics' filesep 'private']);

for iCh = 1:nMics
    raRes =  ita_roomacoustics_reverberation_time(result.ch(iCh:nMics:result.nChannels),'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'calcedc',false, 'T30');
    resultT30(iCh) =  raRes.T30;
end

cd(comeFrom);
resultT30 = mean(merge(resultT30));
if ishandle(h)
    close(h)
end

% saves the T30result into the workspace an shows it in the ITAtoolbox window
ita_setinbase('resultT30', resultT30);


ita_guisupport_currentdomain('barspectrum')

fgh = ita_guisupport_getParentFigure(hObject);
setappdata(fgh, 'audioObj', resultT30);
ita_guisupport_updateGUI(fgh);

ylim([0 12])
xlim(freqRange)
% saves the plot and the T30/frequencyband Values
dlmwrite(fullfile(ita_preferences('DataPath') , 'T30.csv'), [resultT30.freqVector , resultT30.freqData], '\t');
ita_savethisplot([ita_preferences('DataPath') filesep result.comment]);

% this shows the T30/fractional octave bands values on screen
% open T30.csv;
end