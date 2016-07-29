%% Übung zur Vorlesung Elektroakustik - PDI, JCK
%Init

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;
ita_preferences('toolboxlogo',false);

%% Introduction to Discrete Fourier Transform
% Generate a simple sine and plot the time signal.
% Task: Use the menu bar to see the spectrum (domain->magnitude)
f           = 1000;     % Sine frequency in Hz.
amplitude   = 1;        % Amplitude.
fftDegree   = 14;       % Signal length, see explanation below.
sr          = 44100;    % Sampling rate in 1/s.
% fftDegree: For the efficient fast Fourier transform (FFT) a signal with a
%            number of samples in the power of two is required. Thus the
%            signal lengths are varied in steps.
%            Example: 
%                       - Sampling rate: 44100 1/s
%
%                       - Number of samples:  2^17 = 131072
%                       - Resulting signal length: 2^17/44100Hz = 2.9722 s
%                       
%                       - Number of samples: 2^18 = 262144
%                       - Resulting signal length: 2^18/44100 = 5.9443 s

% Generate the signal
sine = ita_generate('sine',amplitude,f,sr,fftDegree);

sine.nSamples = 890;

sine.plot_time % Plot resulting sine signal in the time domain. Reminder: Take a look at the frequency domain!


%% Audio Signal Processing with Music Signal
% Open a music file. This could also be a measurement or recording.
s = ita_demosound;

s.plot_time

% play back the signal
s.play;

s.plot_freq

%% view the spectrogram
s.plot_spectrogram

%% Filtering
% Let's apply a low and high pass, that means we actually apply a bandpass, to the
% original music signal. In this case we take the band limitations from a
% telephone line.
%
% *  300 Hz lower cut off
% * 4000 Hz upper cut off
%
f_low  = 300;
f_high = 4000;
g = ita_filter_bandpass(s,'lower',f_low,'upper',f_high);

% Have a look at the results
g.plot_freq 

% Play back the telephone emulation
g.play

% view the spectrogram
g.plot_spectrogram

%% Influence of the phase;
% Take the music signal and delete the phase information. 
close all
g_nophase = ita_zerophase(s);
g_nophase.plot_freq_phase
g_nophase.play

%% Add a random phase but take the original magnitude of the spectrum
g_randphase = ita_randomize_phase( s );
g_randphase.plot_freq_phase;
g_randphase.play;

return %% back to PPT !

%% Generate perfect impulse
close all, clc, fftDegree = 16; sr = 44100;
impulse = ita_generate('impulse',1,sr,fftDegree);
impulse.plot_time('xlim',[-1 2])
impulse.play

%% Deconvolution with Music
s = ita_demosound;

h = fft(s) / fft(s);
h.plot_spkphase

%% Avoid Division by zero
H = ita_divide_spk(s, s, 'regularization',[100 10000]);
H.plot_freq

return %% back to PPT !

%% Measurement Signals -- Generate white noiselevel
close all, clc, fftDegree = 16; sr = 44100;
noise   = ita_generate('noise',1,sr,fftDegree);
noise   = ita_normalize_dat(noise); % Normalize to 0dBFS
noise.plot_spectrogram
noise.play

%% Generate linear sweep
sweep   = ita_generate_sweep('mode','lin','fftDegree',fftDegree, 'samplingRate',sr , 'freqRange', [40 18000]);
sweep.plot_spectrogram
sweep.play

%% Generate exponential sweep
sweep   = ita_generate_sweep('fftDegree',fftDegree, 'samplingRate',sr , 'freqRange', [40 18000]);
sweep.plot_spectrogram
sweep.play

return %% back to PPT !

%% Generate artifical room impulse response
% In this section a simulated room impulse response (RIR) will be
% generated basing on a noise signal.

% Set room and recording position parameters.
revTime = 1;    % Reverberation time of the room, in sec.
delay   = 0.05; % Pre-delay before sound arrives at the listener, in sec.
fftDegree = 17; % length of IR is 2^fftDegree samples

% Generate RIR
RIR          = ita_generate('noise', 0.5, sr, fftDegree);                       % Plain noise
RIR.timeData = RIR.timeData .* 10 .^( RIR.timeVector * ( -60/ revTime ) / 20);  % with exponantial decay (=signal)
RIR          = ita_time_shift(RIR, delay, 'time');                              % and delay (in seconds)
RIR.signalType = 'energy';
RIR.channelNames{1} = 'ideal RIR';
RIR.plot_time_dB

%% Use the Measurement Dummy Class from the ITA-Toolbox for virtual measurement
MS = itaMSTFdummy; % get measurement setup object

% specify measurement parameters
MS.fftDegree            = 19; % Set length of sweep signal
MS.stopMargin           = 1; % Time to wait until the system decays
MS.freqRange            = [20 20000]; % Frequency range for the measurement
MS.outputamplification  = -30; % level below maximum amplitude in dBFS (full scale)
MS.averages             = 1; % number of measurements to be averaged to get a mean result
MS.samplingRate         = sr; % sampling Rate of the system

% specify the device under test (DUT) to be measured
MS.nonlinearCoefficients = [1]; % only linear transmission or e.g. [1 0.1 0.1] for g = 1*s^1 + 0.1*s^2 + 0.1*s^3
MS.noiselevel            = -30; % noise level below maximum amplitude in dBFS
MS.systemresponse        = RIR; % impulse response of the system
MS.nBits                 = 24; % Quantization of the system

% simulation of the actual measurement
h_measured               = MS.run; % get the measured impulse response with nonlinearities, quantization and noise
h_measured.plot_time_dB % plot IR in dB

%% How to obtain a higher SNR ?
% Usually the noise level during room acoustical measurements is quite
% high. To improve the signal to noise ratio (SNR), we can measure the IR
% several times and average the results. This improves the SNR since noise 
% is not correlated (+3dB), but the measurement signal is correlated
% (+6dB).

% Close all plots
close all

% Set number of averages, feel free to experiment!
MS.averages = 4;

% % Average! - this is what happens below, when you run your measurement
% for idx = 1:averages
%     awgn   = 10^(-SNR / 20) * ita_generate('noise', 1, sr, s.nSamples); % Generate new additive measurement noise for every measurement!
%     g(idx) = s*RIR + awgn;  % Add background noise
% end
% g = sum(g)/averages;

% Measurement with deconvolution
h_measured_av          = MS.run ;
h_measured_av.channelNames{1} = ['with ' num2str(MS.averages) ' averages'];

% Merge
res = merge(RIR,h_measured, h_measured_av);

% Plot and compare!
res.plot_time_dB


%% Nonlinearities - Spectrogram of g(t)
close all, clc
MS2 = itaMSTFdummy;
MS2.outputamplification = 0;
MS2.nonlinearCoefficients = [1 0.1 0.1 0.1];
g = MS2.run_raw;
g.plot_spectrogram

%% Impulse response of non-linear system
h = MS2.run;
h.plot_time_dB

%% Nonlinearities with RIR noise and quantization
MS.outputamplification = 0;
MS.nonlinearCoefficients = [1 0.1 0.1 0.1];
MS.noiselevel            = -10;
h = MS.run;
h.plot_time_dB

%% measurement setup
ccx
ita_preferences('useMeasurementChain',0);
ccx
MS = itaMSTF;
MS.inputChannels  = 1;
MS.outputChannels = 1;
MS.fftDegree = 17;
MS.freqRange = [10 25000]

%% electrical reference
MS.outputamplification = 0
ita_robocontrol(0,'lineref',0)
MS.init
MS.run_latency;

%%
MS.run_reference
ref = MS.reference;
ref.plot_all

%% run transfer function measurement
ita_robocontrol(0,'norm',0)
MS.outputamplification = -10;
a = MS.run
a.ptd

%%
b = ita_time_window(a,[0.3 0.4],'time')
b.pf

%% signal measurement - calibrated
ccx
ita_preferences('useMeasurementChain',1);
ccx
MS = itaMSRecord;
MS.inputChannels = 3;

%%
MS.calibrate

%% impedance setup
ccx
MS = itaMSImpedance;
MS.fftDegree = 18;

%% calibrate with known resistor
MS.calibrate

%% run impedance measurement of loudspeaker
MS.outputamplification = 20
Z_mit = MS.run
Zs = merge(Z,Z_mit)
Zs.pfp('nodb')
