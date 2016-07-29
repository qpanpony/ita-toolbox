ccx;

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Settings
prefix = 'BBExample_SFD_HA_M';
sfa = @ita_sfa_run;
sfcm = 6;
settings = {'sfcmethod',sfcm, 'sfdmode',2,'blocksize',2^10,'overlap',0.75,'sensorspacing',0.014,'direct_plot',false,'compensate',false,'fraction',3,'t_c',.5,'flimit',[100 10000],'psdbands',false};
idx = 0;
bbfontscale = 1.15;
addpath(ita_preferences('SFC_AudioFolder'));
%% Basic Sound Field Sequence - IDEAL
idx = idx+1;
signal = ita_read('IdealSoundFields_IDEALHA_HRTF_BTE_non_compensated.ita');
signal = signal.ch([1 2]);


[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:},'t_c',0.1);

fname{idx} = 'BSFS_IDEAL';

%% Basic Sound Field Sequence - Hoertnix
idx = idx+1;
signal = ita_read('IdealSoundFields_Hoertnix_HRTF_BTE_diffuse_compensated.ita');
signal = signal.ch([1 2]);

[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:},'t_c',0.1);

fname{idx} = 'BSFS_Hoertnix_nocomp';

%% Basic Sound Field Sequence - Hoertnix
idx = idx+1;
signal = ita_read('IdealSoundFields_Hoertnix_HRTF_BTE_non_compensated.ita');
signal = signal.ch([1 2]);

[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:},'t_c',0.1);

fname{idx} = 'BSFS_Hoertnix_comp';

%% Basic Sound Field Sequence - HA
idx = idx+1;
signal = ita_read('IdealSoundFields_HA_HRTF_BTE_diffuse_compensated.ita');
signal = signal.ch([1 2]);

[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:},'t_c',0.1);

fname{idx} = 'BSFS_HA_nocomp';

%% Basic Sound Field Sequence - HA
idx = idx+1;
signal = ita_read('IdealSoundFields_HA_HRTF_BTE_non_compensated.ita');
signal = signal.ch([1 2]);

[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:},'t_c',0.1);

fname{idx} = 'BSFS_HA_comp';

%% Noise in semi-FF
idx = idx+1;
load('Noise in FF.mat');
signal = Messung5.ch([1 2]);
ampf = signal.rms;
ampf = ampf(2)./ampf(1);
%signal = ita_amplify(signal,[ampf 1]);
clear Messung*;


[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:});

fname{idx} = 'NoiseSemiFF';

%% Speech in semi-FF
idx = idx + 1;
load('Front Speech in FF.mat');
signal = Messung4.ch([1 2]);
ampf = signal.rms;
ampf = ampf(2)./ampf(1);
%signal = ita_amplify(signal,[ampf 1]);
clear Messung*;

[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:});

fname{idx} = 'SpeechSemiFF';

%% Near Speech in Seminarroom
%SpeechinSeminarroom_1_9m
idx = idx + 1;
load('SpeechinSeminarroom_1_9m.mat');
signal = Messung17_Female1.ch([1 2]);
ampf = signal.rms;
ampf = ampf(2)./ampf(1);
%signal = ita_amplify(signal,[ampf 1]);
clear Messung*;

[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:});

fname{idx} = 'NearSpeechSeminarRoom';

%% Far Speech in Seminarroom
%SpeechinSeminarroom_4_7m
idx = idx + 1;
load('SpeechinSeminarroom_4_7m.mat');
signal = Messung21_Female1.ch([1 2]);
ampf = signal.rms;
ampf = ampf(2)./ampf(1);
%signal = ita_amplify(signal,[ampf 1]);
clear Messung*;

[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:});
fname{idx} = 'FarSpeechSeminarRoom';

%% Speech in Vorraum Hallraum (Quelle nah)
idx = idx+1;
speech = ita_read('Lang1.wav');
speech = ita_append(ita_generate('emptydat',44100,16),ita_extract_dat(speech.ch(1),20));

TF = ita_read('vorraum_hallraum_pos1_TF.ita');
TF = ita_time_window(TF.ch([1 2]),[0.6 0.8],'crop');

signal = ita_normalize_dat(ita_convolve(speech,TF));
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:});

fname{idx} = 'NearSpeechVorraumHallraum';

%% Speech in Vorraum Hallraum (Quelle fern)
idx = idx+1;
speech = ita_read('Lang1.wav');
speech = ita_append(ita_generate('emptydat',44100,16),ita_extract_dat(speech.ch(1),20));

TF = ita_read('vorraum_hallraum_pos3_TF.ita');
TF = ita_time_window(TF.ch([1 2]),[0.6 0.8],'crop');

signal = ita_normalize_dat(ita_convolve(speech,TF));
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:});

fname{idx} = 'FarSpeechVorraumHallraum';

%% Windnoise
idx = idx + 1;
signal = ita_read('windnoise.ita');

[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfa(signal,settings{:});
fname{idx} = 'Windnoise';

%% Plot
for idx = 1:numel(fname)
    % isfd(idx).plot_dat;
    % ylim([0 1]);
    % title('');
    % ita_savethisplot_gle('fileName',['BBExampleSFD' fname{idx}],'output','png pdf');
    
    %for idy = 1:4
    %    isfc(idx).ch(idy).image;
    %    title('');
    %    ita_savethisplot_gle('fileName',['BBExample_SFD_M' int2str(2) '_SFC_M' int2str(2) '_' fname{idx} 'freqDep_SFC' isfc(idx).channelNames{idy} ],'output','png pdf','template','stackedimage_present');
    %end
    isfc(idx).mean.plot_dat;
    ita_plottools_reduce();
    ylim([-0.01 1.01]);
    drawnow;
    title('');
    ita_savethisplot_gle('fileName',[prefix int2str(2) '_SFC_M' int2str(sfcm) '_' fname{idx} '_SFC'],'output','png pdf','comment',mfilename,'tex',1,'texincprefix','graphics/','template','A5');
    
    
    close all;
    
    cNames = char(isfc(idx).channelNames);
    isfc(idx).channelNames = cellstr(cNames(:,1:2));
    isfc(idx).image('stacked');
    title('');
    set(gca,'CLim',[0 1])
    colormap(ita_colormap);
    drawnow;
    %ita_savethisplot_gle('fileName',['BBExample_SFD_M' int2str(2) '_SFC_M' int2str(2) '_' fname{idx} 'freqDep_SFC'],'output','png pdf','comment',mfilename);
    ita_savethisplot_gle('fileName',[prefix int2str(2) '_SFC_M' int2str(sfcm) '_' fname{idx} '_SFC_FD'],'output','png pdf','comment',mfilename,'tex',1,'texincprefix','graphics/','template','A5');
    
    
    
    % isfa(idx).plot_dat;
    % ylim([-30 30]);
    % title('');
    % ita_savethisplot_gle('fileName',['BBExampleSFA' fname{idx}],'output','png pdf');
    close all;
    
    
end
