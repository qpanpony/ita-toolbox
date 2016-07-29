function state = calculatePnm(params, state)
% calculatePnm.m
% Author: Noam Shabtai
% ITA-RWTH, 17.10.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% state = calculatePnm(params, state)
% Calculate spherical Fourier transform of p(k,th,ph).
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
% Output Parameters;
%   state.translation.pnm - spherical Fourier transform of the pressure field around the source.
%                   (Na+1)^2 x freqs.

loc_ind = state.slide.loc_ind;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fetch correct translated cnm and T.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch loc_ind
case 'reference'
    cnm = params.center.cnm;
    hn_NMs_x_freqs = params.center.hn_freqs_x_NMs.';
case 'translation'
    cnm = state.translation.cnm;
    hn_NMs_x_freqs = params.center.hn_freqs_x_NMs.';
otherwise
    cnm = state.slide.cnm(:,:,loc_ind);
    hn_NMs_x_freqs = params.center.hn_freqs_x_NMs(:,1:(1+params.array.N)^2).';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate pnm - (Nc+1)^2 x freqs 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pnm = cnm .* hn_NMs_x_freqs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store output pnm in state.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch loc_ind
case 'reference'
    state.center.pnm = pnm;
case 'translation'
    state.translation.pnm = pnm;
otherwise
    state.slide.pnm(:,:,loc_ind) = pnm;
end
