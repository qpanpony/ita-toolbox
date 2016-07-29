function test_ita_mpb_filter()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% generate input signal
a = ita_generate('flatnoise',1,44100,16);

%% test function with options
b = ita_mpb_filter(a,[0 2000]); %low pass
b = ita_mpb_filter(a,[200  0]); %high pass
b = ita_mpb_filter(a,[1000 2000]); %passband

b = ita_mpb_filter(a,'a-weight'); %A weight
b = ita_mpb_filter(a,'c-weight'); %C weight
b = ita_mpb_filter(a,'oct',3); %1/3 octave
b = ita_mpb_filter(a,'octaves',3); %1/3 octave
b = ita_mpb_filter(a,'3-oct'); %third octave
b = ita_mpb_filter(a,'third-octaves'); %third octave
% b = ita_mpb_filter(a,'octaves*',3); %High band Octave Filtering - Model Room Measurements % TODO % option does not work!

b = ita_mpb_filter(a,[0 2000],'order',10); %order 10
b = ita_mpb_filter(a,[200 2000],'zerophase'); %zerophase
b = ita_mpb_filter(a,[200 2000],'class',2); %class 1
b = ita_mpb_filter(a,[200 2000],'minimumphase'); %minimumphase

%% Plot
ita_plot_freq_phase(b);
end