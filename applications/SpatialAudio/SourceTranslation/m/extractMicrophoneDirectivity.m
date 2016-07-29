function state = extractMicrophoneDirectivity(params, state, dirs)
% extractMicrophoneDirectivity.m
% Author: Noam Shabtai
% ITA-RWTH, 9.1.2014
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = extractMicrophoneDirectivity(params, state)
% Extract the transfer functions of each microphone 
%   with regard to every assumed location of the source.
% Perform a loop over source location and calls singlePositionExtractMicrophoneDirectivity.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state.mic_directivity.mic_filter -
%                               Tensor : freqs x array points x locations.
%                               Holds the transfer function of each microphone for each
%                               assumed location of the source.

switch params.stages.mic_directivity.extract
case 1
    if params.display.headers
        fprintf('Extract microphone directivities ...\n');
    end

    mic_data = itaHDF5([dirs.database_dir, dirs.slash,...
                                          dirs.mic_dir, dirs.slash,...
                                          dirs.mic_filename]);
    mic_data = mic_data.mic32_without_absorber;

    state.mic_directivity.theta = mic_data.coordinates.theta; % mic dir points x 1
    state.mic_directivity.signal = mic_data.get_audio;
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
        state = singlePositionExtractMicrophoneDirectivity(params, state);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save state
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mic_filter = state.mic_directivity.mic_filter;
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.mic_filter_filename],...
          'mic_filter');
case 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load state
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if params.display.headers
        fprintf('Loading microphone directivities ...\n');
    end
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.mic_filter_filename],...
         'mic_filter');
    state.mic_directivity.mic_filter = mic_filter;
end
