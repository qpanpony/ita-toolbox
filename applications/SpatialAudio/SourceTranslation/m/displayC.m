function displayC(params, state);
% displayC.m
% Author: Noam Shabtai
% ITA-RWTH, 18.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% displayC(params, state);
% Display the interpolated function c(k,th,ph).
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
% Output Parameters;
%   none.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display interpolated c(k,th,phi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K = params.source.K;
f_khz = (params.fft.f)/1000;
figure(1);
for k_ind = 1:K
    title(sprintf('c(k,th,ph) at %3.1f KHz', f_khz(k_ind)));
    surf(params.display.grid, db(state.interp_c(:,k_ind)));
    pause(0.1);
end
