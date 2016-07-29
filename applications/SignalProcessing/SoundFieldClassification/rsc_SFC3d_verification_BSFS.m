ccx;

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Settings
settings = {'sfcmethod',6, 'sfdmode',2,'blocksize',2^8,'overlap',0.75,'sensorspacing',0.014,'direct_plot',false,'compensate',false,'fraction',3,'t_c',.5,'flimit',[100 10000],'psdbands',false};
idx = 0;
bbfontscale = 1.15;
addpath(ita_preferences('SFC_AudioFolder'));

sfcfunc = @ita_sfa_3D;
prefix = 'Example_3D';
mode = '3d';
d_rep = 0.0115;

%% Create HRTF
resolution = 2;
d = 2;
d_sf_mic = 0.01;
switch mode
    case '1d'
        [hrtf, d_rep] = ita_analytic_directivity_hearing_aid(d_sf_mic,d,resolution);
    case '3d'
        [hrtf, d_rep] = ita_analytic_directivity_soundfield_mic(d_sf_mic,d,resolution);
end
hrtf.directions = build_search_database(hrtf.directions);

ita_write(hrtf,'HRTF_for_BSFS_SFMic_ideal.ita','overwrite')



%% Create BSFS
BSFS = ita_sfm_all('HRTF',hrtf,'audio',ita_generate('noise',1,44100,17));
% save
ita_write(BSFS,'BSFS_SFMic_ideal.ita','overwrite')

%% Basic Sound Field Sequence - SF_MIC
% idx = idx+1;
% disp(idx);
% signal = ita_read('BSFS_SFMic_ideal.ita');
% 
% 
% [isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = sfcfunc(signal,settings{:},'t_c',0.2,'sensorspacing',d_rep);
% 
% fname{idx} = 'BSFS_IDEAL_SFMIC';
% 
% 
% %% save results
% save([prefix '.mat']);
% 
% %% Plot
% disp('Plots');
% for idx = 1:numel(fname)
%     % isfd(idx).plot_dat;
%     % ylim([0 1]);
%     % title('');
%     % ita_savethisplot_gle('fileName',['BBExampleSFD' fname{idx}],'output','png pdf');
%     
%     %for idy = 1:4
%     %    isfc(idx).ch(idy).image;
%     %    title('');
%     %    ita_savethisplot_gle('fileName',['BBExample_SFD_M' int2str(2) '_SFC_M' int2str(2) '_' fname{idx} 'freqDep_SFC' isfc(idx).channelNames{idy} ],'output','png pdf','template','stackedimage_present');
%     %end
%     plotname = [prefix '_SFD_M' int2str(2) '_SFC_M' int2str(5) '_' fname{idx} '_SFC2'];
%     if isempty(dir(plotname))
%         
%         evalF = [400 4000];
% 
%         evalIdx = isfc(idx).freqVector >= min(evalF) & isfc(idx).freqVector <= max(evalF);
%         plotsfc = isfc(idx);
%         plotsfc.time = plotsfc.time(:,evalIdx,:);
%         plotsfc.freqVector = plotsfc.freqVector(evalIdx);
%         
%         plotsfc.mean.plot_dat;
%         pause(2);
%         %ita_plottools_reduce();
%         ylim([-0.5 1.5]);
%         drawnow;
%         title('');
%                 
%         ita_savethisplot_gle('fileName',plotname,'output','png pdf svg','comment',mfilename,'template', 'line_1column','font_scale',bbfontscale);
%         close all;
%     end
%     
%     plotname = [prefix '_SFD_M' int2str(2) '_SFC_M' int2str(5) '_' fname{idx} '_SFC2_FD'];
%     if isempty(dir(plotname))
%         cNames = char(isfc(idx).channelNames);
%         isfc(idx).channelNames = cellstr(cNames(:,1:2));
%         isfc(idx).image('stacked');
%         title('');
%         set(gca,'CLim',[0 1])
%         drawnow;
%         %ita_savethisplot_gle('fileName',['BBExample_SFD_M' int2str(2) '_SFC_M' int2str(2) '_' fname{idx} 'freqDep_SFC'],'output','png pdf','comment',mfilename);
%         ita_savethisplot_gle('fileName',plotname,'output','png pdf','comment',mfilename,'palette','gray','template', 'line_1column');
%         
%         
%         
%         % isfa(idx).plot_dat;
%         % ylim([-30 30]);
%         % title('');
%         % ita_savethisplot_gle('fileName',['BBExampleSFA' fname{idx}],'output','png pdf');
%         close all;
%     end
%     
% end
