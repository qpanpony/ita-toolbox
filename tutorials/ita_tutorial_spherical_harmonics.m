%% Sound field synthesis and analysis in spherical harmonics
%
% <<../../pics/ita_toolbox_logo_wbg.png>>
%
% This tutorial demonstrates some of the spherical harmonic signal
% processing techniques implemented in the ITA-Toolbox
% 
% For information about the presented methods, refer to
%   Williams - Fourier Acoustics,
%   Rafaely - Fundamentals of Spherical Array Processing 

% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  Jun-2017

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% First off, clear the workspace
ccx
cd(fullfile(ita_toolbox_path, 'tutorials'))
addpath('helpers')

%% Let's start by creating a spherical sampling of order N_max
NmaxSampling = 20;
sampling = ita_sph_sampling_gaussian(NmaxSampling);

% take a look at the sampling
sampling.scatter;

% we can calculate the complex valued spherical harmonic basis functions 
% for the sampling with
Y = ita_sph_base(sampling,NmaxSampling);
Y_real = ita_sph_base(sampling, NmaxSampling, 'real');

% plot the basis functions
plot_basis_functions(sampling, 2, Y)
plot_basis_functions(sampling, 2, Y_real)
%% Indexing
% The linear index nm for spherical harmonic coefficients is defined as
% nm = n.^2 + n + m + 1
% Functions exist to convert from one indexing to the other and vice versa
n = 2;
m = 1;
nm = ita_sph_degreeorder2linear(n, m)
[n, m] = ita_sph_linear2degreeorder(nm)



%% Plane wave incident
Nmax = 7;
real = true;
k = linspace(0.5, 5, 128);

DOA = itaCoordinates([1,0,0]);
y_vec = ita_sph_base(DOA, Nmax, 'real', real)';

% calculate the modal strength on a rigid sphere for a plane wave incidence
% from the DOA
B = ita_sph_modal_strength(sampling, Nmax, k, 'rigid');

% calculate the resulting spherical harmonic coefficients
pnm = zeros((Nmax + 1)^2, numel(k));
for idx = 1:numel(k)
    pnm(:,idx) = B(:,:,idx) * y_vec;
end
%% Let's look at the pressure on the sphere
% The wave number index for plotting can be chosen by changing idxPlot
idxPlot = 50;
figure
sampling.surf(pnm(:,idxPlot))
title(['kr = ', num2str(k(idxPlot) * uniquetol(sampling.r))]);

%% Beamforming

% define the look directions of the beamformer
lookDirections = ita_sph_sampling_equiangular(30);

% calculate the sh basis functions for all look directions
Y_lookDirs = ita_sph_base(lookDirections, Nmax, 'real', real)';

% calculate the radial filter to compensate for the modal strength of the
% sphere
radialFilter = zeros((Nmax+1)^2, (Nmax+1)^2, numel(k));
for idx = 1:numel(k)
    radialFilter(:,:,idx) = pinv(B(:,:,idx));
end

% perform the beamforming
beamformerOutput = zeros(lookDirections.nPoints, numel(k));
for idx = 1:numel(k)
    beamformerOutput(:,idx) = 4*pi / (Nmax + 1)^2 * Y_lookDirs' * radialFilter(:,:,idx) * pnm(:,idx);
end

% plot a map projection for all look directions used in the beamforming
figure
lookDirections.plot_map_projection(beamformerOutput(:,1))
%% Sound pressure from a vibrating spherical cap at the north pole
% coordinates of the north pole
northPole = itaCoordinates([0,0,1]);

NmaxCap = 20;
% SH basis functions for the north pole
Y_cap = ita_sph_base(northPole, NmaxCap);


% apterture angle of 30 degree for the spherical cap
alpha = 30 * pi / 180;
rCap = sin(alpha);
G = ita_sph_aperture_function_sla(northPole, NmaxCap, rCap, 'diag');

% radial distance from the sphere
distance = 3;
% radiation impedance and propagation term from the sphere to a point in
% free space with a distance of 3 meters from the origin
H = ita_sph_modal_strength(northPole, NmaxCap, k, 'rigid', 'transducer', 'ls', 'dist', distance);

% radial velocity of the cap
u = 0.01;

% grid around the sphere for plotting purposes
grid = ita_sph_sampling_equiangular(20);
grid_Y = ita_sph_base(grid, NmaxCap);

% resulting sound pressure on the specified grid in 3 meter distance
p = zeros(grid.nPoints, numel(k));
for idx = 1:numel(k)
    p(:,idx) = conj(grid_Y) * H(:,:,idx) * G * Y_cap' * u;
end

% plot the resulting sound pressure at a spherical surface in the specified
% distance
idxPlot = 50;
surf(grid, p(:,idxPlot));
title(['k = ', num2str(k(idxPlot) * uniquetol(northPole.r))]);
