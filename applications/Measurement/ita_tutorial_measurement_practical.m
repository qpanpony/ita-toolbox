%% Tutorial about how to perform a practical measurement
% This function should explain the basic steps to perform measurments with
% the ITA-Toolbox.
%
% To do:
% +   namen der Funktion ändern: diese ist wirklich an Anwenden der Messklasse und ita_tutorial_measurement ist mehr zum verstehen der Theorie
% +   diese playrec versionen erklären, also wenn man immer nur 2 channel hat oder keine soundkarte. aber besser irgendwo unten in der Datei weil es ja nicht jeden interessiert
% +   useMeasurment chain
% +   calibrate

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



%% hardware requirements: sound card and AISO driver

% - You need a sound card with ASIO drivers. (???)
% - Alternative: ASIO For all (http://www.asio4all.com/)


%% select your sound card

% call ita_preferences, navigate to 'IO Settings' and select your sound
% card as recording and playing device

ita_preferences

%% measurement of transfer function: quick way

% The class itaMSTF allows the measurement of tranfer functions
MS = itaMSTF

% the measurement setup can be modified via the GUI:
MS.edit

% run measurment
impulseResponse = MS.run

%% define all measurment options in the code

trackLength   = 4;            % length of excitation signal in seconds
type          = 'exp';        % type of excitation signal: exponential sweep
freqRange     = [20,12000];   % frequency range of sweep
stopMargin    = 0.1;          % the last part of the excitation is silent to allow all frequencies to decay
averages      = 1;            % number of averages
commentStr    = 'Example measurement 2014-11-27';

inputChannels      = 1:3;
outputChannels     = 1;

outputamplification = -35;    % Digital output amplification in dBFS. 0 dBFS is maximum. This amplification is automatically compensated in the measurement.

useMeasurementChain = false;  % measurement chain is needed for calibration
pauseTime           = 0;      % time in seconds pause before measurement


% create measurement object with defined parameters
MS = itaMSTF('freqRange', freqRange, 'trackLength', trackLength, 'stopMargin', stopMargin, ...
    'inputChannels', inputChannels, 'outputChannels', outputChannels, 'averages', averages, ...
    'pause' , pauseTime, 'comment', commentStr, 'type', type, 'outputamplification', outputamplification, ...
    'useMeasurementChain', useMeasurementChain);

%% estimate signal to noise ratio

% this method records background noise and raw signal and calculates the
% signal to noise ratio in frequency bands
snr = MS.run_snr;
snr.plot_freq


[snr, signalRec, noiseRec] = MS.run_snr;
ita_plot_freq(mere(signalRec, noiseRec))

%% measurment with calibrated measurement chain

% - define chain with GUI
% - define chain in script
% - 'none' => ignored when calibration, 'unknown' => ???, 
% - default sensitivity values are only true if all part of the chain are
%   calibrated correctly
% - explain calibration GUI
%   - pistonphone => mic, (or data sheet for dummy head or Fig-of-eight mic)
%   - voltage calibration => AD & PreAmp, 
%   - input channel feedback => DA & Amp
% 
% - 

%% further measurement classes 

itaMSTFdummy           % transfer measurement class that simulates measurement (including transfer function, quantization, background noise and nonlinearities)

itaMSTFbandpass        % transfer function measurement with automatic split of frequency bands to different channels (freqRange has to be matrix)
itaMSTFmimo            % supports compensation for more than one output channel
itaMSTFinterleaved     % interleaved sweeps to measure multiple output channles in short time

itaMSPlaybackRecord    % play back a signal and record input. no deconvolution
itaMSRecord            % just record, no ouput  

itaMSmls               % measure with maximum length sequences (MLS) (incl. Hadamard transformation)

itaMSImpedance         % measure impedances (ITA Robo or comparable needed)

