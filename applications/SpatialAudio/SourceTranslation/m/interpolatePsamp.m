function state = interpolatePsamp(params, state, dirs);
% interpolatePsamp.m
% Author: Noam Shabtai
% ITA-RWTH, 17.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = interpolatePsamp(params, state, dirs);
% Interpolate the sampled version of p(k,th,ph).
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state.interp.pnm - interpolated pnm - (Narray+1)^2 x freqs
%   state.interp.interp_p - interpolated p(k,th,ph) - grid x freqs
%   state.interp.cnm - interpolated cnm - (Narray+1)^2 x freqs



switch params.stages.interpolate_p_after_sampling
case 1
    if params.display.headers
        fprintf('Calculate pnm from sampled points and interpolate p(k,th,phi)...\n');
    end

    % Pull spatially-smapled pressure spectrum.
    if params.mode.simulated_cnm
        p = state.sampling.p;
    else
        p = params.fft.p;
    end
    % Define shortcuts.
    K = params.fft.K;
    N = min(params.source.N,params.array.N);

    % Ynm : samp_grid x (Narray+1)^2
    Ynm = params.array.Ynm;

    % Sampled pnm is (Narray+1)^2 x freqs.
    pnm = inv(Ynm'*Ynm)*Ynm' * p;

    % Calculate p(k,th,ph) after sampling - grid x freqs
    % sampled pnm is (Nrray+1)^2 x freqs.
    % Ynm is grid x (Ndisplay+1)^2.
    interp_p = params.display.Ynm(:,1:(N+1)^2) * pnm(1:(N+1)^2,:);

    % hnm, Hankel functions of the first kind seen from exact array center.
    Nmin = min(params.array.N, params.source.N);
    highestMN = (Nmin+1)^2;
    hn_NMs_x_freqs = params.center.hn_freqs_x_NMs(:,1:highestMN).';

    % Calculate cnm from sampled pnm
    cnm = pnm(1:(N+1)^2,:) ./ hn_NMs_x_freqs;

    % Save parameters
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.interp_after_sampling_filename],...
          'pnm', 'interp_p', 'cnm');
case 2
    if params.display.headers
        fprintf('Loading parameters that are translated from the center...\n');
    end

    % Load parameters
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.interp_after_sampling_filename],...
          'pnm', 'interp_p', 'cnm');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restore values to state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.interp.pnm = pnm;
state.interp.cnm = cnm;
state.interp.interp_p = interp_p;
