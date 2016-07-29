function RT = ita_laboratory_v2_RTmeasurement()

% This m file measures the reverberation time with four microphones and
% saves the average result in RT.mat
% in directory ...\ITA-Toolbox\Applications\Laboratory\V2
%% initialise

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

mfilePath = fileparts(mfilename('fullpath'));
% mfilePath = '';  % just save in current directory instead of mfile path
ita_preferences('fontsize',14);
% ita_preferences('verboseMode',0);
% commandwindow

%% measurement setup
% excitation settings
inputChannels           = 1:8;
outputChannels          = 1;
fraction                = 3;
fftDegree               = 20;
samplingRate            = 44100;
measurementRange        = [200 22050];
stopMargin              = 0.25;
averages                = 1;
comment                 = 'Laboratory V2';
outputAmplification     = '-20dB';
iMS                     = load('V2_MeasuringStation.mat','iMS');
iMS                     = iMS.iMS;
MS                      = itaMSTF('inputChannels',inputChannels,'outputChannels',outputChannels,'samplingRate',samplingRate, ...
                                'fftDegree',fftDegree,'freqRange',measurementRange, ...
                                'stopMargin',stopMargin,'outputamplification', outputAmplification,...
                                'comment',comment,'averages',averages);
MS.inputMeasurementChain = iMS.inputMeasurementChain(1:8);
MS.outputMeasurementChain = iMS.outputMeasurementChain;
save([mfilePath filesep 'V2_MS.mat'],'MS');

%% Measurement
% Signal-to-Noise
[SNR,Signal] = MS.run_snr(fraction);
FRF = (Signal*MS.compensation)/MS.outputamplification_lin;
FRF.signalType = 'energy';

SNR.plot_spk('ylim',[0 80]);

% Reverb Time
RT_all = ita_roomacoustics(ita_extract_dat(FRF.ch(5:8),16),'T20','freqRange',measurementRange,'edcMethod','justCut');
RT = mean(RT_all.T20);
ita_write(RT);

%
close all
RT.plot_spk('nodb','ylim',[0 1],'xlim',[225 22000]);
