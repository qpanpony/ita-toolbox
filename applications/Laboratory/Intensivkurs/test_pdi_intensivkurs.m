%%

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

MS = itaMSTF;


%%
MS.inputChannels = 1;
MS.outputChannels = 3;

MS.fftDegree = 17;

%%
close all
MS.fftDegree = 19;
MS.outputamplification = 30;
a = MS.run;
a.plot_time_dB

ita_write(a,['rir_aula_' num2str(idx)],'overwrite')
idx = idx + 1;


%%
rt = ita_roomacoustics(a.merge)

%%
rt(3).bar


%%
L = ita_roomacoustics_EDC(a.merge);
L.plot_time_dB