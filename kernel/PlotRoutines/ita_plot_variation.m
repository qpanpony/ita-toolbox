function varargout = ita_plot_variation(varargin)
%ITA_PLOT_VARIATION - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_plot_variation(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_plot_variation(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_variation">doc ita_plot_variation</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  15-Feb-2012



% TODO:
% - auch für itaAudios, dann aber auto domain gucken
% - freqrange / timerange
% - auto cut ir
% - funktion ita_plot_area() die nur plottet
% TODO von test_mgu_area:
% - auf itaAudios => automatisch berechnen (optionen: std, nanstd, minmax, ...) oder mid/upper/lower direkt angeben
% - oder nur area plotten lassen
% - berechnung auf amplitude, energie oder dB werten?
% - unterscheidung freq/ time
% - log lin bei freq
% - evtl: bei lin xscale funktioniert transparenz => x-achse linear plotten nur log beschriften
% - set appdata to avoid cursor errors (ita_plottools_buttonpress)

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaSuper', 'areaMethod', 'std', 'domain', 'auto', 'logXscale', 'auto', 'lineWidth', 2',...
    'lineSpec', '-', 'lineColor', [0 0 1], 'areaColor', 0.7, 'faceTransparency', 1, 'edgeTransparency', 0, 'grid', true, 'lineIsFristPlot' ,true,'figure_handle',[],'axes_handle',[], ...
    'justTakeFiniteValues', false);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);



if strcmpi(sArgs.domain, 'auto')
    domain = input.domain;
elseif any(strcmpi(sArgs.domain, {'time' 'freq'}))
    domain = sArgs.domain;
else
    error('unknown domain: %s (time, freq or auto) ', sArgs.domain)
end

if strcmp(sArgs.logXscale, 'auto')
    if strcmpi(domain, 'freq')
        xScaleLog = true;
    else
        if abs(diff(input.([domain 'Vector'])(1:3),2)) < 1e-15 % equal bin distance
            xScaleLog = false;
        else
            xScaleLog = true;
        end
    end
else
    xScaleLog = sArgs.logXscale;
end

lineWidth        = sArgs.lineWidth;
lineSpecString   = sArgs.lineSpec;
lineColor        = sArgs.lineColor;
faceTransparency = sArgs.faceTransparency;
edgeTransparency = sArgs.edgeTransparency;

% area color
if numel(sArgs.areaColor) == 3
    creamColor =sArgs.areaColor;
elseif numel(sArgs.areaColor) == 1
    creamColor = max(lineColor, sArgs.areaColor);
else
    error('wrong area color format')
end
edgeColor  = creamColor;

%% calc y values
if strcmpi(domain, 'freq')  % erstmal so, bis sich da jemand was schlaues einfallen laesst
    if input.allowDBPlot
        inputData = input.freqData_dB;
    else
        inputData = input.freqData;
    end
else
    inputData = input.([domain 'Data']);
end

switch lower(sArgs.areaMethod)
    case 'std'
        if any(isnan(inputData(:)))
            error('Data contains NaNs. Use option ita_plot_variation(..., ''areaMethod'', ''nanStd'')')
        end
        yMeanData = mean(inputData, 2);
        yStdData  = std(inputData, 1, 2);
        yAreaData = [yMeanData-yStdData yMeanData+yStdData];
        legendCell = {'mean value' 'standard deviation'};
    case 'nanstd'
        yMeanData = nanmean(inputData, 2);
        yStdData  = nanstd(inputData, 1, 2);
        yAreaData = [yMeanData-yStdData yMeanData+yStdData];
        legendCell = {'mean value (without NaNs)' 'standard deviation (without NaNs)'};
    case 'minmax'
        yMeanData = nanmean(inputData, 2);

        yAreaData = [min(inputData,[],2) max(inputData,[],2)];
        legendCell = {'mean value (without NaNs)' 'min / max'};
    case 'directinput'
        yMeanData = inputData(:,1);
        yAreaData = inputData(:,2:3);
        legendCell = {};
    otherwise
        error('unknown method')
end

%% x values
xVec = input.([domain 'Vector']);

if xScaleLog   % there is no zero in log scale => delete zeros
    idx2del = xVec == 0;
    xVec(idx2del) = [];
    yAreaData(idx2del,:) =[];
    yMeanData(idx2del,:) =[];
end



if sArgs.justTakeFiniteValues
    idx2del = any(~isfinite(yAreaData),2);
        xVec(idx2del) = [];
    yAreaData(idx2del,:) =[];
    yMeanData(idx2del,:) =[];
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

%% plot
if size(xVec,1) ~= size(yMeanData,1) || size(xVec,1) ~= size(yAreaData,1)
    error('')
end

if sArgs.lineIsFristPlot % plot line twice (it will be first and third entry in legend)
    plot(xVec, yMeanData,  lineSpecString, 'linewidth', lineWidth, 'color', lineColor)
end

patch([xVec(:); xVec(end:-1:1)], [yAreaData(:,1); flipud(yAreaData(:,2)) ], creamColor, 'FaceAlpha', faceTransparency, 'EdgeColor', edgeColor, 'EdgeAlpha', edgeTransparency)
hold all
plot(xVec, yMeanData,  lineSpecString, 'linewidth', lineWidth, 'color', lineColor)

if xScaleLog
    set(gca, 'Xscale', 'log');
end
hold off

xlim([min(xVec) max(xVec)])
if sArgs.grid
    grid on
    set(gca, 'layer', 'top')
end

%%

title(input.comment)
legend(legendCell)
if strcmpi(domain, 'freq')
    xlabel('Frequency (in Hz)')
elseif strcmpi(domain, 'time')
    xlabel('Time (in sec)')
end

%end function
end