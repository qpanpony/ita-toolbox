function state = interpolateP(params, state);
% interpolateP.m
% Author: Noam Shabtai
% ITA-RWTH, 17.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = interpolateP(params, state);
% Interpolate p(k,th,ph) from estimated pnm(k).
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
%   state.translation.interp_p - interpolated p(k,th,ph) - grid x freqs


loc_ind = state.slide.loc_ind;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fetch correct pnm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch loc_ind
case 'reference' 
    pnm = state.center.pnm;
    N = params.source.N;
case 'translation'
    pnm = state.translation.pnm;
    N = params.source.N;
otherwise
    pnm = state.slide.pnm(:,:,loc_ind);
    N = params.array.N;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate p(k,th,ph) from pnm(k) - grid x freqs
% pnm is (N+1)^2 x freqs.
% Ynm is grid x (N+1)^2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ynm = params.display.Ynm(:,1:(1+N)^2);
interp_p = Ynm * pnm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store output interp_p in state.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch loc_ind
case 'reference'
    state.center.interp_p = interp_p;
case 'translation'
    state.translation.interp_p = interp_p;
otherwise
    state.slide.interp_p = interp_p;
end
