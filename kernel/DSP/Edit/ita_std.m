function varargout = ita_std(varargin)
%ITA_STD - Get the std over all channels
%  This function calculates the std over all channels. If audioObj is a
%  cell array, the std is calculated for each channel over the dimension
%  of the cell array (used to average measurement).
%
%  Syntax: audioObj = ita_std(audioObj, Options)
%
%       Options (default):
%           'same_channelnames_only' (false):   calculate std only over channels with same name
%
%   See also ita_median, ita_rms, ita_sum, ita_add, ita_get_value.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_std">doc ita_std</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  02-Sep-2008

%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Initialization and Input Parsing
narginchk(1,3);
sArgs           = struct('pos1_a','itaSuper','same_channelnames_only',false);
[result, sArgs] = ita_parse_arguments(sArgs,varargin);

if numel(result) > 1 %get std over cell array dimension and not over channel of each struct
    tmp = result(1);
    data = zeros(size(tmp.data,1),prod(tmp.dimensions),numel(result));
    for i = 1:numel(result)
        data(:,:,i) = result(i).data;
    end
    result = result(1);
    result.data = squeeze(std(data,0,3));
    
    resChannelNames = result.channelNames;
    for idxCh = 1:result.nChannels   %alter name field off all channels
        resChannelNames{idxCh} = ['std(' resChannelNames{idxCh} ')'];
    end
    result.channelNames = resChannelNames;
else
    if sArgs.same_channelnames_only
        rest = result;
        idx = 1;
        while rest.nChannels > 0
            chname1 = rest.channelNames{1};
            [temp, rest] = ita_split(rest,chname1);
            temp = std(temp);
            temp = ita_metainfo_rm_historyline(temp);
            result(idx) = temp;
            idx = idx+1;
        end
        result = merge(result);     
    else
        result = std(result);
    end
end
%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end