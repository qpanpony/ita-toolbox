%% Willkommen zur Uebung Medizinische Akustik II
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
% Bei Fragen und Anregungen: Jan-Gerrit Richter jri@akustik.rwth-aachen.de
%
%
% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% Teil 1: Abtastung

% Abtastung von Audio-Signalen
% Akustische Messungen und Signalverarbeitung findet in der Regel mit PCs
% statt. Um akustische Signale zu verarbeiten muessen sie (nach Wandlung
% durch einen Sensor, z.B. ein Mikrophon, und Verstaerkung) digitalisiert
% werden. Hierzu ist eine zeitliche Abtastung notwendig.
%
% Abtastung bedeutet, dass das Signal in festen Zeitabstaenden erfasst und
% der Wert zu diesen Zeitpunkten festgehalten wird. Die Abtastrate
% (Sampling Rate) gibt dabei an wie viele Werte pro Sekunde gespeichert
% werden.
%
% Um dies zu verdeutlichen wird ein 100 Hz Sinus mit einer Abtastrate von
% 300 Hz gesampled dargestellt
ita_aliasing_demo(100,300);

close all;
ita_aliasing_demo(100,150);

close all;
ita_aliasing_demo(100,90);


%%
% Dieser Effekt nennt sich Aliasing.  Hohe Frequenzen werden falsch
% abgetastet und überlagern sich mit den tieferen Frequenzen.
% Dies soll nun mit einem Hörbeispiel verdeutlicht werden.
sound = ita_read('MedAk_Lang.wav');
sound = sound/3;
sound.play;


%%
% Zunaechst der 'richtige' Vorgang, das Signal wird vor der Abtatsung mit
% einem Tiefpass gefiltert, so dass keine Frequenzen hoeher als die halbe
% Abtastfrequenz auftreten
sound1 = sound;
sound1 = ita_filter_bandpass(sound1,'upper',1000);
sound1.timeData = sound1.timeData(1:20:end); % Jeden 20sten Wert nehmen
sound1.samplingRate = sound1.samplingRate / 20; % SamplngRate korrigieren
sound1.play;

%%
% Nun der 'falsche' Vorgang. Die Abtastung erfolgt ohne vorherigen Tiefpass
sound2 = sound;
sound2.timeData = sound2.timeData(1:20:end);
sound2.samplingRate = sound2.samplingRate / 20;
sound2.play;

%%
% Schaut man sich die beiden Signale im Frequenzbereich an, so sieht man
% den Unterschied:
plot_sound = merge(sound1, sound2);
plot_sound.plot_freq;

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
% und stellen eine Frequenz von 70 Hz ein.
%
% Experiementieren sie nun mit der Abtastfrequenz des Stroboskopes und des
% Sinus-Tones.
%
% 
ita_tools_frequencygenerator;

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




%% Messtechnik
%% Grundlagen der Messtechnik
% Zur Beschreibung von Uebertragungsstrecken bei LTI-Systemen (linear und
% zeitinvariant) werden in der Akustik zumeist Impulsantworten bzw. ihre
% Transformation in den Frequenzbereich, die Uebertragungsfunktion
% verwendet.
%
% Im folgenden soll eine einfache Messung einer Raumimpulsantwort
% durchgefuehrt werden.
%
% Als Anregungssignal kann prinzipiel jedes breitbandige Signal verwendet
% werden, aufgrund verschiedener Vorteile wird hier haeufig ein 'sweep' (in
% der Frequenz aufsteigender Sinus) verwendet. Um die Impulsantwort eines
% Systems zu erhalten wird es mit dem Anregungssignal angeregt, die
% Systemantwort aufgezeichnet und anschliessend mit der Anregung entfaltet.

inputChannels  = 3;
outputChannels = 3;

% Erzeugen sie zunaechst das Anregungssignal:
freq_range = [20 20000];
fft_degree = 17;
s = ita_generate_sweep('mode','exp','freqRange',freq_range,'fftDegree',fft_degree);
s = s./3;
% s.plot_dat

% Eine Messung kann nun durch einfaches Abspielen der Anregung und
% Aufzeichnen der Antwort durchgefuehrt werden.
g = ita_portaudio(s,'inputChannels',inputChannels,'outputChannels',outputChannels);

% Zunaechst betrachten wir beide Signale im Zeit- und Frequenzbereich
s_and_g = ita_merge(s,ita_normalize_dat(g));
s_and_g.plot_dat;
s_and_g.plot_spk;

% Um den Einfluss des Anregungssignals zu korrigieren muessen die Signale
% in den Frequenzbereich transformiert werden um durch Teile der Spektren
% eine Entfalltung zu erreichen.
S = fft(s);
G = fft(g);

H = ita_divide_spk(G, S, 'regularization',freq_range);
H.plot_spk



%% Spracherzeugung und Vokaltrakt
% Zum besseren Verstaendnis der Stimmerzeugung steht ein kuenstlicher
% Vokaltrakt zur Verfuegung. Der Vokaltrakt ist ein maßstabsgerechtes
% Modell, so dass die Formanten dem menschlichen Vokaltrakt entsprechen.
% Der Vokaltrakt ist mit einem Anschluss für einen Lautsprecher an Stelle
% der Stimmlippen sowie zwei Messpositionen zur Befestigung von Mikrophonen
% ausgestattet.   
%
% Aufgabe: Vokaltrakt sprechen lassen
%
% Frage: Was ist notwendig um den kuenstlichen Vokaltrakt sprechen zu lassen?
% Stichwort: Quelle-Filter-Modell

% Die Anregung durch die Stimmlippen kann stark vereinfacht als
% Saegezahnsignal modelliert werden:
f_Grundton = 100;
quelle = itaAudio;
quelle.fftDegree = 20;
quelle.time = mod(quelle.timeVector, 1/f_Grundton);
quelle = ita_normalize_dat(quelle).*0.99;

% Das Signal im Zeitbereich:
quelle.plot_time;
xlim([0 0.25])

% Und im Frequenzbereich:
quelle.plot_spk;

% Anhoeren:
outputChannels = 3;

signal = ita_portaudio(quelle./10,'outputChannels',outputChannels);

% Man erkennt deutlich die Grundfrequenz und Obertoene, es klingt sehr
% kuenstlich

% Verbinden sie jetzt den Lautsprecher mit dem Vokaltrakmodel und spielen
% das Quellsignal ab. 
outputChannels = 4;

signal = ita_portaudio(quelle./1.25,'outputChannels',outputChannels);

% Ist ein Vokal erkennbar? Was unterscheidet sich noch von einem
% menschlichen Vokal?


%% Bestimmung der Formaten des kuenstlichen Vokaltraktes

% Alternativ, falls das Vokaltraktmodel nicht verfügbar ist kann eine
% gespeicherte Messung verwendet werden
 g = ita_read('TFVokaltraktmodell.ita');

g.plot_freq;

% Die Uebertragungsfunktion des Systems laesst sich nun durch dividieren der
% Spektren an Systemaus- und Eingang berechnen. Ein Zeitfesnter bereinigt
% uebermaeßiges Rauschen, ueberfluessige Nullen koennen abgeschnitten werden.
h = g.ch(1)/g.ch(2);
% h.plot_dat_dB;
h = ita_time_window(h,[ 0.02 0.04],'symmetric');
h = ita_extend_dat(h,quelle.fftDegree,'symmetric');
h = ita_normalize_dat(h)*0.99;
h.plot_spk;
xlim([100 10000]);

% Nun soll die Uebertragung unserer bereits zuvor generierten Anregung der
% Stimmlippen durch das Vokaltraktmodel 'simuliert' werden. Hierfuer wird
% das Anregungssignal mit dem Filter (der gemessenen
% Uebertragungsfunktion) gefaltet.

% Zuerst beide zusammen darstellen:
ita_plot_spk(merge(fft(quelle), fft(h)));

% Faltung durch multiplikation im Frequenzbereich 
ae = quelle*h;

% Das Ergebniss im Frequenzbereich
ae.plot_spk;

% Anschließend anhören
outputChannels = 3;

signal = ita_portaudio(ae./2.5,'outputChannels',outputChannels);



%% vergleich der grundfrequenz


f_Grundton = 100;
quelle = itaAudio;
quelle.fftDegree = 20;
quelle.time = mod(quelle.timeVector, 1/f_Grundton);
quelle = ita_normalize_dat(quelle).*0.99;

ae = quelle*h;
% Das Ergebniss im Frequenzbereich
ae.plot_spk;


f_Grundton = 200;
quelle2 = itaAudio;
quelle2.fftDegree = 20;
quelle2.samplingRate = 80000;
quelle2.time = mod(quelle2.timeVector, 1/f_Grundton);
quelle2 = ita_normalize_dat(quelle2).*0.99;
quelle2 = ita_resample(quelle2,44100);
quelle2.fftDegree = 20;
quelle2.pf
ae2 = quelle2*h;
ae2.plot_spk;