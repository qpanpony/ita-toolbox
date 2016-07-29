function  ita_tools_frequencygenerator(varargin)
%ITA_TOOLS_FREQUENCYGENERATOR - frequency generator
%  This function is a sine frequency generator with GUI.
%
%  Syntax:
%    ita_tools_frequencygenerator(options)
%
%   Options (default):
%           'freqRange' ([19 20000])                         : frequency range in HZ
%           'samplingRate' (ita_preferences('samplingRate')) : sampling rate in Hz
%           'volumeRange' ([-100 0])                         : range of volume in dBFS
%
%  Example:
%   ita_tools_frequencygenerator
%
%  See also:
%   ita_generate, ita_tools_aliasing_demo
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_tools_frequencygenerator">doc ita_tools_frequencygenerator</a>

% <ITA-Toolbox>
% This file is part of the application Tools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  10-Dec-2014

%% Initialization and Input Parsing
sArgs  = struct( 'freqRange', [19 20000], 'samplingRate', ita_preferences('samplingRate'), 'volumeRange', [-100 0] );
sArgs  = ita_parse_arguments(sArgs,varargin);

gData.data.samplingRate = sArgs.samplingRate;
gData.data.soundCardID  = ita_preferences('PlayDeviceID');

gData.data.freq_high    = sArgs.freqRange(2);
gData.data.freq_low     = sArgs.freqRange(1);

gData.data.volume_high  = sArgs.volumeRange(2);
gData.data.volume_low   =  sArgs.volumeRange(1);

gData.data.outputChannels  = ita_channelselect_gui(0, 1, 'onlyoutput');
gData.onlinePar  = struct('freq', 100, 'level', -30);

%% create GUI

h.f = figure('position', [100 100 600 300], 'name', mfilename, 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'nextPlot', 'new');% , 'CloseRequestFcn', @closeRegFcn);
defaultOptions = {'parent', h.f, 'units', 'normalized'};
defaultHeight = 0.08;

h.tx_title = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.1 0.8 0.8  0.15], 'string', 'Frequency Generator', 'fontSize', 20, 'horizontalAlignment', 'center');

h.sl_freq = uicontrol('style','slider', defaultOptions{:}, 'position', [0.1 0.6 0.8 defaultHeight], 'SliderStep', [0.005 0.1], 'String', 'Frequency','Value', 0.5198, 'Callback', @freqSliderUpdated);
h.ed_freq = uicontrol('style', 'edit',  defaultOptions{:}, 'position', [0.5 0.7 0.4  defaultHeight], 'string', '100', 'callback', @freqEditUpdate, 'fontSize', 13);
h.tx_freq = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.2 0.7 0.3  defaultHeight], 'string', 'Frequency in Hz: ', 'fontSize', 13);
% % h.ax_freq = axes(defaultOptions{:}, 'position', [0.1 0.7 0.8 0.07]);

h.sl_volume = uicontrol('style','slider', defaultOptions{:}, 'position', [0.1 0.3 0.8 defaultHeight], 'Min', gData.data.volume_low, 'Max', gData.data.volume_high, 'SliderStep', [0.01 0.1], 'value', -50,'callback', @volumeSliderUpdated);
h.ed_volume = uicontrol('style', 'edit',  defaultOptions{:}, 'position', [0.5 0.4 0.4 defaultHeight], 'string', '-50', 'Callback', @volumeEditUpdate, 'fontSize', 13);
h.tx_volume = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.2 0.4 0.3 defaultHeight], 'string', 'Level in dBFS: ', 'fontSize', 13);

h.tb_active = uicontrol('style', 'togglebutton',  defaultOptions{:}, 'position', [0.4 0.1 0.2 defaultHeight], 'string', 'On / Off: ', 'fontSize', 13, 'callback', @OnOffCallback);


gData.h         = h;
guidata(h.f, gData)

volumeSliderUpdated(gData.h.sl_volume)
freqSliderUpdated(gData.h.sl_freq)

%end function
end


function OnOffCallback(toggleButton, ~)

if get(toggleButton, 'Value')
    startGenerator(toggleButton)
else
    gData = guidata(toggleButton);
    gData.onlinePar.isRunning = false;
    guidata(gData.h.f, gData);
end

end

function startGenerator(obj, ~)
gData = guidata(obj);

pageBufferCount = 3;
approxBlockSize = 3000;  % will be adjusted to allow full periods of sine waves
outputChannel   = gData.data.outputChannels;

% init sound card if necessary
if ~playrec('isInitialised')
    playrec('init', gData.data.samplingRate, gData.data.soundCardID, -1);
    fprintf('\t playrec... waiting 0.5 second \n');
    pause(0.5);
end

% init variables
pageBuffer = zeros(pageBufferCount,1);

gData.onlinePar.isRunning    = true;
guidata(gData.h.f, gData);
currentFrequency = 0;

while gData.onlinePar.isRunning && ishandle(gData.h.f)
    
    if gData.onlinePar.freq ~= currentFrequency % generate new sine
        
        nPeriods = round(approxBlockSize / gData.data.samplingRate * gData.onlinePar.freq);                                                 % full periods
        blockSize = round(nPeriods * gData.data.samplingRate / gData.onlinePar.freq);
        
        currentFrequency = nPeriods * gData.data.samplingRate  / blockSize; % adjust frequency to integer of samples
        gData.onlinePar.freq = currentFrequency;
        guidata(gData.h.f, gData);
        set(gData.h.ed_freq, 'string', sprintf('%3.0f', currentFrequency))
        
        audioDataRAW = sin(2*pi* (1:blockSize)' / gData.data.samplingRate * currentFrequency);
        audioDataRAW = repmat(audioDataRAW, 1, numel(outputChannel));
        
    end
    
    audioData = audioDataRAW * 10^(gData.onlinePar.level / 20);
    
    pageBuffer = [pageBuffer(2:end); playrec('play',single(audioData),outputChannel )];
    isFinished = false;
    
    while ~isFinished && pageBuffer(1) && gData.onlinePar.isRunning  && ishandle(gData.h.f) % not finished and is valid page no
        gData = guidata(gData.h.f);
        pause(0.001)
        isFinished = playrec('isFinished',pageBuffer(1));
    end
    
end
playrec('delPage',pageBuffer);

end

function freqEditUpdate(obj, ~)
gData = guidata(obj);
freq = ita_str2num(get(obj, 'String'));
freq = max(min(freq, gData.data.freq_high), gData.data.freq_low);  % limit to freqRange
sliderValue = log2(freq-gData.data.freq_low) / log2(gData.data.freq_high - gData.data.freq_low);
sliderValue = min(max(sliderValue, 0), 1);
set(gData.h.sl_freq, 'value', sliderValue);
freqSliderUpdated(gData.h.sl_freq)
end

function freqSliderUpdated(freqSlider, ~)
gData = guidata(freqSlider);

sliderValue = get(freqSlider, 'value');
freq_low = gData.data.freq_low;
freq_high =gData.data.freq_high;

freq = round(2^(sliderValue*log2(freq_high-freq_low))+ freq_low);

set(gData.h.ed_freq, 'string', sprintf('%2.0f', freq))
gData.onlinePar.freq = freq;

guidata(gData.h.f, gData);
end

function volumeEditUpdate(obj, ~)
gData = guidata(obj);
volume = ita_str2num(get(obj, 'String'));
volume = max(min(volume, gData.data.volume_high), gData.data.volume_low);  % limit
sliderValue = volume;
set(gData.h.sl_volume, 'value', sliderValue);
volumeSliderUpdated(gData.h.sl_volume)
end

function volumeSliderUpdated(volSlider, ~)
gData = guidata(volSlider);
sliderValue = round(get(volSlider, 'value'));
set(gData.h.ed_volume, 'string', num2str(sliderValue))
gData.onlinePar.level = sliderValue;
guidata(gData.h.f, gData);
end


% function axisUpdateFreq(ax_h, ~)
% gData = guidata(ax_h);
% currentPoint = get(ax_h, 'CurrentPoint')
% figurePosition = get(gData.h.f, 'position')
% axisPosition =  get(ax_h, 'position')
%
% relativePosInFigure = currentPoint(1:2) ./ figurePosition(3:4);
%
% relativePosInAxis = (relativePosInFigure - axisPosition(1:2) ) ./ (axisPosition(1:2) + axisPosition(3:4));
%
% xLimits = get(ax_h, 'xlim');
% relativePosInAxis(1) * xLimits(2)
%
%  % hier merkte ich dass das mit dem log2 der x achse nervig werden kann
%  % und habe aufgehört
%
% end

% % %% init part from main function
% % [tickVec, tickLabel] =  ita_plottools_ticks('log');
% % idxValid = tickVec > 20 & tickVec < samplingRate/2;
% %
% % tickVec = tickVec(idxValid);
% % tickLabel = tickLabel(idxValid);
% % h.scatterPlot = scatter(h.ax_freq, 100, 0, 200, [1 0 0], 'filled');
% % set(h.ax_freq, 'xscale','log', 'xlim', [20 samplingRate/2], 'xgrid', 'on', 'yTick', [], 'xTick', tickVec, 'xticklabel', tickLabel,  'ButtonDownFcn', @axisUpdateFreq )
% % xlabel(h.ax_freq, 'Frequency in Hz')
