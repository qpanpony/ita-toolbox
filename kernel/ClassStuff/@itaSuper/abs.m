function varargout = abs(varargin)
%get the absolute value

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(1,1);
data = varargin{1};

%% take absolute value in the current domain
for idx = 1:numel(data)
    ita_verbose_info(['abs@itaSuper: abs in ' data.domain ' domain'],1);
    data(idx).data = abs(data(idx).data);
    channelNames = data(idx).channelNames;
    for iChannel = 1:data(idx).nChannels
        channelNames{iChannel} = ['abs(',channelNames{iChannel},')'];
    end
    data(idx).channelNames = channelNames;
end

%% Add history line
varargout{1} = ita_metainfo_add_historyline(data,'itaSuper.abs',varargin);