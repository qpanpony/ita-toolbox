% 1. Matlab Pfad einstellen!!!!!


% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Projektdatei einlesen
% project laden
rpf = RavenProject('..\RavenInput\Classroom\trilateration.rpf');


%% Simulationsparameter einstellen
% spiegelquellen bis 2. ordnung
rpf.setISOrder_PS(2);

% 20000 ray tracing partikel
rpf.setNumParticles(20000);

% Länge der Impulsantwort einstellen (sollte mindestens der Nachhallzeit entprechen!)
rpf.setFilterLength(2800);  %[ms]
% rpf.setFilterLengthToReverbTime();    % schätzt über Eyring die Nachhallzeit und passt die Filterlänge an

% Raumtemperatur einstellen
rpf.setTemperature(21); %°C


%% Simulationsausgabe definieren
% befehle monaurale impulsantwort
rpf.setGenerateRIR(1);

% befehle binaurale impulsantwort
rpf.setGenerateBRIR(1);

% histogramme berechnen
rpf.setExportHistogram(1);  % histogramme z.B. benötigt für schnelle Nachhallzeitauswertung (RavenProject.getT30)


%% Quell- und Empfängerdaten
% quell position setzen
rpf.setSourcePositions([9 1.7 -2.5]);
rpf.setSourceViewVectors([-1 0 0]);
rpf.setSourceUpVectors([0 1 0]);

% receiver position setzen
rpf.setReceiverPositions([4.4500    1.0000   -3.9000]);

% quellnamen setzen
rpf.setSourceNames('Speaker Left');

% directivity setzen
rpf.setSourceDirectivity('KH_O100_Oli_5x5_3rd_relativiert_auf_azi0_ele0.daff');

%% Simulation starten
% simulation abfeuern
rpf.run;

%% Ergebnisse abholen
% monaurale impulsantwort holen
mono_ir = rpf.getMonauralImpulseResponseItaAudio();     % oder rpf.getMonauralImpulseResponse() ohne ITA-Toolbox
binaural = rpf.getBinauralImpulseResponseItaAudio();
reverb_time = rpf.getT30();


%% ITA-Toolbox......
mono_ir.plot_time;      % plotte monaurale IR im Zeitbereich
binaural.plot_freq;     % plotte binaurale IR im Frequenzbereich

%% Beispiel: Lautsprecher einrechnen
ls_O100 = ita_read('..\RavenDatabase\FrequencyResponse\KH_O100_reference_holesclosed_final_at1V1m_fft14.ita');
ir_mit_lautsprecher = ita_convolve(mono_ir, ls_O100);

%% Additional features
% model zeigen
% rpf.plotModel;
