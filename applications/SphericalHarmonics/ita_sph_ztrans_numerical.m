function b_e = ita_sph_ztrans_numerical(b_s,d_z,k,r_obs)
%ITA_SPH_ZTRANS_NUMERICAL - Multipole vector after coaxial translation in z 
% function b_e = ita_sph_ztrans_numerical(b_s,d_z,k)
% 
% Numerically computes the vector of coefficients b_e of a coaxially in z 
% translated multipole souce (original vecotr: b_s). 
%
% b_s:      Multipole coefficients vector
% d_z:      Translation [m]
% k:        Regarded wave number
% r_obs:    Observation radius
% 
% Johannes Klein (johannes.klein@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 15.11.2011

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Get max order from input vector
n_max = sqrt(max(size(b_s))) - 1;

%% Centered sampling grid
s = ita_sph_sampling_gaussian(n_max);
s.r = r_obs;
s.nmax = n_max; % Replacing faulty 'update' method of itaSphSampling

%% Shifted sampling grid
% The new grid is the previos one, translated only in z-direction. This
% implies, that the vector from the old points to the new points equals d_z
% in direction and value.
% The translation of the sampling grid obviously has to be done in the
% opposite direction to the one the source is to supposed to be shifted to.
% The computation for the vectors from 0 to the new points in e is done in itaSamplingSph. 
e = s;
e.z = e.z - d_z;
e.nmax = n_max; % Replacing faulty 'update' method of itaSphSampling

%% Setup Multipole Transformation
degreeIndex = ita_sph_linear2degreeorder(1:(n_max+1)^2);

% H: N_p x (N + 1)
% H_s is the matrix used to radiate the multipole source outwards to the
% sampling points of grid s. H_e does the same for the points of grid e.

H_s = s.Y .* ita_sph_besselh(degreeIndex, 2, k*s.r);
H_e = e.Y .* ita_sph_besselh(degreeIndex, 2, k*e.r);

%% Generate sampling points on sampling grids
p_e = H_e * b_s;

%% Duraiswami regularization (No advantage in simualtion) (alternatively do: Pinv)

% Regularization parameter
epsilon = 10^-8;

% W: N_p x N_p
W = repmat(s.weights, 1, size(s.weights,1)) .*  eye(size(s.weights,1));

% D: (N+1)^2 x (N+1)^2
D = repmat((1 + degreeIndex .* ( degreeIndex +1 )),size(degreeIndex,2),1) .* eye(size(degreeIndex,2));

% Multipole decomposition
b_e = (H_s' * W * H_s + epsilon * D)\ H_s' * W * p_e;
end