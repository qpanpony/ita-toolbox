%% Tutorial for lab 'V5V6' (at ITA)
%
%
%
% *HAVE FUN! and please report bugs*
%
% _2012 - Pascal Dietrich_
% toolbox-dev@akustik.rwth-aachen.de
%
% <<../pics/toolbox_bg.png>>a =
%

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Init
ccx; %löscht alle Variablen (siehe Workspace) und Verlauf des Command Windows
ita_preferences('toolboxlogo',false);

%ita_preferences %öffnet Toolbox Einstellungen, wichtig: Soundkartentreiberwahl, sollte "....ASIO" sein.

%% Erstelle Messsetup und führe erste Messung durch

MSimp = itaMSImpedance; %erstellt Instanz (Objekt) der Impedanzmessklasse

%weise Eingags- und Ausgangskanaele zu

MSimp.inputChannels  = 3;
MSimp.outputChannels = 3;
MSimp.freqRange = [5 7000];
MSimp.outputamplification = -25;
%! Bei FireRobo-Kisten Schalter hinten beachten!
% Schalter Oben auf "Robo" --> Stellt Soundkartenausgänge 3 und 4 auf
% Zur Information: Robo ist die Leistungsendstufe/Verstärker in der FireRobo Kiste.
% Ausgänge des Verstärkers ebenfalls auf Rückseite (Bananenbuchsen)


%betrachtet, was bisher geschehen ist
MSimp.edit

%zuächst muss die Messkette zur korrekten Impedanzmessung über einen internen Widerstand kalibriert werden

% Calibrate the Setup

MSimp.calibrate;


%nun fuehren wir eine erste Messung durch und betrachten das Ergebnis

%% Measure Impedance of loudspeaker
Z = MSimp.run; % 'messsetup'.run startet immer die Messung

Z.plot_freq_phase('nodb')


%% Es folgen die Messungen zur Bestimmung der Thiele/Small Parameter

%das Chassis wird ohne zusätzliche Masse im Freifeld liegend gemessen

h = helpdlg('Lautsprecher ohne Masse im Freifeld');
uiwait(h);

imp_ohne_Masse = MSimp.run;
imp_ohne_Masse.channelNames = {'Impedanz ohne Masse'};

%nun wird die Masse hinzugefuegt

h = helpdlg('Schraube die Masse auf die Halterung');
uiwait(h);

imp_mit_Masse = MSimp.run;
imp_mit_Masse.channelNames = {'Impedanz mit Masse'};
%im Folgenden koennen die Messungen betrachtet werden

imp_zusammen = merge(imp_mit_Masse, imp_ohne_Masse);
imp_zusammen.plot_freq

%Anschließend koennen die Parameter errechnet werden

h = helpdlg('Messe effektiven Durchmesser, wiege die Zusatzmasse und trage die Werte direkt in die Funktion ein (m in [kg], d in [m]');
uiwait(h);

% hier Eintragen:
%TS = ita_thiele_small(imp_ohne_Masse, imp_mit_Masse, 'Masse??', 'Durchmesser??')
m = itaValue(0.075,'kg');
d = itaValue(0.16,'m');

TS = ita_thiele_small(imp_ohne_Masse, imp_mit_Masse, m,d );

% alternativ: ita_thiele_small_gui aufrufen


%% Messung im Gehaeuse
% Nun messen wir die Impedanz im Gehaeuse

%1. geschlossen
h = helpdlg('Setzte geschlossene Rueckwand ein ');
uiwait(h);

imp_geschlossen = MSimp.run;
imp_geschlossen.channelNames = {'geschlossen'};

%2. Bassreflex 5,3cm
h = helpdlg('Setzte 5,3cm geoeffnete Rueckwand ein ');
uiwait(h);

imp_5_3 = MSimp.run;
imp_5_3.channelNames = {'5,3cm'};

%3. Bassreflex 7cm
h = helpdlg('Setzte 7cm geoeffnete Rueckwand ein ');
uiwait(h);

imp_7 = MSimp.run;
imp_7.channelNames = {'7cm'};

%4. Bassreflex 8,8cm
h = helpdlg('Setzte 8,8cm geoeffnete Rueckwand ein ');
uiwait(h);

imp_8_8 = MSimp.run;
imp_8_8.channelNames = {'8cm'};

%5. Bassreflex 12,6cm
h = helpdlg('Setzte 12,6cm geoeffnete Rueckwand ein ');
uiwait(h);

imp_12_6 = MSimp.run;
imp_12_6.channelNames = {'12cm'};

%6. Bassreflex 17,4cm
h = helpdlg('Setzte 17,4cm geoeffnete Rueckwand ein ');
uiwait(h);

imp_17_4 = MSimp.run;
imp_17_4.channelNames = {'17,4cm'};

%Und betrachte das Ergebnis
imp_BR = merge(imp_geschlossen, imp_5_3, imp_7, imp_8_8, imp_12_6, imp_17_4);
imp_BR.plot_freq_phase
%HINWEIS für Plots:
%im Plotfenster öffnet sich mit Taste 'h' eine allg. Hilfe über die
%Tastaturshortcuts:
%z.B. kann man im x-Bereich hineinzommen: mit Pfeiltasten Cursorbewegen,
%mit Leertaste Cursor wechseln, mit 'x' Ausschnitt wählen.
%
%Andere wichtige Funktion: mit 'a' wechselt man bei itaAudio-Objekten mit
%mehreren Kanälen (Channels - hier der Fall) zwischen einzelkanal und alle
%Kanäle. Im Einzelkanalmodus geht man die Kanäle mit der "teilen" und
%"multiplizieren" Taste durch (Nummernblock)
%
%Probiere in einen bestimmten Bereich hineinzoomen und die verschiedenen
%Kanäle durchzugehen! - Es ist sehr hilfreich für spätere Messungen.


%% Luftschallmessung
% Nun nehmen wir eine Luftschallmessung der unterschiedlichen
% Konstruktionsprinzipien vor

%zunaechst wird ein Messsetup fuer die Uebertragungsfunktion ("TransferFunction"=>TF) erstellt

MS1 = itaMSTF;

MS1.inputChannels = 1;
MS1.outputChannels = 3;

MS1.fftDegree = 19; % entspricht länge des Messsignals

%MS1.run_latency ??

%Setzte die geschlossene Rueckwand ein
%Positioniere das Mikrofon vor dem Lautsprecher.
%Der Messton erklingt

tf_geschlossen = MS1.run
tf_geschlossen.channelNames = {'Mikrofon vor Lautsprecher; geschlossen'};

%setzte eine geoeffnete Rueckwand ein

h = helpdlg('Setzte eine geoeffnete Rueckwand ein ');
uiwait(h);

tf_BR = MS1.run
tf_BR.channelNames = {'Mikrofon vor Lautsprecher; offen'};

%im Anschluss kann das Ergebnis betrachtet werden

tf_LS = merge(tf_BR, tf_geschlossen);

tf_LS.plot_freq_phase

%% Calibration of the system

MS = itaMSTF;
MS.useMeasurementChain = 1;
MS.inputChannels = 3;
MS.outputChannels = 3;
MS.calibrate

%%


x = MS.run_backgroundNoise; % schauen, ob calibration geklappt hat


%%
MS.freqRange = [40 500];
vec = ita_loudspeakertools_maxSPL(MS,'bandsPerOctave', 3,'powerRange',[0.02 1],...
    'powerIncrement',2,'nHarmonics',4,'signalReference','THDN', ...
    'distortionLimit',3,'tolerance',0.05,'nominalLoudspeakerImpedance',8,...
    'windowSamples',[],'pauseConst',5);

%%
MS.freqRange = [20 2000];
pause(2)
tf_LS = MS.run

U = MS.outputVoltage;

