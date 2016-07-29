function plot_makeNiceTicks(obj, evd)
% replace the ticks from 10^something to normal values

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


hAxis = gca;

% first use automatic numbering, to make sure the values are correct
set(hAxis,'XTickMode','auto');
% get the numbers and convert them to nice numbers (instead of 10^...)
niceTicks = round(0.1*get(hAxis,'XTick'))*10;
if numel(niceTicks) == 1
    singleTick = niceTicks;
    minMaxFreq = get(hAxis, 'XLim');
    minFreq = minMaxFreq(1);
    maxFreq = minMaxFreq(2);
    % round up / down
    tickExponent = log10(singleTick);
    minUnit = 10^(tickExponent-1);
    maxUnit = 10^(tickExponent);
    % round to a granularity of ...Unit
    minFreq = minUnit * ceil(minFreq/minUnit);
    if maxFreq > 2*singleTick
        maxFreq = maxUnit * floor(maxFreq/maxUnit);
    else
        % if the upper bound is is less than twice the Tick value
        % use a smaller granularity
        maxFreq = minUnit * floor(maxFreq/minUnit);
        maxUnit = maxFreq - singleTick;
    end
    
    % find the position of the single Tick
    positionSingleTick = (singleTick - minFreq) / minUnit + 1;    
    % set all ticks (avoid double entry of singleTick)
    niceTicks = [minFreq:minUnit:singleTick singleTick:maxUnit:maxFreq];
%     indFirstValue = find(niceTicks == singleTick,1);
    indOtherValues = find(niceTicks(positionSingleTick+1:end) == singleTick) + positionSingleTick;
    niceTicks(indOtherValues) = [];
    
    niceTickLabelAll = cellstr(num2str(niceTicks.'));
    % delete all except first, last and singleTick
%     niceTickLabel = char(size(niceTickLabelAll));
    niceTickLabel = cell(size(niceTickLabelAll));
    niceTickLabel([1 positionSingleTick end]) = niceTickLabelAll([1 positionSingleTick end]);
%     niceTickLabel(~[1 positionSingleTick end],:) = repmat('',[1 size(niceTickLabel,2)]);
else
    niceTickLabel = niceTicks;
end
set(hAxis, 'XTick', niceTicks);
set(hAxis,'XTickLabel', niceTickLabel);
end
