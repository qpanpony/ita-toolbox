function state = ita_schroederDecay(params, state)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

if ~params.stages.schroeder_decay return; end

h = state.rir_signal_filtered(:,params.schroeder_decay.frequency_index);
fs = params.rir.sampling_frequency;

total_energy = sum(abs(h).^2,1);
total_energy_dB = 10*log10(total_energy);

backward_integration = total_energy - cumsum(abs(h).^2);
backward_integration_dB = 10*log10(backward_integration);

decay_curve_dB = backward_integration_dB - total_energy_dB;
    
T5_index = find(decay_curve_dB>=-5, 1, 'last');
T25_index = find(decay_curve_dB>=-25, 1, 'last');

T5 = (T5_index-1)/fs;
T25 = (T25_index-1)/fs;

switch(params.schroeder_decay.method)
case {'3T20', 'iso'}
    relevant_decay_curve_indices = find(-25 <= decay_curve_dB & decay_curve_dB <= -5);
case 'edt'
    relevant_decay_curve_indices = find(-10 <= decay_curve_dB);
otherwise
    error('iso can be either 3T20 or iso or edt.');
end

% Calculate reverberation time.
switch(params.schroeder_decay.method)
case {'iso', 'edt'}
    if length(relevant_decay_curve_indices) > 3
        % x = t*a + b
        % x = H*theta
        % =>
        % H = [[t0; t1; t2; ...] , [1; 1; 1; ...]]
        % theta = [a, b]'
        x = decay_curve_dB(relevant_decay_curve_indices);
        t = (relevant_decay_curve_indices - 1) / fs;
        H = [t, ones(length(t),1)];
        theta = inv(H'*H)*H'*x;
        a = theta(1);
        b = theta(2);
        T60 = (-60-b) / a;
    else
        T60=3*(T25-T5);  
    end
case '3T20'
    T60=3*(T25-T5); 
end

state.schroeder_decay.T60 = T60;
state.schroeder_decay.T5 = T5;
state.schroeder_decay.T25 = T25;
state.schroeder_decay.curve_dB = decay_curve_dB;
