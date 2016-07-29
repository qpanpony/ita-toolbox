function state = singlePositionExtractMicrophoneDirectivity(params, state)
% singlePositionExtractMicrophoneDirectivity.m
% Author: Noam Shabtai
% ITA-RWTH, 9.1.2014
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = singlePositionExtractMicrophoneDirectivity(params, state)
% Extract the microphones directivity for the whole array,
%   for this particular assumed location of the source.
% extractExtractMicrophoneDirectivity performs a loop over source location and calls this function.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
% Output Parameters;
%   state.mic_directivity.mic_filter -
%                               Tensor : freqs x array points x locations.
%                               Holds the transfer function of each microphone for each
%                               assumed location of the source.

f = params.fft.f;
K = params.fft.K;
nPoints = params.array.grid.nPoints;
loc_ind = state.slide.loc_ind;
loc = params.slide.locs(loc_ind,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculate the distance from each microphone to the assumed position.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r_orig = params.array.r;
r_diff = params.array.grid.cart - repmat(loc, nPoints, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculate the distance from the center the assumed position.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp_square = sum(loc.^2);
displacement = sqrt(disp_square);
r_disp_square = sum(r_diff.^2,2);
r_disp = sqrt(r_disp_square);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Use the cosine law to calculate the zenith from each
%       microphone to the assumed position.
%       disp_theta: array points x 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp_theta = real(acos((r_orig.^2 + r_disp_square - disp_square)./(2*r_orig*r_disp)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Find the directivity measurements with closest zenith to alhpa.
%       min_ang_dif_raw : 1 x array points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mic_theta = state.mic_directivity.theta;    % mic dir points x 1
mic_signal = state.mic_directivity.signal;  % ita_audio instance.

disp_theta_matrix = repmat(disp_theta.', length(mic_theta), 1);   % mic dir points x array points
mic_theta_matrix = repmat(mic_theta, 1, length(disp_theta));     % mic dir points x array points
ang_diff_matrix = abs(disp_theta_matrix - mic_theta_matrix);       % mic dir points x array points

min_ang_diff_raw = min(ang_diff_matrix); % 1 x array points

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Find the frequency response of any microphone to equalize with.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for array_ind = 1 : length(disp_theta)
    relevant_mic_dir_ind = find(abs(ang_diff_matrix(:,array_ind) - min_ang_diff_raw(array_ind))<0.0001);
    if isempty('relevant_mic_dir_ind')
        warning('no relevant microphone directivities found');
    end
    mic_filter(:,array_ind) = mean(mic_signal.freqData(:,relevant_mic_dir_ind),2);
end
for f_ind = 1:K
    [val, compensate_ind(f_ind)] = min(abs(mic_signal.freqVector-f(f_ind)));  
end
mic_filter = mic_filter(compensate_ind,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Store output in state 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.mic_directivity.mic_filter(:,:,loc_ind) = mic_filter;
