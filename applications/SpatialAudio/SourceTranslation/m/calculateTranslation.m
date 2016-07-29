function state = calculateTranslation(params, state, dirs)
% calculateTranslation.m
% Author: Noam Shabtai
% ITA-RWTH, 31.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = calculateTranslation(params, state, dirs)
% Calculate transformation matrices H and T, cnm, pnm, sampling and interpolation
%   for a single source location.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state - include results errors for each algorithm for each source location.

switch params.stages.calculate_translation
case 1
    if params.display.headers
        fprintf('Calculate parameters that are translated from the center...\n');
    end

    % 0 performs translation from the center.
    state.slide.loc_ind = 'translation'; 

    % Calculate H : dsipPoints x (Nc+1)^2 x freqs .
    state = simulateHandT_firstTranslation(params, state);

    % Calculate cnm : (Na+1)^2 x freqs.
    state = calculateCnm(params, state);

    % Calculate pnm: (Na+1)^2 x freqs.
    state = calculatePnm(params, state);

    % Interpolate p from pnm: grid x freqs.
    state = interpolateP(params, state);

    % Save state
    translation = state.translation;
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.translate_filename],...
          'translation');
case 2
    if params.display.headers
        fprintf('Loading parameters that are translated from the center...\n');
    end

    % Load state
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.translate_filename],...
          'translation');
    state.translation = translation;
end
