function results = ita_outputResults(params,state)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

results.source_location = params.source.location;
results.microphone_location = params.microphone.location;
results.microphone_to_source_distance = params.microphone.distance_to_source;
results.microphone_to_source_angle = params.microphone.angle_to_source;
results.sampling_frequency = params.rir.sampling_frequency;

results.gains_RxNMsxNMm = state.gains;
results.impulse_time_indices_Rx1 = state.impulse_time_indices;
results.num_of_impulses = state.num_of_impulses;
results.rir_signal_TxNMsxNMm = state.rir_signal;
