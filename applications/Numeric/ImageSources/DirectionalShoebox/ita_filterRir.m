function state = ita_filterRir(params,state)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

if ~params.stages.rir.filter return; end

h = state.rir_signal;
N = params.filter.order;
band = params.filter.normalized_band;

[numerator, denominator] = butter(N, band);
hf = filter(numerator, denominator, h);

state.rir_signal_filtered = hf;


