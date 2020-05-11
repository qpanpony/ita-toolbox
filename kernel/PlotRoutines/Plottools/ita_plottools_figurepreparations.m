function varargout = ita_plottools_figurepreparations(varargin)
%ITA_PLOTTOOLS_FIGUREPREPARATIONS - help function for plots
%  This function sets axis limits, titles, labels etc
%
%  Syntax:
%   figure_handle = ita_plottools_figurepreparations(audioObjIn, fgh, axh, lnh, Options)
%
%   Options (default):
%           'options' ('struct') :                 description
%           'legend' (ita_preferences('legend')) : description
%
%  Example:
%   audioObjOut = ita_plottools_figurepreparations(audioObjIn)
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_figurepreparations">doc ita_plottools_figurepreparations</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-Apr-2010

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
options         = struct('pos1_data','itaSuper','pos2_fgh','handle','pos3_axh','handle','pos4_lnh','handle','options',struct('legend','','options','','abscissa','','PlotData',''),'legend',ita_preferences('legend'));
options.data    = itaAudio;
[data,fgh,axh,lnh,options] = ita_parse_arguments(options,varargin);
legendflat      = options.legend;
options         = options.options;
abscissa        = options.abscissa;
plotData        = options.plotData;

if isempty(options.fontname)
    options.fontname = 'default';
end
if isempty(options.fontsize)
    options.fontsize = 12;
end

%% Figure stuff
old_figure_mode = false;
if ~isempty(options.figure_handle) && ishandle(options.figure_handle)
    old_figure_mode = true;
end

%% Sets limits of x axis
if ~isempty(options.xlim)
    xlim(axh,[options.xlim(1) options.xlim(2)]);
else
    if strcmp(options.xUnit,'Hz') && ~options.linfreq % for freq_dB min. 20 Hz
        xlim(axh,[max(20,min(abscissa)) max(abscissa)])
    else % for all others complete data range
        xlim(axh,[min(abscissa) max(abscissa)])
    end
end

%% Sets limits of y axis
% scaling
if ~isempty(options.ylim)
    ylim(axh,[options.ylim(1) options.ylim(2)]);
else
    %find max and min for scaling
    if options.nodb %linear y-axis
        abs_max = max(abs(plotData(isfinite(plotData))));
        abs_min = -abs_max;
        
        if isempty(abs_min)
            abs_min = -1;
        end
        if isempty(abs_max)
            abs_max = 1;
        end
        deltaLim = abs_max-abs_min;
        if ~isfinite(deltaLim) || abs(deltaLim) < eps
            deltaLim = 1;
        end
        abs_min = abs_min-0.05*deltaLim;
        abs_max = abs_max+0.05*deltaLim;
        
        if ~any(plotData(:)<0) % should be faster than: all(plotData(:)>0)
            abs_min = 0;
        end
        
    else %log y-axis in dB
        abs_max = max(plotData(isfinite(plotData)));
        if isempty(abs_max)
            abs_max = 10;
        end
        abs_min = abs_max - 90;
        abs_max = abs_max + 10;
        abs_min = 10*floor(abs_min./10);
        abs_max = 10*ceil(abs_max./10);
        if abs_max > abs_min + 100 %set max range to 100 dB
            abs_min = abs_max -100;
        end
    end
    set(axh,'YLim',sort([abs_min abs_max]));
end



%% background color
if ita_preferences('blackbackground')~=0 %%saves time
    ita_whitebg(repmat(~ita_preferences('blackbackground'),1,3))
end

%% Set Axis and that stuff...
hold on % hold has to be enabled here, not below ita_plottools_figure(fgh) mli

if options.ylog
    set(axh,'yscale','log'); %mli , plot impedance
end

% exract ylabel option from plotAxesProperties (because it doesn't work with (set(axHandle, 'ylable', 'dB'))
idxYlabelOption = find(strcmpi(data.plotAxesProperties, 'ylabel'));
if ~isempty(idxYlabelOption)
    options.yLabel  = data.plotAxesProperties{idxYlabelOption+1};
    data.plotAxesProperties(idxYlabelOption:idxYlabelOption+1) = [];
end

% mpo, adding Interpreter = 'none' to avoid TeX parsing of underscores
title(axh,options.titleStr,'FontName',options.fontname,'FontSize',options.fontsize,'Interpreter','none');
xlabel(axh,options.xLabel,'FontName',options.fontname,'FontSize',options.fontsize);
if ~options.nodb && ~strcmpi(options.plotType,'spectrogram')
    ylabel(axh,[options.yLabel ' in dB'],'FontName',options.fontname,'FontSize',options.fontsize);
else
    ylabel(axh,options.yLabel,'FontName',options.fontname,'FontSize',options.fontsize);
end
set(fgh,'NumberTitle','on','Name', [options.figureName ' - ' options.titleStr]);

if strcmp(options.xUnit,'Hz')
    [XTickVec_lin, XTickLabel_val_lin] = ita_plottools_ticks('lin');
    [XTickVec_log, XTickLabel_val_log] = ita_plottools_ticks('log');
    
    if options.linfreq %pdi added
        set(axh,'XTick',XTickVec_lin','XTickLabel',XTickLabel_val_lin)
    else
        set(axh,'XTick',XTickVec_log','XTickLabel',XTickLabel_val_log)
    end
elseif strcmp(options.yUnit,'Hz') && isa(data,'itaAudio')
    % For Labels from 20 Hz on
    [XTickVec_log, XTickLabel_val_log] = ita_plottools_ticks('log');
    kilo_mode = true;
    if options.ylog
        set(axh,'YTick',XTickVec_log','YTickLabel',XTickLabel_val_log)
    else
        if data.samplingRate >= 1e5 %get ticks
            spacer = 25000;
        else
            spacer = round(data.samplingRate / 10);
            if spacer < 50
                spacer = 10;
                kilo_mode = false;
            elseif spacer < 100
                spacer = 50;
                kilo_mode = false;
            elseif spacer < 1000
                spacer = 100;
                kilo_mode = false;
            elseif spacer < 10000
                spacer = 2000;
            else
                ita_verbose_info([thisFuncStr 'failed to generate nice ticks!'],0);
            end
        end
        tick_vec =  0:spacer:data.samplingRate;
        tick_labels = cell(length(tick_vec),1);
        for tick_idx = 1:length(tick_vec)
            if kilo_mode
                tick_labels{tick_idx} = [num2str(tick_vec(tick_idx)./1000) 'k'];
            else
                tick_labels{tick_idx} = num2str(tick_vec(tick_idx));
            end
        end
        set(axh,'YTick',tick_vec' / 1000,'YTickLabel',tick_labels);
    end
end

%% Changes aspectratio of plot
if ~old_figure_mode
    if ~isempty(options.aspectratio)
        ita_plottools_aspectratio(fgh,options.aspectratio);
    else
        ita_plottools_aspectratio(fgh,ita_preferences('aspectratio'));
    end
end

%% Get a grid!
set(axh,'XGrid','on','YGrid','on','XMinorGrid','off','XMinorTick','off','FontName',options.fontname,'FontSize',options.fontsize);

%% Find legend information
if options.nodb
    modeStr = 'nodb';
else
    modeStr = 'log';
end
legendString = data.legend(modeStr);
if numel(legendString) > 20
    ita_verbose_info([thisFuncStr ':disabling legend due to many many channels...'],1)
    legendflat = false;
end

%% Apply line and axes Options
if ~isempty(data.plotAxesProperties)
    try
        set(axh,data.plotAxesProperties{:});
    catch EM
        ita_verbose_info(['Error using plotAxesProperties: ' EM.message], 1)
    end;
end

%% Sets both x and y axis limits
if ~isempty(options.axis)
    axis(axh,options.axis);
end

%% Legend or no Legend, that's the ... pdi: moved after setting the data
if (~isempty(data.plotLineProperties) ||   legendflat) && ~strcmp(options.plotType,'spectrogram')    %Types: time, mag, phase, gdelay
    %pdi: speed reason: no legend required, no time spent on setting the channeldata...
    % rsc/mpo bugfix
    %try RSC: ToDo: catch
    data.plotLineProperties = squeeze(data.plotLineProperties).';
    for idch = 1:data.nChannels
        if isempty(data.plotLineProperties)
            lineProperties = {'DisplayName'; legendString{idch}};
        elseif size(data.plotLineProperties,2) < idch
            lineProperties = [{'DisplayName'; legendString{idch}}; data.plotLineProperties(:,1)];
        else
            lineProperties = [{'DisplayName'; legendString{idch}}; data.plotLineProperties(:,idch)];
        end
        %             if ~strcmp(get(lnh(idch),'Type'),'axes') %false for spectrogram plots
        set(lnh(idch),lineProperties{:});
        %             end
    end
    %end % RSC: ToDo: catch
end
if legendflat && ~strcmp(options.plotType,'spectrogram')
    legend('off'); %toggle legend to update
    %     lh = legend('show','Location','South'); %%%changed from best to South --> saves time
    lh = legend('Location','South'); %%%changed from best to South --> saves time
    %     legend(lh,'show')
    %set(lh,'Interpreter','latex')
end

%% Save information in the figure userdata section
% setappdata(fgh,'AxisHandles',axh);
oldhandles = getappdata(fgh,'AxisHandles');
oldhandles = oldhandles(ishandle(oldhandles));
setappdata(fgh,'AxisHandles',[oldhandles axh]); % HUHU
setappdata(fgh,'ActiveAxis',axh);

if strcmp(options.xUnit,'Hz')
    setappdata(fgh,'XTickLabelLin',XTickLabel_val_lin);
    setappdata(fgh,'XTickVecLin',XTickVec_lin);
    setappdata(fgh,'XTickLabelLog',XTickLabel_val_log);
    setappdata(fgh,'XTickVecLog',XTickVec_log);
end

%jri save ita audio in figure to fix the gui-ans-bug
setappdata(fgh,'audioObj',data);

%% Save information in the axes userdata section
limits = [xlim ylim];
setappdata(axh,'AllChannels',1);   %used for all channel /single channel switch
setappdata(axh,'ActiveChannel',1); %used for all channel /single channel switch
setappdata(axh,'Title',options.titleStr);
setappdata(axh,'ChannelNames',legendString);
setappdata(axh,'Limits',limits);
setappdata(axh,'PlotType',options.plotType)    %Types: time, mag, phase, gdelay
setappdata(axh,'YAxisType',options.yAxisType); %Types: linear and db
setappdata(axh,'XAxisType',options.xAxisType); %Types: time and freq
setappdata(axh,'XUnit',options.xUnit);
setappdata(axh,'YUnit',options.yUnit);
setappdata(axh,'FigureHandle',fgh); %pdi: safer to write this, than to estimate via parent / GUI problem

%% Maximize plot window in WIN32
if isempty(options.aspectratio) && ~old_figure_mode && isempty(ita_preferences('aspectratio'))
    ita_plottools_maximize(fgh);
end

%% Logo
ita_plottools_addlogo(axh);

%% Cursors
if ita_preferences('plotcursors')
    ita_plottools_cursors('on',[],axh);
end

%% Menu
if ita_preferences('itamenu')
    ita_menu('handle',fgh,'type',data);
end

set(fgh,'KeyPressFcn',@ita_plottools_buttonpress); %pdi: moved here from ita_plottools_figure

%% Set Output
varargout(1) = {fgh};
varargout(2) = {axh};

%end function
end

%{
if sArgs.nodbticks
    %     lnh1 = loglog(bin_vector,(abs(data.freqData(bin_indices,:))).','LineWidth',sArgs.linewidth); %Plot it all
        lnh1 = semilogx(bin_vector,ampl_dB,'LineWidth',sArgs.linewidth); %Plot it all
        yticklabels = num2str(10.^(get(gca,'Ytick')./20));
    set(gca,'Ytick',get(gca,'Ytick'),'YTickLabel',yticklabels);
end
%}
