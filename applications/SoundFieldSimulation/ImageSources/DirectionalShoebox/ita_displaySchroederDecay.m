function ita_displaySchroederDecay(params,state)

if ~params.display.schroeder_decay return; end

T60 = state.schroeder_decay.T60;
T5 = state.schroeder_decay.T5;
T25 = state.schroeder_decay.T25;
pdB = state.schroeder_decay.curve_dB;
fs = params.rir.sampling_frequency;

a_bit_after_T60 = 1.2*T60;

t = (0:(length(pdB)-1)) / fs;
figure,
plot(t, pdB);
axis([0, a_bit_after_T60*1.2, -60, 0]);
hold on
plot(T5, -5, 'ro', T25, -25, 'ks', 'linewidth', 3);
set(gca,'fontsize',25);
legend('Decay dB', '-5 dB', '-25 dB');
xlabel('t [s]');
ylabel('Decay [dB]');
title(sprintf('T60 = %.2g s', round(100*T60)/100));
