function state = calculateCnm(params, state)
% Author: Noam Shabtai
% Institution of Technical Acoustics 
% RWTH Aachen University,
% 17.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = calculateCnm(params, state)
% Calculate spherical Fourier transform of c(k,th,ph).
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
% Output Parameters;
%   state.translation.cnm - coefficients of hankel functions with whom pnm is calculated.
%                   (Nc+1)^2 x freqs.

K = params.fft.K;
loc_ind = state.slide.loc_ind;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fetch correct original cnm and T.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch loc_ind
case 'translation'
    input_cnm = params.center.cnm;
    T = state.translation.T;
otherwise
    if params.mode.compensate_for_mic_directivity
        input_cnm = state.mic_directivity.cnm(:,:,loc_ind);
    else
        input_cnm = state.interp.cnm;
    end
    T = state.slide.T;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate cnm - (Nc+1)^2 x freqs 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k_ind = 1 : K
    output_cnm(:,k_ind) = T(:,:,k_ind) * input_cnm(:,k_ind);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store output cnm in state.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch loc_ind
case 'translation'
    state.translation.cnm = output_cnm;
otherwise
    state.slide.cnm(:,:,loc_ind) = output_cnm;
end
