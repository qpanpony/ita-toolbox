%% Init 
% Before you start to measure the TFs of the HRTF, please make sure that:
% 0. set ita_preferences: playing/recording device: ASIO Hammerfall 
% connect the first channel output to the first channel input
%% calibrate
ms_calibrate = itaMSTF;
ms_calibrate.inputChannels = 11;
ms_calibrate.outputChannels = 19;
ms_calibrate.run_latency;

latency = ms_calibrate.latencysamples;

%%
%                         MovtecCOM Port: COM3 
%                         midi output device: multiface midi
% 1. turntable is runnig
% 2. you change the sensitivity of the microphones with ita_robocontrol
% 3. you created a itaEimar object. This object has to be reseted for each
% measurement
% 4. load interleaved sweep 

%ita_robocontrol('-20dB','Norm','0dBu')
HRTF_Eimar  = itaEimar;
outCh       = 19:1:82;

inCh        = 11:12;
% inCh        = 11:14; %flute
% fluet  75mm and 200mm
outAmp      = 35;
freqRange   = [200 22050];
latency     = 619;

iMS_HRTF                = itaMSTFinterleaved; % please close it...
iMS_HRTF.inputChannels  = inCh;
iMS_HRTF.outputChannels = outCh;
iMS_HRTF.freqRange      = freqRange;
iMS_HRTF.latencysamples = latency;
iMS_HRTF.outputamplification = outAmp;
iMS_HRTF.optimize;
iMS_HRTF.skipCrop = 1;
% %% Old interleaved

phiRes          = 2.5;
coord           = ita_generateSampling_equiangular(phiRes,1);       % create coordinates
coord_cut       = coord.n(coord.theta_deg == 90);
coord_cut       = coord_cut.n(coord_cut.phi_deg <= 180 );
% this prevents that the turntable move to every single direction%
%pause(30); 
% coord_cut = coord_cut.n(1);
HRTF_Eimar.measurementPositions     = coord_cut;
HRTF_Eimar.waitBeforeMeasurement    = 1;
HRTF_Eimar.measurementSetup         = iMS_HRTF;
HRTF_Eimar.doSorting = false;


%% Teller rotieren und Kamera
% Camera
%  IP http://137.226.61.17/
% benutzername: itacam
HRTF_Eimar.reset
HRTF_Eimar.reference;
 HRTF_Eimar.move_turntable(90)
%% Init/ Reset Turntable
% dataPath    = [datestr(now,'yyyymmmmdd_HHMM') 'reference_' num2str(phiRes) 'degree_KE3'];
dataPath    = [datestr(now,'yyyymmmmdd_HHMM') 'Jan' num2str(phiRes)];
HRTF_Eimar.dataPath = dataPath;
HRTF_Eimar.reset
HRTF_Eimar.reference;

disp('...................................................................')
disp('Reference position reached!')
disp('...................................................................')
%% Run measurement with Eimar
tic
HRTF_Eimar.run
t= toc;
disp('...................................................................')
disp(['Total time: ' num2str(round(t/60*100)/100)])
disp('...................................................................')

% run postprocessing
if (iMS_HRTF.skipCrop == 1)
    ita_HRTFarc_cropMeasurementData(iMS_HRTF,dataPath);
end
test_rbo_HRTF_meas_peakDetection(dataPath)


