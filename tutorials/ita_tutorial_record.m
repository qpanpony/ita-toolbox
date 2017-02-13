% Recording with the ITA Toolbox
%
% In this tutorial you will learn how to set-up a simple the ITA Toolbox
% for a simple recording task. The first step is to create an instance
% of the itaMSRecord class, the basic recording class of the ITA toolbox.
%
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in
% the ITA-Toolbox folder.
% </ITA-Toolbox>

%% Set Hardware
% Set your recording hardware in 'IO Settings'-tab ('recording' and
% 'playback device'). For a calibrated measurement it is also recommended
% to check 'Measurement Chain' on the % same 'IO Settings' tab.


ita_preferences;

%% Clear Workspace
% The 'ccx' command basically resets Matlab to its start-up state.
ccx;

%% Measurement Setup
% Create instance of recording class
MS = itaMSRecord;

% Define recording parameters
% In this example we'll use the input channel 1 of the selected hardware
% device. In case you activated the 'Measurement Chain' in the
% ita_preferences, you will be asked about the elements in you input and
% output chain, once you define the input and output.
%
% We'll also define an FFT-degree of 19, meaning that our recording time
% will be 2^19 Samples.
%
% We'll set a sampling rate of 44100 Hz. Combined with the FFT-degree of
% 19, this will amount to 11.9 s of recording time. With the itaMSRecord
% class, it is only possible to define fixed recording times. If you
% need an unknown or infinite recording time, you're probably better off
% with normal DAWs, e.g. Reaper http://www.reaper.fm .
MS.inputChannels = 1;
MS.fftDegree = 19;
MS.samplingRate = 44100;

%% Calibration
% To measure absolute SPL, it is mandatory to calibrate the input.
% This is possible if you enabled the 'Measurement Chain' in the
% ita_preferences. If you do not wish to calibrate a certain element
% (not recommended, why would you have specified it before?) you can
% just accept the default value ('1') by clicking accept. To calibrate
% the element, connect you calibrator (pistonphone, voltage source, etc),
% specify the properties of the calibrator in the GUI and click
% 'calibrate'. If the calibration does not report an error (like 'No
% calibration signal detected'), a new calibration value will be shown in
% the GUI. You can either repeat the calibration to see if that value
% changes, or accept the value if it seems reasonable by clicking
% 'Accept'. The calibration GUI will then open for the next element to
% be calibrated. After the last element the GUI will just close.
MS.calibrate;

% Have a look at the calibrated elements.
MS.inputMeasurementChain


%% Recording
% Now the the actual recording can be started (class method 'run'). Make
% sure you use a unique and meaningful target variable name. In this
% case we'll use the generic name 'result'. This target variable will be
% an itaAudio object and can be used with all signal processing tools of
% the ITA Toolbox.
result = MS.run;

% Have a look at the result in the time domain (.plot_time or pt)
result.pt

% Have a look at the result in the time domain with a dB scale
% (.plot_time_dB or ptd)
result.ptd

% Have a look at the result in the frequency domain (.plot_freq or pf)
result.pf

% You can also check your calibration by running a measurement with the
% pistonphone connected. Just repeat the MS.run command (if you don't
% specify a target variable, the measurement result will be in the
% standard variable 'ans') and have a look at the frequency domain
% (.pf). You should see an amplitude of 94dB (depending on your
% pistonphone) at 1000 Hz (also a property of your phone).
%
% Congrats! Now you are able to do a calibrated measurement.
% Happy data acquisition!	