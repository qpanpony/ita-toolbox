%% Getting startet with the ITA-Toolbox 
%
% <<../pics/ita_toolbox_logo_wbg.jpg>>
%
% In the next few lines we (the Developers of the ITA-Toolbox from the Institute of Technical Acoustics at RWTH Aachen) will try to explain how to work with the basic
% objects (instances of a class) for audio data called itaAudio, arbitrary
% time or frequency data objects (where the transform between time and frequency is
% not possible) called itaResult and single values, consisting of a value
% and a physical unit called itaValue. Some basic signal processing tasks
% are also dealt with.
%
% 
%
% *HAVE FUN! and please report bugs* 
%
% _2012 - Pascal Dietrich_
% toolbox-dev@akustik.rwth-aachen.de
%
% <<../pics/ita_toolbox_logo_wbg.jpg>>
% 

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% You can ignore the following line, if you look at the pdf or html document.
error('Do not run this tutorial. Either use cell mode in the source, or look at the pdf or html documents.')

%% Start from scratch
% We like to start with a totally empty workspace in order to avoid
% any strange behavior. 
%
%  
% [Note: please ignore the following '<...>' code,if you are reading the m-File (it's useful for HTML
% documentation)]
%
% <matlab:ccx clear everything thoroughly, close everything>
%
%
% <matlab:ita_toolbox_setup Run ITA-Toolbox Setup?>
%
%
% <matlab:ita_preferences Set preferences for the ITA-Toolbox>


%% Introduction to class |itaValue|
% Let's assume we want to multiply a mass of 5.2 kg with an accelaration of
% 9.81m/s^2 to obtain the gravitational force. Then we like to obtain the
% pressure on a surface of 2 m^2. Have a look at the class documentation to
% see overloaded operators and functions and properties.
%
% <matlab:doc('itaValue') doc itaValue>
%

m = itaValue(5.2,'kg'); %#ok<UNRCH>
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
% This class is used for all kinds of audio signal processing, reaching
% from importing signals like music, towards measurements of e.g. speech or
% even impulse responses of LTI systems.
%
% Let's assume we want to manually generate a sine of frequency 2000 Hz,
% with a length of 2 seconds and a sampling rate of 44100 Hz with amplitude
% 1 Pa. (The same could be done for frequency data as well.)
%
% <matlab:doc('itaAudio') doc itaAudio>
%

sine = itaAudio; %empty audio object

sine.samplingRate = 44100; %set sampling rate
sine.comment = 'My first Sine object with 2000 Hz'; %set comment for entire audio object
sine.channelNames{1} = 'this is the first channel with the sine'; %comment for the first channel
sine.trackLength = 2; %2 seconds length;

% now we directly have a timeVector containing the sampled time from 0 until 2 seconds
t = sine.timeVector;

% let's set the time data, you could use your own MATLAB data here !
sine.time = sin(2*pi*2000 * t);
sine = sine * itaValue(1,'Pa'); %include a suitable physical unit

% let's get the frequency data of this object as double vector
spk = sine.freq;

% let's get the physical unit of the first channel as a string
unitStr = sine.channelUnits{1}

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

% have a look at the workspace and the various types of the variables we created - Congratulations so far! :-)
whos

%% Plotting and ITA-Toolbox GUI 
% We have finished our nice sine signal and can start to plot it right away. There are different
% plots or different domains you might want to look at. We go trough all
% plots and you should pay attention to the signal content you see there.
% The different plots allow the user to concentrate on different aspects of
% the signal.
%
% You can use the *ITA-Toolbox GUI* to switch domain, etc. The GUI always works in
% the main workspace 'base'. This enables you to switch between GUI and
% command line at all points. Under the menu point _workspace_ you can
% change the current audio variable you want to look at.
%
% <matlab:ita_toolbox_gui() Start ITA-Toolbox GUI>
%
% Go to the menu "domain" and see what's possible there !!!

% get the second channel and plot only this
sine_comp.ch(2).plot_freq

% multiply in frequency domain with *
res = sine * sine2;
res.comment = 'convolution of two sines';
res.plot_freq

% multiply in time domain with .*
res = sine .* sine2;
res.comment = 'multiplication of two sines in time domain';
res.plot_freq

%change channel settings of the 2 channel sine
sine_comp = ita_channel_settings(sine_comp);

% close all figures
close all

%% TASK 1 -- Noise signal
% Generate a signal with the sampling rate of 44100 Hz and the length of 2
% seconds with a random noise by using MATLAB's randn(). Have a look at the
% time signal and the spectrum.
s = itaAudio;



% let's set the time data, you could use your own MATLAB data here !
s.samplingRate = 44100;
s.comment = 'Random'; 
s.channelNames{1} = 'channel 1';
s.trackLength = 2;
s.time = randn(size(s.timeVector));
s.plot_time;
s.plot_freq;
% HERE COMES YOUR CODE
% s.trackLength = ...
% s.time = ...

%% Audio Signal Processing with Music Signal
% Open a music file. This could also be a measurement or recording.
s = ita_demosound;

% get a nice mono signal
s = mean(s); %overloaded operator for itaAudio

% have a look at the time domain/frequency domain and the spectrogram with
% the GUI
s.plot_time;

% play back the signal
s.play;

%%% Filtering
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

%% TASK -- Manipulation of Impulse Responses
% Impulse responses of LTI system have in general some characterics that
% can be very useful to post-process measurements. We know for example that the
% information of the LTI system has to be causal (everything in the real world 
% answers after the question has been asked) and the systems have a
% characteristic decay time. For example, the decay time (reverberation
% time) is for small conference rooms about 0.5-0.7 seconds, in lecturing
% halls about 0.7-1 seconds and in a church around 5-15 seconds.
% Loudspeakers on the other hand decay very quickly with a constant less
% than 20 ms. A time window in the impulse response can be used to separate
% the desired signal from background noise and other artefacts of the
% measurement. These artefacts could be the response of a room in the
% measurement, although we wanted to measure the loudspeaker under free
% field conditions. But who has a free-field available at home?
%
% Use the cursors to zoom into the first part on the impulse response. Set
% the cursors to a range and choose _Edit->Window_ to apply a fade out
% between the two cursors. Look at the resulting spectrum.

h = ita_read('loudspeaker_response_raw.ita');
h.plot_time_dB;
