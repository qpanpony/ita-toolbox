%% Willkommen zur Uebung Medizinische Akustik II, Teil 1
%
%
% Die Uebung soll die Inhalte der Vorlesung Medizinische Akustik II
% vertiefen und anhand praktischer Beispiele verdeutlichen.
%
% Als Hilfmittel wird in dieser Uebung die am ITA entwickelte
% Matlab-Erweiterung ITA-Toolbox verwendet.
%
% http://www.ita-toolbox.org
%
% Bei Fragen und Anregungen: Josefa Oberem job@akustik.rwth-aachen.de
%

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% Start from scratch
% Das Script wir am besten mit Hilfe des 'Cell Mode' von Matlab
% abschnittweise bearbeitet.
%
% Die Betrachtung erfolg am leichtesten mit Hilfe der publish Funktion von
% Matlab. Dafuer fuehren sie bitte einfach die aktuelle Zelle aus.
%
% Als erstes benoetigen wir einen leeren Workspace. Gegebenenfalls muessen
% wir noch die ITA-Toolbox korrekt einrichten.

ccx;

% Create this file
 cd(fileparts(which('MedizinischeAkustikV1.m'))); %change the current folder
 web(publish('MedizinischeAkustikV1.m',struct('evalCode',false,'outputDir',pwd)));

%% Einfuehrung in die ITA-Toolbox fuer Matlab
% Eine Einfuehrung in die ITA-Toolbox fuer Matlab sowie einige grundlegende
% Beispiele finden sich im ITA-Toolbox Tutorial
%
% <matlab:edit('ita_toolbox_tutorial.m') ITA-Toolbox Tutorial oeffnen?>


%% Demonstration 'Moden im Hallraum'
%% Fragen:
% 
% Was sind Moden?
%
% Treten Moden nur in rechteckigen Raeumen auf?
%
% Nennen sie Beispiele wo Moden und Resonatoren in der Medizintechnik eine
% Rolle spielen.

%% Demonstration Abtastung
% Zur Demonstration der zeitdiskreten Abtastung stehen ein Lautsprecher und
% ein Stroboskop bereit. Das Stroboskop ist eine Lampe welche mit
% einstellbarer Frequenz an und aus geht. Aufgrund der Traegheit des
% menschlichen Auges werden nur die Informationen bei eingeschaltetem Licht
% wahrgenommen, es entsteht also ein Effekt einer zeitdiskreten Abtastung
% der optischen Wahrnehmung.
%
% Die Frequenz der Abtastung des Stroboskobes kann am Geraet eingestellt
% werden. 
% ACHTUNG: Das die Frequenzskala des Stroboskobes ist "pro Minute".
% Als Veranschaulichung soll die Schwingung eines Lautsprechers dienen. 
% Schliessen sie hierfuer den Lautsprecher an den Audioausgang des
% PCs an und richten sie das Stroboskop auf die Lautsprechermembran.
% 
% Als erstes soll ein einfacher Sinus ueber den Lautsprecher abgegeben
% werden und der Einfluss unterschiedlicher Abtastungsfrequenzen untersucht
% werden. Um einen Sinus mit einstellbarer Frequenz abzuspielen starten sie
% den <matlab:ita_tools_frequencygenerator ITA-Toolbox Frequenzgenerator>
% und stellen eine Frequenz von 100 Hz ein.
%
% Experiementieren sie nun mit der Abtastfrequenz des Stroboskopes und des
% Sinus-Tones.
%
% 

%% Fragen:
%
% Welchen Effekt erhalten die bei gleicher Abtastfrequenz wie Frequenz des
% Sinus?
%   
% Was sehen sie bei deutlich hoeheren Abtastfrequenzen?
%   
% Was sehen sie bei Abtastfrequenzen die ganzzahlige Teiler der Sinusfrequenz sind?
%   
% Was sehen sie bei Abtastfrequenzen die zwischen den ganzzahligen Teilern liegen?
%   
% Was geschieht wenn sie die Frequenz des Sinustones deutlich erhoehen oder
% reduzieren?
%   
% Wo wird diese Methode der Sichtbarmachung von Schwingungen in der
% medizinischen Diagnose verwendet?
%   
% Koennen sie sich weitere Anwendungen in der akustischen Forschung und
% Entwicklung vorstellen?
%   
% Wo liegen moegliche Einschraenkungen der Methode?
%   

% Zur Überprüfung der Ergebnisse können die Aliasing-Effekte mit dem
% Aliasing-Demonstrator angeschaut werden:

ita_aliasing_demo;

close all; clear all;

%% Fouriertransformation - Zeit- und Frequenzbereich
% Signale lassen sich sowohl im Zeit als auch im Frequenzbereich
% darstellen. Die Umwandlung erfolgt mit Hilfe der Fourier- bzw. Inversen
% Fouriertransformation. In der ITA-Toolbox kann ein AudioObjekt mit dem
% Befehl ita_fft in den Frequenzbereich transformiert werden. ita_ifft
% transformiert dann zurück in den Zeitbereich.

% Als Beispiel dient ein Sprachsignal
signal = ita_read('MedAk_Lang.wav');
signal = signal/10;
signal.play;

% Das Signal laesst sich mit dem Befehlt ita_plot_time im Zeitbereich
% darstellen
ita_plot_time(signal);

% Die fft bzw ifft Transformation wird bei Bedarf automatisch durchgefuehrt.
% Eine Darstellung im Frequenzbereich ist ganz einfach mit dem Befehl
% ita_plot_freq moeglich
ita_plot_freq(signal);

% Genau genommen besteht ein Spektrum aus komplexen Werten, hat also Real-
%und Imaginaerteil bzw. Betrag und Phase. Mit dem Befehlt ita_plot_freq_phase
%kann das Pektrum nach Betrag und Phase augezeigt werden.
ita_plot_freq_phase(signal);

% Zur Demonstration des Phaseneinflusses wird die Phase nun durch eine zufaellige Phase ersetzt
signal2 = signal;
signal2.freqData = abs(signal2.freqData) .* exp(1i*2*pi*rand(signal2.nBins, signal2.nChannels));
signal2.play;

% Es gibt auch eine Mischform aus Zeit- und Frequenzbereich, das
% Spektrogramm:
ita_plot_spectrogram(signal);

%% Fragen
% Was passiert wenn die Phase eines Spektrums zu null gesetzt wird?

signal2.freqData =abs(signal2.freqData);% .* exp(1i*2*pi*zeros(signal2.nBins, signal2.nChannels));
signal2.plot_freq_phase
ita_plot_spectrogram(signal2);


% Wie haengen Frequenz- und Zeitaufloesung bei einem Spektrogramm zusammen?


close all; clear all;

%% Abtastung von Audio-Signalen
% Akustische Messungen und Signalverarbeitung findet in der Regel mit PCs
% statt. Um akustische Signale zu verarbeiten muessen sie (nach Wandlung
% durch einen Sensor, z.B. ein Mikrophon, und Verstaerkung) digitalisiert
% werden. Hierzu ist eine zeitliche Abtastung notwendig.
%
% Abtastung bedeutet, dass das Signal in festen Zeitabstaenden erfasst und
% der Wert zu diesen Zeitpunkten festgehalten wird. Die Abtastrate
% (Sampling Rate) gibt dabei an wie viele Werte pro Sekunde gespeichert
% werden.

% Erzeugen sie nun einen Sinus mit der Frequenz 100 Hz, Amplitude 100,
% Sampling Rate 44100 Hz, und FFT Degree 15

sine = ita_generate('sine',100,100,44100,15);


% Stellen sie den Sinus im Zeitbereich dar:

ita_plot_time(sine);
 
% Hier sieht der Sinus kontinuierlich aus. Um nur die tatsaechlichen
% Abtastwerte darzustellen koennen sie die Option 'plotcmd',@stem
% verwenden. Sie koennen die Lupen-Werkzeuge verwenden um sich einen
% Bereich des Signals genauer anzusehen.

ita_plot_time(sine,'plotcmd',@stem);

% Mit dem Befehl ita_plot_freq koennen sie sich das Spektrum des Signals
% ansehen:
ita_plot_freq(sine);


% Aendern sie nun die Abtastfrequenz des Signals auf 300 Hz und stellen sie
% das Ergebniss erneut dar.

sine2 = ita_resample(sine,300);
ita_plot_time(sine2,'plotcmd',@stem);

% Aendern sie nun erneut die Abtastfrequenz des Signals auf 90 Hz und
% stellen sie das Ergebniss erneut dar.

sine3 = ita_resample(sine,90);
ita_plot_time(sine3,'plotcmd',@stem);

% Als nächtest soll der Effekt einer fehlerhaften Unterabtastung untersucht
% werden. Dabei tritt Aliasing auf. Hohe Frequenzen werden falsch
% abgetastet und überlagern sich mit den tieferen Frequenzen.
sound = ita_read('MedAk_Lang.wav');
sound = sound/50;
sound.play;

% Zunaechst der 'richtige' Vorgang, das Signal wird vor der Abtatsung mit
% einem Tiefpass gefiltert, so dass keine Frequenzen hoeher als die halbe
% Abtastfrequenz auftreten
sound1 = sound;
sound1 = ita_filter_bandpass(sound1,'upper',1000);
sound1.timeData = sound1.timeData(1:20:end); % Jeden 20sten Wert nehmen
sound1.samplingRate = sound1.samplingRate / 20; % SamplngRate korrigieren
sound1.play;
sound1.plot_freq;

% Nun der 'falsche' Vorgang. Die Abtastung erfolgt ohne vorherigen Tiefpass
sound2 = sound;
sound2.timeData = sound2.timeData(1:20:end);
sound2.samplingRate = sound2.samplingRate / 20;
sound2.play;
sound2.plot_freq;

%% Fragen
%
% Warum ist ein Tiefpassfilter vor einer Abtastung notwendig?
%
% Ist der Tiefpassfilter auch notwendig wenn höher geresamplet wird als das Ursprungssignal?
%   

close all; clear all;

%% Einfluss auf den Klang
% Laden sie ein Musikstück, z.B. mit der Funktion ita_demosound.
sound = ita_demosound();
sound = sound/100;
play(sound);

% Betrachten sie das Signal im Frequenzbereich
ita_plot_freq(sound);

% Aendern sie nun die Abtastfrequenz durch resampling auf 10 kHz, danach auf 3 kHz
% und hoeren sich das Beispiel an.
sound2 = ita_resample(sound,10000);
play(sound2);

sound3 = ita_resample(sound, 3000);
play(sound3);

%% Fragen:
%
% Welche Abtastfrequenz ist notwendig um den Sinus eindeutig rekonstruieren
% zu koennen?
%
%
% Welche Abtastraten sind notwendig um menschliche Sprache verstaendlich zu
% Speichern und Uebertragen, welche fuer eine vollkommen verlustfreie Speicherung von Musik?
% 
close all; clear all;

%% Bandbegrenzung
% Als nächstes wird der Einfluss einer Bandbegrenzung auf die Sprachverstaendlichkeit untersucht. 
% Zunaechst wird also ein Sprachsignal geladen.
sound = ita_read('MedAk_Lang.wav'); 
sound = sound./100;
sound.play;
ita_plot_spectrogram(sound);

% Fuehren Sie nun eine Bandbegrenzung wie bei einer alten Telefonuebertragun ein:
% Der uebertragene Frequenzbereich bei alten Telefonen liegt zwischen 300 Hz und 4000 Hz

f_low  = 300;
f_high = 4000;
sound2 = ita_filter_bandpass(sound,'lower',f_low,'upper',f_high);

% Wie sieht das Sektrum nun aus?
sound2.plot_freq 

% und wie klingt das ganze?
sound2 = sound2.*2;
sound2.play

% Im nächsten Schritt wird es noch etwas extremer, als untere Grenzfrequenz nehmen wir nun 600 Hz, als obere 1200 Hz
f_low  = 600;
f_high = 1200;
sound3 = ita_filter_bandpass(sound,'lower',f_low,'upper',f_high);

% Wie sieht das Sektrum nun aus?
sound3.plot_freq 

% und wie klingt das ganze?
sound3 = sound3.*10;
sound3.play

%% Fragen:
% Wie wuerde sich die Sprachverständlichkeit bei einer Maennerstimme aendern?
% 
close all; clear all;

%% Diskretisierung
% Audiosignale muessen um an einem Computer verarbeitet werden zu koennen
% nicht nur abgetastet werden. Zusaetzlich ist eine Diskretisierung der
% Amplituden an den Abtastpunkten notwendig.
%
% Typische Audiosignale werden mit 16 oder 24 bit diskretisiert. D.h. die
% Amplitude kann 2^16 = 65536 bzw 2^24 = 16777216 verschiedene Werte
% annehmen

% Laden und spielen sie ein Signal
signal = ita_demosound;
signal = signal/100;
play(signal);

% Jetzt aendern sie die Diskretisierung auf 10 Bit
signal2 = ita_quantize(signal,'bits',10);
ita_plot_time(signal2);
play(signal2);

% Jetzt aendern sie die Diskretisierung auf 3 Bit
signal3 = ita_quantize(signal,'bits',3);
ita_plot_time(signal3);
play(signal3);

%% Fragen:
%
% Welchen Einfluss hat die Diskretisierung?
%
% Wie gross ist die maximal moegliche Dynamik (Verhaeltniss von leisestem
% zu lautestem Ton) bei 8, 16 und 24 Bit?
%   
% Wie gross ist die maximale Dynamik des menschlichen Gehoers?
% 
close all; clear all;
