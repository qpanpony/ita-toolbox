%% Tutorial for lab 'V6 - Bassreflexlautsprecher' (at ITA)
%
%
%
% *HAVE FUN! and please report bugs*
%
% _2012 - Pascal Dietrich_
% toolbox-dev@akustik.rwth-aachen.de
%
% edit: 2017 Hark Braren
%
% <<../pics/toolbox_bg.png>>a =
%

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% F5 block
error('!!! Do NOT use F5 to run the whole script. !!!!!   Use Ctrl+Enter or F7 to step through the code')

%% Init
%ccx; %löscht alle Variablen (siehe Workspace) und Verlauf des Command Windows
ita_preferences('toolboxlogo',false);

%ita_preferences %öffnet Toolbox Einstellungen, wichtig: Soundkartentreiberwahl, sollte "....ASIO" sein.

%% Erstelle Messsetup und führe erste Messung durch

MSimp = itaMSImpedance; %erstellt Instanz (Objekt) der Impedanzmessklasse

%weise Eingags- und Ausgangskanaele zu

MSimp.inputChannels  = 3;
MSimp.outputChannels = 3;
MSimp.freqRange = [2 1800];
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
% This uses the Internal 10 Ohm Resistor to calibrate the impedance setup

%nun fuehren wir eine erste Messung durch und betrachten das Ergebnis

%% Measure Impedance of loudspeaker
Z = MSimp.run; % 'messsetup'.run startet immer die Messung

Z.plot_freq_phase('nodb')


%% Es folgen die Messungen zur Bestimmung der Thiele/Small Parameter
% Wie in Versuch 5 gezeigt können die Thiele Small Parameter aus der
% Verschiebung der Resonanzfrequenz, dem DC Widerstand und weiteren
% Parametern ermittelt werden können. Im folgenden soll die in der Toolbox
% integrierte Funktion benutzt werden, die aber auf den gleichen Prinzipien
% arbeitet

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

h,in = inputdlg({'Masse m in [kg]:';'Effektiver Membrandurchmesser d in [m]'});
uiwait(h);

% hier Eintragen:
%TS = ita_thiele_small(imp_ohne_Masse, imp_mit_Masse, 'Masse??', 'Durchmesser??')
m = itaValue(in{1},'kg');
d = itaValue(in{2},'m');

TS = ita_thiele_small(imp_ohne_Masse, imp_mit_Masse, m,d,'L_e',true);

% alternativ: ita_thiele_small_gui aufrufen

% Der Plot zeigt die gemessene und vom Model gefittete Impedanzkurve. 

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


%% Luftschallmessung - Messsetup
% Nun nehmen wir eine Luftschallmessung der unterschiedlichen
% Konstruktionsprinzipien vor

%zunaechst wird ein Messsetup fuer die Uebertragungsfunktion ("TransferFunction"=>TF) erstellt

MS1 = itaMSTF;
MS1.useMeasurementChain = 1;    % define all Elements of our Measurement Chain
MS1.fftDegree = 19;             % entspricht länge des Messsignals
MS1.inputChannels = 3;
MS1.outputChannels = 3;


%% Calibration of the system
MS1.calibrate

%MS1.run_latency - Only needed if outputcalibration failed

%% Verify:
% Positioniere das Mikrofon wie zur Kalibrierung im Pistonfon.

x = MS1.run_backgroundNoise; % schauen, ob calibration geklappt hat



%% Erste Messung
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
% Welche Einheit hat das Ergebnis, warum?

%%%%%%%%%

%% Schalldruck
% Um den tatsächlich gemessenen Schalldruck zu erhalten muss die
% Übertragungsfunktion mit der Anregungsspannung multipliziert werden.

UOut_value = MS1.outputVoltage;
UOut = itaValue(UOut_value, 'V'); %benutze ein itaValue Objekt um bei der 
                                  %Multiplikation direkt einheitenkorrekte 
                                  %Ergebnisse zu bekommen 
   
tf_LS_p = tf_LS_corr*UOut;
tf_LS_p.comment = 'Schalldruck';
tf_LS_p.pf


% Schaue auch das Ergebnis im Zeitbereich an. Woher kommt das delay??
% Zeitbereichsbetrachtung kann man im Plotfenster über das 'Domain' Menü
% auswählen oder mit Strg+t.

% mit 'd' kann man die Achsenskalierung einstellen. Verwende [0 0.05]s als
% X-Achse. Kann man weitere Impulse erkennen??

% Verwende die 'Time in db' domain (strg+y) um Impulse besser zu erkennen.
% Was sind das für Impulse am Ende des Zeitbereichs ??


%% Time Windowing
% Um die eben gesehenen nichtlinearitäten und/oder mögliche Reflektionen an
% Messequipment aus der Messung herauszurechnen benutzen wir ein Fenster im
% Zeitbereich

%ita_time_window(audioObjekt,[t_Slope_Top, t_Slope_bottom])

tf_LS_p_win = ita_time_window(tf_LS_p,[0.2 0.3])
tf_LS_p_win.pf

%Welche auswirkungen hat die Fensterung im Frequenzbereich



%% Sensitivity

% Hier sehen wir jetzt den gemessenen Schalldruck am Mikrofon. Dieser
% entspricht aber aufgrund der Positionierung des Mikros noch nicht dem
% im gleichen Abstand unter echten Freifeldbedingungen gemessenen
% Schalldruck. 

%%%%%%%%%% DEIN CODE %%%%%%%%%%%%
tf_LS_p_free = tf_LS_p_win  ###
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Um die Sensitivität des Lautsprechers zu bestimmen muss der Schalldruck
%in einem Meter bei einer Ausgangsleistung von 1W, bzw der Ausgangsspannung
%von 1V angegeben werden.
%
%Berechne für beide Varianten die Sensitivität des Lautsprechers unter der
%Annahme eines LTI Systems

%%%%%%%%%% DEIN CODE %%%%%%%%%%%%
sens_LS_1V = tf_LS_p_free ###
sens_LS_1V.comment('Sensitivity @1m 1V')
    
% Kleiner Tipp: Welche Nennimpedanz hat der Lautsprecher. 
% imp_BR.pf

U_1W = itaValue(###,'V');
sens_LS_1W = tf_LS_p_free ###
sens_LS_1W.comment(sprintf('Sensitivity @1m 1W - %1.2f',U_1W.value))



%% THD / MAX SPL Measurement
MS2 = MS1;      %use copy in case we need to repeat some measurement
ita_robocontrol %gimme some POWAAAAA
MS2.freqRange = [63 500];

h = helpdlg('Setzte geschlossene Rueckwand ein ');
uiwait(h);
klirr_cl = ita_loudspeakertools_maxSPL(MS2,'bandsPerOctave', 3,'powerRange',[0.02 10],...
    'powerIncrement',2,'nHarmonics',4,'signalReference','THDN', ...
    'distortionLimit',1,'tolerance',0.05,'nominalLoudspeakerImpedance',8,...
    'windowSamples',[],'pauseConst',5);


%%
h = helpdlg('Setzte eine geöffnete Rueckwand ein ');
uiwait(h);
klirr_br = ###


%%
maxSPL = merge(klirr_cl.ch(1), klirr_br.ch(1))
maxSPL.channelNames = {'closed','with Port'};

maxW = merge(klirr_cl.ch(2), klirr_br.ch(2))/itaValue(8,'Ohm')
maxW.channelNames = {'closed','with Port'};

maxSPL.pf
maxW.pf('noDb')
