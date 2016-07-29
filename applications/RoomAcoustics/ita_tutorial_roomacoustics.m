%% Tutorial Script - Analysis of room impulse responses (RIR)
%
% <<../../pics/ita_toolbox_logo_wbg.jpg>>
%
% This tutorial demonstrates how to use the RoomAcoustics application
%
%

% Author: Martin Guski - March 2013. 
%
% Take a look at this Reference for details and plots:
%
% @INPROCEEDINGS{pdiToolboxDAGA2013,
%   author = {Pascal Dietrich and ?Martin Guski and Johannes Klein and Markus Müller-Trapet
% 	and Martin Pollow and Roman Scharrer and Michael Vorländer},
%   title = {?Measurements and Room Acoustic Analysis with the ITA-Toolbox for
% 	MATLAB},
%   booktitle = DAGA2013,
%   year = {2013}}

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Init
ccx
mode = 1; % 1: simple RIR, 2: modal superposition, 3: read your measurement data from harddrive

%% generate simple RIR (just exponential decay)
% to demonstrate ita_roomacoustics(). Use ita_read() to load real measurements.
if mode == 1
    fftDegree    = 17;    % length of impulse response ( = 2^fftDegree samples)
    samplingRate = 44100; % sampling rate in Hz
    revTime      = 2;     % in seconds
    PSNR         = 50;    % (peak)signal to noise ratio in dB
    
    RIR          = ita_generate('noise', 1, samplingRate, fftDegree);                               % generate noise
    RIR.timeData = RIR.timeData .* 10 .^( RIR.timeVector * ( -60/ revTime ) / 20);                % with exponantial decay (=signal)
    RIR          = ita_time_shift(RIR, 0.1, 'time');                                              % and delay (0.1 seconds)
    RIR          = RIR + 10^ (-(PSNR-10) / 20) *ita_generate('noise', 1, samplingRate, fftDegree);  % add background noise (10 dB difference between peak and mean)
    RIR.comment  = sprintf('Synthetic room impulse response (PSNR = %2.1f dB, T = %2.2f s)', PSNR, revTime);
    RIR.channelNames = {'Synthetic RIR'};
    
    %plot the impulse response
    RIR.plot_dat_dB
end

%% ALTERNATIVE -- Get RIR from modal superposition in rectangular room
if mode == 2
    ita_disp('Calculating modal superposition. This may take some time...')
      revTime      = 2;     % in seconds
    L           = [2.5,3,4]; % room geometry in meters
    r_source    = [1,1,1]; % position of source in meters
    r_receiver  = [1.7,2.4,3.2]; % position of receiver in meters
    fmax        = 2000; % maximum frequency to search for modes in Hertz
    RIR         = ita_roomacoustics_analytic_FRF_book(itaCoordinates(L), itaCoordinates(r_source), itaCoordinates(r_receiver),'f_max',fmax,'T',revTime,'c',340,'fftDegree',fftDegree+1,'samplingRate',samplingRate,'pressuremode',false);
    RIR         = ita_normalize_dat(ita_extract_dat(RIR,fftDegree));
    RIR         = RIR + 10^ (-(PSNR-10) / 20) *ita_generate('noise', 1, samplingRate, fftDegree);  % add background noise (10 dB difference between peak and mean)
    RIR.plot_dat_dB
end

%% Read your measurement data from harddrive
if mode == 3
    RIR = ita_read;
end
%% see help for detailed information on options and syntax of function calls
help ita_roomacoustics

%% calculate reverberation time (EDT, T10, T20, ...) and energy parameter (C50, C80, D50, D80, Center_Time)
% ita roomacoustics() preforms search for start of impulse response, fractional octave band filtering and noise detection and compensation (all according to ISO 3382)
freqRange       = [250 4000];       % frequency range and
bandsPerOctave  = 3;                % bands per octave for filtering

% calculate just T20 with given frequency range in 1/1 octave bands
raResult = ita_roomacoustics(RIR, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'T20');  % BTW: [ 'T20' ] is short for [ 'T20', true ]. works for all boolean options
raResult.T20.bar


%% Calculte more room acoustic parameter with one function call
% for examples EDT, T2, C80 and peak-signal to noise ratio
raResults = ita_roomacoustics(RIR, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'PSNR_Lundeby', 'EDT', 'T20', 'C80', 'PSNR_Lundeby' );

% output is a struct with itaResults:
raResults.EDT.plot_freq
raResults.T20.plot_freq
raResults.C80.plot_freq
raResults.PSNR_Lundeby.plot_freq

%% Calculate Room Acoustic Parameters with default Parameters
% calling ita_roomacoustics() without additional parameters uses the following default parameters:
%       filter parameter (freqRange and bandsPerOctave) will be taken from ita_preferences()
%       calculate the RA parameters defined in ita_roomacoustics_parameters()

raResults = ita_roomacoustics(RIR);
disp(raResults)

%% tonal coloration: ita_roomacoustics_tonal_color()
% calling ita_roomacoustics_tonal_color() without additional parameters will
% calculate bass and treble ratio and use T20 for reverberation time
[bassRatio, trebleRatio]  = ita_roomacoustics_tonal_color(RIR)

% use options to adjust the calculation:
% calculate just bass ratio and use T10 instead of T20
bassRatioT30  = ita_roomacoustics_tonal_color(RIR, 'bass_ratio', true, 'treble_ratio', false, 'reverberationTime', 'T10')


%% calculate schroeder curves
% Plot the energy decay curve according to Schroeder's formulation
raResults = ita_roomacoustics(RIR, 'EDC', 'freqRange', [100 4000], 'bandsPerOctave', 1);
raResults.EDC.plot_time_dB


%% show differences of noise compensation techniques
% different noise compensation techniques are implemented. Most of them are
% compliant with ISO 3382.
noiseCompMethods = {'noCut', 'justCut', 'cutWithCorrection', 'subtractNoise', 'subtractNoiseAndCutWithCorrection'};
allRes = itaAudio(numel(noiseCompMethods),1);                           % create a vector of of itaAudios

for iMethod = 1:numel(noiseCompMethods)
    tmpRes = ita_roomacoustics(RIR, 'EDC', 'freqRange', [1000 1000], 'bandsPerOctave', 1, 'edcMethod', noiseCompMethods{iMethod});
    allRes(iMethod) = tmpRes.EDC;
end

allRes = merge(allRes);                                                 % merge vector to one itaAduio with N channels
allRes.channelNames = ita_sprintf('edcMethod: %s', noiseCompMethods);   % give meaningful channelnames ...
allRes.comment = 'Differences of noise compensation technueques';
allRes.plot_time_dB                                                     % logarithmic plot in time domain

