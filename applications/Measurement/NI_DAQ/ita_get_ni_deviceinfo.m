function [inputChannels,outputChannels,niDevices,rateLimits] = ita_get_ni_deviceinfo(inputSens)
% determine NI hardware setup for maximum input and output capabilities

% Author: Markus Mueller-Trapet -- Email: markus.mueller-trapet@nrc.ca
% Created:  10-May-2017

if ~nargin
    inputSens = 0.01;
end

%% gather device info
niDevices	= daq.getDevices();	% returns an object with all the NI cards
nDevices	= length(niDevices);

% samplingRate limits
rateLimits = [1 192000]; % set max defaults

%% input channels
inputChannelIdx = 0;
for iDevice = 1:nDevices
    for iSub = 1:numel(niDevices(iDevice).Subsystems)
        % only have to do this here, as we go through all subsystems
        tmpLimit = round(niDevices(iDevice).Subsystems(iSub).RateLimit);
        rateLimits(1) = max(rateLimits(1),min(tmpLimit));
        rateLimits(2) = min(rateLimits(2),max(tmpLimit));
        if ~isempty(strfind(lower(niDevices(iDevice).Subsystems(iSub).SubsystemType),'input'))
            for iChannel = 1:niDevices(iDevice).Subsystems(iSub).NumberOfChannelsAvailable
                inputChannelIdx = inputChannelIdx + 1;
                inputChannels.mapping(inputChannelIdx) = {[iDevice,iChannel]};
                inputChannels.name{inputChannelIdx} = [niDevices(iDevice).ID '_' niDevices(iDevice).Subsystems(iSub).ChannelNames{iChannel,1}];
                inputChannels.type{inputChannelIdx} = niDevices(iDevice).Subsystems(iSub).DefaultMeasurementType;
                inputChannels.sensitivity(inputChannelIdx)	= inputSens;
            end
        end
    end
end
% default active state is zero
inputChannels.isActive = zeros(inputChannelIdx,1);

%% output channels
outputChannelIdx = 0;
for iDevice = 1:nDevices
    for iSub = 1:numel(niDevices(iDevice).Subsystems)
        if ~isempty(strfind(lower(niDevices(iDevice).Subsystems(iSub).SubsystemType),'output'))
            for iChannel = 1:niDevices(iDevice).Subsystems(iSub).NumberOfChannelsAvailable
                outputChannelIdx = outputChannelIdx + 1;
                outputChannels.mapping(outputChannelIdx) = {[iDevice,iChannel]};
                outputChannels.name{outputChannelIdx} = [niDevices(iDevice).ID '_' niDevices(iDevice).Subsystems(iSub).ChannelNames{iChannel,1}];
                outputChannels.type{outputChannelIdx} = niDevices(iDevice).Subsystems(iSub).DefaultMeasurementType;
            end
        end
    end
end
% default active state is zero
outputChannels.isActive = zeros(outputChannelIdx,1);


end % function