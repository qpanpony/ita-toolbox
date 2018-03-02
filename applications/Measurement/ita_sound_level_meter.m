function varargout = ita_sound_level_meter(varargin)
%ITA_SOUND_LEVEL_METER - Real-time calibrated sound level meter
%  This function provides a real-time display of a third-octave sound level
%  meter for an arbitrary number of channels (display optimized for single
%  channel). It accepts a calibrated measurement setup and additional
%  optional parameters to calculate absolute sound pressure level.
%
%  Real-time audio part is adapted from ita_tools_liveFFT
%
%  Syntax:
%   audioObjOut = ita_sound_level_meter(itaMSRecord, options)
%
%   Options (default):
%           'blockSize' (4096) : input block size in samples
%           'micEq' ([])       : apply equalization to mic data (in third-octaves)
%           'selfNoise' ([])   : if data is available, shows mic self noise (in third-octaves)
%
%  Example:
%   ita_sound_level_meter(MS)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sound_level_meter">doc ita_sound_level_meter</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Markus Mueller-Trapet -- Email: markus.mueller-trapet@nrc-cnrc.gc.ca
% Created:  22-Feb-2018 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_MS','itaMSRecord', 'blockSize', 4096, 'micEq', [], 'selfNoise', []);
[MS,sArgs] = ita_parse_arguments(sArgs,varargin);

blockSize = min(2^12,sArgs.blockSize); % too large block sizes may not work

%% input and general parameters
pageBufCount = 2;
samplingRate = MS.samplingRate;
recChannels  = MS.inputChannels;
freqLim      = MS.freqRange;
sens         = repmat(double(MS.inputMeasurementChain.hw_ch(MS.inputChannels).sensitivity),blockSize,1);
minDB        = -60;

if isempty(recChannels)
    return
end

% throw out labels we don't need
[XTickVec_log, XTickLabel_log] = ita_plottools_ticks('log');
ids = union(find(XTickVec_log < min(freqLim)),find(XTickVec_log > max(freqLim)));
XTickVec_log(ids) = [];
XTickLabel_log(ids) = [];

[octMat,octFreqVec] = octaveband_matrix(samplingRate,2*blockSize,freqLim,3);
flat = ones(numel(octFreqVec),1);
minFreq = max(5,min(octFreqVec)/2);
octFreqVec = [minFreq; octFreqVec];
nBins = numel(octFreqVec);

freqLim = [minFreq/2 min(samplingRate/2, freqLim(2))];
win = hanning(2*blockSize);
win = win./rms(win);
currentBlock = zeros(2*blockSize,numel(recChannels));
runningFreqData = zeros(nBins-1,numel(recChannels));

weightingTypes = {'            none','               A','               C'};
weightingFilters = [flat,abs(weighting_filter(flat,octFreqVec(2:end),'A')).^2,abs(weighting_filter(flat,octFreqVec(2:end),'C')).^2];
weightingLabels = {'','(A)','(C)'};
timeConstantTypes = {'       Slow (1.0s)','     Fast (0.125s)','   Impulse (35ms)'};
timeConstants = [1,0.125,0.035];

if isempty(sArgs.micEq)
    micEq = flat;
else
    micEq = abs(sArgs.micEq.freq2value(min(max(sArgs.micEq.freqVector),max(min(sArgs.micEq.freqVector),octFreqVec(2:end))))).^2;
end

if isempty(sArgs.selfNoise)
    selfNoise = 20e-9.*flat;
else
    selfNoise = abs(sArgs.selfNoise.freq2value(min(max(sArgs.selfNoise.freqVector),max(min(sArgs.selfNoise.freqVector),octFreqVec(2:end)))));
end
self_noise_plot = 20.*log10(selfNoise) + 94;

%% Figure settings etc.
figSize = get(0,'screenSize').*[1 1 0.8 0.8];
h.f = figure('Visible','on','NumberTitle', 'off', 'Position',figSize, 'Name','Band Analyzer','MenuBar', 'none');
movegui(h.f,'center')
lineHeight = floor(figSize(4) / 3);
% main plot axes
h.ax =  axes('parent', h.f, 'Units','pixels', 'Position', [0.1*figSize(3) 0.5*lineHeight 0.85*figSize(3) 2*lineHeight]);
% control UIs
% frequency weighting
h.weightingType    = uicontrol('Style','popup', 'String',weightingTypes, 'Position', [0.1*figSize(3) 0.1.*lineHeight 150 25],'FontSize',12,'BackgroundColor',0.32.*[1 1 1],'ForegroundColor',0.95.*[1 1 1]);
h.weightingText    = uicontrol('Style','text','String','Weighting Type', 'Position',  [0.1*figSize(3) 0.2.*lineHeight 150 25],'FontSize',12,'FontWeight','bold','BackgroundColor',0.32.*[1 1 1],'ForegroundColor',0.95.*[1 1 1]);
% time constant
h.timeConstantType = uicontrol('Style','popup', 'String',timeConstantTypes, 'Position', [0.1*figSize(3)+200 0.1.*lineHeight 150 25],'FontSize',12,'BackgroundColor',0.32.*[1 1 1],'ForegroundColor',0.95.*[1 1 1]);
h.timeConstantText =  uicontrol('Style','text','String','Time Constant', 'Position',  [0.1*figSize(3)+200 0.2.*lineHeight 150 25],'FontSize',12,'FontWeight','bold','BackgroundColor',0.32.*[1 1 1],'ForegroundColor',0.95.*[1 1 1]);

% for window close request
h.livePar.exit = false;
set(h.f,'Visible','on', 'CloseRequestFcn', {@CloseRequestFcn})
guidata(h.f, h)

% initial plot
plotData = 20.*rand(nBins,numel(recChannels));
colors = parula(numel(recChannels)+1);
lineHandleFreq = bar(h.ax,octFreqVec,plotData,0.75,'hist','LineStyle','none','EdgeColor',colors(1:numel(recChannels),:),'FaceColor',colors(1:numel(recChannels),:),'BaseValue',minDB);

axh  = get(h.ax, 'children');
for idx = 1:numel(axh)
    if ~ismember(axh(idx),lineHandleFreq)
        set(axh(idx),'Visible','off')
        set(axh(idx),'HandleVisibility','off')
    end
end

hold all
lineHandleSelfNoise = semilogx(h.ax,octFreqVec(2:end),self_noise_plot,'r--','LineWidth',2);

grid
set(h.ax,'XScale','log','XTick',[minFreq XTickVec_log]','XTickLabel',[{'SUM'} XTickLabel_log],'FontSize',14)
set(h.ax,'yLim',[-3 123], 'xLim', freqLim)

title(h.ax, 'Third-Octave Band Analyzer', 'fontsize', 20)
xlabel(h.ax, 'Frequency in Hz','FontSize',16)

ita_whitebg(h.f);

% display string for SUM in dB
for iCh = 1:numel(recChannels)
    txtHandle(iCh) = text(0.8*minFreq, 20, '16.0', 'Color', [1 1 1], 'FontSize', 20, 'FontWeight', 'bold'); %#ok<AGROW>
end

%% run continuously
% audio init
playRecHandle = ita_playrec;
if ~prepare_playrec(playRecHandle,samplingRate,ita_preferences('recDeviceID'),recChannels)
    error('Could not initialize playrec');
end

firstTimeThrough = true;
playRecHandle('delPage');
pageNumList = repmat(-1, [1 pageBufCount]);
% for real-time status
iter = 0;
nIter = ceil(10*48000/blockSize); % 10s of blocks
tic;

% frequency weighting
currentWeightingType = 1;
weightingFilt = weightingFilters(:,currentWeightingType);
yLabel = ['dB' upper(weightingLabels{currentWeightingType}) ' re 20uPa'];
ylabel(h.ax, yLabel,'FontSize',16)

% time weighting/smoothing
currentTimeConstantType = 1;
tc = timeConstants(currentTimeConstantType);
exp_alpha = 1 - exp(-1./tc.*blockSize./samplingRate);

while ~h.livePar.exit
    % restart with different filter settings
    if currentWeightingType ~= get(h.weightingType, 'Value') || currentTimeConstantType ~= get(h.timeConstantType, 'Value')
        % frequency weighting
        currentWeightingType = get(h.weightingType, 'Value');
        weightingFilt = weightingFilters(:,currentWeightingType);
        lineHandleSelfNoise.YData = self_noise_plot + 10.*log10(weightingFilt);
        
        yLabel = ['dB' upper(weightingLabels{currentWeightingType}) ' re 20uPa'];
        ylabel(h.ax, yLabel,'FontSize',16)
        % time weighting/smoothing
        currentTimeConstantType = get(h.timeConstantType, 'Value');
        tc = timeConstants(currentTimeConstantType);
        exp_alpha = 1 - exp(-1./tc.*blockSize./samplingRate);
        
        t = toc; %#ok<NASGU>
        iter = 0;
        playRecHandle('delPage');
        pageNumList = repmat(-1, [1 pageBufCount]);
        firstTimeThrough = true;
        currentBlock = zeros(2*blockSize,numel(recChannels));
        runningFreqData = zeros(nBins-1,numel(recChannels));
        tic;
    end
        
    iter = iter + 1;
    if iter == nIter
        realTimeStatus = toc/(blockSize/samplingRate)/nIter;
        ita_verbose_info(['Real time status: ' num2str(realTimeStatus,'%1.2f')],2);
        iter = 0;
        tic;
    end
    % audio processing
    pageNumList = [pageNumList playRecHandle('rec',blockSize, recChannels)]; %#ok<AGROW>
    
    % check for skipped samples
    if(firstTimeThrough)
        playRecHandle('resetSkippedSampleCount');
        firstTimeThrough = false;
    else
        if (playRecHandle('getSkippedSampleCount'))
            ita_verbose_info(sprintf('%d samples skipped!!\n', playRecHandle('getSkippedSampleCount')), 0);
            firstTimeThrough = true;
        end
    end
    
    % wait while soundcard is recording
    playRecHandle('block', pageNumList(1));
    
    timeData = double(playRecHandle('getRec', pageNumList(1)));
    
    playRecHandle('delPage', pageNumList(1));
    pageNumList = pageNumList(2:end);
    if isempty(timeData) % if there is no data (yet) from the soundcard
        ita_verbose_info('no data form soundcard - continue',1)
        continue
    else
        % apply calibration
        timeData = timeData./sens;
        % FIFO buffer of 2 block lengths
        currentBlock = [currentBlock(blockSize + (1:blockSize),:); timeData];
    end
    
    % plot freq data
    freqRaw = fft_power_local(currentBlock.*win);
    % exponential smoothing
    runningFreqData = (1-exp_alpha).*runningFreqData + exp_alpha.*weightingFilt.*micEq.*(octMat*abs(freqRaw).^2);
    plotData = 10.*log10([sum(runningFreqData,1); runningFreqData] + eps) + 94;
    for iCh = 1:numel(recChannels)
        sumBarX = lineHandleFreq(iCh).Vertices(3,1) + 0.2.*diff(lineHandleFreq(iCh).Vertices(3:4,1));
        txtHandle(iCh).Position = [sumBarX plotData(1,iCh)-6,0];
        txtHandle(iCh).String = num2str(plotData(1,iCh),'%02.1f');
        tmp = [minDB.*ones(3,nBins); repmat(plotData(:,iCh).',2,1)];
        lineHandleFreq(iCh).Vertices(:,2) = [tmp(2:end).'; repmat(minDB,2,1)];
    end
    h = guidata(h.f);
    pause(0.005) % draw and update live parameters
end

% return last data at the end
varargout = {itaResult(sqrt(runningFreqData),octFreqVec(2:end),'freq')*itaValue(1,'Pa')};
if nargout > 1
    varargout(2) = {itaAudio(currentBlock,samplingRate,'time')*itaValue(1,'Pa')};
end
ita_verbose_info('End',1)
delete(h.f)
end % function

%% subfunctions
function [bandMatrix,bandFreqVec] = octaveband_matrix(samplingRate,nSamples,freqRange,bandsPerOctave)
freqVector = (0:floor(nSamples/2)).'.*samplingRate./nSamples;
[bandFreqVec, fmExact] = ita_ANSI_center_frequencies(freqRange,bandsPerOctave,samplingRate);
bandFreqVec = bandFreqVec(:);
bandLimitsLower = fmExact.*(2^(-1/(2*bandsPerOctave)));
bandLimitsUpper = fmExact.*(2^(1/(2*bandsPerOctave)));

bandMatrix = zeros(numel(bandLimitsLower),numel(freqVector));
for iBand = 1:numel(bandLimitsLower)
    idx_low = max(1,find(freqVector >= bandLimitsLower(iBand),1,'first'));
    idx_high = min(numel(freqVector),find(freqVector < bandLimitsUpper(iBand),1,'last'));
    bandMatrix(iBand,idx_low:idx_high) = 1;
end
end

function x = fft_power_local(x)
nSamples = size(x,1);
nBins = floor(nSamples/2) + 1;
x = fft(x)./nSamples;
sizeX = size(x);
sizeX(1) = nBins;
x = x(1:nBins,:);
x(2:end,:) = x(2:end,:).*sqrt(2);
% even/odd number of samples treated differently
if ~mod(nSamples,2) % even samples
    x(end,:) = x(end,:)./2;
end
x = reshape(x,sizeX);
end

function success = prepare_playrec(playRecHandle,samplingRate,deviceID,channelList)
% prepare playrec with the specified parameters
success = false;
if (ndims(channelList) ~= 2 || size(channelList, 1) ~= 1) %#ok<ISMAT>
    return;
end
%Test if current initialisation is ok
if playRecHandle('isInitialised')
    if playRecHandle('getSampleRate') ~= samplingRate
        fprintf('Changing playrec sample rate from %d to %d\n', playRecHandle('getSampleRate'), samplingRate);
        playRecHandle('reset');
    elseif playRecHandle('getRecDevice') ~= deviceID
        fprintf('Changing playrec record device from %d to %d\n', playRecHandle('getRecDevice'), deviceID);
        playRecHandle('reset');
    elseif playRecHandle('getRecMaxChannel') < max(channelList)
        fprintf('Resetting playrec to configure device to use more input channels\n');
        playRecHandle('reset');
    end
end
%Initialise if not initialised
if ~playRecHandle('isInitialised')
    fprintf('Initialising playrec to use sample rate: %d, recDeviceID: %d and no play device\n', samplingRate, deviceID);
    playRecHandle('init', samplingRate, -1, deviceID)
end
if ~playRecHandle('isInitialised')
    return;
elseif playRecHandle('getRecMaxChannel') < max(channelList)
    disp('Selected device does not support %d output channels\n', max(channelList));
    return;
end

%Clear all previous pages
playRecHandle('delPage');
success = true;

end

function CloseRequestFcn(s,o,e) %#ok<INUSD>
h = guidata(s);
if h.livePar.exit % if main while loop is not running
    ita_verbose_info('End',1)
    delete(h.f);
else
    h.livePar.exit = true;
    guidata(h.f, h)
end
end
