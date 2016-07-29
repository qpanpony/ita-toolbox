function varargout = mean(varargin)
% normal mean value

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(1,1);
data = varargin{1};
if numel(data)>1 %get mean over multiple instances and not over channel of each struct
    result = sum(data)/numel(data);
    
    resChannelNames = result.channelNames;
    for idxCh = 1:result.nChannels   %alter name field of all channels
        resChannelNames{idxCh} = ['mean' resChannelNames{idxCh}(4:end)];
    end
    result.channelNames = resChannelNames;
else % mean over channels
    result = sum(data)/data.nChannels;
    result.channelNames = {['mean' result.channelNames{1}(4:end)]};
end

%% Add history line
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.mean',varargin);
end