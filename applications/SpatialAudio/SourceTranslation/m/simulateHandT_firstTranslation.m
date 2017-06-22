function state = simulateHandT_firstTranslation(params, state)
% simulateHandT_firstTranslation.m
% Author: Noam Shabtai
% ITA-RWTH, 27.11.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = simulateHandT_firstTranslation(params, state)
% Calculate matrix [h1 ... hQ].' where
%   hq=[h_0(kr_q)Y_0^0...h_N(kr_q)Y_N^N].' 
% This is a matrix of hankel functions multiplied by spherical harmonics.
% Qx(N+1)^2
% r here is frequency dependent.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   state.center.H - Matrix H with constant r relative to the array center.
%                   disPoints x (Nc+1)^2 x freqs.
%
% Output Parameters;
%   state.translation.H - Matrix H with varying r, taking into account source translation.
%                   disPoints x (Nc+1)^2 x freqs.
%
%   state.translation.T - Tranclation matrix for cnm: cnm' = T*cnm.
%                   disPoints x (Nc+1)^2 x freqs.

K = params.fft.K;
nPoints = params.display.grid.nPoints;
N = params.source.N;
Hc = params.center.H;
loc = params.source.freq_loc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Matrices H with varying r, disPoints x (Nc+1)^2 x freqs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k_ind = 1:K
    r_diff = params.display.grid.cart - repmat(loc(k_ind,:), nPoints, 1);
    r(:,k_ind) = sqrt(sum(r_diff.^2,2));
end

kr_disPoints_x_freqs = r .* repmat(params.fft.k.', nPoints, 1);  

% prepare hankel functions for translated source
coordinate = itaCoordinates;
for k_ind = 1 : K
    coordinate.cart = loc(k_ind, :);
    grid = params.display.grid - coordinate;

    % Spherical Harmonics: num_angels x (Nc+1)^2.
    Ynm = ita_sph_base(grid, N);

    hn_disPoints_x_N = ita_sph_besselh([0:N], 1,...
                        kr_disPoints_x_freqs(:,k_ind));
    hn_disPoints_x_NMs = ita_sph_extend_n_to_nm(hn_disPoints_x_N,2);
    Ht(:,:,k_ind) = hn_disPoints_x_NMs .* Ynm;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Transformation matrices T for translation, disPoints x (Nc+1)^2 x freqs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k_ind = 1 : K
    T(:,:,k_ind) = pinv(Ht(:,:,k_ind)) * Hc(:,:,k_ind);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Store output in state 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.translation.H = Ht;
state.translation.T = T;
