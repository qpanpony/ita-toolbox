function varargout = maxMagnPhase(varargin)
% maximum value for magnitude and phase individually

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Created:  21-Jan-2019

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



narginchk(1,1);
result = varargin{1};
% all_meas = ita_merge(varargin{1}.ch(1));
if numel(result)>1 %get max over multiple instances and not over channel of each struct
    tmp = result(1);
    data = zeros(size(tmp.freqData,1),prod(tmp.dimensions),numel(result));
    for i = 1:numel(result)
        data(:,:,i) = result(i).freqData;
    end
    result = result(1); % use first entrance as container
    
    % calculate max in magn and phase separately
    magnMax = squeeze(max(abs(data),[],3));
    idxRefZero = tmp.freq2index(100); % get index for 20 Hz to use for unwrap
    phaseMax = squeeze(max(ita_unwrap(angle(data),'refZeroBin',idxRefZero),[],3));    
    
    % combine max values in magn and phase
    result.freqData = magnMax .* exp(1i * phaseMax);
else % max over channels
    % calculate max in magn and phase separately
    magnMax = squeeze(max(abs(result.freqData),[],2)); 
    idxRefZero = result.freq2index(100); % get index for 20 Hz to use for unwrap
    phaseMax = squeeze(max(ita_unwrap(angle(result.freqData),'refZeroBin',idxRefZero),[],2));
    % combine max values in magn and phase
    result.freqData = magnMax .* exp(1i * phaseMax); 
end

resChannelNames = result.channelNames;
for idxCh = 1:result.nChannels   %alter name field of all channels
    resChannelNames{idxCh} = ['maxMagnPhase(' resChannelNames{idxCh} ')'];
end
result.channelNames = resChannelNames;

%% Add history line
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.maxMagnPhase',varargin);
end