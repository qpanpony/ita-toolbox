function varargout = ita_plot_variation_area(input, sArgs)
%ITA_PLOT_VARIATION - This is a private helper function for
%ita_plot_variation that creates the area plots
%   Do not use this function directly! Returns the legend string for the
%   created area plot.
%
%  Syntax:
%   audioObjOut = ita_plot_variation_area(audioObjIn, sArgs)
%
%   sArgs is the argument struct given by ita_plot_variation. 
%
%  Example:
%   legendString = ita_plot_variation_area(audioObjIn)
%
%  See also:
%   ita_plot_variation
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_variation_area">doc ita_plot_variation_area</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Philipp Schäfer -- Email: psc@akustik.rwth-aachen.de
% Created:  22-Oct-2019

%% Initialization
domain = sArgs.domain;
xScaleLog = sArgs.logXscale;
axh = sArgs.axes_handle;

% area color
if numel(sArgs.areaColor) == 3
    areaColor = sArgs.areaColor;
else
    error('wrong area color format')
end

% edge color
if ischar(sArgs.edgeColor) && strcmp(sArgs.edgeColor, 'same')
    edgeColor  = areaColor;
else
    edgeColor  = sArgs.edgeColor;
end

%% x-values
xVec = input.([domain 'Vector']);

%% Raw y-data
if strcmpi(domain, 'freq')  % erstmal so, bis sich da jemand was schlaues einfallen laesst
    if input.allowDBPlot
        inputData = input.freqData_dB;
    else
        inputData = input.freqData;
    end
else
    inputData = input.([domain 'Data']);
end

%% Remove x=0
if xScaleLog   % there is no zero in log scale => delete zeros
    idx2del = xVec == 0;
    xVec(idx2del) = [];
    inputData(idx2del,:) = [];
end

%% Calculate y-values
dataContainsNan = any(isnan(inputData(:)));
switch lower(sArgs.areaMethod)
    case 'std'
        if dataContainsNan
            error('Data contains NaNs. Use option ita_plot_variation(..., ''areaMethod'', ''nanStd'')')
        end
        yMeanData = mean(inputData, 2);
        yStdData  = std(inputData, 1, 2);
        yAreaData = [yMeanData-yStdData yMeanData+yStdData];
        legendStr = 'std';
    case 'nanstd'
        yMeanData = nanmean(inputData, 2);
        yStdData  = nanstd(inputData, 1, 2);
        yAreaData = [yMeanData-yStdData yMeanData+yStdData];
        legendStr = 'std (without NaNs)';
    case 'percentile'
        percentileValues = sArgs.percValues;
        assert(isnumeric(percentileValues) && numel(percentileValues) == 2, 'Percentile values must be given as 2-element vector.')
        percentileValues = sort(percentileValues);
        
        yAreaData = prctile(inputData, percentileValues, 2);
        legendStr = sprintf('percentiles [%d %d]%%', percentileValues(1), percentileValues(2));
    case 'minmax'
        yAreaData = [min(inputData,[],2) max(inputData,[],2)];
        legendStr = 'min / max';
    case 'directinput'
        yAreaData = inputData;
        legendStr = '';
    otherwise
        error('unknown areaMethod')
end

%% Remove unwanted data
if sArgs.justTakeFiniteValues
    idx2del = any(~isfinite(yAreaData),2);
    xVec(idx2del) = [];
    yAreaData(idx2del,:) = [];
end

%% plot
if size(xVec,1) ~= size(yAreaData,1)
    error('Number samples in x- and y-data does not match')
end

patch(axh, [xVec(:); xVec(end:-1:1)], [yAreaData(:,1); flipud(yAreaData(:,2)) ],...
    areaColor, 'FaceAlpha', sArgs.faceTransparency,...
    'EdgeColor', edgeColor, 'EdgeAlpha', sArgs.edgeTransparency);

%% Output
if nargout
    varargout{1} = legendStr;
end

%end function
end