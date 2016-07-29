function ita_menucallback_MesssetupEditieren(hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ita_preferences('bandsperoctave',1);
ita_preferences('freqRange',[40 16000]);

load MS_V1.mat;

MS.inputChannels = 1;
MS.outputamplification = -20;
MS.fftDegree = 19;
MS.comment = ('Einzelmessung mit manueller Filterung');
MS.compensation;

% ModulITA set settings
ita_modulita_control('channel','all','input','xlr','inputrange', -20, 'feed', 'pha')
ita_setinbase('MS',MS);
msgbox('Messsetup wurde erfolgreich erstellt','Messsetup', 'help', 'modal' )

end