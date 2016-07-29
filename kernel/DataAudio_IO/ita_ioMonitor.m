function ita_ioMonitor(varargin)
%ITA_IOMONITOR - shows the levels of the input channels 
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_ioMonitor(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_ioMonitor(audioObjIn)
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


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  18-Apr-2012


% TODO:
% - pink noise auf ausgänge geben können, level mit slider
% - soundkarte wechseln?
% - so umschrieben, dass konsole nutzbar...
% - maximal so grop wie monitor
% - dB sacle einstellbar

%% Initialization and Input Parsing

sArgs        = struct('blockSize',2048 , 'pageBufferSize', 3, 'dynamicRange', 144);
sArgs      = ita_parse_arguments(sArgs,varargin);

samplingRate = ita_preferences('samplingRate');


%
playDeviceID = ita_preferences('playDeviceID');
recDeviceID  = ita_preferences('recDeviceID');
% [playDeviceName, playDeviceInfo] = ita_portaudio_deviceID2string(playDeviceID);
[recDeviceName, recDeviceInfo]   = ita_portaudio_deviceID2string(recDeviceID);
if  isempty(recDeviceInfo) % isempty(playDeviceInfo) ||
    disp('Device is not installed! Select you sound card in ita_preferences > IO Settings');
    return;
end
% nChannelsOut = playDeviceInfo.outputChans;
nChannelsIn  = recDeviceInfo.inputChans;

h.maxLevels = zeros(1,nChannelsIn)-inf;  % init max levels with -inf

%% create GUI

axSize = [nChannelsIn*120 520];
figSize = axSize + [300 100];
h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[0 0 figSize], 'Name','ita_ioMonitor','MenuBar', 'none');

% create axes
h.ax = axes('parent', h.f, 'position', [(figSize-axSize)./[1.1 1.4]  axSize]./ [figSize figSize]);

% barplot for level and peak
h.barHandleMax  = bar(h.ax, 1:nChannelsIn, -abs(sArgs.dynamicRange)/2*ones(nChannelsIn,1), 'Basevalue', -abs(sArgs.dynamicRange), 'facecolor', [1 0.3 0.2]);
set(h.ax, 'NextPlot', 'add')
h.barHandle     = bar(h.ax, 1:nChannelsIn, -abs(sArgs.dynamicRange)*ones(nChannelsIn,1), 'Basevalue', -abs(sArgs.dynamicRange), 'facecolor', [0.1 0.3 1]);

% nce format
axis(h.ax, [0.5 nChannelsIn+0.5 -abs(sArgs.dynamicRange) 0])
xlabel(h.ax, 'Channel')
ylabel(h.ax, 'Level in dBFS')
grid(h.ax, 'on')
title(h.ax, recDeviceName)


h.resetPeakButton = uicontrol('style', 'pushbutton', 'parent', h.f, 'position', [20 figSize(2)/2 80 50], 'string', 'reset peak', 'callback', @resetPeak);

movegui(h.f,'west')
guidata(h.f, h)

set(h.f, 'visible', 'on')
%% init sound card
pageBuffer = ones(1, sArgs.pageBufferSize) * -1;
runMaxSpeed = true;
chanList = 1:nChannelsIn;
hPlayRec    = ita_playrec;
if ~hPlayRec('isInitialised')
    hPlayRec('init', samplingRate, playDeviceID, recDeviceID);
    % init mit mehr optionen?
    %  hPlayRec('init', sArgs.samplingRate, playDeviceID, recDeviceID,playDeviceInfo.outputChans,recDeviceInfo.inputChans,0,playrecBufferSize/sArgs.samplingRate,playrecBufferSize/sArgs.samplingRate);
    ita_verbose_info('ita_portaudio:initializing... waiting 1 second...',1);
    pause(1); %pdi: was 1 before
end


%% main loop
while ishandle(h.f)
    
    pageBuffer = [pageBuffer hPlayRec('rec', sArgs.blockSize, chanList)]; %#ok<AGROW>
    
    if(runMaxSpeed)
        while(hPlayRec('isFinished', pageBuffer(1)) == 0)
        end
    else
        hPlayRec('block', pageNumList(1));
    end
    
    lastRecording = hPlayRec('getRec', pageBuffer(1));
    if~isempty(lastRecording)
        newLevelValues = 10*log10(sum(lastRecording.^2) / sArgs.blockSize );
        h = guidata(h.f);
        h.maxLevels = max(h.maxLevels, newLevelValues);
        guidata(h.f, h);
        set(h.barHandle, 'yData',newLevelValues )
        set(h.barHandleMax, 'yData', h.maxLevels )
    end
    
    drawnow;
    
    playrec('delPage', pageBuffer(1));
    pageBuffer = pageBuffer(2:end);
end
end


function resetPeak(self, eventdata)
h = guidata(self);
h.maxLevels = h.maxLevels -inf;
guidata(h.f, h)
end