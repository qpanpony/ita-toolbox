function ita_listeningtest_itu(varargin)
%ITA_LISTENINGTEST_ITU - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_listeningtest_itu(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_listeningtest_itu(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_listeningtest_itu">doc ita_listeningtest_itu</a>

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  30-May-2011 



%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('fileList',[], 'writeLogFile', true, 'resultPath', '.', 'showProgress', true, 'justPlayingSliderActive', true );
[sArgs] = ita_parse_arguments(sArgs,varargin); 

%%
% TODO
% - mono/stereo prüfen, ...
% - faden angucken, da stimmt was nict
% - wirklich schließen abfrage
% - write log
% - save results
% - define result path
% - option: nur playing slider aktiv
% - evtl bei start alle wav files checken???

% error('Nix fertig')
 

ltData.startText        = 'In diesem Hörversuch sollen Sie ....';
ltData.compareQuestion  = 'Anweisung für den HV ... ';
ltData.endText          = 'Danke für die Teilnahme am Hörversuch.';

if ~exist(sArgs.resultPath, 'dir')
    error('path doesn''t exist (%s)', sArgs.resultPath)
end

if ~iscellstr(sArgs.fileList)
    error('invalid wave file list')
end

h.resultPath              = sArgs.resultPath;
h.showProgress            = sArgs.showProgress;
h.justPlayingSliderActive = sArgs.justPlayingSliderActive;

h.writeLogFile  = sArgs.writeLogFile;

h.syncPlay      = true;


h.fileList            = sArgs.fileList;  % first file is reference, reference also as version
[h.nVersions h.nSets] = size(h.fileList);

h.currentSet          = 0;
h.resultData          = nan(h.nVersions, h.nSets);
h.switchSound         = false;
nSlider               = h.nVersions; % without reverence


%% random order of sets and version

[del randIDX]        = sort( rand(h.nSets,1)); %#ok<ASGLU>
h.setOrder           = randIDX;


% besserer zufall:
h.versionOrder    = zeros(h.nVersions, h.nSets); % index of set are real setnumbers NOT played number
for iSet = 1:h.nSets       % schleife damit rand noch mehr zufällig
    pause(rand/10)
    [del randIDX]          = sort( rand(h.nVersions ,1)); %#ok<ASGLU>
    h.versionOrder(:, iSet) = randIDX;
end

%% get user name
inputName        =  inputdlg('Bitte Namen eingeben','Name',1 ,{'Vorname Nachname'}, 'on');
if isempty(inputName)
    return
end
h.testPersonName = genvarname(cell2mat(inputName));
cl = clock;
h.dateString =  sprintf( '%04i%02i%02i_%02i%02i', cl(1), cl(2), cl(3), cl(4), cl(5));
    

%% create log file
if h.writeLogFile
        h.fid = fopen(fullfile(h.resultPath, ['LOG_' h.testPersonName '__' h.dateString '.txt']), 'wt');

        fwrite(h.fid, 'Log Datei \n');
        fwrite(h.fid, sprintf( ' Datum:      %02i.%02i.%04i %02i:%02i Uhr\n', cl(3), cl(2), cl(1), cl(4), cl(5)));     
        fwrite(h.fid, sprintf('Name : %s \n', inputName{1} ));
end



%% generate GUI
layout.sliderWidth          = 20;
layout.sliderColumnWidth    = 60;
layout.sliderHeight         = 200;
layout.buttonHeight         = 30;


layout.figSize          = [ 100+layout.sliderColumnWidth*(nSlider+1) 500]; 
layout.defaultSpace     = 20;
layout.compTxtHeight    = 40;
layout.tbSize           = [120 30];
layout.tbPosition       = [layout.figSize(1)/2-170 layout.figSize(2) - 2*layout.defaultSpace-layout.compTxtHeight-layout.tbSize(2) layout.tbSize; layout.figSize(1)/2+170-120 layout.figSize(2)-2*layout.defaultSpace-layout.compTxtHeight-layout.tbSize(2) layout.tbSize];

h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[360,500 layout.figSize], 'Name','Listening Test','MenuBar', 'none');
movegui(h.f,'center')


h.text          = uicontrol('Style','text','String',ltData.compareQuestion, 'Position',  [layout.defaultSpace layout.figSize(2)-layout.defaultSpace-layout.compTxtHeight layout.figSize(1)-2*layout.defaultSpace layout.compTxtHeight] );
h.bigText       = uicontrol('Style','text','String',ltData.startText, 'Position',  [layout.defaultSpace layout.defaultSpace*2+layout.buttonHeight  layout.figSize(1)-2*layout.defaultSpace layout.figSize(2)- 3*layout.defaultSpace-layout.buttonHeight] );
h.btNext        = uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [(layout.figSize(1)-3*layout.buttonHeight)/2 layout.defaultSpace  layout.buttonHeight*3 layout.buttonHeight], 'callback', {@nextSet});
h.progressText  = uicontrol('Style','text','String', '', 'Position',  [0 0 100 20] );

h.sliderArray   = zeros(nSlider,1);
h.txValueArray  = zeros(nSlider,1);
h.tbArray       = zeros(nSlider,1);
xOffset         = 100;
currYpos        = layout.figSize(2)-layout.defaultSpace-layout.compTxtHeight - layout.sliderHeight - layout.defaultSpace;
h.tbReference = uicontrol('Style','togglebutton', 'String', 'Ref', 'Position',  [ 30  currYpos-layout.sliderWidth-layout.defaultSpace-30  2*(layout.sliderColumnWidth-layout.defaultSpace)  layout.buttonHeight], 'Callback',{@updateToggleButtons} );

for iSlider = 1:nSlider
    xPosMitte               = xOffset + iSlider*layout.sliderColumnWidth;
    h.txValueArray(iSlider) = uicontrol('Style','text',   'string', '0',  'Position',   [xPosMitte-(layout.sliderColumnWidth-layout.defaultSpace)/2  currYpos+ layout.sliderHeight-layout.defaultSpace layout.sliderColumnWidth-layout.defaultSpace 20]);
    h.sliderArray(iSlider)  = uicontrol('Style','slider',   'Position',   [xPosMitte-layout.sliderWidth/2 currYpos-30  layout.sliderWidth layout.sliderHeight], 'Callback', {@updateSliderPosition}, 'Max', 100);
    h.tbArray(iSlider)      = uicontrol('Style','togglebutton', 'String', char(64+iSlider), 'Position',  [xPosMitte-(layout.sliderColumnWidth-layout.defaultSpace)/2  currYpos-layout.sliderWidth-layout.defaultSpace-30  layout.sliderColumnWidth-layout.defaultSpace  layout.buttonHeight], 'Callback', {@updateToggleButtons});
end

% varables to control playback
h.control.stopIt    = 0;
h.control.isPlaying = 0;
h.control.next      = 0;


% make slider etc invisible
set([h.tbArray; h.sliderArray; h.tbReference; h.txValueArray; h.text; h.progressText  ], 'visible', 'off')

h.ltData = ltData;

guidata(h.f, h);
set(h.f,'visible', 'on')


%end function
end


function updateSliderPosition(obj, eventData) %#ok<INUSD>
h = guidata(obj);
idxSlider = find(h.sliderArray == obj);

value = round(get(h.sliderArray(idxSlider), 'value'));
set(h.sliderArray(idxSlider), 'value', value);
set(h.txValueArray(idxSlider), 'string', num2str(value));

end


function updateToggleButtons(obj, eventData) %#ok<INUSD>
h = guidata(obj);


allTbh = [h.tbReference; h.tbArray];      % 1 für ref, 2 für ersten slider, 3 für zweiten, ....
if get(obj, 'value')  % tb wurde aktiviert
    idxTbWahl = find(allTbh == obj); 
    h.control.currWavFile = h.currSoundlist{idxTbWahl};
    guidata(h.f, h);
    
    if h.justPlayingSliderActive
        set(h.sliderArray, 'enable', 'inactive')
        if idxTbWahl > 1 % also nicht ref
            set(h.sliderArray(idxTbWahl-1), 'enable', 'on')
        end
    end

    if sum(cell2mat(get(allTbh, 'value'))) == 1 % start playback ( kein andere war aktiv)
%         disp('play')
        play(h)
    else                                                % switch wav (playback läuft bereits mit anderer wav)
%         disp('SW')
        set(allTbh, 'value', 0)
        set(obj, 'value', 1)
        h.control.switchSound  = true;
        guidata(h.f, h);
    end
else % deaktiviert => end playback
    h.control.stopIt  = true;
    guidata(h.f, h);
%     disp('AUS')
end


end

%% playback function
function play(h)

%% Parameter
blockSize = 1024*8; 
% nFrames2Fade = 0;

%% Init sound device
pageBufCount =  1;
runMaxSpeed  = false;
Fs = ita_preferences('samplingRate');
if playrec('isInitialised')
    playrec('reset');
end
playrec('init',Fs, ita_preferences('playDeviceID'), ita_preferences('recDeviceID'));
playrec('delPage');
pageNumList = repmat(-1, [1 pageBufCount]);
firstTimeThrough = true;

%% wav Parameter bestimmen
[m d] = wavfinfo(h.control.currWavFile);
if strcmp(m, 'Sound (WAV) file')
    xLength  = str2double(d(strfind(d, 'Sound (WAV) file containing: ') + 28: strfind(d, ' samples')));
else
    errordlg('wav Datei konnte nicht gelesen werden. Programm wird abgebrochen.', 'Fehler')
    return
end

iBlock = 1;
nBlocks =  floor(xLength/blockSize);
h.control.isPlaying =1;
h.control.stopIt = 0;
guidata(h.f, h)

ampFaktor = 1.4;

%%
% fadeWin = hanning(blockSize*nFrames2Fade);
% fadeWin = reshape(((1:blockSize*nFrames2Fade)/(blockSize*nFrames2Fade)), blockSize, []);
nCh = 2;
% hanWin  = exp([1:blockSize blockSize:-1:1]' / blockSize*5) ;
hanWin = hanning(blockSize*2);
% hanWin = (10.^hanning(blockSize*2)-1)/9;

% hanWin  = (hanWin - min(hanWin)) / (max(hanWin) - min(hanWin));


fadeIn  = repmat(hanWin(1:blockSize), 1, nCh);
fadeOut = repmat(hanWin(blockSize+1:end), 1, nCh);

fadeInNextBlock = 0;
lastTrack = h.control.currWavFile;


debug = []
%% Hauptschleife
while (iBlock <= nBlocks) && ishandle(h.f)    % TODO: letztes Frame auch spielen
    
    pause(0.00001)       % doof aber notwendig, damit globale var aktualisiert wird
    h = guidata(h.f);  
    if h.control.stopIt || h.control.next% Simulation beenden
%         disp('break')
        break
    end
    
    
    % SIGNAL einlesen
    if ~h.control.switchSound  % play normal
       
        x  = ampFaktor * wavread(h.control.currWavFile,  [(iBlock-1)*blockSize+1 (iBlock)*blockSize] );
            if fadeInNextBlock
                x = x .* fadeIn;
                fadeInNextBlock = fadeInNextBlock -1;
                disp('fade in')
            end
    else % fade out
        
        if ~h.syncPlay
            iBlock =1;
        end

        h.control.switchSound  = false;
        guidata(h.f, h);
        
        lastTrack = h.control.currWavFile;
        x  = ampFaktor * fadeOut .* wavread(h.control.currWavFile,  [(iBlock-1)*blockSize+1 (iBlock)*blockSize] );
        fadeInNextBlock = 1;
        disp('fadeOut')
    end
    
    
    
    
    if iBlock ==  nBlocks               % loop
%         iBlock = 1 +nFrames2Fade;
        iBlock = 1 ;
%         fadeInNextBlock  = 1;
%         x = x .* fadeOut;
%         disp('fade out')
    end
    

    %     f1 = zeros(1,blockSize)+1;
    %     f2 = zeros(1,blockSize);
    
%     if iBlock >= nBlocks - nFrames2Fade +1 % wenn wir am ende angekommen sind
%         
%         otherFrame = iBlock - nBlocks + nFrames2Fade;
%         x2  = ampFaktor * wavread(h.control.currWavFile );
%         x = x.*fadeWin(end:-1:1,nBlocks -iBlock  +1) + x2.*fadeWin(:, otherFrame);
%         %         f1 = fadeWin(end:-1:1,nBlocks - iBlock  +1)';
%         %         f2 = fadeWin(:, otherFrame)';
%         
%     end

    
    pageNumList = [pageNumList playrec('play',x,[1 2])]; %#ok<AGROW>
    debug = [debug; x];
%     disp('play a block')
    % nicht gesendete Samples anzeigen
    if(firstTimeThrough)
        playrec('resetSkippedSampleCount');
        firstTimeThrough = false;
    else
        if(playrec('getSkippedSampleCount'))
            fprintf('%d samples skipped!!\n', playrec('getSkippedSampleCount'));
            firstTimeThrough = true;
        end
    end
    % Puffer
    if pageNumList(1) ~= -1
        if(runMaxSpeed)
            while(playrec('isFinished', pageNumList(1)) == 0)
            end
        else
            playrec('block', pageNumList(1));
        end
    end
    playrec('delPage', pageNumList(1));
    pageNumList = pageNumList(2:end);

    iBlock = iBlock +1;
end


% playrec('reset')
set([h.tbArray; h.tbReference], 'Value', 0)
h.control.isPlaying     = 0;
h.control.stopIt        = 0;

if h.control.next
%     writeLogFile(h) % todo
end
end

function nextSet(obj, e) %#ok<INUSD>
h = guidata(obj);

if h.currentSet == 0    % load first set
    % make gui elemets visible
    set([h.tbArray; h.sliderArray; h.tbReference; h.txValueArray; h.text], 'visible', 'on')
    if h.showProgress
        set(h.progressText, 'visible', 'on');
    end
    set(h.bigText, 'visible', 'off')
    set(h.btNext, 'string', 'next')
else
    
    
    userRatingABC = cell2mat(get(h.sliderArray, 'Value'));
    % check for slider values
    if all( userRatingABC == 0)
        errordlg('Bitte erst die Beispiel bewerten und dann weiter klicken.')
        return
    end 
    
    % assign ratings to real soundfiles
    realSetNo               = h.setOrder(h.currentSet); 
    userRating2realVersions(h.versionOrder(:, realSetNo))   = userRatingABC;
    h.resultData(:,realSetNo) = userRating2realVersions(:);
    
    if h.writeLogFile
        
        fwrite(h.fid, sprintf(' User rating: \n'));
        for iSound = 1:h.nVersions
            fwrite(h.fid, sprintf('   Version %02i => rating %i \n',iSound,   h.resultData(iSound,realSetNo) ));
        end
        fwrite(h.fid, sprintf('\n'));
    end
    %stop playing
    h.control.stopIt  = 1;
    guidata(h.f, h);

end


if h.currentSet == h.nSets    % make gui elemets invisible
    
    if h.writeLogFile
        fclose(h.fid);
    end
    resultData = h.resultData; %#ok<NASGU>
    save(fullfile(h.resultPath, ['Result_' h.testPersonName '__' h.dateString '.mat']), 'resultData', 'h');
    ita_verbose_info([ 'Test finished. Saved results as ''Result_' h.testPersonName '__' h.dateString '.mat'' '],1)
    
    
    set([h.tbArray; h.sliderArray; h.tbReference; h.txValueArray; h.text; h.progressText], 'visible', 'off')
    set(h.bigText, 'visible', 'on', 'string', h.ltData.endText)
    set(h.btNext, 'string', 'End', 'Callback', {@closeGUI})
    return
end

% next set    
h.currentSet        = h.currentSet +1; % played set no
realSetNo           = h.setOrder(h.currentSet); 
h.currSoundlist     = h.fileList([ 1; h.versionOrder(:, realSetNo)], realSetNo);


% write logfile
if h.writeLogFile
    fwrite(h.fid, sprintf('Played set number %i \n', h.currentSet));
    fwrite(h.fid, sprintf('  Reference:   %s\n',  h.fileList{1, realSetNo}));
    for iSound = 1:h.nVersions
        fwrite(h.fid, sprintf('  Version %02i : %s\n', iSound, h.fileList{iSound, realSetNo}));
    end
end



% update GUI
set(h.progressText, 'string', sprintf('%i of %i', h.currentSet, h.nSets))
if h.justPlayingSliderActive
    set(h.sliderArray, 'Value', 0, 'enable', 'inactive');
end


guidata(obj, h);
end

function closeGUI(o, e) %#ok<INUSD>
    h = guidata(o);
    close(h.f)

end