function varargout = ita_outputMonitor(varargin)
%ITA_OUTPUTMONITOR - Play noise on each channel
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_outputMonitor
%
%
%  Example:
%   audioObjOut = ita_outputMonitor
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_ioMonitor">doc ita_ioMonitor</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  25-07-2013



%% create GUI
[playDeviceName playDeviceInfo] = ita_portaudio_deviceID2string(ita_preferences('playDeviceID')); %#ok<ASGLU>
[recDeviceName recDeviceInfo] = ita_portaudio_deviceID2string(ita_preferences('recDeviceID')); %#ok<ASGLU>

nOutputChans = playDeviceInfo.outputChans;

checkboxHeight =50;
checkboxWidth = 80;

checkboxesWidth = nOutputChans/8*(checkboxWidth+10)+20;
checkboxesHeight = min(nOutputChans,8)*checkboxHeight+20;
axSize = [checkboxesWidth checkboxesHeight];
figSize = axSize + [100 0] ;
h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[0 0 figSize], 'Name','IO Monitor','MenuBar', 'none');

% checkbox for each channel

for index = 1:nOutputChans
     xIndex = (mod(index,8));
    if (xIndex == 0)
        xIndex = 8;
    end
        
    positionX = figSize(2) - 20 - xIndex*checkboxHeight+10;
    positionY = 20+(checkboxWidth+10)*(floor(index/8.1));
    h.outputCheckbox(index) = uicontrol('style', 'checkbox', 'parent', h.f, 'position', [positionY positionX checkboxWidth checkboxHeight], 'string', ['Out' num2str(index)],'value',1, 'callback', @resetPeak);
end



% play button
h.resetPeakButton = uicontrol('style', 'pushbutton', 'parent', h.f, 'position', [figSize(1)-80 figSize(2)-60 80 50], 'string', 'Play Channels', 'callback', @playChannels);
set(h.f, 'visible', 'on')
movegui(h.f,'west')
guidata(h.f, h)
end

function playChannels(self, eventdata)
h = guidata(self);
channelVector = zeros(1,length(h.outputCheckbox));
for index = 1:length(channelVector)
    channelVector(index) = get(h.outputCheckbox(index),'Value');
end


% generate noise for channels
[playDeviceName playDeviceInfo] = ita_portaudio_deviceID2string(ita_preferences('playDeviceID')); %#ok<ASGLU>
[recDeviceName recDeviceInfo] = ita_portaudio_deviceID2string(ita_preferences('recDeviceID')); %#ok<ASGLU>

nOutputChans = playDeviceInfo.outputChans;
noise = ita_generate('pinknoise',1,44100,16);

% generate noise output
signalLength = sum(channelVector) * length(noise.timeData);
signal = repmat({noise.timeData},1,sum(channelVector));
timeData = zeros(signalLength,nOutputChans);
timeData(:,channelVector == 1) = blkdiag(signal{:});

noise.timeData = timeData;
ita_portaudio_run(noise,'OutputChannels',1:nOutputChans,'CancelButton','true')

end

function resetPeak(self, eventdata)

end