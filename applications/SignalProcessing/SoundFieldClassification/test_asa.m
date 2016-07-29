function res = test_asa

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Settings
idx = 0;
settings = {};
bbfontscale = 1.15;
addpath(ita_preferences('SFC_AudioFolder'));

prefix = 'Example_CEF';


%% Speech in Vorraum Hallraum (Quelle fern)
idx = idx+1;
disp(idx);
%speech = ita_read('Lang1.wav');
speech = ita_generate('noise',1,44100,20);
%speech = ita_append(ita_generate('emptydat',44100,16),ita_extract_dat(speech.ch(1),20));

TF = ita_read('vorraum_hallraum_pos3_TF.ita');
TF = ita_time_window(TF.ch([1 2 5 6]),[0.6 0.8],'crop');

signal = ita_normalize_dat(ita_convolve(speech,TF));
signal = ita_extract_dat(signal,12);
res(idx) = ita_asa(signal,settings{:})

fname{idx} = 'FarSpeechVorraumHallraum';

%% save results
%save([prefix '.mat']);


%% Plot
% ita_plot_dat(abs(res.cef));
% 
% mCEF = abs(mean(mean(res.cef,1),2));
% bs = str2double(res.cef.channelNames);
% figure();
% plot(bs,squeeze(mCEF.time)); 

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
%         res(idx).sfc.mean.plot_dat;
%         ita_plottools_reduce();
%         ylim([-0.5 1.5]);
%         drawnow;
%         title('');
%         ita_savethisplot_gle('fileName',plotname,'output','png pdf svg','comment',mfilename,'template', 'line_1column','font_scale',bbfontscale);
%         close all;
%     end
%     
%     plotname = [prefix '_SFD_M' int2str(2) '_SFC_M' int2str(5) '_' fname{idx} '_SFC2_FD'];
%     if isempty(dir(plotname))
%         cNames = char(res(idx).sfc.channelNames);
%         res(idx).sfc.channelNames = cellstr(cNames(:,1:2));
%         res(idx).sfc.image('stacked');
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
end