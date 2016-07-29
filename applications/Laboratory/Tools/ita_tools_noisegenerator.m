function varargout = ita_tools_noisegenerator(varargin)
%ITA_TOOLS_NOISEGENERATOR - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_tools_noisegenerator(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_tools_noisegenerator(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_tools_noisegenerator">doc ita_tools_noisegenerator</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@rwth-aachen.de
% Created:  31-Mar-2015 
% Pretty much an exact copy of frequencygenerator
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

h.tx_title = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.1 0.8 0.8  0.15], 'string', '3rd Octave Noise Generator', 'fontSize', 20, 'horizontalAlignment', 'center');

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
fftDegree = 17;
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

blockCounter = 1;

while gData.onlinePar.isRunning && ishandle(gData.h.f)
    
    if gData.onlinePar.freq ~= currentFrequency % generate new sine
        
        guidata(gData.h.f, gData);
        set(gData.h.ed_freq, 'string', sprintf('%3.0f', currentFrequency))
        
        noise = ita_generate('Whitenoise',1,gData.data.samplingRate,fftDegree);
        freqHigh = gData.onlinePar.freq * 2^(1/6);
        freqLower = gData.onlinePar.freq / 2^(1/6);
        audioDataRAW = ita_filter_bandpass(noise, 'upper', freqHigh, 'lower', freqLower);
        audioDataRAW = audioDataRAW.timeData;
        audioDataRAW = repmat(audioDataRAW, 1, numel(outputChannel));
        currentFrequency = gData.onlinePar.freq;
        maxBlockNum = floor(length(audioDataRAW)/5000);
    end
    
    if (length(audioDataRAW) > 5000)
        audioData = audioDataRAW * 10^(gData.onlinePar.level / 20);
        
        if (blockCounter == maxBlockNum)
            endBlock = length(audioData);
        else
            endBlock = 5000*(blockCounter); 
        end
        audioBlock = audioData(1+(5000*(blockCounter-1)):endBlock,:);
        pageBuffer = [pageBuffer(2:end); playrec('play',single(audioBlock),outputChannel )];
        isFinished = false;
        blockCounter = mod(blockCounter,maxBlockNum)+1;
        
    else
        audioData = audioDataRAW * 10^(gData.onlinePar.level / 20);
        pageBuffer = [pageBuffer(2:end); playrec('play',single(audioData),outputChannel )];
        isFinished = false;
    end
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