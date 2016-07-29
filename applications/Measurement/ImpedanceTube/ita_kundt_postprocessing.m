% ITA_KUNDT_POSTPROCESSING - Kundt Postprocessing
% 
% This function processes all files in one folder, generates plots with lots of options
%
% Author: RSC

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

ccx;

%% Import measurement
filefilter = '*_raw.ita';

%% Settings for postprocessing
TimeWindow1 = [0.04 0.06];
tube_dim = 'smallTubeITA';
surface_factor = 1;

% If turned on, all measurement with 'threshhold' number of bad freqBins will be ignored. For all other measurements, values out of range will be replaced with the range limits
remove_bad_measurements = true;
threshhold = 0.01;

%% Settings for plots
x_lim = [100 8000];
y_lim = [0 1];
linfreq = 'off';

plot_all = false;
plot_mean = true;
plot_std = true;
plot_single_windows = 0;

freqbands = []; % E.g. 3 for terz, 12 for half tones, 1 for octaves, empty for full spectrum
freqbands_csv = 3;
smooth = 1/3; % Like 1 / freqbands, empty for no smooth
smooth_reps = 5; % will repeat smoothing n times (bandwith will be adjusted automatically)

export_txt = true;


%% Start postprocessing
raw_data = ita_read(filefilter);

for idx = 1:numel(raw_data)
    this = ita_ifft(raw_data(idx)); %Select one and go to time domain
    z_0 = ita_generate('flat',1,this.samplingRate,this.fftDegree) * ita_constants('z_0'); %Constant needed for calculation
    this = ita_time_shift(this);
    this = ita_time_window(this,TimeWindow1,'time','symmetric');
    %tf1(idx) = this.ch(1) / this.ch(2);
    %tf2(idx) = this.ch(1) / this.ch(3);
    rb_result = ita_kundt_calc_impedance(this,tube_dim);
    impedance(idx) = ita_fft(rb_result); %#ok<*SAGROW>
    reflection(idx) = (impedance(idx) - z_0) / (impedance(idx) + z_0);
    absorption(idx) = 1 - abs(reflection(idx))^2  * surface_factor;
    [tmp1, absorption(idx).channelNames{1}] = fileparts(this.fileName(1:end-11));
    absorption(idx).channelNames{1} = strrep(absorption(idx).channelNames{1},'_','-'); % Remove underscores as they trigger the LaTeX interpreter
end

%% Limit results
if remove_bad_measurements
    ok = true(size(absorption));
    
    
    for idx = 1:numel(absorption)
        x_lim_idx = absorption(idx).freq2index(x_lim);  % kann ja eintlich raus aus der schleife da alle meesungen gleich, doer?
%         validFreqData2 = absorption(idx).freq2value(min(x_lim):max(x_lim));
        validFreqData = absorption(idx).freqData(x_lim_idx(1):x_lim_idx(2));
        ok(idx) = (sum( validFreqData > 1 | validFreqData < 0) / numel(validFreqData)) <= threshhold;
        
        if ~ok(idx)
           ita_verbose_info(['Bad measurement: ' raw_data(idx).comment],0); 
        end
        absorption(idx).freqData(absorption(idx).freqData < 0) = 0; % Remove values out of valid range
        absorption(idx).freqData(absorption(idx).freqData > 1) = 1;
    end
    absorption = absorption(ok);
end

absorption = ita_merge(absorption);
absorption.comment = 'Absorption';
abs_tmp = absorption;
%% Start plots
absorption = abs_tmp;
rest = absorption;

if export_txt
    if ~isempty(freqbands_csv)        %#ok<*UNRCH>
        ita_write_txt(ita_spk2frequencybands(ita_mean(absorption,'same_channelnames_only'),'fraction',freqbands_csv,'method','averaged','limits',x_lim),'results.txt');
    else
        ita_write_txt(ita_mean(absorption,'same_channelnames_only'),'results.txt');
    end
end

while ~isempty(rest)
    if plot_single_windows
        [absorption, rest] = ita_split(rest,rest.channelNames{1});
    else
        rest = [];
    end
    
    if plot_all
        all_abs = absorption;
        if ~isempty(smooth)
            for idsmooth = 1:smooth_reps
                all_abs = ita_smooth(all_abs, 'LogFreqOctave1', smooth/smooth_reps, 'Real');
            end
        end
%         if ~isempty(freqbands)
%             all_abs = ita_spk2frequencybandlevels(all_abs,freqbands,'averaged','nosquare','limits',x_lim);
%         end
        ita_plot_spk(all_abs,'nodb','xlim',x_lim,'ylim',y_lim);
        ita_savethisplot('legend_position','br','graph_size',[],'fileName','all','output','eps png')

    end
    
    if plot_mean
        mean_abs = absorption;
        if ~isempty(smooth)
            for idsmooth = 1:smooth_reps
            mean_abs = ita_smooth(mean_abs, 'LogFreqOctave1', smooth/smooth_reps, 'Real');
            end
        end
%         if ~isempty(freqbands)
%             mean_abs = ita_spk2frequencybandlevels(mean_abs,freqbands,'averaged','nosquare','limits',x_lim);
%         end
        old_mean_abs = mean_abs;
        mean_abs = ita_mean(mean_abs,'same_channelnames_only');
        color = colormap; % Same color as plot before
        color = color(1,:);
        mean_abs.plotLineProperties = {'Color',color};
        fgh = ita_plot_spk(mean_abs,'nodb','xlim',x_lim,'ylim',y_lim);
        
        if plot_std
            thisstd = ita_std(old_mean_abs,'same_channelnames_only');
            pltstd = mean_abs+thisstd;
            %color = colormap; % Same color as plot before
            %color = color(1,:);
            pltstd.plotLineProperties = {'LineStyle','--','Color',color};
            fgh = ita_plot_spk(pltstd,'nodb','xlim',x_lim,'ylim',y_lim,'figure_handle',fgh,'hold','on');
            
            pltstd = mean_abs-thisstd;
            %color = colormap; % Same color as plot before
            %color = color(1,:);
            pltstd.plotLineProperties = {'LineStyle','--','Color',color};
            fgh = ita_plot_spk(pltstd,'nodb','xlim',x_lim,'ylim',y_lim,'figure_handle',fgh,'hold','on');
        end
        for idx = 1:mean_abs.nChannels
            chNames{idx} = mean_abs.channelNames{idx}(6:end-1);
        end
        lgh = legend(chNames,'Interpreter','none');
%         ita_savethisplot_gle('legend_position','br','graph_size',[],'fileName',[chNames{1}],'output','eps png')

        box off
        lWidth = 1.5;
        lines=findobj(gca,'type','line');
        set(lines,'LineWidth',lWidth)
	
        set(gca, 'LineWidth', 1.3)
    
%         set(gcf, 'PaperOrientation', 'landscape');
%         set(gcf, 'Units', 'centimeters');
%         paperSize = get(gcf, 'PaperSize');
%         set(gcf, 'paperPosition', [-1 -0.5 paperSize(1)+3 paperSize(2)+1])
        
        
    
            ita_savethisplot(gcf, [chNames{1}(1:end) '_dickeLinien4' '.png'])
            return
    end
    
    
end

