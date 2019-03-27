function varargout = ita_quantile_lines(varargin)
%ITA_MEDIAN - Get the median over all channels.
%
%  This function calculates the frequency domain quantile lines following
%  the definition of the boxplot
%
%  Syntax: analysis_results = ita_quantile_lines(dat, Options)
%           Options:
%               'minmax25' 
%               'minmax25reduced' (default)
%               'tukey'
%               'meanstd'
%               'meanminmax'
%
%  See also ita_mean, ita_get_value.
%
%  Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
%  Created:  21-Jan-2019

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];     

%% Initialization and Input Parsing
narginchk(1,2);
sArgs           = struct('pos1_a','itaAudioFrequency','options','string');
[result, sArgs] = ita_parse_arguments(sArgs,varargin); 
if nargin < 2
    options = 'minmax25reduced';
else
    options = varargin{2};
end

%% Update Header
% result.channelNames{1} = ['MEDIAN - ' result.channelNames{1}]; % TODO % check channel names

%% Calculate lines
if(strcmpi(options,'minmax25'))
    quantileLines(1) = maxMagnPhase(result);
    quantileLines(4) = medianMagnPhase(result);
    quantiletmp1 = quantileMagnPhase(result,[0.25,0.75]);
    quantileLines(5) = quantiletmp1.ch(1);
    quantileLines(3) = quantiletmp1.ch(2);
    quantiletmp2 = quantileMagnPhase(result,[0.025,0.975]);
    quantileLines(6) = quantiletmp2.ch(1);
    quantileLines(2) = quantiletmp2.ch(2);
    quantileLines(7) = minMagnPhase(result);
elseif(strcmpi(options,'minmax25reduced'))
    quantileLines(1) = maxMagnPhase(result);
    quantileLines(3) = medianMagnPhase(result);
    quantiletmp1 = quantileMagnPhase(result,[0.25,0.75]);
    quantileLines(4) = quantiletmp1.ch(1);
    quantileLines(2) = quantiletmp1.ch(2);
    quantileLines(5) = minMagnPhase(result);
elseif(strcmpi(options,'tukey'))
    quantileLines(1) = medianMagnPhase(result);
    quantileLines(2) = quantileMagnPhase(result,[0.25,0.75]);
    % calculate inter quantile difference
%     IQD = quantileLines(2)
%     
% IQD = diff(quantilesSpec);
% IQDFactor = 3;
% upperBoundIQD = medianSpec + IQDFactor/2*IQD;
% lowerBoundIQD = medianSpec - IQDFactor/2*IQD;
% OutlierLower = y < repmat(lowerBoundIQD, size(y, 1), 1);
% OutlierUpper = y > repmat(upperBoundIQD, size(y, 1), 1);
    error('not yet implemented')
elseif(strcmpi(options,'meanstd'))
    meanTmp = meanMagnPhase(result);
    stdTmp = stdMagnPhase(result);
    quantileLines(1) = meanTmp;
    
    magnTmp = abs(meanTmp.freqData) + abs(stdTmp.freqData);
    phaseTmp = angle(meanTmp.freqData) + angle(stdTmp.freqData);
    tmpITA = result;
    tmpITA.freqData = magnTmp .* exp(1i * phaseTmp);
    quantileLines(2) = tmpITA;
    
    magnTmp = abs(meanTmp.freqData) - abs(stdTmp.freqData);
    phaseTmp = angle(meanTmp.freqData) - angle(stdTmp.freqData);
    tmpITA = result;
    tmpITA.freqData = magnTmp .* exp(1i * phaseTmp);
    quantileLines(3) = tmpITA;
    
elseif(strcmpi(options,'meanminmax'))
    quantileLines(1) = maxMagnPhase(result);
    quantileLines(2) = meanMagnPhase(result);
    quantileLines(3) = minMagnPhase(result);    
else
    error('Unknown input options')
end

result = ita_merge(quantileLines);


%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end