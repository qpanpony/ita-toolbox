function varargout = ita_median(varargin)
%ITA_MEDIAN - Get the median over all channels.
%
%  This function calculates the median over all channels.
%
%  Syntax: audioObj = ita_median(audioObj)
%
%  See also ita_mean, ita_get_value.
%
%  Reference page in Help browser <a href="matlab:doc ita_median">doc ita_median</a>
%
%  Author: Matthias Lievens -- Email: mli@akustik.rwth-aachen.de
%  Created:  05-Nov-2008

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];     

%% Initialization and Input Parsing
narginchk(1,1);
sArgs           = struct('pos1_a','itaAudioFrequency');
[result, sArgs] = ita_parse_arguments(sArgs,varargin); 

%%
ita_verbose_info([thisFuncStr 'Please be careful with this implementation!'],1)

%% Update Header
result.channelNames{1} = ['MEDIAN - ' result.channelNames{1}]; % TODO % check channel names

%% Median
result.freqData = median( result.freqData ,2 );

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end