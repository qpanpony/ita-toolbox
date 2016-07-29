function ita_displayRir(params,state)

if ~params.display.rir return; end

h = state.rir_signal;
N = size(h,1);
K = size(h,2);
fs = params.rir.sampling_frequency;
Ts = 1/fs;
t = (0:N-1)*Ts;

figure,
plot(t,h(:,1),'linewidth',2);
set(gca,'fontsize',25);
xlabel('t [s]');
ylabel('h(t)');
title('impulse response');
