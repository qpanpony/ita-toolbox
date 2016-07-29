function state = calculateReferenceP(params, state, dirs)
% calculateReferenceP.m
% Author: Noam Shabtai
% Institution of Technical Acoustics 
% RWTH Aachen University,
% 4.11.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = calculateReferenceP(params, state, dirs)
% Calculate the reference of the transformation matrices H and T, cnm, pnm, sampling and interpolation
%   for a single source location.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state - include results errors for each algorithm for each source location.

switch params.stages.calculate_reference_p
case 1
    if params.display.headers
        fprintf('Calculate the reference pressure for a source in the middle of the array...\n');
    end

    % -1 means simulating the case where the source is at the center.
    state.slide.loc_ind = 'reference'; 

    % Calculate pnm: (Na+1)^2 x freqs.
    state = calculatePnm(params, state);

    % Interpolate p from pnm: grid x freqs.
    state = interpolateP(params, state);

    % Save parameters
    center = state.center;
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.reference_p_filename],...
          'center');
case 2
    if params.display.headers
        fprintf('Loading the reference pressure for a source in the middle of the array...\n');
    end

    % Load state
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.reference_p_filename],...
          'center');
    state.center = center;
end
