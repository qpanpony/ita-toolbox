%%% Verification of the sound field classification by a point source in a reverberant room

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


ccx;
%% sfc_settings
t_c = 1;

mode = '3d'; %'3d' 1d or 3d mode (hearing aid or sound field mic)

sfc_settings = {'sfcmethod',6, 'sfdmode',2,'blocksize',2^12,'overlap',0.75,'direct_plot',false,'compensate',false,'fraction',3,'t_c',t_c,'flimit',[20 20000],'psdbands',false};
sfc_settings2 = {'sfcmethod',5, 'sfdmode',2,'blocksize',2^12,'overlap',0.75,'direct_plot',false,'compensate',false,'fraction',3,'t_c',t_c,'flimit',[20 20000],'psdbands',false};
nReps = 3; % Number of repetition of each setting;
d_sf_mic = 0.01; % diameter of sound field mic;
    timestamp = datestr(now,30);
%hrtfName = ['HA_HRTF_d_sf_mic_0.01.ita'];

%% Load HRTF
% hrtf = ita_read(hrtfName);
% hrtf.directions = build_search_database(hrtf.directions);
% d_rep = str2double(hrtf.comment);

%% Room settings
%L_r_in_rh = 0.1:0.5:3;
L_r_in_rh = logspace(log10(0.005),log10(20),15);
%L_r_in_rh = logspace(log10(1),log10(20),5);

r_in_rh = L_r_in_rh;
DRR = 0;
x = [5 4 3].*3; % Room dimensions
V = x(1)*x(2)*x(3);
S = 2*x(1)*x(2) + 2*x(1)*x(3) + 2*x(2)*x(3);

T = 1;
rh = (0.057 * sqrt(V/T)); % Hallradius

r_l = r_in_rh .* rh;

%% Create HRTF
 n_d = 15;
 resolution = 10;
 d = r_l;
 d(d>5) = [];
 d = sort([d logspace(log10(d_sf_mic),log10(5),max(2,n_d-numel(d)))]);
 d(d>5) = [];
switch mode
    case '1d'
        [hrtf, d_rep] = ita_analytic_directivity_hearing_aid(d_sf_mic,d,resolution);
    case '3d'
        [hrtf, d_rep] = ita_analytic_directivity_soundfield_mic(d_sf_mic,d,resolution);
end
hrtf.directions = build_search_database(hrtf.directions);

%% Simulate
% try
%     matlabpool close force;
% end
% matlabpool local;

switch mode
    case '1d'
        sfc_fun = @ita_sfa_run;
    case '3d'
        sfc_fun = @ita_sfa_3D;
end

%%sfcData = zeros(numel(L_r_in_rh),4,nReps);
E = zeros(numel(L_r_in_rh),nReps);
wb = itaWaitbar([numel(L_r_in_rh), nReps]);
sfc_temp = itaResultTimeFreq([numel(L_r_in_rh), nReps]);
for idx = 1:numel(L_r_in_rh)
    r_in_rh = L_r_in_rh(idx);
    
    
    r = r_in_rh * rh;
%     hrtfName = ['SoundFieldMic_r_' num2str(d_sf_mic) '_d_' num2str(r) '_res_' num2str(res) '.ita'];
%     
%     if exist(hrtfName,'file')
%         hrtf = ita_read(hrtfName);
%         d_rep = str2double(hrtf.comment);
%     else
%         [hrtf, d_rep] = ita_analytic_directivity_soundfield_mic(d_sf_mic,r,res);
%         ita_write(hrtf,hrtfName);
%     end
    
    for idRep = 1:nReps
        wb.inc;
        
        %r_in_rh = 1./(10.^(DRR./20))
        
        
        %% generate RIR
        dynamic = 120+max(0,20*log10(r));
        IR = ita_stochastic_room_impulse_response('HRTF',hrtf, 'V', V ,'S', S ,'T60', T, 'sourceposition',itaCoordinates([r,pi/2,0],'sph'),'max_reflections_per_second',1000*max(1,10*log10(r)),'dynamic',dynamic,'first_reflection',-1);
        IR_list(idx,idRep) = IR;
        %% Generate input signal
        sourcesignal = ita_generate('noise',1,44100,19);
        signal = ita_convolve(sourcesignal,IR);
        
        %E(idx,idRep) = mean(signal.rms).^2;
        
        %% Sound Field Classification
        [~, ~, sfc_temp(idx,idRep), ~] = sfc_fun(signal,sfc_settings{:},'sensorspacing', d_rep);
        sfc_temp(idx,idRep).time = sfc_temp(idx,idRep).time(round(sfc_temp(idx,idRep).nSamples/3):round(sfc_temp(idx,idRep).nSamples*2/3) ,:,:);
        
        [~, ~, sfc2(idx,idRep), ~] = sfc_fun(signal,sfc_settings2{:},'sensorspacing', d_rep);
         sfc2(idx,idRep).time = sfc2(idx,idRep).time(round(sfc2(idx,idRep).nSamples/3):round(sfc2(idx,idRep).nSamples*2/3) ,:,:);
        
        %sfc.plot_dat;
        
        
    end
end

close(wb);
save(['test_sfc_3d_data_' datestr(now,30) '.mat'])

% try
%     matlabpool close force;
% end

%% %%%%%%%%% SFC Mode 6 %%%%%%%%%%%%%%%%%%%%%%%
%% Post processing for sfc-6
evalF = [400 1200];

evalIdx = sfc_temp(1).freqVector >= min(evalF) & sfc_temp(1).freqVector <= max(evalF);
clear sfcData
for idx = 1:size(sfc_temp,1)
    for idRep = 1:size(sfc_temp,2)
        sfcData(idx,:,idRep) = squeeze(nanmean(nanmean(sfc_temp(idx,idRep).time(:,evalIdx,:),2),1));
    end
end
sfcData = sfcData;
sfcData = max(sfcData,0);
sfcData(sfcData <= 0) = 0.000000001;
sfcData = min(sfcData,1);
sfcStd = nanstd(sfcData,[],3);
sfcData = nanmean(sfcData,3);
sfcData = bsxfun(@rdivide,sfcData,sum(sfcData,2));

E = mean(E,2);

idrh = find(L_r_in_rh >= 1,1,'first');
E = E ./ E(idrh);


%% Plot absolute distribution for sfc-6
%figure();
%plot(L_r_in_rh,sfcData(:,1:4))

%figure();
%plot(L_r_in_rh,10*log10(sfcData(:,1:4)))
plotfun = @semilogx;
calcfun = @(x) 10*log10(x);

f = 1000;
c = 340;
L_r_in_rh_theo = L_r_in_rh * 0.8;
r_theo = L_r_in_rh_theo * rh;
k = 2*pi*f/c;


theo_w_diff = 0.5 * ones(size(L_r_in_rh_theo));
theo_w_dir = theo_w_diff ./ L_r_in_rh_theo.^1;
theo_w_reactive = theo_w_dir ./ (k.*r_theo.^(1));

theo_w = [theo_w_dir; theo_w_diff; theo_w_reactive];

W = sum(theo_w,1).';

fgh1 = figure();
totE = bsxfun(@times,(W.^1),sfcData);
stdE = bsxfun(@times,(W.^1),sfcStd);

relE = sfcData.^1;
CO = get(gca,'ColorOrder');

plotE = totE;

plotfun(L_r_in_rh,calcfun((plotE(:,1))),'b-+');
hold all;
% plotfun(L_r_in_rh,calcfun(plotE(:,1)+stdE(:,1)),'b:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,1)-stdE(:,1)),'b:+');


plotfun(L_r_in_rh,calcfun((plotE(:,2))),'g-o')
% plotfun(L_r_in_rh,calcfun(plotE(:,2)+stdE(:,2)),'g:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,2)-stdE(:,2)),'g:+');

plotfun(L_r_in_rh,calcfun((plotE(:,3))),'r-d')
% plotfun(L_r_in_rh,calcfun(plotE(:,3)+stdE(:,3)),'r:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,3)-stdE(:,3)),'r:+');

plotfun(L_r_in_rh,calcfun((plotE(:,4))),'k-*')
% plotfun(L_r_in_rh,calcfun(plotE(:,4)+stdE(:,4)),'k:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,4)-stdE(:,4)),'k:+');

set(gca,'ColorOrder',circshift(CO,-4));



rel_theo_w = bsxfun(@rdivide,theo_w,sum(theo_w,1));


plotW = theo_w.';

plotfun(L_r_in_rh,calcfun(plotW(:,1)),'b--+');
plotfun(L_r_in_rh,calcfun(plotW(:,2)),'g--o');
plotfun(L_r_in_rh,calcfun(plotW(:,3)),'r--d');

legend({'Free','Diffuse','Reactive','Noise'});
xlabel('Distance  r/r_c');
ylabel('Normalized Sound Field Energy');

xlim([min(L_r_in_rh)*0.9 max(L_r_in_rh)*1.1]);
ylim([-40 40]);

ita_savethisplot_gle('fileName',[mfilename '_sfc6_abs'],'output','pdf','template','A5','legend_position','tr')

%% Plot relative distribution for sfc-6
%figure();
%plot(L_r_in_rh,sfcData(:,1:4))

%figure();
%plot(L_r_in_rh,10*log10(sfcData(:,1:4)))
plotfun = @semilogx;
calcfun = @(x) x;

fgh1 = figure();
totE = bsxfun(@times,(E.^0.6),sfcData);
stdE = bsxfun(@times,(E.^0.6),sfcStd);

relE = sfcData.^1;
CO = get(gca,'ColorOrder');

plotE = relE;

plotfun(L_r_in_rh,calcfun((plotE(:,1))),'b-+');
hold all;
% plotfun(L_r_in_rh,calcfun(plotE(:,1)+stdE(:,1)),'b:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,1)-stdE(:,1)),'b:+');


plotfun(L_r_in_rh,calcfun((plotE(:,2))),'g-o')
% plotfun(L_r_in_rh,calcfun(plotE(:,2)+stdE(:,2)),'g:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,2)-stdE(:,2)),'g:+');

plotfun(L_r_in_rh,calcfun((plotE(:,3))),'r-d')
% plotfun(L_r_in_rh,calcfun(plotE(:,3)+stdE(:,3)),'r:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,3)-stdE(:,3)),'r:+');

plotfun(L_r_in_rh,calcfun((plotE(:,4))),'k-*')
% plotfun(L_r_in_rh,calcfun(plotE(:,4)+stdE(:,4)),'k:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,4)-stdE(:,4)),'k:+');

set(gca,'ColorOrder',circshift(CO,-4));

f = 1000;
c = 340;
L_r_in_rh_theo = L_r_in_rh * 0.8;
r_theo = L_r_in_rh_theo * rh;
k = 2*pi*f/c;


theo_w_diff = 0.5 * ones(size(L_r_in_rh_theo));
theo_w_dir = theo_w_diff ./ L_r_in_rh_theo.^1;
theo_w_reactive = theo_w_dir ./ (k.*r_theo.^(1));

theo_w = [theo_w_dir; theo_w_diff; theo_w_reactive];

rel_theo_w = bsxfun(@rdivide,theo_w,sum(theo_w,1));


plotW = rel_theo_w.';

plotfun(L_r_in_rh,calcfun(plotW(:,1)),'b--+');
plotfun(L_r_in_rh,calcfun(plotW(:,2)),'g--o');
plotfun(L_r_in_rh,calcfun(plotW(:,3)),'r--d');

legend({'Free','Diffuse','Reactive','Noise'});
xlabel('Distance  r/r_c');
ylabel('Normalized Sound Field Energy');

xlim([min(L_r_in_rh)*0.9 max(L_r_in_rh)*1.1]);
%ylim([0 2.5]);

ita_savethisplot_gle('fileName',[mfilename '_sfc6_rel'],'output','pdf','template','A5','legend_position','tr')

%% %%%%%%%%% SFC Mode 5 %%%%%%%%%%%%%%%%%%%%%%%
%% Post processing for sfc-5
sfc_temp = sfc2;
evalF = [100 2000];

evalIdx = sfc_temp(1).freqVector >= min(evalF) & sfc_temp(1).freqVector <= max(evalF);
clear sfcData
for idx = 1:size(sfc_temp,1)
    for idRep = 1:size(sfc_temp,2)
        sfcData(idx,:,idRep) = squeeze(nanmean(nanmean(sfc_temp(idx,idRep).time(:,evalIdx,:),2),1));
    end
end
sfcData = sfcData;
sfcData = max(sfcData,0);
threshold = 0.000001;
sfcData = max(sfcData,threshold);

sfcData = min(sfcData,1);
sfcStd = nanstd(sfcData,[],3);
sfcData = nanmean(sfcData,3);
%sfcData = bsxfun(@rdivide,sfcData,sum(sfcData,2));

E = mean(E,2);

idrh = find(L_r_in_rh >= 1,1,'first');
E = E ./ E(idrh);


%% Plot absolute distribution for sfc-5
%figure();
%plot(L_r_in_rh,sfcData(:,1:4))


%figure();
%plot(L_r_in_rh,10*log10(sfcData(:,1:4)))
plotfun = @semilogx;
calcfun = @(x) 10*log10(x);

f = 1000;
c = 340;
L_r_in_rh_theo = L_r_in_rh * 0.8;
r_theo = L_r_in_rh_theo * rh;
k = 2*pi*f/c;


theo_w_diff = 0.5 * ones(size(L_r_in_rh_theo));
theo_w_dir = theo_w_diff ./ L_r_in_rh_theo.^1;
theo_w_reactive = theo_w_dir ./ (k.*r_theo.^(1));

%theo_w_dir = theo_w_dir-theo_w_reactive;

theo_w = [theo_w_dir; theo_w_diff; theo_w_reactive];

W = sum(theo_w,1).';

fgh1 = figure();
totE = bsxfun(@times,(W.^1),sfcData);
stdE = bsxfun(@times,(W.^1),sfcStd);

relE = sfcData.^1;
CO = get(gca,'ColorOrder');

plotE = totE;

plotfun(L_r_in_rh,calcfun((plotE(:,1))),'b-+');
hold all;
% plotfun(L_r_in_rh,calcfun(plotE(:,1)+stdE(:,1)),'b:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,1)-stdE(:,1)),'b:+');


plotfun(L_r_in_rh,calcfun((plotE(:,2))),'g-o')
% plotfun(L_r_in_rh,calcfun(plotE(:,2)+stdE(:,2)),'g:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,2)-stdE(:,2)),'g:+');

plotfun(L_r_in_rh,calcfun((plotE(:,3))),'r-d')
% plotfun(L_r_in_rh,calcfun(plotE(:,3)+stdE(:,3)),'r:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,3)-stdE(:,3)),'r:+');

plotfun(L_r_in_rh,calcfun((plotE(:,4))),'k-*')
% plotfun(L_r_in_rh,calcfun(plotE(:,4)+stdE(:,4)),'k:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,4)-stdE(:,4)),'k:+');

set(gca,'ColorOrder',circshift(CO,-4));



rel_theo_w = bsxfun(@rdivide,theo_w,sum(theo_w,1));


plotW = theo_w.';

plotfun(L_r_in_rh,calcfun(plotW(:,1)),'b--+');
plotfun(L_r_in_rh,calcfun(plotW(:,2)),'g--o');
plotfun(L_r_in_rh,calcfun(plotW(:,3)),'r--d');

legend({'Free','Diffuse','Reactive','Noise'});
xlabel('Distance  r/r_c');
ylabel('Normalized Sound Field Energy');

xlim([min(L_r_in_rh)*0.9 max(L_r_in_rh)*1.1]);
%ylim([0 2.5]);

ita_savethisplot_gle('fileName',[mfilename '_sfc5_abs'],'output','pdf','template','A5','legend_position','tr')

%% Plot relative distribution for sfc-5
%figure();
%plot(L_r_in_rh,sfcData(:,1:4))

%figure();
%plot(L_r_in_rh,10*log10(sfcData(:,1:4)))
plotfun = @semilogx;
calcfun = @(x) x;

fgh1 = figure();
totE = bsxfun(@times,(E.^0.5),sfcData);
stdE = bsxfun(@times,(E.^0.5),sfcStd);

relE = sfcData.^1;
CO = get(gca,'ColorOrder');

plotE = relE;

plotfun(L_r_in_rh,calcfun((plotE(:,1))),'b-+');
hold all;
% plotfun(L_r_in_rh,calcfun(plotE(:,1)+stdE(:,1)),'b:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,1)-stdE(:,1)),'b:+');


plotfun(L_r_in_rh,calcfun((plotE(:,2))),'g-o')
% plotfun(L_r_in_rh,calcfun(plotE(:,2)+stdE(:,2)),'g:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,2)-stdE(:,2)),'g:+');

plotfun(L_r_in_rh,calcfun((plotE(:,3))),'r-d')
% plotfun(L_r_in_rh,calcfun(plotE(:,3)+stdE(:,3)),'r:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,3)-stdE(:,3)),'r:+');

plotfun(L_r_in_rh,calcfun((plotE(:,4))),'k-*')
% plotfun(L_r_in_rh,calcfun(plotE(:,4)+stdE(:,4)),'k:+');
% plotfun(L_r_in_rh,calcfun(plotE(:,4)-stdE(:,4)),'k:+');

set(gca,'ColorOrder',circshift(CO,-4));

f = 1000;
c = 340;
L_r_in_rh_theo = L_r_in_rh * 0.8;
r_theo = L_r_in_rh_theo * rh;
k = 2*pi*f/c;


theo_w_diff = 0.5 * ones(size(L_r_in_rh_theo));
theo_w_dir = theo_w_diff ./ L_r_in_rh_theo.^1;
theo_w_reactive = theo_w_dir ./ (k.*r_theo.^(1));

theo_w = [theo_w_dir; theo_w_diff; theo_w_reactive];

rel_theo_w = bsxfun(@rdivide,theo_w,sum(theo_w,1));


plotW = rel_theo_w.';

plotfun(L_r_in_rh,calcfun(plotW(:,1)),'b--+');
plotfun(L_r_in_rh,calcfun(plotW(:,2)),'g--o');
plotfun(L_r_in_rh,calcfun(plotW(:,3)),'r--d');

legend({'Free','Diffuse','Reactive','Noise'});
xlabel('Distance  r/r_c');
ylabel('Normalized Sound Field Energy');

xlim([min(L_r_in_rh)*0.9 max(L_r_in_rh)*1.1]);
%ylim([0 2.5]);

ita_savethisplot_gle('fileName',[mfilename '_sfc5_rel'],'output','pdf','template','A5','legend_position','tr')
