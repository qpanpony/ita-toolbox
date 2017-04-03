%% Akustische Messtechnik exercise
% _2016 JCK, ROP
%
% WARNING: This script contains blanks to be filled
%
%% Block A - Anechoic Chamber
%% A4 - Loudspeaker Transfer Function
% Measurement Setup
MS = itaMSTF;
MS.inputChannels    = %%
MS.outputChannels   = %%
MS.fftDegree        = %%
MS.repeats          = %%

% Calibrate
MS.calibrate;

% Measurement
result = MS.run;

% Plot result
result.pt
result.ptd
result.pf

% Window
result_win = ita_time_window(result, [], 'time');

% Plot windowed result
result_win.pt
result_win.ptd
result_win.pf

% Normalize result
% Watts
Loudspeaker_Impedance = %%
Loudspeaker_Voltage = MS.excitation.rms * MS.outputMeasurementChain.sensitivity;
Loudpseaker_Watts = Loudspeaker_Voltage^2/Loudspeaker_Impedance;
% Distance
Loudspeaker_Distance = %%
Floor = % 1 = no floor reflection, 2 = floor reflection
Loudspeaker_Sensitivity = result_win/Loudpseaker_Watts/Loudspeaker_Distance/Floor;


%% A6 - Sound Power
MS = itaMSRecord;
MS.inputChannels    = %%
MS.outputChannels   = %%
MS.fftDegree        = %%
MS.repeats          = %%

% Calibrate
MS.calibrate;

% Measurement
L_distance = %
L_result_1 = MS.run;

% Apply weighting
L_weight_1 = %
L_result_1_rms_weighted = L_result_1.rms * L_weight_1;

% Merge all results
L_result = (result_1_rms_weighted + ) / (weight_1 + );
L_L = 20*log10(L_result/2e-5);
Lw = L_L + 20*log10(L_distance) + 11;

%% Block B - Reverberation Chamber