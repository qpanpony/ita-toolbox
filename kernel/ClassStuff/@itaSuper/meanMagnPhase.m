function varargout = meanMagnPhase(varargin)
% mean value for magnitude and phase individually
% INPUT
%   in: itaAudio to take mean from
%   mode:   mode for taking the mean over magnitude and phse
%           0: no unwrap
%           1: unwrap without reference
%           2: unwrap with reference at 100 Hz
%           3: align but no unwrap (more complex, but more accurate)

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Created:  21-Jan-2019

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>
unwrapRefFreq = 100;

narginchk(1,2);
result = varargin{1};
if nargin < 2
   mode = 1; 
else
   mode = varargin{2};
end
       
if numel(result)>1 %get max over multiple instances and not over channel of each struct
    tmp = result(1);
    data = zeros(size(tmp.freqData,1),prod(tmp.dimensions),numel(result));
    for i = 1:numel(result)
        data(:,:,i) = result(i).freqData;
    end
    result = result(1); % use first entrance as container
    
    % calculate min in magn and phase separately
    magnMed = squeeze(mean(abs(data),3));
    % phase depending on mode
    switch mode
        case 0 % pure angle
            phaseMed = squeeze(mean(angle(data),3));
        case 1 % unwrap
            phaseMed = squeeze(mean(unwrap(angle(data)),3));
        case 2 % unwrap with reference 100 Hz
            idxRefZero = tmp.freq2index(unwrapRefFreq); % get index for 20 Hz to use for unwrap
            phaseMed = squeeze(mean(ita_unwrap(angle(data),'refZeroBin',idxRefZero),3));
        case 3 % align
            alignedPhase = ita_align_phase(angle(data));
            phaseMed = squeeze(mean(alignedPhase,3));
        otherwise
    end
    
    % combine min values in magn and phase
    result.freqData = magnMed .* exp(1i * phaseMed);
    
else % max over channels
    
    % calculate min in magn and phase separately
    magnMed = squeeze(mean(abs(result.freqData),2)); 
    
    % phase depending on mode
    switch mode
        case 0 % pure angle
            phaseMed = squeeze(mean(angle(result.freqData),2));
        case 1 % unwrap
            phaseMed = squeeze(mean(unwrap(angle(result.freqData)),2));
        case 2 % unwrap with reference 100 Hz
            idxRefZero = result.freq2index(unwrapRefFreq); % get index for 20 Hz to use for unwrap
            phaseMed = squeeze(mean(ita_unwrap(angle(result.freqData),'refZeroBin',idxRefZero),2));
        case 3 % align
            alignedPhase = ita_align_phase(angle(result.freqData));
            phaseMed = squeeze(mean(alignedPhase,2));
        otherwise
    end
    
    % combine min values in magn and phase
    result.freqData = magnMed .* exp(1i * phaseMed); 
end

resChannelNames = result.channelNames;
for idxCh = 1:result.nChannels   %alter name field of all channels
    resChannelNames{idxCh} = ['meanMagnPhase(' resChannelNames{idxCh} ')'];
end
result.channelNames = resChannelNames;

%% Add history line
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.meanMagnPhase',varargin);
end