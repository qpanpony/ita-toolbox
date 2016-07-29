function ita_menucallback_NachhallMitRauschen (hObject, event)
% Abgeschaltetes Rauschen mit Pegelverlauf

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

% init modulITA
ita_modulita_control('channel','all','input','xlr','inputrange', -20, 'feed', 'pha');

%% generate signal
h = msgbox('Signal is being generated','Interrupted noise', 'help', 'modal' );
noise = ita_generate('pinknoise', 1 ,44100, 18);
noise.trackLength = noise.trackLength + 12;

% equalization
freq = 178;
dode = ita_time_window(abs(ita_read('dodecahedron_old.ita')'),[0.15 0.18],'symmetric');
dode = ita_extend_dat(dode,noise.nSamples,'symmetric');
dode_eq(1) = ita_invert_spk_regularization(dode.ch(1),[50 freq],'filter');
dode_eq(2) = ita_invert_spk_regularization(dode.ch(2),[freq 12000],'filter');
dode_eq = ita_minimumphase(merge(dode_eq));

noise = ita_normalize_dat(noise * dode_eq);

close(h);

%% load MS
load MS_V1.mat;
MS.freqRange = [50 12000];
MS = itaMSPlaybackRecord(MS);
MS.inputChannels = 1;
MS.outputamplification = -20;
MS.excitation = noise;

%% run measurement
h = msgbox('Performing and evaluating measurement','Interrupted noise', 'help', 'modal' );
res_noise = MS.run;
res_band = ita_filter_bandpass(res_noise,'lower',1000/sqrt(2),'upper',1000*sqrt(2),'zerophase',false);

bs = 512;
dt = bs/MS.samplingRate;
throwAway = ceil(0.5/dt);
nFrames = floor(res_band.nSamples/bs);
tmp = reshape(res_band.time((throwAway*bs+1):nFrames*bs),[bs nFrames-throwAway]);
nFrames = nFrames-throwAway;
rmsVals = sqrt(mean(tmp.^2));

close(h);

%% plot result
t = 0:dt:(nFrames-1)*dt;
maxVal = mean(rmsVals(1:100));
dynRange = max(60,20.*log10(maxVal/min(rmsVals)));
plot(t,20.*log10(rmsVals./maxVal),'LineWidth',2);
xlim([0 nFrames*bs/MS.samplingRate]);
ylim([-dynRange 5]);
xlabel('Time in s');
ylabel('Modulus in dB re 1');
title('Level dacay for interrupted noise, 1kHz octave band');
grid

end % function