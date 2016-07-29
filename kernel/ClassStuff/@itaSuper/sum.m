function varargout = sum(varargin)
%get the sum of all channels

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(1,1);
data = varargin{1};

%% check for multiple instance
if numel(data)>1 %get mean overmultiple instances and not over channel of each struct
    sum_result = data(1);
    channelNames = sum_result.channelNames;
    for idxCh = 1:sum_result.nChannels   %alter name field of all channels
        channelNames{idxCh} = ['sum(' channelNames{idxCh},')'];
    end
    for idx = 2:length(data)
        sum_result = sum_result + data(idx);
    end
    sum_result.channelNames = channelNames;
else
    %% sum over channels
    sum_result = split(data,1);
    if numel(data.dimensions) > 1
        for i = 1:numel(data.dimensions)-1
            sum_result = split(sum_result,1);
        end
    end
    sum_result.data = sum(data.data,2); % the loop is cleaner but this might be faster
    % for i= 2:data.nChannels
    %     sum_result = sum_result + split(data,i);
    % end
    sum_result.channelNames = {['sum(' data.channelNames{1} ')']};
end

%% Add history line
varargout{1} = ita_metainfo_add_historyline(sum_result,'itaSuper.sum',varargin);
end