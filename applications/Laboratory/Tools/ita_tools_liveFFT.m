function ita_tools_liveFFT()
% nice2have:
% - channel selection
% - freqRange
% - win ausw�hlbar
% - resize function
% - buttons: hold akt. spec (grau im hintergrund) + clear

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



%   sound device parameter
fs = ita_preferences('samplingRate');
pageBufCount        = 2;
runMaxSpeed         = false;

recChannel          = ita_channelselect_gui(1, 0, 'onlyinput');
if isempty(recChannel)
    return
end

freqLim = [];

%%
figSize = get(0,'screenSize').*[1 1 0.8 0.8];

blockSizes = 2.^(9:16);


h.f = figure('Visible','on','NumberTitle', 'off', 'Position',figSize, 'Name','Live FFT','MenuBar', 'none');
movegui(h.f,'center')

lineHeight = floor(figSize(4) / 3);


h.ax1 =  axes('parent', h.f, 'Units','pixels', 'Position', [0.1*figSize(3) 2.1*lineHeight 0.85*figSize(3) 0.75*lineHeight]);
h.ax2 =  axes('parent', h.f, 'Units','pixels', 'Position', [0.1*figSize(3) 1*lineHeight 0.85*figSize(3) 0.75*lineHeight]);



blockSizeCell = cell(numel(blockSizes));
for iBs = 1:numel(blockSizes);
    blockSizeCell{iBs} = sprintf('% 3.2f ms', blockSizes(iBs) / fs *1000);
end
h.fftSize     = uicontrol('Style','listbox', 'String',blockSizeCell , 'Position', [0.1*figSize(3) lineHeight*.3 100 lineHeight*.5] , 'Callback', @restart);
h.fftSizeText =  uicontrol('Style','text','String','Blocksize', 'Position',  [0.1*figSize(3) lineHeight*.85 100 20] );



% h.text          = uicontrol('Style','text','String',ltData.compareQuestion, 'Position',  [centerOfGUI(1)+layout.defaultSpace centerOfGUI(2)+layout.figSize(2)-layout.defaultSpace-layout.compTxtHeight layout.figSize(1)-2*layout.defaultSpace layout.compTxtHeight] );
% h.togglebuttonA    = uicontrol('Style','togglebutton', 'String','Version A','Position',layout.tbPosition(1,:)+ [centerOfGUI 0 0], 'Callback', {@chooseSound});


% h.nextButton    = uicontrol('Style','pushbutton', 'String',ltData.intoButtonString,'Position',[layout.figSize(1)-130-layout.defaultSpace, layout.defaultSpace, 130, 30]+ [centerOfGUI 0 0], 'Callback', {@GUI_next});
% h.bigText       = uicontrol('Style','text','String',ltData.introText, 'Position', [layout.defaultSpace,layout.defaultSpace+40,layout.figSize-2*layout.defaultSpace - [0 40] ]+ [centerOfGUI 0 0], 'Visible' , 'off', 'fontsize', 11);
% h.hArray = [h.text  h.togglebuttonA  h.togglebuttonB  h.nextButton   ];



%     h.attribA       = uicontrol('Style','popupmenu','String',ltData.attributes, 'Position',  layout.tbPosition(1,:)- [10 100 -20 0]+ [centerOfGUI 0 0] );
%
h.livePar.exit = false;



guidata(h.f, h)
set(h.f,'Visible','on', 'CloseRequestFcn', {@CloseRequestFcn})


%%

if playrec('isInitialised')
    playrec('reset');
end
playrec('init',fs, ita_preferences('playDeviceID'), ita_preferences('recDeviceID'));

set(h.fftSize, 'value', 3)
while ~h.livePar.exit
    
    blockSize = blockSizes(get(h.fftSize, 'Value'));
    nBins = blockSize/2+1;
    win = hanning(blockSize);
    
    h.livePar.restart = false;
    guidata(h.f,h)
    
    %     figure;
    plot(h.ax1, (0:blockSize-1).'/fs,zeros(blockSize,1))
    timeLim = [0 blockSize-1]/fs;
    lineHandleTime = get(h.ax1, 'children');
    
    
    plot(h.ax2, (0:nBins-1)/2/(nBins-1).'*fs,zeros(nBins,1))
    if isempty(freqLim)
        freqLim = [20 fs/2];
    else
        freqLim = [max(0,freqLim(1)) min(fs/2, freqLim(2))];
    end
    lineHandleFreq  = get(h.ax2, 'children');
    normVec         = [1; 2*ones(nBins-2,1); 1] / sqrt(2) / blockSize;
    
    playrec('delPage');
    pageNumList = repmat(-1, [1 pageBufCount]);
    firstTimeThrough = true;
    
    title(h.ax1, 'time domain', 'fontsize', 15)
    xlabel(h.ax1, 'time in s')
    title(h.ax2, 'frequency domain', 'fontsize', 15)
    xlabel(h.ax2, 'frequency in Hz')
    ylabel('dB FullScale (dBFS)')
    
    
    while ~h.livePar.exit && ~h.livePar.restart
        pageNumList = [pageNumList playrec('rec',blockSize, recChannel)]; %#ok<AGROW>
        
        % check for skipped samples
        if(firstTimeThrough)
            playrec('resetSkippedSampleCount');
            firstTimeThrough = false;
        else if (playrec('getSkippedSampleCount'))
                ita_verbose_info(sprintf('%d samples skipped!!\n', playrec('getSkippedSampleCount')), 1);
                firstTimeThrough = true;
            end
        end
        
        % wait while soundcard is playing
        if(runMaxSpeed)
            while(playrec('isFinished', pageNumList(1)) == 0)
            end
        else
            playrec('block', pageNumList(1));
        end
        
        
        inputTMP = double(playrec('getRec', pageNumList(1)));
        
        
        playrec('delPage', pageNumList(1));
        pageNumList = pageNumList(2:end);
        if isempty(inputTMP)     % wenn noch keine daten von Soundkarte => keine berechnung
            ita_verbose_info('no data form soundcard - continue',1)
            continue
        end
        
        % plot time data
        set(lineHandleTime, 'YData', inputTMP)
        set(h.ax1, 'ylim',[-1 1], 'xlim', timeLim)
        
        % plot freq data
        freqRaw = fft(inputTMP.*win);
        set(lineHandleFreq, 'YData',20*log10(abs(normVec .* freqRaw(1:nBins))) )
        set(h.ax2, 'ylim',[-120 0], 'xlim', freqLim, 'xscale', 'log') % vor der schleife?
        
        h = guidata(h.f);
        pause(0.01) % draw and update live parameters
    end
    
    
end

ita_verbose_info('Ende',1)
delete(h.f)
end

function restart(s,o,e)
h = guidata(s);
h.livePar.restart = true;
guidata(h.f, h)
end



function CloseRequestFcn(s,o,e)
h = guidata(s);
if h.livePar.exit % if main while loop is not running
    ita_verbose_info('Ende',1)
    delete(h.f)
else
    h.livePar.exit = true;
end
guidata(h.f, h)
end
