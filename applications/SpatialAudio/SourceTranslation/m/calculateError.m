function state = calculateError(params, state, dirs)
% calculateError.m
% Author: Noam Shabtai
% ITA-RWTH, 12.11.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% state = calculateError(params, state, dirs)
% Calculate the error for each assumed position of the source.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state.errors - errors for each algorithm for each source location.

switch params.stages.errors.calculate
case 1
    if params.display.headers
        fprintf('Calculate errors for each assumed center...\n');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate errors
    % state.J : types x freqs x locs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    points = size(params.slide.locs,1);
    for loc_ind = 1 : points
        if params.display.headers & ~mod(loc_ind,100)
            fprintf('... point %d out of %d (%d%%)\n',...
                    loc_ind, points, round(100*loc_ind/points));
        end
        state.slide.loc_ind = loc_ind;
        state = singlePositionError(params, state);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save state
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    J = state.errors.J;
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.errors_filename],...
          'J');
case 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load state
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if params.display.headers
        fprintf('Loading errors for each assumed center...\n');
    end
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.errors_filename],...
         'J');
    state.errors.J = J;
end
