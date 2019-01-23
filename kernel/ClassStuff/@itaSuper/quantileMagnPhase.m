function varargout = quantileMagnPhase(varargin)
% calulate quantile values for magnitude and phase
%
%  Syntax: quantileLines = quantileMagnPhase(itaObjs, quantileBound)
%
% INPUT: 
%       itaObjs - ITA objects to perform the operation on
%       quantileBound - Boundaries for the quantile (usage see MATLAB buildin quantile)
% OUTPUT: 
%       quantileLines - itaObjs with indicated quantile lines in frequency domain

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Created:  21-Jan-2019

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(1,2);
result = varargin{1};
quantileBounds = varargin{2};

if numel(result)>1 %get max over multiple instances and not over channel of each struct
    tmp = result(1);
    data = zeros(size(tmp.freqData,1),prod(tmp.dimensions),numel(result));
    for i = 1:numel(result)
        data(:,:,i) = result(i).freqData;
    end
    result = result(1); % use first entrance as container
    result(2) = result(1);
    
    % calculate min in magn and phase separately
    magnTmp = (quantile(abs(data),quantileBounds,3));
    idxRefZero = tmp.freq2index(100); % get index for 20 Hz to use for unwrap
    phaseTmp = (quantile(ita_unwrap(angle(data),'refZeroBin',idxRefZero),quantileBounds,3));
    
    % combine min values in magn and phase
    result(1).data = magnTmp(:,:,1) .* exp(1i * phaseTmp(:,:,1));
    result(2).data = magnTmp(:,:,2) .* exp(1i * phaseTmp(:,:,2));
    
    % reset the channel names based on the individual channel instances
    resChannelNames = result.channelNames;
    for idxCh = 1:result(1).nChannels   %alter name field of all channels
        resChannelNames1{idxCh} = ['quantile_',mat2str(quantileBounds(1)*100),'(' resChannelNames{idxCh} ')'];
        resChannelNames2{idxCh} = ['quantile_',mat2str(quantileBounds(2)*100),'(' resChannelNames{idxCh} ')'];
    end
    result(1).channelNames = resChannelNames1;
    result(2).channelNames = resChannelNames2;

else % max over channels
    
    % calculate min in magn and phase separately
    magnTmp = squeeze(quantile(abs(result.freqData),quantileBounds,2)); 
    idxRefZero = result.freq2index(100); % get index for 20 Hz to use for unwrap
    phaseTmp = squeeze(quantile(ita_unwrap(angle(result.freqData),'refZeroBin',idxRefZero),quantileBounds,2));
    result = result.ch(1:2);
    
    % combine min values in magn and phase in two channels
    result.freqData = magnTmp .* exp(1i * phaseTmp); 
    
    % reset the channel names based on the comment
    resChannelComment = result.comment;
    resChannelNames{1} = ['quantile_',mat2str(quantileBounds(1)*100),'(' resChannelComment ')'];
    resChannelNames{2} = ['quantile_',mat2str(quantileBounds(2)*100),'(' resChannelComment ')'];
    result.channelNames = resChannelNames;
end

%% Add history line
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.quantileMagnPhase',varargin);
end