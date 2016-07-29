function varargout = ita_channelnames_to_numbers(varargin)
%ITA_CHANNELNAMES_TO_NUMBERS - Find channelnumbers according to channel names
%
%
%  Syntax: channels = ita_channelnames_to_numbers(data, channelnames, Options)
%           data - your audio struct
%           channelnames - cellstr array with channelnames to search for
%           Options (default):
%               all (false) :           returns all hits, usually only the first is returned
%               substring (false) :     searches for partial matches, e.g. finds ch1 when searching for ch
%               and (false) :           All names must be met
%
%           Returns a cell-element or array for every channelname you searched for
%
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_channelnames_to_numbers">doc ita_channelnames_to_numbers</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  14-Jan-2009

%% HUHU - rsc kann die weg?

%% Initialization
% Number of Input Arguments
narginchk(2,8);
% Find Audio Data
data = varargin{1};

if iscellstr(varargin{2})
    searchnames = varargin{2};
elseif ischar(varargin{2})
    searchnames = {varargin{2}};
else
    error('ita_channelnames_to_numbers: I cant handle that');
end


sArgs = struct('substring',false,'all',false,'and',false);
sArgs = ita_parse_arguments(sArgs,varargin,3);

channelnames = data.channelNames;

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back
if sArgs.and
    search_index = 1;
    for channel_index = 1:data.nChannels;
        
        channelnumbers{search_index}(channel_index) = isincellstr(searchnames,channelnames{channel_index},'substring',sArgs.substring);
        
        if channelnumbers{search_index}(channel_index) > 0 && ~sArgs.all
            break
        end
    end
    result{search_index} = find(channelnumbers{search_index}>0);
    if isempty(result{search_index})
        ita_verbose_info('ITA_CHANNELNAMES_TO_NUMBERS: I could not find any channel with that name',1); %#ok<*WNTAG>
    end
    
else
    for search_index = 1:length(searchnames);
        for channel_index = 1:length(channelnames);
            
            channelnumbers{search_index}(channel_index) = isincellstr(searchnames{search_index},channelnames{channel_index},'substring',sArgs.substring); %#ok<*AGROW>
            
            if channelnumbers{search_index}(channel_index) > 0 && ~sArgs.all
                break
            end
        end
        result{search_index} = find(channelnumbers{search_index}>0);
        if isempty(result{search_index})
            ita_verbose_info('ITA_CHANNELNAMES_TO_NUMBERS: I could not find any channel with that name',1); %#ok<*WNTAG>
        end
    end
end





varargout(1) = {result};
