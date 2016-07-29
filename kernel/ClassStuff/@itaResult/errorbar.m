function varargout = errorbar(varargin)
% overloaded bar plot routine for freq itaResults (e.g. band levels)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

sArgs = struct('pos1_data','itaSuper','nodb',ita_preferences('nodb'),'figure_handle',[],'axes_handle',[],'linfreq',ita_preferences('linfreq'),...
    'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'),'fontsize',ita_preferences('fontsize'),...
    'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false,'unwrap',false,'stderr',false,'stdDev',[],'N',[],'color','blue');
[data sArgs] = ita_parse_arguments(sArgs, varargin);

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %set ita toolbox preferences and get the matlab default settings

if numel(data) > 1 || data.nChannels > 1 % errorbar across  multi-instance or channels
    inputdata   = mean(data);
    errs        = std(data);
    if numel(data) > 1
        N    = numel(data);
    else
        N = data.nChannels;
    end
elseif numel(data) == 1 && data.nChannels == 1 && ~isempty(sArgs.stdDev) && ~isempty(sArgs.N) % std given explicitly
    inputdata = data;
    errs = sArgs.stdDev;
    N = sArgs.N;
else
    error('No data for the calculation of mean and std was given');
end

if sArgs.stderr
    errs = errs/sqrt(N); % standard error
end

%% checking
if isTime(inputdata)
   error('itaResult.errorbar:this is a frequency plot function, use hist() instead'); 
end

if sArgs.ylog
    sArgs.nodb = 1;
end

if strcmpi(inputdata.channelUnits{1},'s')
   sArgs.nodb = 1; 
end

%% cut down on the amount of data
if inputdata.nBins > 1000
    ita_verbose_info('itaResult.bar:Oh Lord. A lot of data to plot, I will skip something.',1);
    fast_mode = ceil(inputdata.nBins./20);
else
    fast_mode = 1;
end

bin_vector = inputdata.freqVector;
if round(bin_vector(1)) == 0 && ~sArgs.linfreq
    bin_indices = 2:fast_mode:inputdata.nBins;
else
    bin_indices = 1:fast_mode:inputdata.nBins;
end
bin_vector = bin_vector(bin_indices);

%% Get plot data
if sArgs.nodb
    % cannot plot complex data
    if ~all(isreal(inputdata.freqData))
        plotData = abs(inputdata.freqData);
    else
        plotData = inputdata.freqData;
    end
    errPlotData1 = errs.freqData;
    errPlotData2 = errs.freqData;
else %normal dB plot
    plotData = inputdata.freqData_dB;
    % error bars have to be calculated as well
    %(non-symmetric for dB values)
    tmp = (inputdata + errs)/inputdata;
    tmp.freq(~isfinite(tmp.freq)) = 1;
    errPlotData1 = tmp.freqData_dB;
    tmp = (inputdata - errs)/inputdata;
    tmp.freq(~isfinite(tmp.freq)) = 1;
    errPlotData2 = tmp.freqData_dB;
end
plotData     = plotData(bin_indices,:);
errPlotData1 = errPlotData1(bin_indices,:);
errPlotData2 = errPlotData2(bin_indices,:);

%% Figure and axis handle
if ~isempty(sArgs.figure_handle) && ishandle(sArgs.figure_handle)
    fgh = sArgs.figure_handle;
    figure(fgh);
    if ~sArgs.hold
        hold off;
    else
        hold on;
    end
else
    fgh = ita_plottools_figure;
end

if isempty(sArgs.axes_handle)
    sArgs.axes_handle = gca;
    sArgs.resize_axes = true;
else
    axes(sArgs.axes_handle); %#ok<MAXES>
    sArgs.resize_axes = false;
end

%% Cycle through color order if hold
if sArgs.hold
    nPlots = numel(get(sArgs.axes_handle,'Children'));
    co=get(sArgs.axes_handle,'ColorOrder');
    set(sArgs.axes_handle,'ColorOrder',co([(nPlots+1):end 1:nPlots],:));
end

%% plot command
if ~sArgs.nodb
    lnh = errorbar(repmat(bin_vector,1,inputdata.nChannels),plotData,errPlotData1,errPlotData2,'lineWidth',sArgs.linewidth,'color',sArgs.color);
else
    lnh = errorbar(repmat(bin_vector,1,inputdata.nChannels),plotData,errPlotData1,errPlotData2,'lineWidth',sArgs.linewidth,'color',sArgs.color);
end

if sArgs.linfreq %pdi: linear frequency plotting
    set(sArgs.axes_handle,'XScale','linear');
else
    set(sArgs.axes_handle,'XScale','log');
end
axh = get(fgh,'CurrentAxes');
setappdata(axh,'ChannelHandles',lnh);

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
sArgs.yUnit      = ' XXX wo? ';
sArgs.titleStr   = inputdata.comment;
sArgs.xLabel     = 'Frequency in Hz';
sArgs.yLabel     = 'Modulus';
sArgs.figureName = 'Frequency Domain';
sArgs.legendString = inputdata.legend;
sArgs.data       = data; %used for domain entries in gui
[fgh,axh] = ita_plottools_figurepreparations(inputdata,fgh,axh,lnh,'options',sArgs);

%% Return the figure handle
if nargout
    varargout(1) = {fgh};
    varargout(2) = {axh};
end

ita_restore_matlab_default_plot_preferences(matlabdefaults) % restore matlab default settings

end