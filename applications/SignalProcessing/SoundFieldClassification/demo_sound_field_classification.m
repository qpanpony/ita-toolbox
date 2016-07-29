% Demo Sound Field Analysis

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

clc
%% Realtime
%ita_preferences; % Select sound device

%% BTE
[isfi, isfd, isfc, isfa] = ita_sfa_run('realtime','autocompphase',false,'sfcmethod',5,'blocksize',2^12,'sensorspacing',0.014,'channels',[1 2],'redrawframes',1,'compensate',false,'playback',false,'audiobuffersize',3,'fraction',3,'flimit',[100 10000],'bandidplot',[6 20],'direct_plot',true,'plot_sfdspace',true,'t_c',1,'autocompamp',true,'autocompphase',true,'interactive',true,'ampmminit',10^(-0.2/20),'gdelayinit',10e-6,'t_autocalib',0);

%% ITC
% [isfi, isfd, isfc, isfa] = ita_sfa_run('realtime','blocksize',2^12,'blocks',8,'sensorspacing',0.006,'channels',[3 4],'redrawframes',1,'compensate',false,'playback',false,'audiobuffersize',3,'autocalibrate',false,'fraction',0,'flimit',[200 4000],'bandidplot',1);