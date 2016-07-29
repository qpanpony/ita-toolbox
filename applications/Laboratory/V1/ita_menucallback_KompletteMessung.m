function ita_menucallback_KompletteMessung(hObject, event)

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

NameDerMessung =  genvarname(cell2mat(inputdlg( 'Bitte geben Sie den Name der Messung ein.','Name der Messung', 1)));

% ModulITA set settings
ita_modulita_control('channel','all','input','xlr','inputrange', -20, 'feed', 'pha');
% Measuring
MS = ita_getfrombase('MS');
MS.inputChannels = 1:4;
ita_setinbase('MS',MS);
IR = MS.run;
IR.comment = ['Versuch 1 - Automatische Messung - ' NameDerMessung];
ita_setinbase(['IR_kompletteMessung_' NameDerMessung],IR);
ita_write(IR,[NameDerMessung '.ita'])

h_msgbox = msgbox('Starte Filterung. Dieser Vorgang kann bis zu 45 sec dauern','komplette Messung', 'help', 'modal' );
RT = ita_roomacoustics(IR, 'T30'); % welche Parameter sollen hier berechnet werden?
close(h_msgbox)
ita_setinbase('RT', RT.T30);
ita_guisupport_currentdomain('barspectrum')

fgh = ita_guisupport_getParentFigure(hObject);
setappdata(fgh, 'audioObj', RT.T30);
ita_guisupport_updateGUI(fgh);


filename = [IR.comment ' - T30.csv'];
%write an plot
dlmwrite(fullfile(ita_preferences('DataPath') ,filename), [RT.T30.freqVector , RT.T30.freqData], '\t');
ita_savethisplot([ita_preferences('DataPath') filesep IR.comment]);
% winopen(fullfile(ita_preferences('DataPath'), filename));
end