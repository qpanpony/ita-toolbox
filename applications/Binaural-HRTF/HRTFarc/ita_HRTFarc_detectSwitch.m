function motorTimeOut = ita_HRTFarc_detectSwitch(audioObject)
%% find times indicating entry and exit points of the switch area
%  at the beginning and end of a full arc rotation.
%  
%  Input : audioObject - 1 channel with motor signal 
%  Output: motorTimeOut = [a b c d]
%          a, b = first switch range
%          c, d = second switch range
%  d - a : corresponds to duration extracted from moving arc rigid body (tracking data)
%  d - b : 360° omitting most of the acceleration phase
%          --> more suitable for rotation speed estimation
%          --> preferable range to be used in case of no directional correction via tracking data
%  b - a : time spent while passing the first switch 
%          --> to be added to start time detected from tracking data (ca. a)

    % === rectify and integrate signal
    absData = audioObject;
    absData.timeData = abs(audioObject.timeData);
    integData = ita_integrate(absData, 'domain', 'time');
    
    % === round to 3 decimal resolution to remove effect of small fluctuations 
    integData.timeData = round(integData.timeData,3);
    
    
    % === start of first switch pulse
    switchSamples(1) = find(integData.timeData == min(integData.timeData),1,'last');
    
    % === end of first and start of second switch pulse
    % (median is used, assuming that the duration between the two peaks 
    % is much longer than the switch regions)
    switchSamples(2) = find(integData.timeData == median(integData.timeData),1,'first');
    switchSamples(3) = find(integData.timeData == median(integData.timeData),1,'last');
   
    % === end of second switch pulse 
    switchSamples(4)= find(integData.timeData == max(integData.timeData),1,'first');
       
    if switchSamples(3)-switchSamples(2)< switchSamples(2)-switchSamples(1) || ...
            switchSamples(3)-switchSamples(2)< switchSamples(4)-switchSamples(3)
        % plot data to debug and throw error
        switches = zeros(size(integData.timeData));
        switches(switchSamples) = 1;
        integData.pt; hold on; plot((1:length(switches))/integData.samplingRate,switches)
        error('getMotorSwitchTimes: The second peak is detected too early. Please take a look')
    end
    
    motorTimeOut = switchSamples/ integData.samplingRate;
end