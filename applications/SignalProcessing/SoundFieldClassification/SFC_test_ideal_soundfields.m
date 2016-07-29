%sf_test_ideal_soundfields

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;
settings = {'blocksize',2^8,'overlap',0.75,'sensorspacing',0.014,'direct_plot',false,'compensate',false,'fraction',3,'t_c',.2,'flimit',[100 10000],'psdbands',false};
addpath(ita_preferences('SFC_AudioFolder'));

%% Magnitude and Phase errors of Hoertnix
% comp = ita_read('hoertnix_compensation.ita');
% errors = merge(comp.ch(1)/comp.ch(2), comp.ch(3)/comp.ch(4), comp.ch(5)/comp.ch(6), comp.ch(7)/comp.ch(8) );
% errors.comment = '';
% fgh = ita_plot_spk(errors,'ylim',[-2 2],'xlim',[100 10000]);
% ita_savethisplot_gle('fgh',fgh,'fileName','HoertnixMagnitudeErrors','output','eps pdf png');
% fgh = ita_plot_phase(errors,'ylim',[-90 90],'xlim',[100 10000]);
% ylim([-10 10]); title('');
% ita_savethisplot_gle('fgh',fgh,'fileName','HoertnixPhaseErrors','output','eps pdf png');
% fgh = ita_plot_groupdelay(errors,'ylim',[-0.02 0.02],'xlim',[100 10000]);
% ylim([-0.002 0.002]); title('');
% ita_savethisplot_gle('fgh',fgh,'fileName','HoertnixGDelays','output','eps pdf png');
% ylim([-0.0002 0.0002]); title('');
% ita_savethisplot_gle('fgh',fgh,'fileName','HoertnixGDelaysZoom','output','eps pdf png');

close all;
%% IdealHA Ideal Sensor
signal = ita_read('IdealSoundFields_IDEALHA_HRTF_BTE_non_compensated.ita');
signal = signal.ch([1 2]);

idx = 1;
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(signal,settings{:});
comment = 'Basic Sound Field Sequence';

sfi_error(idx) = abs(isfi(idx));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx));
sfa_error(idx).comment = comment;
close all;

%% IdealHA Ideal Sensor

idx = idx +1;
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(signal,settings{:},'freqdependentsfc',false);
comment = 'Freq independent SFC';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;

%% Amplitude mismatch
idx = idx+1;
mismatch_dB = 1;
mismatch = 10^(mismatch_dB/20);
biased_signal = merge(signal.ch(1), mismatch .* signal.ch(2));
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});

comment = 'Amplitude Mismatch 1dB';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;


close all;
%figure();image(sfd_error,'CLim',[0 1]);

%% Phase error (delay)
idx = idx+1;
delay_samples = 44;
biased_signal = merge(signal.ch(1), ita_time_shift(signal.ch(2),delay_samples,'samples'));
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'Sensor Delay 1ms';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% Phase error (delay)
idx = idx+1;
delay_samples = 4;
biased_signal = merge(signal.ch(1), ita_time_shift(signal.ch(2),delay_samples,'samples'));
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'Sensor Delay 0.1ms';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% Phase error (freq constant)
idx = idx+1;
phase_mismatch = 10;
biased_signal = signal;
signal.freqData(:,2) = signal.freqData(:,2) * exp(1i * phase_mismatch/360*2*pi);
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'Phase error 10Deg';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% Amplitude and Phase mismatch
idx = idx+1;
mismatch_dB = 1;
mismatch = 10^(mismatch_dB/20);
delay_samples = 44;
biased_signal = merge(signal.ch(1), mismatch .* ita_time_shift(signal.ch(2),delay_samples,'samples'));
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'Amplitude Mismatch 1dB and Delay 1ms';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% Amplitude and Phase mismatch
idx = idx+1;
mismatch_dB = 1;
mismatch = 10^(mismatch_dB/20);
delay_samples = 4;
biased_signal = merge(signal.ch(1), mismatch .* ita_time_shift(signal.ch(2),delay_samples,'samples'));
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'Amplitude Mismatch 1dB and Delay 0.1ms';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% HA HRTF nonCompensated
idx = idx+1;
signal = ita_read('IdealSoundFields_HA_HRTF_BTE_non_compensated.ita');
biased_signal = signal.ch([1 2]);
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'HearingAids';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% HA HRTF Compensated
idx = idx+1;
signal = ita_read('IdealSoundFields_HA_HRTF_BTE_diffuse_compensated.ita');
biased_signal = signal.ch([1 2]);
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'HearingAids Compensated';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% Hoertnix HRTF nonCompensated
idx = idx+1;
signal = ita_read('IdealSoundFields_Hoertnix_HRTF_BTE_non_compensated.ita');
biased_signal = signal.ch([1 2]);
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'Hoertnix';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% Hoertnix only, no sensor
idx = idx + 1;
comment = 'headonly';
sfi_error(idx) = abs(isfi(idx-1)-isfi(idx-3));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx-1)-isfd(idx-3));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx-1)-isfc(idx-3)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx-1)-isfa(idx-3));
sfa_error(idx).comment = comment;



%% Hoertnix HRTF Compensated
idx = idx+1;
signal = ita_read('IdealSoundFields_Hoertnix_HRTF_BTE_diffuse_compensated.ita');
biased_signal = signal.ch([1 2]);
[isfi(idx), isfd(idx), isfc(idx), isfa(idx)] = ita_sfa_run(biased_signal,settings{:});
comment = 'Hoertnix Compensated';
sfi_error(idx) = abs(isfi(idx)-isfi(1));
sfi_error(idx).comment = comment;
sfd_error(idx) = (isfd(idx)-isfd(1));
sfd_error(idx).comment = comment;
sfc_error(idx) = (isfc(idx)-isfc(1)); 
sfc_error(idx).comment = comment;
sfa_error(idx) = (isfa(idx)-isfa(1));
sfa_error(idx).comment = comment;
close all;

%% Plots
 for idx = 1:numel(sfc_error)
%     %SFI Error
%     for idch = 1:sfi_error(idx).nChannels
%         filename = ['SFIError_' sfi_error(idx).comment '_' sfi_error(idx).channelNames{idch}];
%         filename(~isstrprop(filename,'alphanum')) = [];
%         if ~exist(filename,'dir')
%             fgh = figure();
%             ita_plottools_aspectratio(fgh,0);
%             drawnow;
%             image(sfd_error(idx).ch(idch),'CLim',[0 1]);
%             title('');
%             drawnow;
%             ita_savethisplot_gle('fgh',fgh,'fileName',filename,'output','eps pdf png','font_scale',2);
%             close(fgh);
%         end
%     end
%     
%     %SFD Error
%     for idch = 1:sfd_error(idx).nChannels
%         filename = ['SFDError_' sfd_error(idx).comment '_' sfd_error(idx).channelNames{idch}];
%         filename(~isstrprop(filename,'alphanum')) = [];
%         if ~exist(filename,'dir')
%             fgh = figure();
%             ita_plottools_aspectratio(fgh,0);
%             drawnow;
%             image(sfd_error(idx).ch(idch),'CLim',[-1 1]);
%             title('');
%             drawnow;
%             ita_savethisplot_gle('fgh',fgh,'fileName',filename,'output','eps pdf png','font_scale',2);
%             close(fgh);
%         end
%     end
    
% SFC Error
    filename = ['SFCError_' sfc_error(idx).comment];
    filename(~isstrprop(filename,'alphanum')) = [];
    %         if ~exist(filename,'dir')
    %             fgh = figure();
    %             ita_plottools_aspectratio(fgh,0);
    %             drawnow;
    %             image(sfc_error(idx).ch(idch));
    %             set(gca,'clim',[-1 1]);
    %             title('');
    %             drawnow;
    %             ita_savethisplot_gle('fgh',fgh,'fileName',filename,'output','eps pdf png','font_scale',2);
    %             close(fgh);
    %         end
    cNames = char(sfc_error(idx).channelNames);
    sfc_error(idx).channelNames = cellstr(strtok(sfc_error(idx).channelNames,' '));
    sfc_error(idx).mean.plot_dat;
    ita_plottools_reduce();
    ylim([-1.01 1.01]);
    %drawnow;
    title('');
    bbfontscale = 1.15;
    
    ita_savethisplot_gle('fileName',[filename '_BB'],'output','png pdf','comment',mfilename,'template', 'line_1column','font_scale',bbfontscale);
    
    sfc_error(idx).channelNames = cellstr(cNames(:,1:2));
    sfc_error(idx).mean.plot_dat;
    
    close all;
    
    sfc_error(idx).image('stacked');
    title('');
    set(gca,'clim',[-1 1]);
    %drawnow;
    %ita_savethisplot_gle('fileName',['BBExample_SFD_M' int2str(2) '_SFC_M' int2str(2) '_' fname{idx} 'freqDep_SFC'],'output','png pdf','comment',mfilename);
    ita_savethisplot_gle('fileName',filename,'output','png pdf','comment',mfilename,'palette','gray','template', 'line_1column');
    
    close all;
    
%     %SFA Error
%     for idch = 1:sfa_error(idx).nChannels
%         filename = ['SFAError_' sfa_error(idx).comment '_' sfa_error(idx).channelNames{idch}];
%         filename(~isstrprop(filename,'alphanum')) = [];
%         if ~exist(filename,'dir')
%             fgh = figure();
%             ita_plottools_aspectratio(fgh,0);
%             drawnow;
%             image(sfa_error(idx).ch(idch),'CLim',[-30 30]);
%             title('');
%             drawnow;
%             ita_savethisplot_gle('fgh',fgh,'fileName',filename,'output','eps pdf png','font_scale',2);
%             close(fgh);
%         end
%     end
end
close all;