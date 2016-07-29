function varargout = ita_split(varargin)
%ITA_SPLIT - split channels into two variables
%
%  This function splits a multichannel struct into separate variables with
%  the channels specified. It can also be used to re-arrange and copy
%  channels.
%
%  Syntax: [data_struct_A data_struct_B] = ita_split(data_struct,[channels to A],[channels to B],Options)
%  Syntax: [data_struct_A data_struct_B] = ita_split(data_struct,{ChannelNames to A},{ChannelNames to B})
%  Syntax: [data_struct_A data_struct_B] = ita_split(data_struct,[channels to A]) - others to B
%  Syntax: [data_struct_A] = ita_split(data_struct,[channels to A])
%  Syntax: [data_struct_A] = ita_split(data_struct) - delete last channel
%
%  Options (default): 
%   substring (false):  enable substring search
%                       and (false) - 'and' search for ChannelNames instead of 'or' 
%
%  See also ita_merge, ita_sum, ita_amplify.
%
%  Reference page in Help browser
%        <a href="matlab:doc ita_split">doc ita_split</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%  Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
%  Created: 2008/06/20

%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Gui
if nargin == 0
    ele = 1;
    pList{ele}.description = 'itaAudio';
    pList{ele}.helptext    = 'The itaAudio to split';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 2;
    pList{ele}.datatype    = 'line';
    
    ele = 3;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = 'result_ita_split';
    
    %call gui
    pList = ita_parametric_GUI(pList,'Split itaAudio');
    if ~isempty(pList)
        result = pList{1};
        varargout{1} = result;
        ita_setinbase(pList{2}, result);
    end
    return;
    
end

%% Initialization
%Inarg checking
narginchk(1,7);
%find data

sArgs = struct('substring',false,'and',false);
if nargin > 3
    sArgs = ita_parse_arguments(sArgs,varargin,4);
end

sArgsvar   = struct('pos1_num','itaSuper');
[data, sArgsvar] = ita_parse_arguments(sArgsvar,{varargin{1}}); %#ok<NASGU>

if numel(data)>1
    for idx = 1:numel(data)
        data(idx) = ita_split(data(idx),varargin{2:end});
    end
    varargout{1} = data;
    return
end

% domainType = ita_get_domain(data);
% dat    = data.(domainType);
% header = data;

if nargin > 2  %Allow empty channellists for the second one
    second_is_empty = isempty(varargin{3});
else
    second_is_empty = true;
end

if nargin >= 2 %rsc - lets find ChannelNames and replace them by their numbers
    if ischar(varargin{2})
        varargin{2} = {varargin{2}};
    end
    if iscellstr(varargin{2})
        varargin(2) = {cell2mat(ita_channelnames_to_numbers(varargin{1},varargin{2},'all','substring',sArgs.substring,'and',sArgs.and))};
    end
    if nargin >=3
        if ischar(varargin{3})
            varargin{3} = {varargin{3}};
        end
        if iscellstr(varargin{3})
            varargin(3) = {cell2mat(ita_channelnames_to_numbers(varargin{1},varargin{3},'all','substring',sArgs.substring))};
            if isempty(varargin{3})
                second_is_empty = true;
            end
        end
    end
end

number_channels = data.nChannels;

if nargin == 1
    channel_vec_A = 1:(number_channels-1);
    channel_vec_B = number_channels;
elseif nargin == 2 || second_is_empty %only A vec specified %Allow empty channellists for the second one
    channel_vec_A = varargin{2};
    if min(channel_vec_A) == 0
        error('ITA_SPLIT:Oh Lord. Cannot split into 0 channels.')
    end
    if (max(channel_vec_A) > number_channels)
        error('Oh Lord. More required output channels then input channels available.')
    end
    channel_vec_B = setdiff(1:number_channels,channel_vec_A);
else % A and B vec specified
    channel_vec_A = varargin{2};
    channel_vec_B = varargin{3};
    if (min(channel_vec_A) == 0) || (min(channel_vec_B) == 0)
        error('ITA_SPLIT:Oh Lord. Cannot split into 0 channels.')
    end
end

%only one output, only datA important, delete B
if nargout == 0
    %error('Oh Lord. I am producing data for the trash bin.')
elseif nargout == 1
    clear channel_vec_B;
end

%% Splitting -- Channel A
data_A = data;
data_A = split(data_A, channel_vec_A);

% Add history line
data_A = ita_metainfo_add_historyline(data_A,mfilename,varargin);

%% Channel B
if exist('channel_vec_B','var')
    data_B = data;
    data_B = split(data_B, channel_vec_B);
    
    % Add history line
    data_B = ita_metainfo_add_historyline(data_B,'ita_split',varargin);
end

%% Find output parameters
if ~isempty(channel_vec_A)
    varargout{1} = data_A;
else
    varargout(1) = {itaAudio()};
end

if nargout == 2 || exist('channel_vec_B','var')
    if ~isempty(channel_vec_B)
        varargout(2) = {data_B};
    else
        varargout{2} = itaAudio();
    end
end

%End function
end
