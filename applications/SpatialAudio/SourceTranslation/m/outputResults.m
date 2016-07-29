function results = outputResults(params, state, dirs)
% outputResults.m
% Author: Noam Shabtai
% ITA-RWTH, 4.12.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% results = outputResults(params, state, dirs)
% Output the center and the resulting directivity pattern pnm.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   results.loc - freqs x 3 x types (of error functions) :
%                 the center coordinates for each frequency and error type.
%   results.pnm - (Narray+1)^2 x freqs x types (of error_functions) :
%                 tpnm of the resulting directivity.

switch params.stages.output_results
case 1
    if params.display.headers
        fprintf('Output simulation results...\n');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get all errors and locations from the slide-source operation 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    locs = params.slide.locs;              % locs x 3
    J = state.errors.normJ;                % locs x freqs x types
    J4_ind = 5;
    J5_ind = 6;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find center according to J0 - J3 using min{J},
    % but remember minimum also for J4 and J5.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [val,loc_ind] = min(J, [], 1);         % 1 x freqs x types
    loc_ind = permute(loc_ind, [2,3,1]);   % freqs x types
    for type_ind = 1:J5_ind
        loc(:,:,type_ind) = locs(loc_ind(:,type_ind),:); %freqs x 3 x type
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find xy center according to minJ4 and z center according to minJ5
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_J4 = loc(:,1,J4_ind); %freqs x 1
    y_J4 = loc(:,2,J4_ind); %freqs x 1
    z_J5 = loc(:,3,J5_ind); %freqs x 1
    loc(:,:,J4_ind) = [x_J4, y_J4, z_J5]; 

    K = params.fft.K;
    for k_ind = 1:K
        loc_ind(k_ind, J4_ind) = find(ismember(locs,loc(k_ind,:,J4_ind),'rows'));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find central pnm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    max_freq = params.mode.max_frequency_for_centralization;
    if params.mode.limit_frequency_for_centralization
        max_k_ind = find(params.fft.f<=max_freq,1,'last');
    else
        max_k_ind = K;
    end

    if isempty(max_k_ind)
        for type_ind = 1:J4_ind
            pnm(:,:,type_ind) = state.interp.pnm;
        end
    else
        for k_ind = 1:K
            for type_ind = 1:J4_ind
                pnm(:,k_ind,type_ind) = state.slide.pnm(:,k_ind,loc_ind(min(k_ind,max_k_ind),type_ind));
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Interpolate p from the pnm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    N = params.array.N;
    Ynm = params.display.Ynm(:,1:(1+N)^2);
    for type_ind = 1:J4_ind
        interp_p(:,:,type_ind) = Ynm * pnm(:,:,type_ind);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Store loc and pnm in results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    results.loc = loc;
    results.pnm = pnm;
    results.interp_p = interp_p;
    results.frequencies = params.fft.f;
    results.max_freq_for_centralization = params.fft.f(max_k_ind);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.results_filename],...
          'results');
case 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if params.display.headers
        fprintf('Loading errors for each assumed center...\n');
    end
    load([dirs.parent_dir, dirs.slash, dirs.mat_dir,...
          dirs.slash, dirs.results_filename],...
         'results');
end
