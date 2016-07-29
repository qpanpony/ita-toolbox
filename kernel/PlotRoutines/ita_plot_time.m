function [varargout] = ita_plot_time(varargin)
%ITA_PLOT_TIME - Plot amplitude over time
%  This function plots the time signal. According to the options, one can
%  select a part of the plot('axis'), change the aspect ratio of the axis
%  ('aspectratio'),change the limits of the axes -> see Options for more
%  details.
%
%  Syntax: hfig = ita_plot_time(itaAudio)
%  Syntax: hfig = ita_plot_time(itaAudio,'Option',value)
%
%  Options: (standard: -> )
%   'precise'('on'|->'off') :    Sets the precision of the plots
%   'figure_handle' ([]) :       Sets the figure_handle
%   'axes_handle' ([]) :         Sets the axes_handle
%   'xlim' ([]) :                Sets the limits for the x axis
%   'ylim' ([]) :                Sets the limits for the y axis
%   'axis' ([]) :                Sets the limts for both axis
%   'aspectratio' ([]) :         Sets the ratio of the axis
%   'plotcmd' (@plot) :            function handle for plot function to use (e.g. @stem)
%
%
%  Examples:
%  ita_plot_time(itaAudio,'figure_handle',1) plots in figure 1 using
%  hold on 
%
%  ita_plot_time(data_struct,'axis',[0 0.1 0 0.3]) plots only from 
%  0 to 0.1 on the X axis and form 0 to 0.3 on the Y axis
%
%  ita_plot_time(data_struct,'aspectratio',0.5) Sets the ratio off the 
%  axis Y and X to 0.5
%   See also ita_plot_time_dB, ita_plot_freq, ita_read, ita_write.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_time">doc ita_plot_time</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',true,'figure_handle',[],'axes_handle',[],'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'),...
    'fontsize',ita_preferences('fontsize'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false,'plotcmd',@plot,'plotargs',[],'fastmode',0);
[data, sArgs] = ita_parse_arguments(sArgs, varargin);


% bugfix for multiple instances (mpo)
if numel(data) > 1
    ita_verbose_info([thisFuncStr 'There is more than one instance stored in that object. Plotting the first one only.'],0);
    data = data(1);
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
    fgh = ita_plot_time(data(1), varargin{2:end});
    for idx = 2:numel(data)
        [fgh, axh] = ita_plot_time(data(idx), varargin{2:end},'figure_handle',fgh,'hold','on');
    end
    if nargout
        varargout(1) = {fgh};
        varargout(2) = {axh};
    end
    return;
end

%% Fast Plotting Mode - Version 2
if data.nSamples > 600000 && ~sArgs.precise
    ita_verbose_info([thisFuncStr 'Oh Lord. A lot of data to plot, I will skip something.'],1);
    fast_mode = ceil(data.nSamples./200000);
else
    fast_mode = 1;
end
if sArgs.fastmode
    fast_mode = sArgs.fastmode;
end

%% Generate time vector
time_indices = 1:fast_mode:data.nSamples;
time_vector  = data.timeVector(time_indices);
time_vector  = time_vector(:);

%% Get plot data
if sArgs.nodb 
    plotData = data.timeData;
else %normal dB plot
    plotData = data.timeData_dB;
end
plotData = plotData(time_indices,:);

%% Figure and axis handle
if ~isempty(sArgs.figure_handle) && ishandle(sArgs.figure_handle)
    fgh = sArgs.figure_handle;
%     figure(fgh);
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
lnh = sArgs.plotcmd(sArgs.axes_handle,time_vector,plotData,plotargs{:});
axh = get(fgh,'CurrentAxes');
setappdata(axh,'ChannelHandles',lnh);

%% call help function
sArgs.abscissa = time_vector;
sArgs.plotData = plotData;

sArgs.xAxisType  = 'time'; %Types: time and freq
if sArgs.nodb
    sArgs.plotType   = 'time'; %Types: time, mag, phase, gdelay
    sArgs.yAxisType  = 'linear'; %Types: db and linear
    sArgs.figureName = ['Time Domain - ' data.comment];
    domainName = 'time';
else
    sArgs.plotType   = 'time_db'; %Types: time, mag, phase, gdelay
    sArgs.yAxisType  = 'db'; %Types: db and linear
    sArgs.figureName = ['Time Domain (dB) - ' data.comment];
    domainName = 'time in db';
end
sArgs.xUnit      = 's';
sArgs.yUnit      = '';
sArgs.titleStr   = data.comment;
sArgs.xLabel     = 'Time in seconds';
sArgs.yLabel     = 'Amplitude';
sArgs.data       = data; %used for domain entries in gui

[fgh,axh] = ita_plottools_figurepreparations(data,fgh,axh,lnh,'options',sArgs);
setappdata(fgh,'ita_domain', domainName);
%% Return the figure handle
if nargout
    varargout(1) = {fgh};
    varargout(2) = {axh};
end

ita_restore_matlab_default_plot_preferences(matlabdefaults) % restore matlab default settings