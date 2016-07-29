function varargout = power(varargin)
% get the nices power

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(2,2);

exponent = varargin{2};
for ind = 1:numel(varargin{1})
    audioObj = varargin{1}(ind);
    
    audioObj.timeData = audioObj.timeData.^exponent;
    channelUnits = audioObj.channelUnits;
    for idx=1:audioObj.nChannels
        channelUnits{idx} = ita_deal_units(channelUnits{idx},['^' num2str(exponent)]); %TODO
    end
    audioObj.channelUnits = channelUnits;
    audioObj.channelNames = ita_sprintf('(%s).^%s', audioObj.channelNames, num2str(exponent));
    % Add history line
    varargout{1}(ind) = ita_metainfo_add_historyline(audioObj,'itaSuper.power',{audioObj,num2str(exponent)});
end
