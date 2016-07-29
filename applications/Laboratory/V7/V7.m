%% create measurement setup for transfer path measurement

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx; % clear all
MS = ita_measurement;

%% adjust the setting on the measurement equipment
% set polariation voltage for the preamplifier
% ita_modulita_control;

%% adjust the values and run the measurement
MS.outputamplification = -30;
L = MS.run;

%% change MS to right speaker
MS.outputChannels = 2;

%% now right speaker
R = MS.run;

%% merge the results
LR = merge(L, R);

%% apply a time window

% shift the IR and use a symmetric window...
LR_shifted = ita_time_shift(LR);
LR_win = ita_time_window(LR_shifted, [0.004 0.008], 'symmetric');

%% alternatively: using a specialized loudspeaker window
% LR_win = ita_quiesst_adrienne_temporal_window(LR);

%% eliminate the notches by applying an amplification there
LR_noNotches = ita_smooth_notches(LR_win, 'squeezeFactor', 0.3);

%% invert, only using a limited frequency range
freqRange = [200 16000];
LR_inverted = ita_invert_spk_regularization(LR_noNotches, freqRange);

%% apply a time shift again
% 100ms
LR_inv_shifted = ita_time_shift(LR_inverted, 0.2, 'time');

%% send the filter to the convolver

b = itaBruteFIR(LR_inv_shifted);

%% ...and right speaker
R_eq = MS.run;

%% change MS to left speaker
MS.outputChannels = 1;

%% and measure again, left
L_eq = MS.run;

%% merge the the result and listen to music
LR_eq = merge(L_eq, R_eq);

