%% Recording with the ITA Toolbox
%
% In this tutorial you will learn how to set-up a simple the ITA Toolbox
% for a simple recording task. The first step is to create an instance
% of the itaMSRecord class, the basic recording class of the ITA
% toolbox.
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in
% the ITA-Toolbox folder.
% </ITA-Toolbox>
%
% For feedback or questions, please contact the ITA Toolbox developers:
% toolbox-dev@akustik.rwth-aachen.de
%
% JCK 2017

%% Set Hardware
% Set your recording hardware in 'IO Settings'-tab ('recording' and
% 'playback device'). For a calibrated measurement it is also
% recommended to check 'Measurement Chain' on the % same 'IO Settings'
% tab.
ita_preferences;

%% Clear Workspace
% The 'ccx' command basically resets MATLAB to its start-up state.
ccx;

%% Measurement Setup
% Create an instance of the recording class.
MS = itaMSRecord;

% Define recording parameters
% In this example we'll use the input channel 1 of the selected hardware
% device. For multiple channels please specify a vector (see example 
% below). In case you activated the 'Measurement Chain' in the
% ita_preferences, you will be asked about the elements in you input 
% chain, once you define the input and output.
% The input measurement chain consists of 3 elements (sensor, preamp and
% A/D converter). For each element you do not want to calibrate please 
% choose 'none' from the respective drop-down menu. For elements you 
% want to calibrate it is recommended to choose 'unknown' (meaning that
% you do not know the sensitivity of this element). All other options 
% are default entries for specific pieces of equipment and can be 
% ignored. If you do not want to calibrate each element individually,
% just declare the 'sensor' as 'unknown' and all other elements as 
% 'none'. This way you can calibrate the entire chain at once with a 
% sensor calibration device (e.g. a pistonphone).
%
% We'll also define an FFT-degree of 19, meaning that our recording time
% will be 2^19 Samples.
%
% We'll set a sampling rate of 44100 Hz. To fulfill the Nyquist 
% criterion (f_sampling = f_measurement * 2) you need to sample your 
% signal with 2 times the highest frequency it contains. The highest 
% audible frequency for humans is about 20 kHz. With a margin of safety 
% we consider it to be 22050 Hz, resulting in a 44100 Hz sampling 
% frequency Combined with the FFT-degree of 19, this will amount to 
% 11.9 s of recording time. With the itaMSRecord class, it is only 
% possible to define fixed recording times. If you need an unknown or 
% infinite recording time, you're probably better off with normal DAWs, 
% e.g. Reaper http://www.reaper.fm .
MS.inputChannels = 1; % for multiple channels (e.g. 1, 2 & 3): [1 2 3] 
MS.fftDegree = 19;
MS.samplingRate = 44100;

% To have a look at all the settings you can just type the name of your
% measurement setup object (e.g. 'MS') in the MATLAB command line and
% have a look at the output.
MS

%% Calibration
% To measure absolute SPL, it is mandatory to calibrate the input.
% This is possible if you enabled the 'Measurement Chain' in the
% ita_preferences. If you do not wish to calibrate a certain element
% (not recommended, why would you have specified it before?) you can
% just accept the default value ('1') by clicking accept. To calibrate
% the element, connect you calibrator (pistonphone, voltage source,
% etc), specify the properties of the calibrator in the GUI and click
% 'calibrate'. If the calibration does not report an error (like 'No
% calibration signal detected'), a new calibration value will be shown
% in the GUI. You can either repeat the calibration to see if that value
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

% After the measurement you will see some command line output. The 
% interesting part for you right now is the 'Maximum digital level' 
% value. Its unit is 'dBFS' (dB full scale). 0 dBFS means that your
% recorded signal uses 100% of the available quantization range of your
% A/D converter. Signals with an amplitude above 0 dBFS will be clipped
% and you will get a warning in the command line saying 'Careful, 
% clipping or something else went wrong!'. The only solution to that 
% problem is to reduce the sensitivity of your input hardware (if 
% possible) or to move away further from the sound source. A signal in 
% the range from -20 dBFS to -5 dBFS usually provides good and safe 
% measurement results.


% Have a look at the result in the time domain (.plot_time or pt)
result.pt

% Have a look at the result in the time domain with a dB scale
% (.plot_time_dB or .ptd)
result.ptd

% Have a look at the result in the frequency domain (.plot_freq or pf)
result.pf

% You can also check your calibration by running a measurement with the
% pistonphone connected. Just repeat the MS.run command (if you don't
% specify a target variable, the measurement result will be in the
% standard variable 'ans') and have a look at the frequency domain
% (.pf). You should see an amplitude of 94dB (depending on your
% pistonphone) at 1000 Hz (also a property of your phone).

%% Save data
% To save your measurement data for later post processing you can use
% the 'ita_write' function. It's first input argument is the itaAudio
% object you want to save (e.g. 'result'), the second one is the 
% filename (optionally including the full file path). Without a path
% (as in the example below) the file will be saved in the 
% 'current folder' in MATLAB. If you specify a '.ita' extension, the 
% data will be saved as itaAudio. '.wav' will save the data as 
% normalized WAV file.
ita_write(result, 'result_file.ita');
% In case you would like to save all the workspace variables (including 
% you measurement setup ('MS') and the result ('result') you can also 
% use the native 'save' command. In this example we'll save everything 
% to a file called 'workspace.mat'.
save('workspace.mat');
% Congrats! Now you are able to do a calibrated measurement and save 
% your results. Happy data acquisition!