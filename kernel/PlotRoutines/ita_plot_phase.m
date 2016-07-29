function varargout = ita_plot_phase(varargin)
%ITA_PLOT_PHASE - Plots the phase of a spectrum
%  This function plots the phase of a spectrum.
%
%  Syntax:
%   ita_plot_phase(audioObjIn, options)
%
%  Options (same as in ita_plot_spk): (standard: -> )
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
%
%  Example:
%   figure-handle = ita_plot_phase(audioObjIn)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_phase">doc ita_plot_phase</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  05-Nov-2009

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',ita_preferences('nodb'),'unwrap',false,'wrapTo360',false,...
    'figure_handle',[],'axes_handle',[],'linfreq',ita_preferences('linfreq'),'linewidth',ita_preferences('linewidth'),...
    'fontname',ita_preferences('fontname'),'fontsize',ita_preferences('fontsize'), 'xlim',[],'ylim',[],'axis',[],...
    'aspectratio',[],'hold','off','precise',true,'ylog',false,'plotargs',[]);
[data sArgs] = ita_parse_arguments(sArgs, varargin);

% set default if the linewidth is not set correct
if isempty(sArgs.linewidth) || ~isnumeric(sArgs.linewidth) || ~isfinite(sArgs.linewidth)
    sArgs.linewidth = 1;
end

%% Plotting of multi-instances
if numel(data) > 1
    fgh = ita_plot_phase(data(1), varargin{2:end});
    for idx = 2:numel(data)
        [fgh, axh] = ita_plot_phase(data(idx), varargin{2:end},'figure_handle',fgh,'hold','on');
    end
    if nargout
        varargout(1) = {fgh};
        varargout(2) = {axh};
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
%get phase vector
if sArgs.unwrap
    plotData = unwrap(angle(data.freqData(bin_indices,:)),[],1) .* 180/pi;
    phase_str = 'Unwraped Phase';
elseif sArgs.wrapTo360
    plotData = wrapTo2Pi(unwrap(angle(data.freqData(bin_indices,:)),[],1)) .* 180/pi;
    phase_str = 'Phase (wrapped to 360)';
else%normal case
    plotData = angle(data.freqData(bin_indices,:)) .* 180/pi;
    phase_str = 'Phase';
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
    if isempty(sArgs.plotargs)
        lnh = semilogx(bin_vector,plotData,'LineWidth',sArgs.linewidth); %Plot phase
    else
        lnh = semilogx(bin_vector,plotData,sArgs.plotargs,'LineWidth',sArgs.linewidth); %Plot phase
    end
else
    lnh = plot(bin_vector,plotData,'LineWidth',sArgs.linewidth);
end
axh = get(fgh,'CurrentAxes');
setappdata(axh,'ChannelHandles',lnh);

% Sets both x and y axis limits %pdi changed: no scaling of y axis for phase,please
if ~isempty(sArgs.axis)
    sArgs.xlim = sArgs.axis(1:2);
    sArgs.axis = [];
end

if sArgs.unwrap
    plimits = [min(min(plotData(:)),-180) max(max(plotData(:)),180)];
    plimits(1) = 180 * floor(plimits(1)./180);
    plimits(2) = 180 * ceil (plimits(2)./180);
    sArgs.ylim = plimits;
elseif sArgs.wrapTo360
    sArgs.ylim = [0 360];
else
    sArgs.ylim = [-180 180];
end

%% call help function
sArgs.abscissa = bin_vector;
sArgs.plotData = plotData;

sArgs.xAxisType  = 'freq'; %Types: time and freq
sArgs.yAxisType  = 'linear'; %Types: db and linear
sArgs.nodb       = true;
sArgs.plotType   = 'phase'; %Types: time, mag, phase, gdelay
sArgs.xUnit      = 'Hz';
sArgs.yUnit      = 'degree';
sArgs.titleStr   = [data.comment];
sArgs.xLabel     = 'Frequency in Hz';
sArgs.yLabel     = [phase_str ' in degree'];
sArgs.figureName = 'Frequency Domain';
sArgs.legendString = data.legend;

[fgh,axh] = ita_plottools_figurepreparations(data,fgh,axh,lnh,'options',sArgs,'legend',false); %pdi: please no legend for the phase, that's overkill!

%% Set Axis for phase
if sArgs.unwrap
    if diff(plimits) > 2000
        % TODO % Ticks for wide range ticks
    else
        set(axh,'YTick',plimits(1):90:plimits(2))
    end
elseif sArgs.wrapTo360
    set(axh,'YTick',0:90:360)
else %normal case
    set(axh,'YTick',-180:90:180)
end

%% Find output parameters
if nargout  % Write Data
    varargout(1) = {fgh};
    varargout(2) = {axh};
end

ita_restore_matlab_default_plot_preferences(matlabdefaults) % restore matlab default settings
%end function
end