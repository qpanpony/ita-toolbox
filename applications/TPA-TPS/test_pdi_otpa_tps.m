ccx

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

a = ita_generate('impulse',1,44100,16);
b = a* 0;
a_mat = [a, b; b*2, -2*a];
b_mat = [1*a, 1*a; 1*a, 1*a];

c = [1 1; 1 1];



%% Y matrix
fft_degree = 16;
folder = '/Users/pascaldietrich/MATLAB/__Bosch/BOSCH - auralizationBox otpa/vonMLI/Y_r';
for idx = 1:3
    for jdx = 1:3
        Yr(idx,jdx) = ita_extract_dat(ita_read([folder filesep 'y' num2str(idx) num2str(jdx) '.ita']),fft_degree,'symmetric');
    end
end


folder = '/Users/pascaldietrich/MATLAB/__Bosch/BOSCH - auralizationBox otpa/vonMLI/Ys_model';
for idx = 1:3
    for jdx = 1:3
        Ys(idx,jdx) = ita_extract_dat(ita_mpb_filter( ita_read([folder filesep 'y' num2str(idx) num2str(jdx) '.ita']),[10 0], 'zerophase'),fft_degree,'symmetric');
    end
end


%% fit
tic
for idx = 1:3
    for jdx = 1:3
        x = ita_frequency_dependent_time_window(Ys(idx,jdx),[0.6 0.7; 0.2 0.3; 0.05 0.06], [1000 3000], 'symmetric');
        Ys_fit(idx,jdx) = ita_audio2zpk_rationalfit(x,'degree',80,'freqRange',[30 8000]);
    end
end

for idx = 1:3
    for jdx = 1:3
        x = ita_frequency_dependent_time_window(Yr(idx,jdx),[0.6 0.7; 0.2 0.3; 0.05 0.06], [1000 3000], 'symmetric');
        Yr_fit(idx,jdx) = ita_audio2zpk_rationalfit(Yr(idx,jdx),'degree',80,'freqRange',[30 8000],'mode','log');
    end
end
toc

%% write
folder = 'E:\pdi_daten\MATLAB\TPA-TPS';

ita_write(Ys_fit,[folder filesep 'Ys_fit.ita'])
ita_write(Yr_fit,[folder filesep 'Yr_fit.ita'])

%% load
folder = 'E:\pdi_daten\MATLAB\TPA-TPS';

Ys_fit = load([folder filesep 'Ys_fit.ita'],'-mat');
Yr_fit = ita_read([folder filesep 'Yr_fit.ita']);

%%

for idx = 1:3
    for jdx = 1:3
        Ys_test(idx,jdx) = Ys_fit(idx,jdx)';% / Ys(idx,jdx);
        Yr_test(idx,jdx) = Yr_fit(idx,jdx)';% / Yr(idx,jdx);
    end
end


%% coupling
tic
K = Ys / (Yr + Ys);
toc

%%
% K_fit = Ys_fit / (Yr_fit + Ys_fit);
for idx = 1:3
    for jdx = 1:3
%         K_fit(idx,jdx).channelNames{1} = ['K' num2str(idx) num2str(jdx)];
        K(idx,jdx).channelNames{1}     = ['K' num2str(idx) num2str(jdx)];
    end
end

%%
K_test = Ys_test / (Yr_test + Ys_test);


%%
for idx = 1:3
    for jdx = 1:3
        K(idx,jdx).channelNames{1} = ['K' num2str(idx) num2str(jdx)];
    end
end
ita_plot_spkphase(merge(K))


%%
res1 = a_mat * c;
ita_plot_spk(merge(res1),'nodb','ylim',[-5 5])

res2 = a_mat * b_mat;
ita_plot_spk(merge(res2),'nodb','ylim',[-5 5])

%% coupling
Ys = [1 0; 0, 1];
Yr = [0.9 0.1; 0.1 0.9];

Ys_mat = [1*a, 0*a; 0*a, 1*a];
Yr_mat = [.9*a, .1*a; .1*a, .9*a];


K = Ys / (Yr + Ys)
for idx = 1:3
    for jdx = 1:3
        Yr(idx,jdx) = ita_extract_dat(ita_read([folder filesep 'y' num2str(idx) num2str(jdx) '.ita']),fft_degree,'symmetric');
    end
end


K_mat = Ys_mat / (Yr_mat + Ys_mat)



%%
ccx

%% mli raw TP with hammer

clear TP
for foot_idx = 1:3
    for idx = [1]
        data = ita_read(['\\verdi\scratch\lievens\pdi\steel_cones\tps\Yc_foot' num2str(foot_idx) '_MDF_25e-3__pvc_run' num2str(idx) '.ita']);
        
        F = ita_time_window(data.ch(1),[0.02 0 0.5 0.7],'time');
        p = data.ch(2:6);
        TP = p/F;
        
    end
    res(foot_idx) = ita_time_window(TP,[0.9 1.1],'time');
    
end




%% mli
data = ita_read('Z:\lievens\pdi\steel_cones\Fvp__4-20Hz_expsweep_fft20_8WashT.ita');
a = data.ch([2 3 1]);
p = data.ch([7:11]);
F = data.ch(4:6);
% imp = F.ch(1)*0;
% imp.timeData(:,1) = imp.nSamples;
% F = merge(F,imp);

%% OPA
TP = ita_otpa(p,F,'blocksize',4096*8,'overlap',0.5,'tol',0.01,'window',@hann);
TPopa = merge(TP.ch(1));
TPopa.plot_spk

x = ita_time_window(TPopa,[0.002 0 double(TPopa.trackLength)*[0.9 0.99]],'time');
x.plot_spk

%% pre-white spectrum
TP = ita_otpa(p,F,'blocksize',4096*8,'overlap',0.5,'tol',0.1,'window',@hann,'prewhite');
for idx = 1:TP(1).nChannels
    TPopa(idx) = merge(TP.ch(idx));
end
% TPopa(2).plot_spk
% x = ita_time_window(TPopa,[0.002 0 double(TPopa.trackLength)*[0.5 0.99]],'time');
% x.plot_spk

%% comparison
close all
idx = 1;
TP(idx).plot_spk('ylim',[-40 0]);
x = merge(res.ch(idx));
x.plot_spk('ylim',[-40 0]);


%% synthesis
for pidx = 1:numel(TP)
    p_test(pidx) = ita_sum(F * ita_extend_dat(TP(pidx),a.nSamples,'symmetric'));
end
p_test = merge(p_test);



%% hammer messung
data_hammer = ita_read('Z:\lievens\pdi\steel_cones\Yc_foot1_MDF_25e-3__pvc_run1.ita');
data_hammer = ita_time_shift(data_hammer,'30dB');
data_hammer = ita_time_shift(data_hammer,0.025,'time');
data_hammer = ita_time_window(data_hammer,[0.02 0],'time');
data_hammer = ita_frequency_dependent_time_window(data_hammer,[0.5 1; 0.05 0.1],500);

res = ita_divide_spk( data_hammer.ch([1:3 5:12]),data_hammer.ch(4),'regularization',[20 4000]);

TPorig = ita_divide_spk(res,res.ch(4),'regularization',[20 4000]);
TPorigF = TPorig.ch(7:11);
TPorigF.plot_spk

%% synthesis with orig
for pidx = 1:numel(TP)
    p_test_orig(pidx) = ita_sum(F * ita_extend_dat(TPorigF.ch(pidx),a.nSamples,'symmetric'));
end
p_test_orig = merge(p_test_orig);


%% OPA with synthesis data
TP = ita_otpa(p_test_orig,F,'blocksize',4096,'overlap',0.5,'tol',0.00000000001,'window',@hann);
TPopa = merge(TP.ch(1))
TPopa.plot_spk


%% OPA with randomized phase
TPrand = ita_otpa(ita_randomize_phase(p),ita_randomize_phase(F),'blocksize',4096*8,'overlap',0.5,'tol',0.00000000001,'window',@hann);
TPoparand = merge(TPrand.ch(1))
TPoparand.plot_spk


%% ************************************************************************
%% Excitation Signal
F0 = itaAudio();
F0.samplingRate = 100;
F0.time = zeros(100,1);
F0.time = 0.2*sin(2*F0.timeVector* pi);
F0.time(1) = 1;
F0.time(20) = -1;
n = itaAudio; n.trackLength = 15;
n.time = (n.timeVector / n.trackLength)*50 + 20; 
% n.time = 500 * n.time * 0;


F1 = F0;
F1.time = sin(1*F1.timeVector*2*pi) + 0.3 * sin(2*F1.timeVector*2*pi) + cos(4*F1.timeVector*2*pi);
n1 = itaAudio; n1.trackLength = double(n.trackLength);
n1.time = (n.timeVector / n1.trackLength)*1300 + 100+ 20*sin(40*n.timeVector/double(n1.trackLength) * 2 * pi); 

excitationsignal(1) = ita_normalize_dat( ita_iem_force_transform (F0, n,'oversample',100,'periodic',true));
excitationsignal(2) = 0.1 * ita_normalize_dat( ita_iem_force_transform (F1, n1)); 

%%
amp = 1;
sr = n.samplingRate;
nSamples = n1.samplingRate * double(n1.trackLength);
freq_vec = [20 10000];
stop_margin = 1;
NTIcoeffs = [1 0.2];

% Generating a long MLS signal
mls_raw = ita_generate('mls', amp, sr, 20);

% Performing a hole in the MLS signal
mls = mls_raw;
mls.timeData(1:30000) = 0;

% Sweep and compensation
sweep = amp*ita_generate('linsweep',freq_vec,0.1,sr,nSamples);
sweep = ita_extend_dat(sweep,mls.nSamples);
% sweep = ita_time_shift(sweep,stop_margin/4);
sweep.signalType = 'energy'; % because acts as a filter

silencesweep = mls*sweep;

silencesweep = ita_extend_dat(silencesweep,nSamples);


% Silence Sweep
excitationsignal(3) = ita_normalize_dat(silencesweep);


%% expsweep




%% playback
test = merge(excitationsignal);

%%
ita_portaudio(test,'OutputChannels',[3 4 1])

%%
ita_portaudio(test.ch(3),'OutputChannels',[1])

%% MS
MS = ita_measurement

%% MS messung
ex = ita_amplify(  MS.excitation ,'-15dB');
ex.trackLength = 10;
ex = merge(ex,0.5*ita_time_shift(ex,3,'time'),ita_time_shift(ex,6,'time'));

ex = ita_time_shift(ex,1,'time');

%%
ita_portaudio(ex,'OutputChannels',[3 4 1]);

%%
ita_portaudio(ex.ch(1),'OutputChannels',[1]);


%% test motor
out_ch = [3 2];

motor_sweep = ita_generate('expsweep',[5000 17000],0.1,sr,nSamples);

ita_portaudio(motor_sweep,'OutputChannels',out_ch)

%% folder
folder = '/Users/pascaldietrich/MATLAB/BOSCH - auralizationBox otpa';
cd (folder)


%% auswertung
F_ch = 1:3;
p_ch = 13:15;
TP = ita_otpa(data.ch(p_ch),data.ch(F_ch),'blocksize',4096,'overlap',0.5,'tol',0.00000000001,'window',@hann);

%% deconv
ir = ita_divide_spk(data,data.ch(14),'regularization',[20 10000]);
ir_win = ita_time_window(ir,[0.5 1],'symmetric');

%% ls sweep hexaeder 
ls_sweep = ita_generate('expsweep',[20 17000],0.1,19);
ita_portaudio( ita_amplify(   ls_sweep ,'-20dB'), 'OutputChannels', 3);



