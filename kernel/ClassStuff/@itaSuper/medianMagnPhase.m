function varargout = medianMagnPhase(varargin)
% median value for magnitude and phase individually

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Created:  21-Jan-2019

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(1,1);
result = varargin{1};
if numel(result)>1 %get max over multiple instances and not over channel of each struct
    tmp = result(1);
    data = zeros(size(tmp.freqData,1),prod(tmp.dimensions),numel(result));
    for i = 1:numel(result)
        data(:,:,i) = result(i).freqData;
    end
    result = result(1); % use first entrance as container
    
    % calculate min in magn and phase separately
    magnMed = squeeze(median(abs(data),3));
    idxRefZero = tmp.freq2index(100); % get index for 20 Hz to use for unwrap
    phaseMed = squeeze(median(ita_unwrap(angle(data),'refZeroBin',idxRefZero),3));
    
    % combine min values in magn and phase
    result.data = magnMed .* exp(1i * phaseMed);
    
else % max over channels
    
    % calculate min in magn and phase separately
    magnMed = squeeze(median(abs(result.freqData),2)); 
    idxRefZero = result.freq2index(100); % get index for 20 Hz to use for unwrap
    phaseMed = squeeze(median(ita_unwrap(angle(result.freqData),'refZeroBin',idxRefZero),2));
    
    % combine min values in magn and phase
    result.data = magnMed .* exp(1i * phaseMed); 
end

resChannelNames = result.channelNames;
for idxCh = 1:result.nChannels   %alter name field of all channels
    resChannelNames{idxCh} = ['medianMagnPhase(' resChannelNames{idxCh} ')'];
end
result.channelNames = resChannelNames;

%% Add history line
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.medianMagnPhase',varargin);
end