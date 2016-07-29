function state = compensateWithMicrophoneDirectivity(params, state, dirs)
% compensateWithMicrophoneDirectivity.m
% Author: Noam Shabtai
% ITA-RWTH, 9.1.2014
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = compensateWithMicrophoneDirectivity(params, state)
% Extract the transfer functions of each microphone 
%   with regard to every assumed location of the source.
% Perform a loop over source location and calls singlePositionMicrophoneDirectivity.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state.mic_directivity.pnm -
%                               Tensor : (N_array+1)^2 x freqs x locations.
%                               Holds the compensated pnm (N+1)^2 x freqs matrix for each
%                               assumed location of the source.
%   state.mic_directivity.cnm -
%                               Tensor : (N_array+1)^2 x freqs x locations.
%                               Holds the compensated cnm (N+1)^2 x freqs matrix for each
%                               assumed location of the source.

switch params.stages.mic_directivity.compensate
case 1
    if params.display.headers
        fprintf('Compensate with microphone directivities ...\n');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate state
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    K = params.fft.K;
    N = params.array.N;
    p = params.fft.p;                               % mics x freqs
    w = params.array.grid.weights;                  % mics x 1
    W = repmat(w,1,K);                              % mics x freqs
    wp = p .* W;                                    % mics x freqs

    Ynm = params.array.Ynm;                         % num_angels x 
    
    Nmin = min(params.array.N, params.source.N);
    highestMN = (Nmin+1)^2;
    hn_NMs_x_freqs = params.center.hn_freqs_x_NMs(:,1:highestMN).';

    mic_filter = state.mic_directivity.mic_filter; % freqs x mics

    points = size(params.slide.locs,1);
    for loc_ind = 1 : points
        if params.display.headers & ~mod(loc_ind,100)
            fprintf('... point %d out of %d (%d%%)\n',...
                    loc_ind, points, round(100*loc_ind/points));
        end

        wp_eq = wp ./ mic_filter(:,:,loc_ind).';
        pnm(:,:,loc_ind) = Ynm' * wp_eq;
        cnm(:,:,loc_ind) = pnm(:,:,loc_ind) ./ hn_NMs_x_freqs;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.mic_compensate_filename],...
          'pnm', 'cnm');
case 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if params.display.headers
        fprintf('Loading results of source sliding...\n');
    end
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.mic_compensate_filename],...
         'pnm', 'cnm');
    state.mic_directivity.pnm = pnm;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restore values to state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.mic_directivity.pnm = pnm;
state.mic_directivity.cnm = cnm;
