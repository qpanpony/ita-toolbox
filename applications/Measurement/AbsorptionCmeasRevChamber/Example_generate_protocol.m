%% allgemeine Daten

% <ITA-Toolbox>
% This file is part of the application RevChamberAbsMeas for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

daten.nMic      = 4;                                                  % Anzahl verschiedener Mikrofonpositionen
daten.nLS       = 3;                                                  % Anzahl verschiedener Lautsprecherpositionen
daten.nObj      = 1;                                                  % Anzahl verschiedener Objektpositionen
daten.date      = '19. April 2011';                                 % Datum der Messung
daten.object    = 'Rockwool Sonorock (50mm) ';    % Name des Prüfobjekts
daten.comment   = {};
%daten.comment   = {'Das ist ein Test bljggggdszhi skzgursfhjjjjjjjjjjjjj jjjjjjjjj jjjjjjjjjjjjjjj jjjjsss sssssssss ssssssssnn nnnnnnnnnnnn n jdskf hgjhg jhyfky buhfd uifhyi nfughuigfj s',...
                %'\\'};
% für den Kommentar kann normaler Latex Code verwendet werden. Zur
% Übersicht im Latex Code wird jedes Element der Kommentar "Cell" in eine
% neue Zeile geschrieben.

%% results einlesen
dach_result = ita_read('M:\Latex-Protokoll Absorption\AbsorptionResults_RockwoolWall_T20.ita');

%% Bilder für das Messprotokoll
% Datenstruktur für alle Bilder, die im Messprotokoll auftauchen sollen:
% bild(i).datenpfad    = 'Datenpfad und Dateiname'
% bild(i).caption      = 'Bildunterschrift im Messprotokoll'

%bild{1}.datenpfad = 'M:\Bilder zum Strömungswiderstand Messgerät\Aufbau.JPG';
%bild{1}.caption   = 'Das ist ein Bild.';
%bild{2}.datenpfad = 'M:\Bilder zum Strömungswiderstand Messgerät\Aufbau.JPG';
%bild{2}.caption   = 'Das ist das selbe Bild.';
bild = {};

%% TeX Protokoll schreiben
ita_generate_protocol_for_revChamber_absMeas(daten,dach_result,bild)
