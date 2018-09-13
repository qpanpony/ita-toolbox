function [varargout] = ita_plot_freq(varargin)
%ITA_PLOT_FREQ - Spectrum Plot
%  This function plots the the absolute values of the spectrum on the
%  positive frequency axis. According to the options, one can select a part
%  of the plot('axis'),linear frequency ('linfreq'), change the linewidth
%  ('linewidth') or the aspectratio of the axis ('aspectratio') -> see
%  Options for more details.
%
%  Call: fgh = ita_plot_freq(data_struct)
%  Call: fgh = ita_plot_freq(data_struct,'Option',value)
%  Call: fgh = ita_plot_freq(data_struct,'figure_handle',ref,'nodB')
%
%  Options: (standard: -> )
%   'nodB' ('on'|->'off') :        Used to switch between Y axis and log(Y) axis
%   'figure_handle' ([]) :         Sets the figure_handle
%   'axes_handle' ([]) :           Sets the axes_handle
%   'linfreq' ('on'|->'off') :     sets the frequency range to linear mode
%   'linewidth' (0.5) :            LineWidth for spectrum
%   'xlim' ([]) :                  Sets the limits for the x axis
%   'ylim' ([]) :                  Sets the limits for the y axis
%   'axis' ([]) :                  Sets the limts for both axis
%   'aspectratio' ([]) :           Sets the ratio of the axis
%   'hold' ('on'|->'off') :        Hold on enables multiple plotting in one figure
%   'ylog' (1 |-> 0) :             will plot on a logarithmic y axis
%   'plotcmd' (@plot) :            function handle for plot function to use (e.g. @stem)
%   
%  Examples:
%  ita_plot_freq(data_struct,'figure_handle',1,'hold','on') plots in figure 1 using
%  hold on
%
%  ita_plot_freq(data_struct,'nodB',true) plots in Y scale instead of
%  log(Y) scale
%
%  ita_plot_freq(data_struct,'axis',[20 100 -35 -25]) plots only from
%  20 to 100 on the X axis and form -35 to -25 on the Y axis
%
%  ita_plot_freq(data_struct,'aspectratio',0.5) Sets the ratio of the
%  axis Y and X to 0.5
%
%   See also ita_plot_dat, ita_plot_dat_dB, ita_read, ita_write.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_freq">doc ita_plot_freq</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  01-May 2006

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',ita_preferences('nodb'),'figure_handle',[],'axes_handle',[],'linfreq',ita_preferences('linfreq'),'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname')...
    ,'fontsize',ita_preferences('fontsize'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false,'unwrap',false,'wrapTo360',false,'plotcmd',@plot,'plotargs',[],'fastmode',0);
[data, sArgs] = ita_parse_arguments(sArgs, varargin);

% bugfix for multiple instances (mpo)
if numel(data) > 1
    ita_verbose_info([thisFuncStr 'There is more than one instance stored in that object. Plotting the first one only.'],0);
    data = data(1);
end

if ~data.allowDBPlot
    sArgs.nodb = true;
end

% set default if the linewidth is not set correct
if isempty(sArgs.linewidth) || ~isnumeric(sArgs.linewidth) || ~isfinite(sArgs.linewidth)
    sArgs.linewidth = 1;
end

%% check if there is data
if numel(data.data) == 0;
    ita_verbose_info('Empty data object, nothing to plot.',0)
    return
end

%% Plotting of multi-instances
if numel(data) > 1
    fgh = ita_plot_freq(data(1), varargin{2:end});
    for idx = 2:numel(data)
        [fgh, axh] = ita_plot_freq(data(idx), varargin{2:end},'figure_handle',fgh,'hold','on');
    end
    if nargout
        varargout(1) = {fgh};
        varargout(2) = {axh};
    end
    return;
end

if sArgs.ylog ||strcmpi(data.channelUnits{1},'s') || any(strcmp(data.channelUnits,'Ohm'))
    sArgs.nodb = true;
end

%% Fast Plotting Mode - Version 2
if data.nBins > 600000 && ~sArgs.precise
    ita_verbose_info([thisFuncStr 'Oh Lord. A lot of data to plot, I will skip something.'],1);
    fast_mode = ceil(data.nBins./200000);
else
    fast_mode = 1;
end
if sArgs.fastmode
    fast_mode = sArgs.fastmode;
end

%% Generate frequency vector
%skip zero freqency for logarithmic x scaling
bin_vector = data.freqVector;
if round(bin_vector(1)) == 0 && ~sArgs.linfreq
    bin_indices = 2:fast_mode:data.nBins;
else
    bin_indices = 1:fast_mode:data.nBins;
end
bin_vector = bin_vector(bin_indices);
bin_vector = bin_vector(:);

%% Get plot data
if sArgs.nodb 
    % cannot plot complex data
    if ~all(isreal(data.freqData))
        ita_verbose_info('values are complex => plotting absolute value',0)
        plotData = abs(data.freqData);
    else
        plotData = data.freqData;
    end
else %normal dB plot
    plotData = data.freqData_dB;
end
plotData = plotData(bin_indices,:);

%% Figure and axis handle
if ~isempty(sArgs.figure_handle) && ishandle(sArgs.figure_handle)
    fgh = sArgs.figure_handle;
    % figure(fgh);%pdi: out massive speed up. any problems?
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
    sArgs.resize_axes = false;
end

%% Cycle through color order if hold
if sArgs.hold
    nPlots = numel(get(sArgs.axes_handle,'Children'));
    co = get(sArgs.axes_handle,'ColorOrder');
    if nPlots > size(co,1) %pdi:bugfix for a lot of channels
       co = repmat(co,2,1);
    end
    set(sArgs.axes_handle,'ColorOrder',co([(nPlots+1):end 1:nPlots],:));
end

%% Start plotting
plotargs = [sArgs.plotargs,{'LineWidth'},{sArgs.linewidth}];
lnh = sArgs.plotcmd(sArgs.axes_handle,bin_vector,plotData,plotargs{:}); %Plot it all
if sArgs.linfreq %pdi: linear frequency plotting
    set(sArgs.axes_handle,'XScale','linear');
else
    set(sArgs.axes_handle,'XScale','log');
end

if isempty(sArgs.axes_handle)
    axh = get(fgh,'CurrentAxes');
else
    axh = sArgs.axes_handle;
end
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
sArgs.yUnit      = '';
sArgs.titleStr   = data.comment;
sArgs.xLabel     = 'Frequency in Hz';
sArgs.yLabel     = 'Modulus';
sArgs.figureName = 'Frequency Domain';
sArgs.data       = data; %used for domain entries in gui
sArgs.ita_domain = 'frequency';
setappdata(fgh,'ita_domain', 'frequency');
[fgh,axh] = ita_plottools_figurepreparations(data,fgh,axh,lnh,'options',sArgs);

%% Return the figure handle
if nargout
    varargout(1) = {fgh};
    varargout(2) = {axh};
end

ita_restore_matlab_default_plot_preferences(matlabdefaults) % restore matlab default settings