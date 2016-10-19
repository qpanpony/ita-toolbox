%
%  OpenDAFF
%
%  File:    exampleReadMagnitudeSpectrum.m
%  Purpose: Example for reading magnitude spectrum content
%  Author:  Frank Wefers (Frank.Wefers@akustik.rwth-aachen.de)
%
%  $Id: exampleReadMagnitudeSpectrum.m,v 1.1 2010/02/08 14:02:19 fwefers Exp $
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


close all;
clear all;

% Try to open your file (result is a handle)
% (any failure will result in a Matlab error and halt the execution)

h = DAFF('open', 'ms.daff');

% Now you can get your hands on the properties (returned as a struct)
% Note: All important information on the file is contained in the properties

props = DAFF('getProperties', h)

% If you like, you can get the metadata as well, like this...
% The result is returned also as a struct

metadata = DAFF('getMetadata', h)

% In order to interpret the data, we need to know
% about the frequencies at which values are defined...
% These are also defined within the properties

disp(['Frequencies: ' props.freqs]);

% Now we fetch the frontal impulse response record,
% in object coordinates (P0°,T0°)

mags1 = DAFF('getNearestNeighbourRecord', h, 'object', 0, 0);

% Lets plot the magnitude spectrum (decibel)

[nchannels, filterlength] = size(mags1);
figure;
grid on;
hold on;
ylim([-80,+10]);
for i=1:nchannels
    semilogx(props.freqs, 10*log10(mags1(i,:)), 'b');
end

% Now lets compare the data to another direction

mags2 = DAFF('getNearestNeighbourRecord', h, 'object', 90, 30);
for i=1:nchannels
    semilogx(props.freqs, 10*log10(mags2(i,:)), 'r');
end

% Close your opened DAFF file when you finished reading

DAFF('close', h);

% Free the OpenDAFF Matlab extension
% Note: This will close all still opened files automatically

clear DAFF;
