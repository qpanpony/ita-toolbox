function varargout = ita_plot_variation(varargin)
%ITA_PLOT_VARIATION - Plots the variation of an itaSuper object over all
%channels
%  This function allows to plot the variation over multiple channels of an
%  itaSuper object. Therefore, a line plot which is used as a reference
%  value (e.g. mean) is combined with one or multiple area plots with refer
%  to the variation of the data.
%
%  Syntax:
%   audioObjOut = ita_plot_variation(audioObjIn, options)
%
%   Plot method options (default):
%       'lineMethod' ('mean'): Method for the data generation of the line plot.
%           'none':         No line is plotted
%           'reference':    The first channel is taken as reference
%           'mean':         Mean value is calculated for each sampling point
%           'median':       Median value is calculated for each sampling point
%           'directinput':  Each channel refers to one plot data:
%                           first channel refers to line plot. Every
%                           additional two channels refer to an area plot.
%                           This overwrites areaMethod
%
%       'areaMethod' ('std'):
%       Method(s) for the data generation of area plot(s). It is supported
%       to have multiple plots using a cell array (e.g. {'std', 'minmax'}).
%           'std':          Calculates the standard deviation
%           'nanstd':       Calculates the standard deviation, excluding NaNs
%           'percentile':   Creates an area between two percentiles.
%           'minmax':       Creates an area plot from minimum to maximum
%           'directinput':  See lineMethod
%
%       'percValues' ([25 75]): Cell with one 2-element vector per area plot
%                               using the percentile method (see examples).
%
%   Options (default):
%       'domain' ('auto'):      Domain for plots ('time', 'freq' or 'auto')
%       'logXscale' ('auto'):   Set x-axis scale to log? (false, true or 'auto')
%       'lineWidth' (2):        Line width of line plot
%       'lineSpec' ('-'):       Style of line plot
%       'lineColor' ([0 0 1]):  Color of line plot
%       'areaColor' (0.7):      Color of area plots. Either Nx3 rgb-matrix
%                               or single value between 0 and 1 which refers
%                               to the brightness. In the latter case, default
%                               colors with the specified brightness are used.
%       'faceTransparency' (1): Transparancy of area plots
%       'edgeColor' ('same'):   Color of the edges of the area plots. Per
%                               default uses same color as for area plots
%                               Otherwise, an [r,g,b]-vector can be specified.
%       'edgeTransparency' (1): Transparency of area edges
%       'grid' (true):          Enable/Disable grid
%
%       'justTakeFiniteValues' (false): Allow inf values or not
%       'figure_handle' ([]):           Figure handle for plotting (default = new figure)
%       'axes_handle' ([]):             Axes handle for plotting (default = new axes)
%
%  Example:
%   [figureHandle, axesHandle] = ita_plot_variation(audioObjIn, 'areaMethod', {'std', 'minmax'})
%
%  Examples using percentiles:
%   [figureHandle, axesHandle] = ita_plot_variation(audioObjIn, 'areaMethod', {'percentile', 'percentile', 'minmax'}, 'percValues', {[25 75], [5 95], []})
%
%  If only using one percentile plot, it is possible to ommit the cell:
%   [figureHandle, axesHandle] = ita_plot_variation(audioObjIn, 'areaMethod', {'percentile', 'minmax'}, 'percValues', [25 75])
%
%  See also:
%   ita_plot_freq, ita_plot_time
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_variation">doc ita_plot_variation</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  15-Feb-2012
% Updated:  22-Oct-2019 (PSC)


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaSuper', 'lineMethod', 'mean', 'areaMethod','std', 'percValues', [],...
    'domain', 'auto', 'logXscale', 'auto',...
    'lineWidth', 2, 'lineSpec', '-', 'lineColor', [0 0 1],...
    'areaColor', 0.7, 'faceTransparency', 1,'edgeColor', 'same', 'edgeTransparency', 1,...
    'grid', true, 'justTakeFiniteValues', false, 'figure_handle',[],'axes_handle',[]);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);


if strcmpi(sArgs.domain, 'auto')
    sArgs.domain = input.domain;
elseif ~any(strcmpi(sArgs.domain, {'time' 'freq'}))
    error('unknown domain: %s (time, freq or auto) ', sArgs.domain)
end
domain = sArgs.domain;

if ischar(sArgs.logXscale) && strcmp(sArgs.logXscale, 'auto')
    if strcmpi(domain, 'freq')
        sArgs.logXscale = true;
    else
        if abs(diff(input.([domain 'Vector'])(1:3),2)) < 1e-15 % equal bin distance
            sArgs.logXscale = false;
        else
            sArgs.logXscale = true;
        end
    end
elseif ~islogical(sArgs.logXscale)
    error('logXscale must be either a boolean or ''auto''')
end

lineWidth        = sArgs.lineWidth;
lineSpecString   = sArgs.lineSpec;
lineColor        = sArgs.lineColor;

%Number of area plots
if ischar(sArgs.areaMethod) && isrow(sArgs.areaMethod)
    sArgs.areaMethod = {sArgs.areaMethod};
end
assert(iscell(sArgs.areaMethod), 'areaMethod must either be a char row vector or a cell containing strings')
nAreas = numel(sArgs.areaMethod);

% area color
if size(sArgs.areaColor, 2) == 3
    areaColors = sArgs.areaColor;
elseif numel(sArgs.areaColor) == 1
    if nAreas == 1
        areaColors = max(lineColor, sArgs.areaColor);
    else
        defaultColors = [1 0 0; 0 0 1; 1 0 1; 0 1 1; 1 1 0];
        nDefaultColors = size(defaultColors, 1);
        assert(nAreas <= nDefaultColors, 'Only %d area plots are supported if using default colors', nDefaultColors)
        areaColors = max(defaultColors(1:nAreas, :), sArgs.areaColor);
    end
else
    error('Wrong area color format')
end

assert(size(areaColors, 1) == nAreas, 'Number of area colors does not match number of defined areas')

%% Calculate mean values
if strcmpi(domain, 'freq')  % erstmal so, bis sich da jemand was schlaues einfallen laesst
    if input.allowDBPlot
        inputData = input.freqData_dB;
    else
        inputData = input.freqData;
    end
else
    inputData = input.([domain 'Data']);
end


if strcmpi(sArgs.lineMethod, 'directinput') || any(strcmpi(sArgs.areaMethod, 'directinput'))
    sArgs.lineMethod = 'directinput';
    sArgs.areaMethod(:) = {'directinput'};
end


dataContainsNan = any(isnan(inputData(:)));
switch lower(sArgs.lineMethod)
    case 'none'
        lineLegendStr = [];
        yLineData = [];
    case 'reference'
        yLineData = inputData(:,1);
        lineLegendStr = 'reference';
    case 'mean'
        if dataContainsNan
            lineLegendStr = 'mean (without NaNs)';
            yLineData = nanmean(inputData, 2);
        else
            lineLegendStr = 'mean';
            yLineData = mean(inputData, 2);
        end
    case 'median'
        if dataContainsNan
            lineLegendStr = 'median (without NaNs)';
            yLineData = nanmedian(inputData, 2);
        else
            lineLegendStr = 'median';
            yLineData = median(inputData, 2);
        end
    case 'directinput'
        yLineData = inputData(:,1);
        lineLegendStr = '';
    otherwise
            error('unknown lineMethod')
end

%% x values
xVec = input.([domain 'Vector']);

if sArgs.logXscale   % there is no zero in log scale => delete zeros
    idx2del = xVec == 0;
    xVec(idx2del) = [];
    if ~isempty(yLineData)
        yLineData(idx2del,:) =[];
    end
end

%% try to use ita plot keys
if isempty( sArgs.figure_handle )
    fgh = ita_plottools_figure;
else
   fgh = sArgs.figure_handle; 
end
if isempty( sArgs.axes_handle )
    axh = gca;
else
    axh = sArgs.axes_handle;
end
ita_plottools_cursors('off',[],axh);
setappdata(fgh,'FigureHandle',fgh)
setappdata(fgh,'AxisHandles',axh)

setappdata(axh,'AllChannels',1)
setappdata(axh,'ActiveChannel',1)

%% Area Plots
legendStrCell = cell(1, nAreas);

newArgStruct = sArgs;
newArgStruct.figure_handle = fgh;
newArgStruct.axes_handle = axh;

areaInput = input;
if strcmpi(sArgs.areaMethod, 'directinput')
    assert(input.nChannels == 2*nAreas+1, 'Number of channels not sufficient for direct input method: First channel for the line plot, then 2 channels for each area plot.')
    areaData = input.([domain 'Data']);
end
for idxArea = nAreas:-1:1
    newArgStruct.areaMethod = sArgs.areaMethod{idxArea};
    newArgStruct.areaColor = areaColors(idxArea, :);
    if iscell(sArgs.percValues)
        newArgStruct.percValues = sArgs.percValues{idxArea};
    end
    if strcmpi(sArgs.areaMethod, 'directinput')
        areaInput.([domain 'Data']) = areaData(:, [2*idxArea 2*idxArea+1]);
    end
    
    legendStrCell{idxArea} = ita_plot_variation_area(areaInput, newArgStruct);
    hold on
end
legendStrCell = legendStrCell(end:-1:1);

%% Line Plot
if ~isempty(yLineData)
    plot(axh, xVec, yLineData,  lineSpecString, 'linewidth', lineWidth, 'color', lineColor)
    legendStrCell{end+1} = lineLegendStr;
end

%% Settings
if sArgs.logXscale
    set(axh, 'Xscale', 'log');
end
hold off

xlim([min(xVec) max(xVec)])
if sArgs.grid
    grid on
    set(axh, 'layer', 'top')
    set(axh, 'FontSize', 12)
end

title(input.comment)
if ~isempty(legendStrCell)
    plotHandles = axh.Children;
    legend(plotHandles, legendStrCell(end:-1:1));
end


if strcmpi(domain, 'freq')
    xlabel('Frequency in Hz')
    ylabel('Modulus in dB')
    if sArgs.logXscale
        [xticks, xlabels] = ita_plottools_ticks('log');
    else
        [xticks, xlabels] = ita_plottools_ticks('lin');
    end
    set(axh, 'XTick', xticks, 'XTickLabel', xlabels)
elseif strcmpi(domain, 'time')
    xlabel('Time in sec')
    ylabel('Amplitude')
end

%% Output
if nargout
    varargout{1} = fgh;
    varargout{2} = axh;
end

%end function
end