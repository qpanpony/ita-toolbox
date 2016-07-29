function varargout = ita_laboratory_v10(varargin)
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
Args  = struct( 'freqRange', [19 20000], 'samplingRate', ita_preferences('samplingRate'), 'volumeRange', [-100 0] );
Args  = ita_parse_arguments(Args,varargin);

gData.data.samplingRate = Args.samplingRate;

gData.data.soundCardID  = ita_preferences('PlayDeviceID');

gData.data.freq_noise_high    = Args.freqRange(2);
gData.data.freq_noise_low     = Args.freqRange(1);

gData.data.freq_sine_high    = Args.freqRange(2);
gData.data.freq_sine_low     = Args.freqRange(1);

gData.data.volume_noise_high  = Args.volumeRange(2);
gData.data.volume_noise_low   = Args.volumeRange(1);

gData.data.volume_sine_high  = Args.volumeRange(2);
gData.data.volume_sine_low   = Args.volumeRange(1);

gData.data.outputChannels  = ita_channelselect_gui(0, 1:2, 'onlyoutput');
gData.onlineParNoise  = struct('freq', 100, 'level', -30, 'isRunning', false);
gData.onlineParSine  = struct('freq', 100, 'level', -30, 'isRunning', false);

%% create GUI

h.f = figure('position', [100 100 1200 300], 'name', mfilename, 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'nextPlot', 'new');% , 'CloseRequestFcn', @closeRegFcn);
defaultOptions = {'parent', h.f, 'units', 'normalized'};
defaultHeight = 0.08;

h.tx_title_noise = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.1 0.8 0.3  0.15], 'string', '3rd Octave Noise Generator', 'fontSize', 20, 'horizontalAlignment', 'center');

h.sl_freq_noise = uicontrol('style','slider', defaultOptions{:}, 'position', [0.1 0.6 0.3 defaultHeight], 'SliderStep', [0.001 0.1], 'String', 'Frequency','Value', 0.5198, 'Callback', @freqSliderUpdatedNoise);
h.ed_freq_noise = uicontrol('style', 'edit',  defaultOptions{:}, 'position', [0.25 0.7 0.15  defaultHeight], 'string', '100', 'callback', @freqEditUpdateNoise, 'fontSize', 13);
h.tx_freq_noise = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.1 0.7 0.15  defaultHeight], 'string', 'Frequency in Hz: ', 'fontSize', 13);

h.tx_title_sine = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.5 0.8 0.3  0.15], 'string', 'Frequency Generator', 'fontSize', 20, 'horizontalAlignment', 'center');

h.sl_freq_sine = uicontrol('style','slider', defaultOptions{:}, 'position', [0.5 0.6 0.3 defaultHeight], 'SliderStep', [0.001 0.1], 'String', 'Frequency','Value', 0.5198, 'Callback', @freqSliderUpdatedSine);
h.ed_freq_sine = uicontrol('style', 'edit',  defaultOptions{:}, 'position', [0.65 0.7 0.15  defaultHeight], 'string', '100', 'callback', @freqEditUpdateSine, 'fontSize', 13);
h.tx_freq_sine = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.5 0.7 0.15  defaultHeight], 'string', 'Frequency in Hz: ', 'fontSize', 13);

h.sl_volume_noise = uicontrol('style','slider', defaultOptions{:}, 'position', [0.1 0.3 0.3 defaultHeight], 'Min', gData.data.volume_noise_low, 'Max', gData.data.volume_noise_high, 'SliderStep', [0.01 0.1], 'value', -50,'callback', @volumeSliderUpdatedNoise);
h.ed_volume_noise = uicontrol('style', 'edit',  defaultOptions{:}, 'position', [0.25 0.4 0.15 defaultHeight], 'string', '-50', 'Callback', @volumeEditUpdateNoise, 'fontSize', 13);
h.tx_volume_noise = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.1 0.4 0.15 defaultHeight], 'string', 'Level in dBFS: ', 'fontSize', 13);

h.tb_active_noise = uicontrol('style', 'togglebutton',  defaultOptions{:}, 'position', [0.15 0.1 0.2 defaultHeight], 'string', 'On / Off: ', 'fontSize', 13, 'callback', @OnOffCallback);

h.sl_volume_sine = uicontrol('style','slider', defaultOptions{:}, 'position', [0.5 0.3 0.3 defaultHeight], 'Min', gData.data.volume_sine_low, 'Max', gData.data.volume_sine_high, 'SliderStep', [0.03 0.03], 'value', -50,'callback', @volumeSliderUpdatedSine);
h.ed_volume_sine = uicontrol('style', 'edit',  defaultOptions{:}, 'position', [0.65 0.4 0.15 defaultHeight], 'string', '-50', 'Callback', @volumeEditUpdateSine, 'fontSize', 13);
h.tx_volume_sine = uicontrol('style', 'text',  defaultOptions{:}, 'position', [0.5 0.4 0.15 defaultHeight], 'string', 'Level in dBFS: ', 'fontSize', 13);

h.tb_active_sine = uicontrol('style', 'togglebutton',  defaultOptions{:}, 'position', [0.55 0.1 0.2 defaultHeight], 'string', 'On / Off: ', 'fontSize', 13, 'callback', @OnOffCallback);


gData.h         = h;
guidata(h.f, gData)

volumeSliderUpdatedNoise(gData.h.sl_volume_noise)
volumeSliderUpdatedSine(gData.h.sl_volume_sine)

freqSliderUpdatedNoise(gData.h.sl_freq_noise)
freqSliderUpdatedSine(gData.h.sl_freq_sine)

%end function
end

function OnOffCallback(toggleButton, ~)
gData = guidata(toggleButton);
    

isAlreadyRunning = gData.onlineParNoise.isRunning || gData.onlineParSine.isRunning;

gData.onlineParNoise.isRunning = get(gData.h.tb_active_noise, 'Value');
gData.onlineParSine.isRunning = get(gData.h.tb_active_sine, 'Value');

 guidata(gData.h.f, gData);

if (get(gData.h.tb_active_noise, 'Value') || get(gData.h.tb_active_sine, 'Value')) && ~isAlreadyRunning
    startGenerator(toggleButton)
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
guidata(gData.h.f, gData);
currentFrequencyNoise = 0;
currentFrequencySine = 0;
currentFrequencyHelper = 0;
blockCounter = 1;
audioDataRAWNoise = 0;
audioDataRAWSine = 0;
blockSize = 3000;



while (gData.onlineParNoise.isRunning || gData.onlineParSine.isRunning ) && ishandle(gData.h.f)

    if gData.onlineParNoise.isRunning &&  ( (gData.onlineParNoise.freq ~= currentFrequencyNoise) || (gData.onlineParSine.freq ~= currentFrequencyHelper))% generate new noise
        
        % get the sine block size to avoid audible repetition cracks
        nPeriods = round(approxBlockSize / gData.data.samplingRate * gData.onlineParSine.freq);                                                 % full periods
        blockSize = round(nPeriods * gData.data.samplingRate / gData.onlineParSine.freq);
        
        guidata(gData.h.f, gData);
        noise = ita_generate('Whitenoise',1,gData.data.samplingRate,fftDegree);
        
        % cut the raw noise to fit blocks
        timeData = noise.timeData;
        devisionMod = mod(noise.nSamples,blockSize);
        noise.timeData = timeData(1:end-devisionMod);
        
        freqHigh = gData.onlineParNoise.freq * 2^(1/6);
        freqLower = gData.onlineParNoise.freq / 2^(1/6);
        audioDataRAWNoise = ita_filter_bandpass(noise, 'upper', freqHigh, 'lower', freqLower);
        audioDataRAWNoise = audioDataRAWNoise.timeData;
        audioDataRAWNoise = repmat(audioDataRAWNoise, 1, numel(outputChannel));
        currentFrequencyNoise = gData.onlineParNoise.freq;
        currentFrequencyHelper = gData.onlineParSine.freq;
        set(gData.h.ed_freq_noise, 'string', sprintf('%3.0f', currentFrequencyNoise))
    end
    
    if gData.onlineParSine.isRunning && (gData.onlineParSine.freq ~= currentFrequencySine) % generate new sine
        
        nPeriods = round(approxBlockSize / gData.data.samplingRate * gData.onlineParSine.freq);                                                 % full periods
        blockSize = round(nPeriods * gData.data.samplingRate / gData.onlineParSine.freq);
        
        currentFrequencySine = nPeriods * gData.data.samplingRate  / blockSize; % adjust frequency to integer of samples
        gData.onlineParSine.freq = currentFrequencySine;
        guidata(gData.h.f, gData);
        set(gData.h.ed_freq_sine, 'string', sprintf('%3.0f', currentFrequencySine))
        
        audioDataRAWSine = sin(2*pi* (1:blockSize)' / gData.data.samplingRate * currentFrequencySine);
        audioDataRAWSine = repmat(audioDataRAWSine, 1, numel(outputChannel));
    end
    
   
    
    if ~gData.onlineParSine.isRunning 
        audioDataRAWSine = 0;
        currentFrequencySine = 0;
    end
    
    if ~gData.onlineParNoise.isRunning 
        audioDataRAWNoise = 0;
        currentFrequencyNoise = 0;
    end
     

    audioDataNoise = audioDataRAWNoise * 10^(gData.onlineParNoise.level / 20);
    audioDataSine = audioDataRAWSine * 10^(gData.onlineParSine.level / 20); 
    audioBlockSine = audioDataSine;   
    
    if gData.onlineParNoise.isRunning 

        maxBlockNum = floor(length(audioDataRAWNoise)/blockSize);
        endBlock = blockSize*(blockCounter); 
        audioBlockNoise = audioDataNoise(1+(blockSize*(blockCounter-1)):endBlock,:);
        blockCounter = mod(blockCounter,maxBlockNum)+1;
        
    else
        audioBlockNoise = audioDataNoise;
    end
    
    audioBlock = audioBlockNoise + audioBlockSine;
    pageBuffer = [pageBuffer(2:end); playrec('play',single(audioBlock),outputChannel )];
    isFinished = false; 
    
    while ~isFinished && pageBuffer(1) && (gData.onlineParNoise.isRunning || gData.onlineParSine.isRunning)  && ishandle(gData.h.f) % not finished and is valid page no
        gData = guidata(gData.h.f);
        pause(0.001)
        isFinished = playrec('isFinished',pageBuffer(1));
    end
    
end
playrec('delPage',pageBuffer);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%noise
function freqEditUpdateNoise(obj, ~)
gData = guidata(obj);
freq = ita_str2num(get(obj, 'String'));
freq = max(min(freq, gData.data.freq_noise_high), gData.data.freq_noise_low);  % limit to freqRange
sliderValue = log2(freq-gData.data.freq_noise_low) / log2(gData.data.freq_noise_high - gData.data.freq_noise_low);
sliderValue = min(max(sliderValue, 0), 1);
set(gData.h.sl_freq_noise, 'value', sliderValue);
freqSliderUpdatedNoise(gData.h.sl_freq_noise)
end

%sine
function freqEditUpdateSine(obj, ~)
gData = guidata(obj);
freq = ita_str2num(get(obj, 'String'));
freq = max(min(freq, gData.data.freq_sine_high), gData.data.freq_sine_low);  % limit to freqRange
sliderValue = log2(freq-gData.data.freq_sine_low) / log2(gData.data.freq_sine_high - gData.data.freq_sine_low);
sliderValue = min(max(sliderValue, 0), 1);
set(gData.h.sl_freq_sine, 'value', sliderValue);
freqSliderUpdatedSine(gData.h.sl_freq_sine)
end


%noise
function freqSliderUpdatedNoise(freqSlider, ~)
gData = guidata(freqSlider);

sliderValue = get(freqSlider, 'value');
freq_noise_low = gData.data.freq_noise_low;
freq_noise_high =gData.data.freq_noise_high;

freq = round(2^(sliderValue*log2(freq_noise_high-freq_noise_low))+ freq_noise_low);

set(gData.h.ed_freq_noise, 'string', sprintf('%2.0f', freq))
gData.onlineParNoise.freq = freq;

guidata(gData.h.f, gData);
end

%sine
function freqSliderUpdatedSine(freqSlider, ~)
gData = guidata(freqSlider);

sliderValue = get(freqSlider, 'value');
freq_sine_low = gData.data.freq_sine_low;
freq_sine_high =gData.data.freq_sine_high;

freq = round(2^(sliderValue*log2(freq_sine_high-freq_sine_low))+ freq_sine_low);

set(gData.h.ed_freq_sine, 'string', sprintf('%2.0f', freq))
gData.onlineParSine.freq = freq;

guidata(gData.h.f, gData);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%noise
function volumeEditUpdateNoise(obj, ~)
gData = guidata(obj);
volume_noise = ita_str2num(get(obj, 'String'));
volume_noise = max(min(volume_noise, gData.data.volume_noise_high), gData.data.volume_noise_low);  % limit
sliderValue = volume_noise;
set(gData.h.sl_volume_noise, 'value', sliderValue);
volumeSliderUpdatedNoise(gData.h.sl_volume_noise)
end

%sine
function volumeEditUpdateSine(obj, ~)
gData = guidata(obj);
volume_sine = ita_str2num(get(obj, 'String'));
volume_sine = max(min(volume_sine, gData.data.volume_sine_high), gData.data.volume_sine_low);  % limit
sliderValue = volume_sine;
set(gData.h.sl_volume_sine, 'value', sliderValue);
volumeSliderUpdatedSine(gData.h.sl_volume_sine)
end

%noise
function volumeSliderUpdatedNoise(volSlider, ~)
gData = guidata(volSlider);
sliderValue = round(get(volSlider, 'value'));
set(gData.h.ed_volume_noise, 'string', num2str(sliderValue))
gData.onlineParNoise.level = sliderValue;
guidata(gData.h.f, gData);
end

%sine
function volumeSliderUpdatedSine(volSlider, ~)
gData = guidata(volSlider);
sliderValue = round(get(volSlider, 'value'));
set(gData.h.ed_volume_sine, 'string', num2str(sliderValue))
gData.onlineParSine.level = sliderValue;
guidata(gData.h.f, gData);
end







