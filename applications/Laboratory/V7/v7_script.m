%% load measured FR for left and right CH and create compensation filter
%load data

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

speakerIR_LR =ita_read;
%time shift
speakerIR_LR = ita_time_shift(speakerIR_LR.merge);
%window
res1 = ita_frequency_dependent_time_window(speakerIR_LR,[0.02 0.035; 0.01 0.012; 0.002 0.004],[200 2000]);
% test_window = merge(speakerIR_LR,res1); test_window.plot_spk

%smoothing and elimination of deep notches
res2 = ita_smooth(res1,'LogFreqOctave1', 1/3, 'Abs');
diff = abs(res1/res2);
vector = min(diff.freqData, 1);
res = (vector .* res1.freqData + (1-vector) .* res2.freqData) / 2;
res1.freqData = res;

%invert and regularize
comp_filter = ita_invert_spk_regularization(res1,[40 16000],'filter');
%normalize
comp_filter = ita_normalize_spk(comp_filter);

%time shift
comp_filter = ita_time_shift(comp_filter);
comp_filter = ita_time_shift(comp_filter,0.05);
%window and time crop
comp_filter = ita_time_window(comp_filter,[0.02 0],'time');
comp_filter_win = ita_time_window(comp_filter,[0.08 0.1],'time','crop');

%calculate minimumphase
comp_filter_min = ita_minimumphase(comp_filter_win,'cutoff');

%test
test = ita_convolve(comp_filter_win,speakerIR_LR);

%% load audiofile and play with/without compensation 
filepath = 'E:\user\Praktikum\Titel 58.wav';
input = ita_read(filepath);
amplification = '0dB';
ita_amplify(input,amplification);

% play
input.play

% compensation(minimumphase), play
input_comp_min = ita_convolve(input,comp_filter_min);
input_comp_min.play

% compensation, play
input_comp = ita_convolve(input,comp_filter_win);
input_comp.play





%%
close all
clc
profile on
tic
ita_v7_playback(ita_amplify(input,'-0dB'))
toc
profile viewer
