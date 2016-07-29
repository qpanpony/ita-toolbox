%% Tutorial to illustrate the effect of impulsive noise during sweep measurements 
% and a new automatic impulsive noise detection
% technique.
%
% Autor: Martin Guski, mgu@akustik.rwth-aachen.de, 14-05-2014
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>
%

%% Simulate a room using a modal superpositioning approach

% signal parameter
samplingRate  = 44100;      % sampling rate in Hz
fmax          = 2000;       % maximum frequency in Hz for simulation (Reduce fmax (for example to 1000) for faster calculation.)
fftDegree     = 18;         % length of signal is 2^fftDegree samples

% room parameter
RT            = 1.5;               % reverberation time in seconds
L             = [2.5,    3, 4  ];  % room geometry in meters
r_source      = [0.1,  0.1, 0.1];  % position of source in meters
r_receiver    = [1.7,  2.4, 3.2];  % position of receiver in meters

mb_handle = msgbox('Modal superpositioning is calculating... This will take some time. Reduce fmax (for example to 1000) for faster calculation.');

RIR           = ita_roomacoustics_analytic_FRF_book(itaCoordinates(L), itaCoordinates(r_source), itaCoordinates(r_receiver),'f_max',fmax,'T',RT,'c',340,'fftDegree',fftDegree+1,'samplingRate',samplingRate,'pressuremode',false);
RIR.fftDegree = fftDegree;

% simulate impulsive noise: ideal impulse from a different position in the room
impulsiveNoise           = ita_roomacoustics_analytic_FRF_book(itaCoordinates(L), itaCoordinates([1 1 1]), itaCoordinates(r_receiver),'f_max',fmax,'T',RT,'c',340,'fftDegree',fftDegree+1,'samplingRate',samplingRate,'pressuremode',false);
impulsiveNoise.fftDegree = fftDegree;
impulsiveNoise.signalType = 'power';

% ambient noise is stationary Gaussian noise
stationaryNoise = itaAudio(randn(2^fftDegree,1), samplingRate, 'time');


% sweep parameter
freqRange    = [55 fmax];
stopMargin   = 1.3;             % time of silence at the end, allowing the last frequencies to decay
sweep        = ita_generate_sweep('freqRange', freqRange, 'fftDegree', fftDegree, 'stopMargin', stopMargin, 'samplingRate', samplingRate);
compensation = ita_invert_spk_regularization(sweep, freqRange);  % compensation (or deconvolution) is the inverted spectrum of the sweep


% prepare plotting
opengl software % on some computer plotting errors occur, switch to software just in case...
fgh = figure('position', get(0, 'screenSize'));
if ishandle(mb_handle), close(mb_handle); end
%% combine signals

% amplification and time shift of components
ampConstNoise     = -40;  % dB
ampImpulviseNoise = 35;   % dB
timeShiftImpNoise = 4.6;  % s
timeDelayRIR      = 0.25; % s


% shift impulsive noise to simulate different time of occurance
impNoise_shift             = impulsiveNoise;
impNoise_shift.trackLength = impNoise_shift.trackLength*2;
impNoise_shift             = ita_time_shift(impNoise_shift, timeShiftImpNoise, 'time');
impNoise_shift.trackLength = impulsiveNoise.trackLength;


% combine all single components in one object
singleComponents = merge( ita_time_shift(RIR, timeDelayRIR, 'time')*sweep, ... % excitation signal at mic position
                          stationaryNoise * 10^(ampConstNoise/20),         ... % stationary noise (with amplification
                          impNoise_shift  * 10^(ampImpulviseNoise/20));        % impulsive noise with amplification

% edit meta data...
singleComponents.channelNames = {'excitation', 'stat. noise' 'impulsive noise'};
singleComponents.comment = '';

% PLOT single components
ita_plot_time_dB(singleComponents,'figure_handle', fgh,  'axes_handle', subplot(231)); 
legend off; title('single components')


%% the recorded signal at the micrpphone position is the sum of all components
rec = sum(singleComponents);
rec_noImpNoise = singleComponents.ch(1)  +  singleComponents.ch(2);  % one version without impulsive noise for comparison

% get implulse response by compensatin the excitation signal (deconvolution)
rir_m            = rec * compensation;
rir_m_noImpNoise = rec_noImpNoise*compensation;

% PLOT resultim impulse responses
bothRIR = merge(rir_m, rir_m_noImpNoise);
ita_plot_time_dB(bothRIR,'figure_handle', fgh,  'axes_handle', subplot(232))
legend({'impulsive noise' 'no impulsive noise'});title('room impulse response')



%% SPECTROGRAM OF IMPULSE RESPONSE

ita_plot_spectrogram(bothRIR.ch(1),'figure_handle', fgh,  'axes_handle', subplot(233))
ylim([0 1.1]); set(gca, 'Ytick', 0:.1:1,'yticklabel', 0:100:1000); title('room impulse response')


%% REVERBERATION TIME

% calculate T20 and T30
ra = ita_roomacoustics(bothRIR.ch(1:2), 'T20', 'T30', 'freqRange', freqRange, 'bandsPerOctave', 3 ); 

% plot T20
ita_plot_freq(ra.T20,'figure_handle', fgh,  'axes_handle', subplot(223));
legend({'impulsive noise' 'no impulsive noise'}, 'location', 'south')
title('evaluated reverberation time')

%% ESTIMATED BACKGROUND NOISE
[result, pRMSR, noise] = ita_impulsiveNoiseDetection(bothRIR, sweep);

% plot
ita_plot_time_dB(noise.ch(1:2),'figure_handle', fgh,  'axes_handle', subplot(224))
title('estimated background noise')
legend(ita_sprintf('L_{max,rms} %2.1f dB' , pRMSR), 'location', 'northwest')