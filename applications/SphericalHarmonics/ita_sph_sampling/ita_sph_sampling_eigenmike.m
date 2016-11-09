function varargout = ita_sph_sampling_eigenmike(varargin)
%ITA_SPH_SAMPLING_EIGENMIKE - Generate Eigenmike em32 sampling
% Microphone positions based on the pentakis dodecahedron, exact positions 
% can be found under:
%   https://www.mhacoustics.com/sites/default/files/EigenStudio%20User%20Manual%20R02A.pdf
%
% Zero degrees in azimuth aligns with the “mh acoustics” logo on the 
% microphone shaft
%
%  Syntax:
%   sampling = ita_sph_sampling_eigenmike()
%
%  See also:
%   ita_sph_sampling
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_sampling_eigenmike">doc ita_sph_sampling_eigenmike</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author:   Marco Berzborn -- Email: mbe@akustik.rwth-aachen.de
% Created:  18-Oct-2016

positions = [
    0.0420   69.0000         0
    0.0420   90.0000   32.0000
    0.0420  111.0000         0
    0.0420   90.0000  328.0000
    0.0420   32.0000         0
    0.0420   55.0000   45.0000
    0.0420   90.0000   69.0000
    0.0420  125.0000   45.0000
    0.0420  148.0000         0
    0.0420  125.0000  315.0000
    0.0420   90.0000  291.0000
    0.0420   55.0000  315.0000
    0.0420   21.0000   91.0000
    0.0420   58.0000   90.0000
    0.0420  121.0000   90.0000
    0.0420  159.0000   89.0000
    0.0420   69.0000  180.0000
    0.0420   90.0000  212.0000
    0.0420  111.0000  180.0000
    0.0420   90.0000  148.0000
    0.0420   32.0000  180.0000
    0.0420   55.0000  225.0000
    0.0420   90.0000  249.0000
    0.0420  125.0000  225.0000
    0.0420  148.0000  180.0000
    0.0420  125.0000  135.0000
    0.0420   90.0000  111.0000
    0.0420   55.0000  135.0000
    0.0420   21.0000  269.0000
    0.0420   58.0000  270.0000
    0.0420  122.0000  270.0000
    0.0420  159.0000  271.0000
];

positions(:,2:3) = positions(:,2:3)/180*pi;

sampling = itaSamplingSph(positions,'sph');
sampling.nmax = 4;

varargout{1} = sampling;

end
