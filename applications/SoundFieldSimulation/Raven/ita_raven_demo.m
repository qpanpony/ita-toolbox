% 1. set/check matlab paths


% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Projektdatei einlesen
% project laden
ravenProjectPath = 'C:\ITASoftware\Raven\RavenInput\Classroom\Classroom.rpf';

if (~exist(ravenProjectPath,'file'))
    [filename, pathname] = uigetfile('Classroom.rpf', 'Please select raven project file!');
    ravenProjectPath = [pathname filename];
end
ravenBasePath = ravenProjectPath(1:end-34);

rpf = itaRavenProject(ravenProjectPath);
%% Simulationsparameter einstellen
% Image sources up to second order
rpf.setISOrder_PS(2);

% 20000 ray tracing partikel
rpf.setNumParticles(20000);

% set impulse response length in ms (at least length of reverberation time)
rpf.setFilterLength(2800);  %[ms]
% rpf.setFilterLengthToReverbTime();    % estimates reverberation time and
% sets rpf.filterLength to this value

% set room temperature
rpf.setTemperature(21); %°C


%% Define simulation outputs
% activate image source simulation
rpf.setSimulationTypeIS(1);

% activate ray tracing simulation
rpf.setSimulationTypeRT(1);

% create mono room impulse response
rpf.setGenerateRIR(1);

% create binaural room impulse response
rpf.setGenerateBRIR(1);

% create and export energy histograms
rpf.setExportHistogram(1);  % histogramme z.B. benötigt für schnelle Nachhallzeitauswertung (RavenProject.getT30)


%% Quell- und Empfängerdaten
% set source positions
rpf.setSourcePositions([9 1.7 -2.5]);
rpf.setSourceViewVectors([-1 0 0]);
rpf.setSourceUpVectors([0 1 0]);

% set receiver positions
rpf.setReceiverPositions([4.4500    1.0000   -3.9000]);

% set sound source names
rpf.setSourceNames('Speaker Left');

% set source directivity 
rpf.setSourceDirectivity('KH_O100_Oli_5x5_3rd_relativiert_auf_azi0_ele0.daff');

%% start simulation 
% run simulation
rpf.run;

%% Ergebnisse abholen
% get room impulse responses
mono_ir = rpf.getImpulseResponseItaAudio();    % rpf.rpf.getImpulseResponse() without ITA-Toolbox
binaural = rpf.getBinauralImpulseResponseItaAudio();
reverb_time = rpf.getT30();


%% ITA-Toolbox......
mono_ir.plot_time_dB;      % plot mono RIR in time domain
binaural.plot_time_dB;     % plot binaural RIR in time domain

%% Example: Include loudspeaer frequency response in RIR (for comparisons with measurements)
pathFrequencyResponse = '..\RavenDatabase\FrequencyResponse\KH_O100_reference_holesclosed_final_at1V1m_fft14.ita';
if (~exist(pathFrequencyResponse,'file'))
    pathFrequencyResponse = [ ravenBasePath pathFrequencyResponse(4:end) ];
end

ls_O100 = ita_read(pathFrequencyResponse);
ir_mit_lautsprecher = ita_convolve(mono_ir, ls_O100);

%% Additional features
% show room model including sound sources
 rpf.plotModel;
 
 % show absorption coefficients
 rpf.plotMaterialsAbsorption;
 
 
