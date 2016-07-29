%% test level sweeps for distortion measurement

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx
freq    = 1000;
sr      = 44100;
fft_deg = 17;

%a = ita_generate('sine',1,freq,sr,fft_deg);
a = ita_generate('noise',1,sr,fft_deg);

level_low  = -60;
level_high =   0;

level_diff = level_high - level_low;

%attenuate
a = ita_amplify(a,[num2str(level_low) 'dB' ]);

%% log level sweep 
%time weighting vector
t = a.timeVector';
t = t./max(t) * level_diff; %normalize and scale -- 0 to max_dB
t = 10.^(t./20);
b.dat = t;
b.header = ita_make_header(t, sr, 't');
b = itaAudio(b);

%% lin level sweep 
%time weighting vector
t = a.timeVector.';
t = t./max(t) * (10^(level_diff/20)-1)  + 1; %normalize and scale -- 0 to max_dB
c.dat = t;
c.header = ita_make_header(t, sr, 't');
c = itaAudio(c);

%% apply
log_levelsweep = a.* b;
lin_levelsweep = a.* c;
log_env = ita_envelope(log_levelsweep);
lin_env = ita_envelope(lin_levelsweep);

%% measurement
a_log = ita_portaudio(log_levelsweep,'InputChannels',[1,4],'OutputChannels',[3 4]);
a_log_env = ita_envelope(a_log);

a_lin = ita_portaudio(lin_levelsweep,'InputChannels',[1,4],'OutputChannels',[3 4]);
a_lin_env = ita_envelope(a_lin);


%%
%measurement_setup = ita_measurement_setup(1,1,44100,16,[20 23050],'OutputAmplification','-40dB', 'Excitation','exp', 'Averages', 8);