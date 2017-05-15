%% Intensivkurs Raumakustik Messtechnik (DEGA version)
% Combined lecture and excercise
%
% WARNING: This excersise might require measurements conducted outside 
% this demo script.
%
% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox.
% All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% _2016 - JCK, GKB
% toolbox-dev@akustik.rwth-aachen.de

warning('off','MATLAB:nargchk:deprecated');

%% Outputsettings
double_outputamp = -6;
double_latencysamples = 8605;
double_inputChannel = 1;
double_outputChannel = 1;

%% SLIDES - ISO 3382, Messung von Übertragunsstrecken, LTI-Systeme, Quantisierung, Abstastung, ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load demo sound for further demos
sound = ita_demosound; % Built-in toolbox demo sound

%% Signals Time and Frequency

% Generate 200Hz sine
sine = ita_generate('sine',1,200,44100,16, 'fullperiod');

% Take a look
sine.pt
xlim([0 0.11]);
xlim([1.44 1.55]);

% Fourier Transformation
% Absolute value and phase
sine.pfp; clc;

% Commonly displayed without phase
sine.pf

% Fourier Transformation expects periodic signals
% Crop sine so it's not a full period anymore
sine_crop = ita_time_crop(sine, [1 sine.nSamples-163]);
sine_crop.pt
xlim([1.44 1.55]);

% Take a look
sine_crop.pf

% What is the influence of the phase?
% Take a look a music signal
sound_amp = ita_amplify_to(sound, double_outputamp);
sound_amp.play;
sound.pt
sound.pfp

% Erase Phase -> Music becomes impulse
test = sound;
test.freqData = abs(sound.freqData) .* exp(1i*0);
test.pfp
test.pt
xlim([-0.2 0.5]);

%% Quantization

% Play with 16bit
sound_amp = ita_amplify_to(sound, double_outputamp);
sound_amp.play;

% Re-quantize the signal and listen to the effect
% 8bit -> 256
quant_8bit = ita_quantize(sound,'bits',8);
quant_8bit_amp = ita_amplify_to(quant_8bit, double_outputamp);
quant_8bit_amp.play;

% 4bit -> 16 values
quant_4bit = ita_quantize(sound,'bits',4);
quant_4bit_amp = ita_amplify_to(quant_4bit, double_outputamp);
quant_4bit_amp.play;
quant_4bit.pt

% 2bit -> 4 values
quant_2bit = ita_quantize(sound,'bits',2);
quant_2bit_amp = ita_amplify_to(quant_2bit, double_outputamp);
quant_2bit_amp.play;
quant_2bit.pt

%% Downsampling

% Play with std. samplingrate
sound.samplingRate

% Downsampling without lowpass
% Take every 20th sample -> 20 times lower sampling rate
sound1 = sound;
sound1.timeData = sound1.timeData(1:20:end);
sound1.samplingRate = sound1.samplingRate / 20;

comp = merge(sound,sound1);
comp.pf
xlim([20 900]);

% Downsampling with lowpass
sound2 = sound;

sound2 = ita_filter_bandpass(sound2,'upper',sound2.samplingRate/2/20);

sound2.timeData = sound2.timeData(1:20:end);
sound2.samplingRate = sound2.samplingRate / 20;

comp = merge(sound,sound1, sound2);
comp.pf
xlim([20 900]);

%% Upsampling

% Generate perfect impulse at 192kHz
sound3 = ita_generate('emptydat',192000,16);
sound3.channelNames = {'Test Signal'};
sound3.timeData = zeros(2^16,1);
sound3.timeData(192000*0.15+2,1) = 1;
sound3.pt; xlim([0.1498 0.1502]); ylim([-0.5 1]);
% As seen before, only band-limited signals can be represented in digital
% systems. At 192kHz upper frequency is 96kHz. To make sure we take 44kHz.
sound3_44 = ita_filter_bandpass(sound3,'upper',44000, 'order', 40);
sound3_44.pt; xlim([0.1498 0.1502]); ylim([-0.5 1]);
 
% We would like to downsample it to 48kHz though. Therefore the upper 
% frequency is 24kHz. To make sure we limit to 18kHz.
sound3_18 = ita_filter_bandpass(sound3,'upper',18000, 'order', 40);
sound3_18.pf
sound3_18.pt; xlim([0.1498 0.1502]); ylim([-0.5 1]);

% Downsampled to 48kHz, the peak is not at the same time.
sound3_18_down = ita_resample(sound3_18, 48000);
sound3_18_down.pt; xlim([0.1498 0.1502]); ylim([-0.5 1]);

% However, upsampling the bandlimited signal reconstructs the original
sound3_18_down_up = ita_resample(sound3_18_down, 192000);
sound3_18_down_up.pt; xlim([0.1498 0.1502]); ylim([-0.5 1]);

% Contrary to the signal containing frequencies up to 44Khz.
sound3_44_down = ita_resample(sound3_44, 48000);
sound3_44_down_up = ita_resample(sound3_44_down, 192000);
sound3_44_down_up.pt; xlim([0.1498 0.1502]); ylim([-0.5 1]);


%% SLIDES - Anregungssignale, Mess-Signale, Moderne Methoden, Enfaltung, MLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MLS

% Generate MLS
MLS = ita_generate_mls('fftDegree', 20);

% Take a look
MLS.pt; xlim([1 1.01]);

% Check auto-correlation
auto_correlation = ita_xcorr_dat(MLS,MLS);
auto_correlation.pt, xlim([0 0.0005]);

% Do a measurement with it
MS = itaMSmls;
MS.inputChannels = double_inputChannel;
MS.outputChannels = double_outputChannel;
MS.fftDegree = 20;
MS.stopMargin = 1;
MS.latencysamples = double_latencysamples;
MS.outputamplification = 20;

result = MS.run;
result.ptd

%% SLIDES - Spektrale Division 2-Kanal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate random signal, aka noise
measurement_noise = ita_generate('noise',1,44100,18);
measurement_noise = ita_mpb_filter(measurement_noise, [200 4000]);
measurement_noise.pf

% Generate transfer function without phase
tf = ita_generate('flat',1,44100,18);
tf = ita_mpb_filter(tf, [20 10000]);
tf.pt; xlim([0 0.04]);
tf.pf

% Convolution without additive noise
result = measurement_noise * tf;
result.signalType = 'energy';
result.pt
result.pf

% Deconvolution
tf_recovered_clean = result / measurement_noise;
tf_recovered_clean.pt; xlim([0 0.04]);
tf_recovered_clean.pf
tf_compare = merge(tf, tf_recovered_clean);
tf_compare.pf

% What happens in noisy system?
additive_noise = ita_generate('noise',0.1,44100,18);

% Convolution with additive noise
result = measurement_noise * tf;
% Add noise in time domain
result = result + additive_noise;
result.signalType = 'energy';
result.pt
result.pf

% Deconvolution
tf_recovered_noise = result / measurement_noise;
tf_recovered_noise.pt; xlim([0 0.04]);
tf_recovered_noise.pf
% What's the effect in the time domain?
comp = merge(tf_recovered_clean, tf_recovered_noise);
comp.pf
comp.pt

% Regularization

tf_recovered_reg = result * ita_invert_spk_regularization(measurement_noise, [200 4000]);
tf_recovered_reg.pt; xlim([0 0.04]);
tf_recovered_reg.pf

comp = merge(tf_recovered_clean, tf_recovered_noise, tf_recovered_reg);
comp.pf;

% Real example measurement
MS = itaMSTF;
MS.inputChannels = double_inputChannel;
MS.outputChannels = double_outputChannel;

MS.fftDegree = 20;
MS.stopMargin = 1;
MS.latencysamples = double_latencysamples;

% Example measurement with noise
MS.type = 'noise';

MS.outputamplification = 3;
result = MS.run;
result.ptd
result.pf

% Example measurement with music
MS.excitation = ita_demosound;

MS.outputamplification = 3;
result = MS.run;
result.ptd
result.pf

%% SLIDES - Spektrale Division - Sweep
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Real example measurement
MS = itaMSTF;
MS.inputChannels = double_inputChannel;
MS.outputChannels = double_outputChannel;

MS.fftDegree = 18;
MS.stopMargin = 1;
MS.latencysamples = double_latencysamples;

% Take a look at the sweep
MS.excitation.pt
xlim([0 5]);
MS.excitation.pf
MS.excitation.plot_spectrogram

% Let's do this
MS.outputamplification = 10;
impulse_response_1 = MS.run;
impulse_response_1.ptd;

% How do I get a better SNR?
% Averaging
MS.averages = 2;
impulse_response_2 = MS.run;
impulse_response_2.ptd;

% MS.averages = 4;
% impulse_response_4 = MS.run;
% impulse_response_4.ptd;

% comp = merge(impulse_response_1, impulse_response_2, impulse_response_4);
comp = merge(impulse_response_1, impulse_response_2);
comp.pf;

% Longer measurement Signal
MS.fftDegree = 19;
impulse_response_19 = MS.run;
impulse_response_19.ptd;

MS.fftDegree = 20;
impulse_response_20 = MS.run;
impulse_response_20.ptd;

comp = merge(impulse_response_19, impulse_response_20);
comp.pf;

% Non-linearities
MS = itaMSTFdummy;
MS.inputChannels = double_inputChannel;
MS.outputChannels = double_outputChannel;

MS.fftDegree = 20;
MS.stopMargin = 1;
MS.freqRange = [20 20000];
MS.averages = 1;
MS.outputamplification = 0;
MS.systemresponse = ita_time_shift(ita_mpb_filter(ita_generate('impulse',1,MS.samplingRate,16), [20 20000]), 0.5, 'time');

MS.nonlinearCoefficients = [1 1 1 1];
MS.noiselevel            = -100;

result = MS.run_raw;
result.plot_spectrogram;

impulse_response = MS.run;
impulse_response.ptd

% Window non-linearities?
impulse_response_win = ita_time_window(impulse_response, [0.1 0 1 1.1], 'time');
comp = merge(impulse_response, impulse_response_win);
comp.ptd
comp.pf

% Is that the correct result? Nope! Level off-set
MS.nonlinearCoefficients = 1;
impulse_response_clean = MS.run;
impulse_response_clean_win = ita_time_window(impulse_response_clean, [0.1 0 1 1.1], 'time');
comp = merge(impulse_response_clean_win, impulse_response_win);
comp.pf
comp.ptd
% Where does this come from? It's an effect of the uneven harmonics!
MS.nonlinearCoefficients = [1 1 0 1];
impulse_response_even = MS.run;
impulse_response_even_win = ita_time_window(impulse_response_even, [0.1 0 1 1.1], 'time');
comp = merge(impulse_response_clean_win, impulse_response_win, impulse_response_even_win);
comp.pf
comp.ptd

% How are they created? Everything that is hard limiting! E.g. digital
% clipping
sine = ita_generate('sine',1,200,44100,20);
sine.timeData(sine.timeData > 0.7) = 0.7;
sine.timeData(sine.timeData < -0.7) = -0.7;
sine.pt; xlim([2.0 2.3]); ylim([0.65 0.73]);
sine.pf

%% SLIDES - Impulsantwort und Nachhallzeit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Measured earlier with a long sweep
impulse_response_20.ptd

% Possible to get Energy Decay Curve (EDC, Schröder Plot)?

ra = ita_roomacoustics(impulse_response_20, 'EDC', 'T20', 'broadbandAnalysis');
ra.EDC.ptd

ra.T20.freqData