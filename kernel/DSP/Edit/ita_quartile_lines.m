function varargout = ita_quartile_lines(varargin)
%ITA_MEDIAN - Get the median over all channels.
%
%  This function calculates the frequency domain quartile lines following
%  the definition of the boxplot
%
%  Syntax: analysis_results = ita_quartile_lines(dat, Options)
%           Options:
%               'minmax25' (default)
%               'minmax25reduced'
%               'tukey'
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
sArgs           = struct('pos1_a','itaAudioFrequency');
[result, sArgs] = ita_parse_arguments(sArgs,varargin); 
if nargin < 2
    options = 'minmax25';
else
    options = varargin{2};
end

%% Update Header
% result.channelNames{1} = ['MEDIAN - ' result.channelNames{1}]; % TODO % check channel names

%% Calculate lines
if(strcmpi(options,'minmax25'))
    quartileLines(1) = maxMagnPhase(result);
    quartileLines(4) = medianMagnPhase(result);
    quartileLines([5,3]) = quartileMagnPhase(result,[0.25,0.75]);
    quartileLines([6,2]) = quartileMagnPhase(result,[0.025,0.975]);
    quartileLines(7) = minMagnPhase(result);
elseif(strcmpi(options,'minmax25reduced'))
    quartileLines(1) = maxMagnPhase(result);
    quartileLines(3) = medianMagnPhase(result);
    quartileLines([4,2]) = quartileMagnPhase(result,[0.25,0.75]);
    quartileLines(5) = minMagnPhase(result);
elseif(strcmpi(options,'tukey'))
    quartileLines(1) = medianMagnPhase(result);
    quartileLines(2) = quartileMagnPhase(result,[0.25,0.75]);
    % calculate inter quartile difference
%     IQD = quartileLines(2)
%     
% IQD = diff(quantilesSpec);
% IQDFactor = 3;
% upperBoundIQD = medianSpec + IQDFactor/2*IQD;
% lowerBoundIQD = medianSpec - IQDFactor/2*IQD;
% OutlierLower = y < repmat(lowerBoundIQD, size(y, 1), 1);
% OutlierUpper = y > repmat(upperBoundIQD, size(y, 1), 1);
    
else
    error('Unknown input options')
end

result = ita_merge(quartileLines);


%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end