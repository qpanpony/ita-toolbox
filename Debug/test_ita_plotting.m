function test_ita_plotting()
%get two signals and a tp

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

sr = 44100;
fftdeg = 15;
a       = ita_generate('flatnoise',1,sr,fftdeg);
a       = ita_merge(a,a,a);

ita_plot(a);
pause(1);
close all;
ita_plot_freq(a);
pause(1);
close all;
ita_plot_freq_groupdelay(a);
pause(1);
close all;
ita_plot_freq_phase(a);
pause(1);
close all;
ita_plot_time(a);
pause(1);
close all;
ita_plot_time_dB(a)
pause(1);
close all;

end