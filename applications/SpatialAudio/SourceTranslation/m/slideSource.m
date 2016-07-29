function state = slideSource(params, state, dirs)
% slideSource.m
% Author: Noam Shabtai
% ITA-RWTH, 31.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = slideSource(params, state, dirs)
% Perform source translation in a loop.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state.errors - errors for each algorithm for each source location.

switch params.stages.slide_source
case 1
    if params.display.headers
        fprintf('Perform source sliding...\n');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate state
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    points = size(params.slide.locs,1);
    for loc_ind = 1 : points
        if params.display.headers & ~mod(loc_ind,100)
            fprintf('... point %d out of %d (%d%%)\n',...
                    loc_ind, points, round(100*loc_ind/points));
        end
        state.slide.loc_ind = loc_ind;
        state = singlePositionCnmPnm(params, state);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save state
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    slide = state.slide;
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.slide_source_filename],...
          'slide');
case 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load state
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if params.display.headers
        fprintf('Loading results of source sliding...\n');
    end
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.slide_source_filename],...
         'slide');
    state.slide = slide;
end

