function varargout = conj(varargin)
% get the conj compl.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(1,1);
data = varargin{1};
%% Conjugate Complex
for idx = 1:numel(data)
    data(idx).freqData = conj(data(idx).freqData);
    channelNames = data(idx).channelNames;
    for iChannel = 1:data(idx).nChannels
        channelNames{iChannel} = ['conj(',channelNames{iChannel},')'];
    end
    data(idx).channelNames = channelNames;
end

%% Add history line
varargout{1} = ita_metainfo_add_historyline(data,'itaSuper.conj',varargin);
end