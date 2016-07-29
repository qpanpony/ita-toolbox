function state = normalizeError(params, state, dirs)
% normalizeError.m
% Author: Noam Shabtai
% ITA-RWTH, 6.12.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% state = normalizeError(params, state, dirs)
% Calculate the error for each assumed position of the source.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state.errors - errors for each algorithm for each source location.

switch params.stages.errors.normalize
case 1
    if params.display.headers
        fprintf('Normalizing errors for each assumed center...\n');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fetch errors out of state.
    % state.errors.J : types x freqs x locs
    % normJ          : locs x freqs x types 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    normJ = permute(state.errors.J, [3,2,1]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Normalize errors.
    % state.normJ : locs x freqs x types 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [a,b,c] = size(normJ);
    for type_ind = 1 : c
        normJ(:,:,type_ind) = normJ(:,:,type_ind) - repmat(mean(normJ(:,:,type_ind),1),a,1);
        normJ(:,:,type_ind) = normJ(:,:,type_ind) ./...
             repmat(std(normJ(:,:,type_ind),0,1),a,1);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save normalized errors
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.norm_err_filename],...
          'normJ');
case 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load normalized errors
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if params.display.headers
        fprintf('Loading normalized errors for each assumed center...\n');
    end
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.norm_err_filename],...
         'normJ');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store parameters in state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.errors.normJ = normJ; % locs x freqs x types
