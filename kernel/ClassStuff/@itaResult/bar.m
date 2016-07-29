function varargout = bar(varargin)
% overloaded bar plot routine for freq itaResults (e.g. band levels)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

sIn = struct('pos1_input','itaResult','nodb',false,'figure_handle',[],'axes_handle',[],'linfreq','off','linewidth',ita_preferences('linewidth'),...
    'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','ylog',false,'fontname',ita_preferences('fontname'),'fontsize',ita_preferences('fontsize'),'log_prefix',[]);
[input, sArgs] = ita_parse_arguments(sIn, varargin);

%% mergin??
if numel(input) > 1
    input = merge(input);
end

%% checking
if isTime(input)
    error('itaResult.bar:this is a frequency plot function, use hist() instead');
end

if ~input.allowDBPlot || sArgs.ylog || any(strcmp(input.channelUnits,'s'))
    sArgs.nodb = 1;
end

%% cut down on the amount of data
if input.nBins > 1000
    ita_verbose_info('itaResult.bar:Oh Lord. A lot of data to plot, I will skip something.',1);
    fast_mode = ceil(input.nBins./20);
else
    fast_mode = 1;
end

bin_vector = input.freqVector;
if round(bin_vector(1)) == 0 && ~sArgs.linfreq
    bin_indices = 2:fast_mode:input.nBins;
else
    bin_indices = 1:fast_mode:input.nBins;
end
bin_vector = bin_vector(bin_indices);

%% 20 uPa Support
channelUnits = input.channelUnits;
if ~sArgs.nodb
    plotData = input.freqData_dB('log_prefix',sArgs.log_prefix);
else
    plotData = input.freqData;
    if ~all(isreal(plotData))
        plotData = abs(plotData);
    end
end

plotData = plotData(bin_indices,:);
if any(ismember(channelUnits,{'W','Pa^2','kg/(s m^2)'})) % power in dB
    ita_verbose_info('itaResult.bar:10 .* log10 (input) plotting is used',1);
end

channelUnits(strcmp(channelUnits,'Pa')) = {'20u Pa'};
channelUnits(strcmp(channelUnits,'W')) = {'1p W'};

%% Figure handle
old_figure_mode = false;
if ~isempty(sArgs.figure_handle) && ishandle(sArgs.figure_handle)
    fgh = sArgs.figure_handle;
    figure(fgh);
    old_figure_mode = true;
    if ~sArgs.hold
        hold off;
    else
        hold on;
    end
else
    fgh = ita_plottools_figure;
end
sArgs.figure_handle = fgh;

if isempty(sArgs.axes_handle)
    sArgs.axes_handle = gca;
    sArgs.resize_axes = false;
else
    axes(sArgs.axes_handle); %#ok<MAXES>
    sArgs.resize_axes = false;
end


%% dB level plot
lnh = bar(bin_vector,plotData,'hist');

h = get(gca,'Children');
for idx = 1:numel(h)
    if ~ismember(h(idx),lnh)
        set(h(idx),'Visible','off')
        set(h(idx),'HandleVisibility','off')
    end
end

axh = get(fgh,'CurrentAxes');
if ~sArgs.linfreq
    set(axh,'XScale','log');
end

if sArgs.ylog
    set(axh,'yscale','log');
end

if sArgs.resize_axes
    set(axh,'Units','normalized', 'OuterPosition', [-.05 0 1.1 1]); %pdi new scaling
end

%% Set Axis and that stuff...
titleStr = [input.comment];
title(titleStr);
xlabel('Frequency in Hz')
if ~sArgs.nodb
    ylabel('Modulus in dB')
else
    ylabel('Modulus')
end
set(gcf,'NumberTitle','off');
set(gcf,'Name', ['Frequency Domain - ' titleStr])

[XTickVec_lin, XTickLabel_val_lin] = ita_plottools_ticks('lin');
[XTickVec_log, XTickLabel_val_log] = ita_plottools_ticks('log');

if sArgs.linfreq
    set(gca,'XTick',XTickVec_lin','XTickLabel',XTickLabel_val_lin)
else
    set(gca,'XTick',XTickVec_log','XTickLabel',XTickLabel_val_log)
end

if isempty(sArgs.xlim) && isempty(sArgs.axis)
    xData = get(lnh,'XData');
    if iscell(xData)
        xLow = 0.99*xData{1}(1);
        xHigh = 1.01*xData{end}(end);
    else
        xLow = 0.99*xData(1);
        xHigh = 1.01*xData(end);
    end
    xlim([xLow,xHigh]);
end

%% background color
ita_whitebg(repmat(~ita_preferences('blackbackground'),1,3))

%% Sets both x and y axis limits
if ~isempty(sArgs.axis)
    axis(sArgs.axis);
end

%% Changes aspectratio of plot
if ~old_figure_mode
    if ~isempty(sArgs.aspectratio)
        ita_plottools_aspectratio(fgh,sArgs.aspectratio);
    else
        ita_plottools_aspectratio(fgh,ita_preferences('aspectratio'));
    end
end

%% Get a grid!
grid on
set(gca,'XMinorGrid','off');
set(gca,'XMinorTick','off');

%% Find legend
ChannelNames = input.channelNames;
% lgh          = legend(ChannelNames);
setappdata(axh,'ChannelHandles',lnh(:));

%% call help function
sArgs.abscissa = bin_vector;
sArgs.plotData = plotData;

sArgs.xAxisType  = 'freq'; %Types: time and freq
if sArgs.nodb
    sArgs.yAxisType  = 'linear'; %Types: db and linear
else
    sArgs.yAxisType  = 'db'; %Types: db and linear
end
sArgs.plotType   = 'mag'; %Types: time, mag, phase, gdelay
sArgs.xUnit      = 'Hz';
sArgs.yUnit      = [input.channelUnits{1} ' '];
sArgs.titleStr   = input.comment;
sArgs.xLabel     = 'Frequency bands in Hz';
sArgs.yLabel     = 'Modulus';
sArgs.figureName = 'Frequency Domain';
sArgs.data       = input; %used for domain entries in gui
sArgs.channelUnits = channelUnits;
sArgs.xlim = xlim;

[fgh,axh] = ita_plottools_figurepreparations(input,fgh,axh,lnh,'options',sArgs);

%% Save information in the figure userdata section
setappdata(fgh,'AxisHandles',axh);
setappdata(fgh,'ActiveAxis',axh);
setappdata(fgh,'XTickLabelLin',XTickLabel_val_lin);
setappdata(fgh,'XTickVecLin',XTickVec_lin);
setappdata(fgh,'XTickLabelLog',XTickLabel_val_log);
setappdata(fgh,'XTickVecLog',XTickVec_log);

%% Save information in the axes userdata section
limits = [xlim ylim];
setappdata(axh,'AllChannels',1);   %used for all channel /single channel switch
setappdata(axh,'ActiveChannel',1); %used for all channel /single channel switch
setappdata(axh,'Title',titleStr);
setappdata(axh,'ChannelNames',ChannelNames);
setappdata(axh,'Limits',limits);
setappdata(axh,'PlotType','mag')     %Types: time, mag, phase, gdelay
setappdata(axh,'YAxisType','db');    %Types: linear and db
setappdata(axh,'XAxisType','freq');  %Types: time and freq
setappdata(axh,'ChannelHandles',lnh);
setappdata(axh,'XUnit','Hz');
setappdata(axh,'YUnit',[input.channelUnits{1} ' ']);
setappdata(fgh,'AllChannels',1);   %used for all channel /single channel switch
setappdata(fgh,'ActiveChannel',1); %used for all channel /single channel switch
setappdata(fgh,'Title',titleStr);
setappdata(fgh,'ChannelNames',ChannelNames);

%% Maximize plot window in WIN32
if isempty(sArgs.aspectratio) && ~old_figure_mode && isempty(ita_preferences('aspectratio'))
    ita_plottools_maximize(fgh);
end

%% Cursors
ita_plottools_cursors(ita_preferences('plotcursors'),[],gca);

%% Return the figure handle
if nargout == 1
    varargout = {fgh};
end

end