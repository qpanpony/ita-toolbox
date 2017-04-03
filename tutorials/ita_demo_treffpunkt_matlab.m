%% Treffpunkt MATLAB - ITA Toolbox lecture demo
%
%
% In this document we will give you a basic introduction to the ITA toolbox
% and its application in signal processing and acoustical measurements.
%
% *HAVE FUN! And please report bugs* 
%
% _2017 - JCK, JRI, MBE, RBO
% toolbox-dev@akustik.rwth-aachen.de
%
% 
 
% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox.
% All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
 
%% SLIDES - ITA INTRODUCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Initialization
% The first toolbox command you should know is 'ccx'. It clears all
% variables, closes all plots, basically brings MATLAB back to its initial
% state.
ccx;
 
% Select your sound card in the ita_preferences, tab 'IO Settings' as
% 'Recording' and 'Playing Device'
ita_preferences;
 
%% Introduction to class |itaValue|
% itaValue is a toolbox class to store values with a physical unit
 
m = itaValue(5.2,'kg');     % Mass [kg]
g = itaValue(9.81,'m/s^2'); % Acceleration [m/s^2]
 
% The units are consolidated upon multiplication or division
F = m*g %#ok<NOPTS> % Force [N]
 
%% Introduction to class |itaCoordinates|
% itaCoordinates is a toolbox class to store and transform coordinate data
 
% Create object with 20 coordinate points
N     = 20;
coord = itaCoordinates(N);
 
% The properties of the object can be accessed with the '.' operator.
% For instance the number of coordinate points
coord.nPoints
 
% As an example we assign random values to all x and y components
coord.x = rand(N,1);
coord.y = rand(N,1);
% To assign the same value to a component of all points we use a scalar
coord.z = 1;
 
% Examine the Cartesian coordinates
coord.cart      % all data
 
% Or their spherical or cylindrical transformations
coord.sph
coord.cyl
 
% Visualization
scatter(coord);          % Plot the points only
plot(coord);   % Plot the points, connected in order        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADVANCED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There are toolbox functions that create specific distributions of
% coordinate points for you. For instance a spherical equiangular sampling
% has points every 5 degrees in horizontal and azimuthal direction.
equi = ita_generateSampling_equiangular(5,5);

% For the latter it is more interesting to have a non-uniform function
% for instance a cardioid.
surf(equi, 1 + cos(equi.theta)); % Points connected to a closed surface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Introduction to class |itaAudio|
% itaAudio is the toolbox class used to store audio data
 
sine = itaAudio; % Create empty object of class itaAudio
 
sine.comment            = 'Sine'; % Set comment for entire object
sine.trackLength        = 2; % Set length in seconds
 
% timeVector contains the list of sampling times
t = sine.timeVector;
 
% Let's generate the actual sine by hand!
f = 1000; % Set frequency
 
% The frequency and sampling times are the argument of a sine.
% Store the resulting amplitude values in the audio object.
sine.time   = sin(2* pi * f * t);
sine = sine * itaValue(1,'Pa'); % Assign a physical unit
 
sine2 = sine; % sine2 is a copy of sine.
sine2 = sine2 * 5; % Amplify through multiplication (here to 5 Pa)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADVANCED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sine.channelNames{1}    = 'First channel'; % Comment for first channel
sine2.channelNames{1} = 'Copy'; % Set new channel name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Several audio objects can be merged to one object with multiple channels
sine_comp = merge(sine, sine2);
 
% Plot
sine_comp.plot_time;    % Time domain, linear amplitude scale
sine_comp.plot_time_dB; % Time domain, dB amplitude scale
% Use the keys A, * and / to look at all or singe channels and flip through
% them.
 
%% SLIDES - DIGITAL SIGNAL PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Generate a sine, the easy way
ccx; % Clear workspace
 
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
 
% Use the function ita_generate to generate the sine
% HINT: You'll find examples for each function in the help and the actual
% function file. Try "help ita_generate" and "edit ita_generate".
sine = ita_generate('sine',amplitude,f,sr,fftDegree);
 
% We limit the number of samples in the time domain for later
% considerations
sine.nSamples = 890;
 
%% Discrete Fourier Transform
 
% Look at the signal in the time domain
% HINT: ".pt" is short for ".plot_time"
sine.pt
% Now have a look at the DFT of the signal. This representation shows you 
% which frequencies are included in the signal.
% HINT: ".pf" is short for ".plot_freq"
sine.pf
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Look at the sine in the time domain. You will see that it ends suddenly
% before it reaches a 0 amplitude level. This is a jump in the signal.
% If you look at the sine in the frequency domain you will see that it
% has a dominant 1000 Hz component as intended. However, the other
% frequency components are not completely gone. That's the case due to the 
% jump in the signal. Only if the signal consists of a full sine period
% will we see just the expected 1000Hz component in the frequency domain.
% Find the right number of samples to fit 20 full periods should into given 
% time slot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% YOUR CODE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 period of 1kHz sine = 1/1kHz = 0.001
% 20 full periods with 441001/s sampling rate => 20 * 0.001 * 44100 = 882
sine.nSamples = 882;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Check the resulting sine
sine.pt
sine.pf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO TASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a white noise signal and look at both domains
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% YOUR CODE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noise = ita_generate('noise',1,44100,15);
noise.pt
noise.pf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
%% Load demo sound for further demos
sound = ita_demosound; % Built-in toolbox demo sound
 
%% Quantization
 
% Re-quantize the signal and listen to the effect
quant_8bit = ita_quantize(sound,'bits',8);
quant_8bit.play;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO TASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantize the signal with different bit values. how is the signal
% changing?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% YOUR CODE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
quant_4bit = ita_quantize(sound,'bits',4);
quant_4bit.play;
quant_4bit.pt

quant_2bit = ita_quantize(sound,'bits',2);
quant_2bit.play;
quant_2bit.pt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
%% Sampling and filtering
 
% We can simulate aliasing by artificially reducing the sampling rate.
% In this example, the sampling rate is reduced by a factor of 20, meaning
% that only every 20th sample would have been recorded.
% The new sampling rate will be 2205 1/s.
% The highest representable (Nyquist) frequency is 1102.5 Hz
 
sound1 = sound;
% Take only every 20th sample -> 20 times lower sampling rate.
sound1.timeData = sound1.timeData(1:20:end);
 
% Adjust the sampling rate information in the objects meta data
sound1.samplingRate = sound1.samplingRate / 20;
 
% Play sound
sound1.play;
 
% Plot
sound1.pf;
 
% Reducing the sampling rate like this results in aliasing. The energy
% contained in frequencies higher than the maximum frequency
% (here: 1102.5 Hz) will be assigned to lower frequencies.
 
sound2 = sound;
% To avoid aliasing we have to make sure, that no
% information above our Nyquist frequency exists.
sound2_filtered = ita_filter_bandpass(sound2,'upper',1000);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO TASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reduce the sampling rate of the filtered signal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% YOUR CODE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sound2.timeData = sound2_filtered.timeData(1:20:end);
sound2.samplingRate = sound2.samplingRate / 20;
sound2.play;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Compare the spectra of sound, sound1 and sound2. Do you see aliasing 
% effects in the first one?
plot_sound = merge(sound, sound1, sound2);
plot_sound.plot_freq;
 
% The representation of the frequencies contained within a signal over the
% time is called spectrogram. Have a look at it for the demo sound!
sound.plot_spectrogram
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO TASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulate the transmission of the music signal over the telephone.
% Telephones only transmit frequencies between 300 Hz and 4000 Hz.
% Use ita_filter_bandpass to filter the signal and cut information
% that is not transmitted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% YOUR CODE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f_low  = 300;
f_high = 4000;
sound_telefon = ita_filter_bandpass(sound,'lower',f_low,'upper',f_high);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Have a look at the spectrogram of the filtered signal.
% What are the differences?
sound_telefon.plot_spectrogram
 
%% Influence of the phase;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADVANCED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take the music signal and delete the phase information. 
 
g_nophase = sound;
% Get rid of the phase information.
g_nophase.freqData = abs(sound.freqData) .* exp(1i*2*pi*zeros(sound.nBins,1));
g_nophase.plot_freq_phase
g_nophase.play
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO TASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a random phase but take the original magnitude of the spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% YOUR CODE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g_randphase = sound;
g_randphase.freqData = abs(sound.freqData) .* exp(1i*2*pi*rand(sound.nBins,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
g_randphase.play;
g_randphase.plot_freq_phase;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% SLIDES - LTI SYSTEMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% LTI System

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADVANCED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a signal that you will send through the LTI system.
s = ita_generate_sweep;
 
% Load previously measured response of an LTI system to the sweep input
g = ita_read('g.ita');
 
% Have a look!
g.pt
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO TASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take the FFT of both signals and divide them to get the impulse 
% response.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% YOUR CODE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = ita_divide_spk(g, s); %#ok<NASGU>
 
% better with regularization
h = ita_divide_spk(g, s, 'regularization', [20 20000]);
 
% Alternative:
% h = g/s;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
h.pt
h.pf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Introduction to class |itaMSTF|
 
% itaMSTF is a toolbox class designed for transfer function measurements
 
% Select your sound card in the ita_preferences, tab 'IO Settings' as
% 'Recording' and 'Playing Device'. NOT NEEDED FOR THE SIMULATION
ita_preferences;
 
% Generate class object
MS = itaMSTFdummy;
 
% Have a look at the defaults
MS %#ok<NOPTS>
 
% Set input and output channels of your hardware
MS.inputChannels  = 1;
MS.outputChannels = 1;
 
% Set signal length, 2^fftDregree samples
MS.fftDegree = 17;
 
% In real measurement setup-ups be careful not do damage the speakers
MS.outputamplification = -5;

% Set output amplification in dBFS. 0 dBFS -> Digital signal amplitude of
% 1. -20 dBFS -> digital signal amplitude of 0.1 . Have a look!
MS.outputamplification = 0;
MS.excitation.plot_time;

%% Room impulse response simulation
% In this section a simulated room impulse response (RIR) will be
% generated basing on a noise signal.

% Generate RIR
fftDegree   = MS.fftDegree; % length of IR is 2^fftDegree samples
fmax        = 10000; % highest eigenfreuency in Hertz

% Define the room size (x,y,z)
L           = [8 5 3]/10;

% Define the source position
r_source    = [5 3 1.2]/10; % positions

% Set the reverbration time of each eigenmode
T           = 1;

% Simulate
RIR         = ita_roomacoustics_analytic_FRF_book(itaCoordinates(L), itaCoordinates(r_source), itaCoordinates([0 0 0]),'f_max',fmax,'T',T,'fftDegree',fftDegree,'pressuremode',false);


%% Measurement
% Set system response
MS.systemresponse = RIR;
MS.nonlinearCoefficients = 1; % only linear transmission or e.g. [1 0.1 0.1] for g = 1*s^1 + 0.1*s^2 + 0.1*s^3
MS.noiselevel            = -30;
 
% Execute measurement
result = MS.run;
 
% Have a look at the result
result.plot_time;
result.plot_freq;
 
% Take note of the signal to noise ratio (SNR)
result.plot_time_dB;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADVANCED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEMO TASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Think about a way of increasing SNR by 6dB. Make your changes in the MS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% YOUR CODE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alternative 1
MS.averages = 4;
 
% Alternative 2
MS.fftDegree = MS.fftDegree + 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
result_6dB_more = MS.run;
 
compare_snr = merge(result, result_6dB_more);
compare_snr.plot_time_dB;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Room Acoustics Demo
% The toolbox contains functions to evaluate measured room impulse
% responses. Here we'll demonstrate a short room acoustical evaluation.
 
% Room acoustics
rA_result = ita_roomacoustics(result, 'freqRange', [250 10000], 'bandsPerOctave', 3, 'T20');
rA_result.T20.pf;