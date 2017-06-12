function state = calculateHandT_slideSource(params, state)
% calculateHandT_slideSource.m
% Author: Noam Shabtai
% ITA-RWTH, 22.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = calculateHandT_slideSource(params, state)
% Calculate matrix [h1 ... hQ].' where
%   hq=[h_0(kr_q)Y_0^0...h_N(kr_q)Y_N^N].' 
% This is a matrix of hankel functions multiplied by spherical harmonics.
% Qx(N+1)^2
% Calculate H for only one point in state.slide.loc.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   state.center.H - Matrix H with constant r relative to the array center.
%                   disPoints x (Nc+1)^2 x freqs.
%
% Output Parameters;
%   state.slide.H - Matrix H with varying r, taking into account source translation.
%                   disPoints x (Narray+1)^2 x freqs.
%
%   state.slide.T - Tranclation matrix for cnm: cnm' = T*cnm.
%                   disPoints x (Narray+1)^2 x freqs.

K = params.fft.K;
nPoints = params.display.grid.nPoints;
loc_ind = state.slide.loc_ind;
loc = params.slide.locs(loc_ind,:);
N = params.array.N;
Hc = params.center.H(:,1:(N+1)^2,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Matrices H with varying r, disPoints x (Narray+1)^2 x freqs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r_diff = params.display.grid.cart - repmat(loc, nPoints, 1);
r = sqrt(sum(r_diff.^2,2));
kr_disPoints_x_freqs = r * params.fft.k.';  
coordinate = itaCoordinates;
coordinate.cart = loc;
grid = params.display.grid + coordinate;

% Spherical Harmonics: num_angels x (Nc+1)^2.
Ynm = ita_sph_base(grid, N);

% prepare hankel functions for translated source
for k_ind = 1 : K
    hn_disPoints_x_N = ita_sph_besselh([0:N], 1,...
                        kr_disPoints_x_freqs(:,k_ind));
    hn_disPoints_x_NMs = ita_sph_extend_n_to_nm(hn_disPoints_x_N,2);
    Ht(:,:,k_ind) = hn_disPoints_x_NMs .* Ynm;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Transformation matrices T for translation, disPoints x (Narray+1)^2 x freqs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k_ind = 1 : K
    T(:,:,k_ind) = pinv(Hc(:,:,k_ind)) * Ht(:,:,k_ind);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Store output in state 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.slide.H = Ht;
state.slide.T = T;
