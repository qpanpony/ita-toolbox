function state = sampling(params, state, dirs);
% sampling.m
% Author: Noam Shabtai
% ITA-RWTH, 21.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% sampling(params, state, dirs);
% Apply a spherical microphone array sampling to the function p(k,th,ph).
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state.sampling.pnm - interpolated pnm after sampling.
%                   (Narray+1)^2 x freqs.
%
%   state.sampling.cnm - interpolated pnm after sampling.
%                   (Narray+1)^2 x freqs.

switch params.stages.sampling
case 1
    if params.display.headers
        fprintf('Sampling the translated directivity...\n');
    end

    % Define shortcuts.
    pnm = state.translation.pnm;
    dth = params.display.grid.theta;
    dph = params.display.grid.phi;
    ath = params.array.grid.theta;
    aph = params.array.grid.phi;
    p = state.translation.interp_p;
    K = params.fft.K;
    Q = params.array.grid.nPoints;

    % Calculate sampled function in the spherical harmonics domain.
    grid_ind = zeros(Q,1);
    for q = 1:Q
        [val,grid_ind(q)] = min(abs(ath(q)-dth)+abs(aph(q)-dph));
    end

    % pressure: samp_grid x freqs
    p = p(grid_ind,:);

    % Save state
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.sampling_filename],...
          'p');
case 2
    if params.display.headers
        fprintf('Loading parameters that are translated from the center...\n');
    end

    % Load state
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.sampling_filename],...
          'p');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restore values to state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.sampling.p = p;
