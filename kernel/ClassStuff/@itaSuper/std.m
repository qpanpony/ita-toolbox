function varargout = std(varargin)
%calculate standard deviation

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(1,1);
result = varargin{1};
if numel(result)>1 %get mean over multiple instances and not over channel of each struct
    tmp = result(1);
    data = zeros(size(tmp.data,1),prod(tmp.dimensions),numel(result));
    for i = 1:numel(result)
        data(:,:,i) = result(i).data;
    end
    result = result(1);
    result.data = squeeze(std(data,0,3));
else % mean over channels
    result.data = std(result.data,0,2);
end

resChannelNames = result.channelNames;
for idxCh = 1:result.nChannels   %alter name field of all channels
    resChannelNames{idxCh} = ['std(' resChannelNames{idxCh} ')'];
end
result.channelNames = resChannelNames;

%% Add history line
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.std',varargin);
end