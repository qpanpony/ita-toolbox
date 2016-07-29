function state = interpolateC(params, state);
% interpolateC.m
% Author: Noam Shabtai
% ITA-RWTH, 17.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = interpolateC(params, state);
% Interpolate c(k,th,ph) from estimated cnm(k).
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
% Output Parameters;
%   state.translation.interp_c - interpolated c(k,th,ph) - grid x freqs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate c(k,th,ph) from interpolated cnm(k) - grid x freqs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cnm is (Nc+1)^2 x freqs.
% Ynm is grid x (Nc+1)^2.
interp_c = params.display.Ynm * state.translation.cnm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store output in state.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.translation.interp_c = interp_c;
