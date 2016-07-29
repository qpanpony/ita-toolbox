%% Intensivkurs Messtechnik - April 2013 - PDI, JCK                        
%Init

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;
ita_preferences('toolboxlogo',false);

%% ITA-TOOLBOX BASICS *****************************************************
%  ************************************************************************

%% Introduction to class |itaValue|
% Let's assume we want to multiply a mass of 5.2 kg with an accelaration of
% 9.81m/s^2 to obtain the gravitational force. Then we like to obtain the
% pressure on a surface of 2 m^2. Have a look at the class documentation to
% see overloaded operators and functions and properties.
%
% <matlab:doc('itaValue') doc itaValue>
%

m = itaValue(5.2,'kg'); 
g = itaValue(9.81,'m/s^2');

F = m*g

S = itaValue(2,'m^2');
p = F/S

%% Introduction to class |itaCoordinates|
% There are a few functions that get you started with the coordinate class.
% After initialization, you have instant access to the coordinates in
% (3D)-cartesian, spherical and cylindrical coordinates. All coordinate
% transforms are handled in the background, so you do not need to care
% about them anymore. As angles the radians is used in common mathematical
% coordinate systems.

% initialize a list of N data points
N = 20;
coord = itaCoordinates(N);

% the number of points can be obtained with
coord.nPoints

% now lets set the x- and y-axis to random values
coord.x = rand(N,1);
coord.y = rand(N,1);
% we set z to a constant value
coord.z = 1;

% now we can examine the data, as cartesian N x 3 matrix
coord.cart      % all data

% or as spherical coordinates, or as single components
coord.sph       % all data
coord.theta
coord.phi
coord.r

% the cylindrical coordinates are somehow related to both other ones,
% allowing to access
coord.cyl       % all data
coord.rho       % together with coord.phi and coord.z

%%% Spherical distribution of points
% Let's make a common set of spherically distributed points, we pick a 
% 5°/5° (theta/phi) resolution and visualize the result.
coord = ita_generateSampling_equiangular(5,5);
% we can visualize the points in the 3D space
scatter(coord);
% here as later: use your mouse to rotate, pan or zoom the plots

% Line plot of some parts of the points
% Plot the first 1000 points in the given order. This is useful for
% turn-table measurements, for example:
plot(coord.n(1:1000));

% Balloon plot to visualize geometries
% We can also plot a balloon stlye plot.
surf(coord);

% or plot a cardioid balloon
surf(coord, 1 + cos(coord.theta));

%% Introduction to class |itaAudio|
% Audio objects
sine = itaAudio; %empty audio object

sine.samplingRate = 44100; %set sampling rate
sine.comment = 'My first Sine object with 2000 Hz'; %set comment for entire audio object
sine.channelNames{1} = 'this is the first channel with the sine'; %comment for the first channel
sine.trackLength = 2; %2 seconds length;

sine.samplingRate = 44100;

% now we directly have a timeVector containing the sampled time from 0 until 2 seconds
t = sine.timeVector;
 
% let's set the time data
f = 1000;
sine.time = sin(2*pi*f * t);
sine = sine * itaValue(1,'Pa'); %include a suitable physical unit
 
% let's get the frequency data of this object as double vector
spk = sine.freq;
 
% let's get the physical unit of the first channel as a string
unitStr = sine.channelUnits{1};
 
% we will do a second sine with 5 Pa and the same frequency
sine2 = sine * 5; % amplify by simple multiplication
sine2.channelNames{1} = 'the copy of the first sine'; % give a new channel name
 
% put them together in one object
sine_comp = merge(sine, sine2);
 
% convert to time domain with .' (ifft) - this is done internally every time
% you plot if the data is in the wrong domain.
sine = sine.';
 
%convert to frequency domain with ' (fft)
sine = sine';

sine.plot_time;
sine.plot_freq;

sine.play;

noise = sine;
% Attention, wouldn't be a copy for a handle-class
nSamples = noise.nSamples;
noise.time = randn(nSamples,1);

%% >>>>>>>> RETURN BACK TO PRESENTATION SLIDES ############################
return %*******************************************************************
% *************************************************************************

%% DSP BASICS *************************************************************
close all, clc
%  ************************************************************************

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

%% Task - Find the correct number of samples
sine.nSamples = 890; % full period should fit into time slot
sine.plot_freq

%% Audio Signal Processing with Music Signal
% Open a music file. This could also be a measurement or recording.
s = ita_demosound;

s.plot_time

% play back the signal
s.play;

s.plot_freq

%% View the spectrogram
s.plot_spectrogram

%% Filtering - Apply band pass
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

%% Influence of the phase in frequency domain
% Take the music signal and delete the phase information. 
close all
g_nophase = ita_zerophase(s);
g_nophase.plot_freq_phase
g_nophase.play

%% Add a random phase but take the original magnitude of the spectrum
g_randphase = ita_randomize_phase( s );
g_randphase.plot_freq_phase;
g_randphase.play;

%% Introduction to Value Quantization -- ADVANCED!
% Value Quantization
close all
s_8bit = ita_quantize(s,'bits',8);
s_8bit.plot_time;
s_8bit.play;

s_4bit = ita_quantize(s,'bits',4);
s_4bit.plot_time;
s_4bit.play;

%% Introduction to Time Discretization -- band limitation -- ADVANCED!
close all
s_SR10k = ita_resample(s, s.samplingRate / 3);
s_SR10k.plot_freq
s_SR10k.play;

% Decimation in time domain without low pass, take all 3 samples in time
% domain only without -> aliasing will occur, undersampling
s_SR10k_aliasing = s;
s_SR10k_aliasing.time           = s_SR10k_aliasing.time(1:3:end);
s_SR10k_aliasing.samplingRate   = s_SR10k_aliasing.samplingRate / 3; 
s_SR10k_aliasing.play

% listen to aliasing artefacts only
artefacts = s_SR10k_aliasing - s_SR10k; 
artefacts.plot_time
artefacts.play

%% >>>>>>>> RETURN BACK TO PRESENTATION SLIDES ############################
return %*******************************************************************
% *************************************************************************

%% MEASUREMENT SIGNALS ****************************************************
close all, clc
%  ************************************************************************

%% Generate perfect impulse                                                
close all, clc, fftDegree = 16; sr = 44100;
impulse = ita_generate('impulse',1,sr,fftDegree);
impulse.plot_time('xlim',[-1 2])
for idx = 1:5
    impulse.play
end

%% Deconvolution with Music - This is a perfect impulse!                   
s = ita_demosound;
h = fft(s) / fft(s);
h.comment = 'music/music';
h.plot_all

%% Avoid Division by zero                                                  
% Have a look frequency and time domain!
H = ita_divide_spk(s, s, 'regularization',[100 10000]);
H.plot_all

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

%% >>>>>>>> RETURN BACK TO PRESENTATION SLIDES ############################
return %*******************************************************************
% *************************************************************************

%% EMULATION **************************************************************
close all, clc
%  ************************************************************************

%% Generate artifical room impulse response                                
% In this section a simulated room impulse response (RIR) will be
% generated basing on a noise signal.

% Generate RIR
fftDegree   = 17; % length of IR is 2^fftDegree samples
L           = [8 5 3]/10; % room geometry (x,y,z) in meters
fmax        = 10000; % highest eigenfreuency in Hertz
r_source    = [5 3 1.2]; % positions
T           = 1; %reverberation time of each eigenmode -> definition of modal damping
RIR         = ita_roomacoustics_analytic_FRF_book(itaCoordinates(L), itaCoordinates(r_source), itaCoordinates([0 0 0]),'f_max',fmax,'T',T,'fftDegree',fftDegree,'pressuremode',false);
RIR.channelNames{1} = 'ideal RIR';
win_vec     = [1.5 2]; % time window parameters in seconds
RIR_cut     = ita_time_window(RIR,win_vec,'time','crop');
RIR_cut     = ita_normalize_dat(RIR_cut); % to obtain a scale just below 0dB in the end only for demonstration purposes
RIR_cut.plot_all % take a look also in time domain!

%% Auralize                                                                
s = ita_demosound;
g = ita_convolve(s,RIR_cut); % apply the impulse response to music signal
g.play

%% Measurement Dummy Class for virtual/emulated measurement                
MS = itaMSTFdummy; % get measurement setup object

% specify measurement parameters
MS.fftDegree             = 19;  % Set length of sweep signal
MS.stopMargin            = 1;   % Time to wait until the system decays
MS.freqRange             = [20 20000]; % Frequency range for the measurement
MS.outputamplification   = -30; % level below maximum amplitude in dBFS (full scale)
MS.averages              = 1;   % number of measurements to be averaged to get a mean result
MS.samplingRate          = RIR_cut.samplingRate;  % sampling Rate of the system

% specify the device under test (DUT) to be measured
MS.nonlinearCoefficients = 1; % only linear transmission or e.g. [1 0.1 0.1] for g = 1*s^1 + 0.1*s^2 + 0.1*s^3
MS.noiselevel            = -30; % noise level below maximum amplitude in dBFS
MS.systemresponse        = RIR_cut; % impulse response of the system
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
RIRplot = RIR_cut;
RIRplot.nSamples = h_measured.nSamples;% zero padding to obtain the same length
res     = merge(h_measured, h_measured_av,RIRplot);

% Plot and compare!
res.plot_time_dB

%% >>>>>>>> RETURN BACK TO PRESENTATION SLIDES ############################
return %*******************************************************************
% *************************************************************************

%% NONLINEARITIES *********************************************************
close all, clc
%  ************************************************************************

%% Nonlinearities - Spectrogram of g(t)                                    
close all, clc
MS2 = itaMSTFdummy;
MS2.outputamplification   = 0; % play around with different values: -40, -20
MS2.nonlinearCoefficients = [1 0.1 0.1 0.1];
g   = MS2.run_raw; % get system output without deconvolution
g.plot_spectrogram

%% Impulse response of non-linear system                                   
h = MS2.run; % incl. deconvolution
h.plot_time_dB 

%% Nonlinearities, RIR, noise and quantization                             
MS.outputamplification   =  0;
MS.nonlinearCoefficients = [1 0.1 0.1 0.1]; % set nonlinear coefficients
MS.noiselevel            = -0; % very high noise level
MS.systemresponse        = RIR_cut;
MS.nBits                 = 16;
h                        = MS.run;
h.plot_time_dB

%% Averaging                                                               
% How many averages are required to get at least 60dB Peak SNR ?
MS.averages = 1; % put your number here!
RIR_meas = MS.run; 
RIR_meas.plot_time_dB;

%% >>>>>>>> RETURN BACK TO PRESENTATION SLIDES ############################
return %*******************************************************************
% *************************************************************************

%% ROOM ACOUSTICS *********************************************************
close all, clc
%  ************************************************************************

%% calculate reverberation time
% reverberation time (EDT, T10, T20, ...) and 
% energy parameter (C50, C80, D50, D80, Center_Time)
% ita roomacoustics() preforms search for start of impulse response, fractional octave band filtering and noise detection and compensation (all according to ISO 3382)
freqRange       = [250 10000];       % frequency range and
bandsPerOctave  = 3;                % bands per octave for filtering

% calculate just T20 with given frequency range in 1/1 octave bands
raResult = ita_roomacoustics(RIR_meas, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'T20');  % BTW: [ 'T20' ] is short for [ 'T20', true ]. works for all boolean options
raResult.T20.bar

%% Calculate more room acoustic parameter with one function call
% for examples EDT, T2, C80 and peak-signal to noise ratio
raResults = ita_roomacoustics(RIR, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'PSNR_Lundeby', 'EDT', 'T20', 'C80', 'PSNR_Lundeby' );

% output is a struct with itaResults:
hFig = ita_plottools_figure;
axh  = subplot(2,2,1);
raResults.EDT.plot_freq('axes_handle',axh, 'figure_handle',hFig)
axh  = subplot(2,2,2);
raResults.T20.plot_freq('axes_handle',axh, 'figure_handle',hFig)
axh  = subplot(2,2,3);
raResults.C80.plot_freq('axes_handle',axh, 'figure_handle',hFig)
axh  = subplot(2,2,4);
raResults.PSNR_Lundeby.plot_freq('axes_handle',axh, 'figure_handle',hFig)

%% ... with measured impulse response
RIRmeas = ita_read('RIR_intensivkurs.ita')
raResults = ita_roomacoustics(RIRmeas, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'PSNR_Lundeby', 'EDT', 'T20', 'C80', 'PSNR_Lundeby' );
hFig = ita_plottools_figure;
axh  = subplot(2,2,1);
raResults.EDT.plot_freq('axes_handle',axh, 'figure_handle',hFig)
axh  = subplot(2,2,2);
raResults.T20.plot_freq('axes_handle',axh, 'figure_handle',hFig)
axh  = subplot(2,2,3);
raResults.C80.plot_freq('axes_handle',axh, 'figure_handle',hFig)
axh  = subplot(2,2,4);
raResults.PSNR_Lundeby.plot_freq('axes_handle',axh, 'figure_handle',hFig)

%% Apply window and auralize
rir_cut    = ita_time_window(ita_time_shift(RIRmeas.ch([1,3,4])),[1.5 2],'time');
g_mono     = ita_normalize_dat(ita_convolve(s,rir_cut.ch(1)));
g_binaural = ita_normalize_dat(ita_convolve(s,rir_cut.ch([2, 3])));
ita_disp('Monaural')
g_mono.play
ita_disp('Binaural')
g_binaural.play

%% >>>>>>>> RETURN BACK TO PRESENTATION SLIDES ############################
return %*******************************************************************
% *************************************************************************
