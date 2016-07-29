%% Tutorial about itaCoordinates - visualize spatial audio data (Demo)
%
% <<../../pics/ita_toolbox_logo_wbg.jpg>>
% 
% This tutorial demonstrates how to use the itaCoodinates class and how to
% plot spatial/spherical audio data with the functions provided.
% 
% *HAVE FUN! and please report bugs* 
%
% _2011 - Martin Pollow_
% toolbox-dev@akustik.rwth-aachen.de
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
% <matlab:ccx clear everything thoroughly, close everything>
%
%
% <matlab:ita_toolbox_setup Run ITA-Toolbox Setup?>
%
%
% <matlab:ita_preferences Set preferences for the ITA-Toolbox>
%

%% Usage of itaCoordinates
% There are a few functions that get you started with the coordinate class.
% After initialization, you have instant access to the coordinates in
% (3D)-cartesian, spherical and cylindrical coordinates. All coordinate
% transforms are handled in the background, so you do not need to care
% about them anymore. As angles the radians is used in common mathematical
% coordinate systems.

% initialite a list of N data points
N = 20; %#ok<UNRCH>
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

% a certain domain can be forced with the commmands
coord.makeCart
coord.makeSph
coord.makeCyl
% but that is not really needed, just access the desired dimensions.

%% Spherical distribution of points
% Let's make a common set of spherically distributed points, we pick a 
% 5°/5° (theta/phi) resolution and visualize the result.
coord = ita_generateSampling_equiangular(5,5);
% we can visualize the points in the 3D space
scatter(coord);
% here as later: use your mouse to rotate, pan or zoom the plots

%% Line plot of some parts of the points
% Plot the first 1000 points in the given order. This is useful for
% turn-table measurements, for example:
plot(coord.n(1:1000));

%% Balloon plot to visualize geometries
% We can also plot a balloon stlye plot.
surf(coord);

%% Define basic directivities and plot them
% Some simple directivities, the magnitude is expressed by the radius of
% the plot and the phase is decoded as color.
monopole = 1;
dipole = cos(coord.theta);
% and plot the dipole
surf(coord, dipole)

%% Plot logarithmic magnitude directivities
% Ususally a logarithmic plot is very good to be able to better judge a
% directivity according to human perception.

% first convert the directivity (from pressure to SPL)
dipole_dB = 20*log10(abs(dipole)); % in (dB re 1)
% in this example all calculated decibel levels are negative
% we have to define a given dynamic range that acts as maximum radius
% let's use a dynamic range of 20dB
dynRange = 20;
% get the highest level
max_dB = max(dipole_dB);
% pull maximum value to the chosen dynRange and truncate all
% dB values that are still negative
dipole_dB_plot = max(0,dipole_dB - max_dB + dynRange);
% how does it look?
surf(coord, dipole_dB_plot)

%% Plotting complex directivities (with noise)
% Also complex data can be plotted
data = randn(coord.nPoints,1) + 3i .* dipole;
surf(coord, data);

%% Plot on a unit sphere
% Sometimes it is nice to plot data as color information on any geometry.
% The unit sphere is the most probable choice, but any geometry can be
% chosen.

unitSphere = ones(coord.nPoints,1);
surf(coord, unitSphere, data);
% note that now the color resembles the magnitude of the data

% by the way, the short form does the same:
surf(coord, 1, data)


%% Plotting phase details of the directivity
% To plot the phase on a unit sphere, we need to do some manual work:

% convert the matlab angle (-pi..pi) to positive phase (0..2pi)
phase = angle(data) + pi;
% phase on unit sphere
surf(coord, 1, phase);
caxis([0 2*pi]);
colormap hsv
% here you have to adjust the color axis manually, as the surf plot
% does not know that we are dealing with phase data

%% Plotting data on partial spheres (e.g. half sphere)
% Data on partial sphere is also not very tricky, as the plot rountine
% automatically triangularizes the given mesh.

coord_half = coord.n(coord.theta < pi/2);
data_half = 1 + coord_half.theta .* exp(1i.* 2 .* coord_half.theta);
surf(coord_half, data_half)

%% Opening the areas where we have no data
% It gets even nicer, if we open the area where we have a lack of data. The
% plop factor gives the relative size of the triangles that we destroy
% together with the larger ones.

surf(coord_half,  1, data_half, 'plop', 4)
% The higher the plop factor, the more patches are preserved.

%% Sample plot with lightning and additional parameters
% itaCoordinates.plot hands over all additional parameters to MATLABs
% built-in function 'patch.m', see the property browser for a detailed
% list of available properties.
sampleDirectivity = monopole + dipole + cos(coord.theta).^2;
surf(coord, sampleDirectivity,'FaceAlpha',0.5,'EdgeColor','w');
camlight
% 'doc camlight' tells you more

%% Combine itaCoordinates with itaAudio data objects and make movies
% When dealing with itaAudio data objects, we can use them directly to plot
% a balloon of a specific frequency. Simple movies are very easy to make.
% For better quality, the absolute maximum should be determined and the
% same axes length be chosen.

return; %this is only for the publish() function
% take a lower spatial resolution of 22.5°/22.5° (theta/phi)
coordSmall = ita_generateSampling_equiangular(22.5,22.5);
% create an audio object
ao = itaAudio;
ao.time = ones(2^8,coordSmall.nPoints);
% and store a cardioid directivity with frequency dependent decay
cardioid = 1 + cos(coordSmall.theta);
ao.freq = bsxfun(@times, 1e4./ao.freqVector, cardioid.');
% apply whiteNoise to the data
ao.freq = ao.freq + rand(size(ao.freq));
% and plot the directivities of this audio object for some frequencies
for freqs = 1000:1000:16000
    surf(coordSmall, ao, freqs)
    pause(0.3);
end