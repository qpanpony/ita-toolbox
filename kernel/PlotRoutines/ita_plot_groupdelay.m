function varargout = ita_plot_groupdelay(varargin)
%ITA_PLOT_GROUPDELAY - plots the group delay of a spectrum
%  This function plots the group delay of a spectrum.
%
%  Syntax:
%   ita_plot_groupdelay(audioObjIn, options)
%
%   Options (default):
%           'nodb' (true) :                                 description
%           'unwrap' (false) :                              description
%           'figure_handle' ([]) :                          description
%           'axes_handle' ([]) :
%           'linfreq' ('off') : 
%           'linewidth' (ita_preferences('linewidth')) :
%           'fontname' (ita_preferences('fontname')) : 
%           'fontsize' ita_preferences('fontsize') : 
%           'xlim' ([])
%           'ylim' ([])
%           'axis' ([])
%           'aspectratio' ([])
%           'hold' ('off') : 
%           'precise' ('true') : 
%           'ylog' (false) : 
%           'normalize' (false) : 
%  Example:
%   figure_handle = ita_plot_groupdelay(audioObjIn)
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_groupdelay">doc ita_plot_groupdelay</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  19-Nov-2009 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',ita_preferences('nodb'),'unwrap',false,'figure_handle',[],'axes_handle',[],'linfreq',ita_preferences('linfreq'),'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'),'fontsize',ita_preferences('fontsize'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false,'normalize',false);
[data sArgs] = ita_parse_arguments(sArgs, varargin);

% set default if the linewidth is not set correct
if isempty(sArgs.linewidth) || ~isnumeric(sArgs.linewidth) || ~isfinite(sArgs.linewidth)
    sArgs.linewidth = 1;
end

%% Plotting of multi-instances
if numel(data) > 1
    fgh = ita_plot_groupdelay(data(1), varargin{2:end});
    for idx = 2:numel(data)
        ita_plot_groupdelay(data(idx), varargin{2:end},'figure_handle',fgh,'hold','on');
    end
    return;
end

%% Fast Plotting Mode - Version 2
if data.nBins > 600000 && ~sArgs.precise
    ita_verbose_info([thisFuncStr 'Oh Lord. A lot of data to plot, I will skip something.'],1);
    fast_mode = ceil(data.nBins./200000);
else
    fast_mode = 1;
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
%get group delay vector
plotData = ita_groupdelay(data);
plotData = plotData(bin_indices,:);

% normalize to mean
if sArgs.normalize
   plotData = bsxfun(@minus,plotData,mean(plotData));
end

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

%% Start plotting
if ~sArgs.linfreq
    lnh = semilogx(bin_vector,plotData,'LineWidth',sArgs.linewidth); %Plot phase
else
    lnh = plot(bin_vector,plotData,'LineWidth',sArgs.linewidth);
end
axh = get(fgh,'CurrentAxes');
setappdata(axh,'ChannelHandles',lnh);

%find y-axis scaling
[abs_min abs_max] = deal(min(plotData(:)), max(plotData(:)));

% get nice limits, group delay usually in fractions of a second
abs_max = 0.1*ceil(abs_max*10);
abs_min = 0.1*floor(abs_min*10);
if abs_min == abs_max
    abs_min = 0;
    abs_max = 1;
end
sArgs.ylim = [min(0,abs_min), abs_max];


%% call help function
sArgs.abscissa = bin_vector;
sArgs.plotData = plotData;

sArgs.xAxisType  = 'freq'; %Types: time and freq
sArgs.yAxisType  = 'linear'; %Types: db and linear
sArgs.nodb       = true;
sArgs.plotType   = 'gdelay'; %Types: time, mag, phase, gdelay
sArgs.xUnit      = 'Hz';
sArgs.yUnit      = 's';
sArgs.titleStr   = ['Groupdelay - ' data.comment];
sArgs.xLabel     = 'Frequency in Hz';
sArgs.yLabel     = 'Groupdelay in seconds';
sArgs.figureName = 'Frequency Domain';
sArgs.data       = data; %used for domain entries in gui
sArgs.legendString = data.legend;
[fgh,axh] = ita_plottools_figurepreparations(data,fgh,axh,lnh,'options',sArgs,'legend',0); %pdi: please no legend for the phase, that's overkill!

%% Find output parameters
if nargout  % Write Data
    varargout(1) = {fgh};
    varargout(2) = {axh};
end

ita_restore_matlab_default_plot_preferences(matlabdefaults) % restore matlab default settings
%end function
end