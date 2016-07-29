%% DEGA Intensivkurs 2012 - PDI
%Init

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;
ita_preferences('toolboxlogo',false);

%% Introduction to Discrete Fourier Transform
f           = 1000;     % Sine frequency in Hz.
amplitude   = 1;        % Amplitude.
fftDegree   = 14;       % Signal length, see explanation below.
sr          = 44100;    % Sampling rate in 1/s.

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

%% Measurement of an LTI system
% some parameters for stereo measurement
inputChannels  = 1; outputChannels = 3;
freq_range     = [20 20000];

s = ita_generate_sweep('mode','exp','freqRange',freq_range); %,'stopMargin',stopmargin,'fftDegree',fft_degree);

% perform the measurement by simply playing back the signal and recording
% the response
g = ita_portaudio(s,'inputChannels',inputChannels,'outputChannels',outputChannels);

% look at the signal and the (normalized) result in time domain, then frequency domain
s_and_g = ita_merge(s,ita_normalize_dat(g));
s_and_g.plot_time;

%% Spectrogram
g.plot_spectrogram

%% Deconvolution
S = fft(s);
G = fft(g);

H = ita_divide_spk(G, S, 'regularization',freq_range);
H.plot_freq

%% transform to time domain
h = ifft(H);
h.plot_time_dB('xlim',[0 min(0.5,double(s.trackLength))])

return %% back to PPT !

%% Measurement of Impulse Response
MS = itaMSTF;
MS.fftDegree = 18; MS.inputChannels  = 1; MS.outputChannels = 3;
MS.latencysamples = 1024;
MS.outputamplification = 20;
h  = MS.run
h.plot_time_dB

%% Calculation of Reverberation Time
h.trackLength = 3;
rt = ita_roomacoustics(h, 'freqRange', [200 8000], 'bandsPerOctave', 3, 'T40' );
rt.bar

%% Clarity Index
c80 = ita_roomacoustics(h, 'freqRange', [200 8000], 'bandsPerOctave', 3, 'C80' );
c80.bar

return %% back to PPT !

%% Nonlinearities - Spectrogram of g(t)
close all, clc
MS = itaMSTFdummy;
MS.outputamplification = 0;
MS.nonlinearCoefficients = [1 0.1 0.1 0.1];
g = MS.run_raw;
g.plot_spectrogram

%% Impulse response
h = MS.run;
h.plot_time_dB

return %% back to PPT !
