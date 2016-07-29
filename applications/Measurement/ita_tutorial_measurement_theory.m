%% Explaining the theory of measurement
%
% <<../../pics/ita_toolbox_logo_wbg.jpg>>
%
% In this tutorial we will show you how basic signal processing and
% measurements of LTI systems work in general. Then we take a look at the
% measurement quality, non-linearities.
%
% *HAVE FUN! and please report bugs* 
%
% _2012 - Pascal Dietrich_
% toolbox-dev@akustik.rwth-aachen.de
%
% <<../../pics/toolbox_bg.png>>
% 

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Init
ccx;
ita_preferences('toolboxlogo',false);

ita_preferences

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

sine.plot_time % Plot resulting sine signal in the time domain. Reminder: Take a look at the frequency domain!


%% Audio Signal Processing with Music Signal
% Open a music file. This could also be a measurement or recording.
s = ita_demosound;

% play back the signal
s.play;

% view the spectrogram
s.plot_spectrogram

%% Filtering
% Let's apply a low and high pass, that means we actually apply a bandpass, to the
% original music signal. In this case we take the band limitations from a
% telephone line.
%
% * 300 Hz lower cut off
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

%% TASK 1 -- Influence of the phase;
% Take the music signal and delete the phase information. 

g_nophase = ita_zerophase(s);
g_nophase.plot_freq_phase
g_nophase.play

% Add a random phase but take the original magnitude of the spectrum
g_randphase = ita_randomize_phase( s );
g_randphase.play;
g_randphase.plot_freq_phase;


%% Measurement Signals
% Generate three different measurement signals:
% A perfect impulse, a noise signal and an exponential sweep signal.
% These signals also correspond to the recorded signal of an ideal
% transmission performed with these signals (i.e. the measured ideal LTI 
% system does not affect the transmitted signals).

% Set signal length
fftDegree = 17; % 2.9722s , feel free to change this!

% Generate perfect impulse
impulse = ita_generate('impulse',1,sr,fftDegree);
impulse = ita_time_shift(impulse,500,'samples'); % Shift a little bit to actually see the impulse...

% Generate white noiselevel
noise   = ita_generate('noise',1,sr,fftDegree);
noise   = ita_normalize_dat(noise); % Normalize to 0dBFS

% Generate exponential sweep
sweep   = ita_generate_sweep('fftDegree',fftDegree, 'samplingRate',sr , 'freqRange', [40 18000]);

% Merge all three generated signals into one itaAudio object for
% convenience.
signals = merge(noise, impulse, sweep);


%% TASK 2 -- Measurement of an LTI system
% Let's perform a measurement of an LTI system, which is characterized by its
% impulse response (IR). The easiest example is to measure the electrical
% behavior of your sound card, i.e. connect an audio cable from the output
% of your sound card to the input. The following graphic illustrates once
% again the relationship of time and frequency domain and the relationship between 
% input and output of an LTI system. Keep in mind, every measurement is
% distracted by noise! The used variable names are according to the
% graphic.
%
% <<../pics/lti_system.png>>
% 
% Make sure you set your hardware correctly in the preferences
%
% <matlab:ita_preferences Set preferences for the ITA-Toolbox>
%

% some parameters for stereo measurement
inputChannels  = 1:2;
outputChannels = 1:2;

% generate a measurement signal and plot it
% YOUR JOB
% fft_degree   = ...; % the length of your signal L = 2^fft_degree [in samples]
% freq_range   = [... ...]; % lower and upper cutoff frequency
% stopmargin   = 0.1; % time to wait for your system to decay
freq_range = [20 20000];
s = ita_generate_sweep('mode','exp','freqRange',freq_range); %,'stopMargin',stopmargin,'fftDegree',fft_degree);
s.plot_time

% perform the measurement by simply playing back the signal and recording
% the response
g = ita_portaudio(s,'inputChannels',inputChannels,'outputChannels',outputChannels);

% look at the signal and the (normalized) result in time domain, then frequency domain
s_and_g = ita_merge(s,ita_normalize_dat(g));
s_and_g.plot_time;
s_and_g.plot_freq;

% we introcuded a signal into the system that might not have a completely
% flat frequency response, we have to account for that by dividing by the
% excitation signal in the frequency domain
S = fft(s);
G = fft(g);

% division, H is now the impulse response in the frequency domain
% what happens at the edges of our frequency range? regularization is the
% key to this problem. We just add a small value called regularization parameter 
% to the denominator.

H = ita_divide_spk(G, S, 'regularization',freq_range);
H.plot_freq

% transform to time domain
h = ifft(H);
h.plot_time_dB('xlim',[0 min(0.5,double(s.trackLength))])


%%
% the transfer path measurement of a room is nothing else but the
% convolution of the measurement signal with the room impulse response (which is a
% multiplication in the frequency domain). To account for the unavoidable
% noise during a real measurement we also superimpose some background
% noise. 'noisy_signal' is the signal recorded during a measurement.

SNR                 = 30;   % signal (peak) to noise ratio
awgn                = 10^(-SNR / 20) * ita_generate('noise', 1, sr, signals.nSamples); % Additive measurement noise

noisy_signals = awgn + signals;

%% Deconvolution - calculate the dirac excitation of the noisy signals
% The same as before, but for non-ideal measurements with background
% noise:
%                           noise
%                            \ / 
%                             +
%                             |
% - signal input ('play') -> LTI(e.g. room) -> ('record') signal output -


% Deconvolution
frf = noisy_signals / signals; % your 'LTI System'

%Plot
frf.plot_freq
ylim([-50 50])
%See the difference!

%% Use filtering and regularization
% Some artifacts could be seen in the previous frequency responses.
% If only a certain frequency range is of interest, a filtered and
% regularized deconvolution can be used. Compare with the previous frequency responses!
frf = ita_divide_spk( noisy_signals , signals , 'regularization', [50 16000],'zerophase',false) ;

% Plot
frf.plot_freq
ylim([-50 50])

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

%% Measurement and analysis of an LTI system (room)
% Let's perform a measurement and an analysis of an LTI system, such as a room, 
% which is characterized by its room impulse response (RIR).
% In the previous step we have generated an artificial perfect RIR.
% Every measurement is distracted by noise, so we'll have regard this in
% our simulated measurement.
%
% <!<../pics/lti_system.png>>
% 

% Set noise parameter
SNR                 = 30;   % signal (peak) to noise ratio

% Close all plots
close all

% Prepare measurement signal
s                   = signals.ch(3);                % use the sweep
s.trackLength       = s.trackLength + 2;    % same lengths of signals

% Prepare RIR
RIR.trackLength     = s.trackLength;

% Generate noise
awgn                = 10^(-SNR / 20) * ita_generate('noise', 1, sr, s.nSamples); % Additive measurement noise

% the transfer path measurement of a room is nothing else but the
% convolution of the measurement signal with the RIR (which is a
% multiplication in the frequency domain). To account for the unavoidable
% noise during a real measurement we also superimpose some background
% noise. 'g' is the signal recorded during a measurement.

g = s*RIR + awgn;

% To obtain the impulse response of the room (which ideally would be
% equal to the RIR), we have to deconvolute the measurement as introduced
% in the previous sections (division in the frequency domain).
h_measured          = ita_divide_spk( g , s , 'regularization', [50 16000],'zerophase',false) ;
h_measured.channelNames{1} = 'measured RIR';

% Merge both signals, the measured and the perfect RIR, for later
% comparisons.
res = merge( h_measured, RIR);

% Plot
res.plot_time_dB

%% Use the Measurement Class from the ITA-Toolbox
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




