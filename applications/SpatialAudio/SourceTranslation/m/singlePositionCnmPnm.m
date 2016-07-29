function state = singlePositionCnmPnm(params, state, dirs)
% singlePositionCnmPnm.m
% Author: Noam Shabtai
% ITA-RWTH, 31.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% state = singlePositionCnmPnm(params, state, dirs)
% Calculate transformation matrices, cnm, pnm and interpolation
%   for a single source location.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   state - include results errors for each algorithm for each source location.

% Calculate H and T : dsipPoints x (Narray+1)^2 x freqs.
state = calculateHandT_slideSource(params, state);

% Calculate cnm : (Na+1)^2 x freqs.
state = calculateCnm(params, state);

% Calculate pnm: (Na+1)^2 x freqs.
state = calculatePnm(params, state);

% Interpolate p from pnm: grid x freqs.
state = interpolateP(params, state);
