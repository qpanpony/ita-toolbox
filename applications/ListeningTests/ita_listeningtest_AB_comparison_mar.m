%% Main Function

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

function ita_listeningtest_AB_comparison_mar(ltData)
%ITA_LISTENINGTEST_AB_COMPARISON - gui for complete one-sided AB comparison
%  This function creates a GUI that can be used for complete one-sided
%  AB comparisons with a user definable number of control pairs
%
%  Syntax:
%   ltResult = ita_listeningtest_AB_comparison(ltData)
%
%   Please call this function with a struct 'ltData' that contains all
%   input parameters for the listening test. A guideline for the creation
%   of the ltData struct can be found in the file
%   ltData = ita_generate_input_for_lt_AB_comparison()
%
%  Example:
%   ltResult = ita_listeningtest_AB_comparison(ltData)
%
%  See also: ita_listeningtest_AB_cmp_generate_input
%   
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_listeningtest_AB_comparison">doc ita_listeningtest_AB_comparison</a>
%
% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  04-Mar-2011 
% Edited:   mar 30-May-2011
%

%%% store ltData in handles structure
h.ltData                    = ltData;

%%% check data in ltData
[y1, h.data.samplingRate] = wavread(ltData.soundList{1});
h.data.nChannels = size(y1,2);
h.data.nSamples  = size(y1,1);

for iSound = 1:ltData.nSounds
    [y, fs] = wavread(ltData.soundList{iSound});
    if ~isequal(h.data.samplingRate, fs)
        error('Different sampling rates in wav files')
    elseif ~isequal(h.data.nChannels, size(y,2)) 
        error('Different number of channels in wav files')
    elseif ~isequal(h.data.nSamples, size(y,1)) 
        error('Different number of samples in wav files')
    end
end

if ltData.useAttributes 
    if ~iscell(ltData.attributes) || ~ischar(ltData.attribQuestion)
        error('Inconsistencies in ltData struct found: useAttributes = true but ltData.attribQuestion or ltData.attributes wrong.')
    end
end

if ~exist(ltData.savePath, 'dir')
    mkdir(ltData.savePath)
end

clear y y1 fs iSound

%%% generate fade windows according to fadeType
switch ltData.fadeType
    case 'inoutFade'
        winLen          = ltData.frameSize * ltData.nFadeFrames;
        hanningWindow   = hanning(winLen);
        zeroVec         = zeros(winLen,1);
        h.data.fadeInWindow  = zeroVec;
        h.data.fadeOutWindow = zeroVec;
        h.data.fadeInWindow( (winLen/2 +1) : end ) = hanningWindow( 1 : winLen/2 );
        h.data.fadeOutWindow( 1 : winLen/2 )       = hanningWindow( (winLen/2 +1) : end );
    case 'xFade'
        winLen          = ltData.frameSize * ltData.nFadeFrames;
        hanningWindow   = hanning(2*winLen);
        h.data.fadeInWindow  = hanningWindow( 1 : winLen );
        h.data.fadeOutWindow = hanningWindow( winLen+1 : end );
    otherwise
        error('Invalid fade type!');
end

%%% get name of person
cl = clock;
h.data.testPersonName = cell2mat(inputdlg( 'Bitte geben Sie Ihren Namen ein.','Name', 1));
if isempty(h.data.testPersonName )
    error('Name is empty')
end
h.data.runIdentifier = sprintf( '%04i%02i%02i_%02i%02i_%s', cl(1), cl(2), cl(3), cl(4), cl(5),genvarname(h.data.testPersonName));
    
%%% initialize log files
if ltData.writeLogFile 
    h.data.fid = fopen(fullfile(ltData.savePath , ['LOG_' h.data.runIdentifier '.txt']), 'wt');
    
    % falls Ausgabe der LOG Datei in der Konsole erfolgen soll
    %   handles.data.fid = 1; fprintf('Dateiname: %s\n\n', handles.data.LogFileName);
    
    header = 'Hörversuch LOG Datei \n';
    header = [header, sprintf( ' Datum:                 %02i.%02i.%04i %02i:%02i Uhr\n', cl(3), cl(2), cl(1), cl(4), cl(5))];
    header = [header, sprintf( ' Versuchsperson:        %s \n',h.data.testPersonName)];
    fprintf( h.data.fid, header );
    fprintf( h.data.fid, '\n\n\n=================================================================\n' );

end

%%% generate GUI with all neccessary uicontrols
h.data.figSize           = [ 600 500 ]; % [width, height] in pixels

h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[1,1, h.data.figSize], 'Name',ltData.figureName,'MenuBar', 'none','CloseRequestFcn', {@CloseRequestFcn});
h.data.backgroundcolor =  get(h.f , 'Color');
movegui(h.f,'center');

% Introduction text and button
h.introButton   = uicontrol('Style','pushbutton', 'String',ltData.introButtonString,'Position',getPos(50,20,50,10,'c',h.data.figSize), 'Callback', {@continueAfterIntro});
h.introText     = uicontrol('Style','text','String',ltData.introText, 'Position', getPos(50,70,80,40,'c',h.data.figSize), 'fontsize', 11); 
h.hIntroArray   = [h.introButton , h.introText];

% Practice Run text and buttons
h.practiceRunText      = uicontrol('Style','text','String',ltData.practiceRunText, 'Position', getPos(50,70,80,40,'c',h.data.figSize), 'fontsize', 11);
h.endPracticeRunButton = uicontrol('Style','pushbutton', 'String','Training beenden und Hörversuch starten','Position',getPos(50,15,70,8,'c',h.data.figSize), 'Callback', {@GUI_next});
h.playAllPracRunButton = uicontrol('Style','pushbutton', 'String','Alle abspielen','Position',getPos(50,42,70,8,'c',h.data.figSize), 'Callback', {@playAllPractice});

startPos = 50 - 10*ltData.nSounds/2 - 5;
for k=1:ltData.nSounds
    h.practiceRunPlayButtons(k)  = uicontrol('Style','toggleButton','String',num2str(k), 'Position', getPos(startPos + 10*k ,30,8,8,'c',h.data.figSize), 'Callback', {@practiceRunButtons});
end
h.hPracticeRunArray = [h.practiceRunText, h.endPracticeRunButton, h.playAllPracRunButton, h.practiceRunPlayButtons];

% Selection text and button
h.cmpText          = uicontrol('Style','text','String',ltData.compareQuestion, 'BackgroundColor', h.data.backgroundcolor, 'FontWeight', 'bold', 'Position', getPos(50,90,80,5,'c',h.data.figSize) );
h.selectionButtonA = uicontrol('Style','togglebutton', 'String','Version A','Position',getPos(30,80,20,8,'c',h.data.figSize), 'Callback', {@chooseSound});
h.selectionButtonB = uicontrol('Style','togglebutton', 'String','Version B','Position',getPos(70,80,20,8,'c',h.data.figSize), 'Callback', {@chooseSound});

% Play options
h.currentPlayText   = uicontrol('Style','text','String','Aktuelle Wiedergabe:', 'BackgroundColor', h.data.backgroundcolor, 'Position', getPos(35,22,20,4,'c',h.data.figSize) );
h.sliderText        = uicontrol('Style','text','String','Start und Ende der Wiedergabe über Slider ändern', 'BackgroundColor', h.data.backgroundcolor, 'Position', getPos(70,22,50,4,'c',h.data.figSize) );
h.toggleAtEndButton = uicontrol('Style','togglebutton', 'Value', 1, 'String','AutoToggle@End','Position', getPos(15,32.5,20,5,'c',h.data.figSize), 'Callback', {@toggleAtEnd});
h.repeatButton      = uicontrol('Style','togglebutton', 'Value', 1, 'String','Repeat','Position', getPos(15,27.5,20,5,'c',h.data.figSize), 'Callback', {@repeat});
h.curPlayAButton    = uicontrol('Style','togglebutton', 'String','A','Position', getPos(30,30,10,10,'c',h.data.figSize), 'Callback', {@playSelection});
h.curPlayBButton    = uicontrol('Style','togglebutton', 'String','B','Position', getPos(40,30,10,10,'c',h.data.figSize), 'Callback', {@playSelection});
h.bckgrdTextBox     = uicontrol('Style','text', 'String','', 'BackgroundColor', 'w', 'Position', getPos(49.5,28,41,4,'lb',h.data.figSize));
h.progressTextBox   = uicontrol('Style','text', 'String','', 'BackgroundColor', 'r', 'Position', getPos(49.5,28,0.1,4,'lb',h.data.figSize));
h.startSlider       = uicontrol('Style','slider'      , 'Value' , 0 ,'Position', getPos(70,33,45,3,'c',h.data.figSize), 'Callback', {@startSlider});
h.endSlider         = uicontrol('Style','slider'      , 'Value' , 1 ,'Position', getPos(70,27,45,3,'c',h.data.figSize), 'Callback', {@endSlider});

% store selection and continue button
h.nextButton   = uicontrol('Style','pushbutton', 'String','Auswahl speichern und weiter','Position', getPos(50,13,60,8,'c',h.data.figSize), 'Callback', {@GUI_next});

h.hArray = [ h.cmpText h.selectionButtonA  h.selectionButtonB h.currentPlayText h.sliderText h.toggleAtEndButton h.repeatButton h.curPlayAButton h.curPlayBButton h.bckgrdTextBox h.progressTextBox h.startSlider h.endSlider h.nextButton];

% show progress in listening test
if ltData.showProgress
    h.progress  =   uicontrol('Style','text','String',' 0 / 0', 'Position', getPos(50,4,20,4,'c',h.data.figSize));
    h.hArray    = [h.hArray  h.progress];
end

% user attributes checkboxes and text
if ltData.useAttributes 
    h.attribText        = uicontrol('Style','text','String',ltData.attribQuestion, 'BackgroundColor', h.data.backgroundcolor, 'Position', getPos(50,68,80,5,'c',h.data.figSize));
    for k=1:numel(ltData.attributes)
        h.attribCbs(k)  = uicontrol('Style','checkbox','String',ltData.attributes{k}, 'BackgroundColor', h.data.backgroundcolor, 'Position', getPos(50,(70-5*k),70,5,'c',h.data.figSize) );
    end
    h.hArray = [h.hArray h.attribText h.attribCbs ];
end

% global online parameters for playback
global onlinePar
onlinePar.track       = 0;
onlinePar.isPlaying   = 0;
onlinePar.stopIt      = 0;
onlinePar.toggleAtEnd = 0;
onlinePar.repeat      = 0;
onlinePar.startSample = 1;
onlinePar.endSample   = h.data.nSamples;

% define color change for pressed buttons
h.data.defaultbuttonColor =  get(h.selectionButtonA , 'BackgroundColor');
h.data.choosedbuttonColor =  'r';

% Initialize visibility of GUI at start
set(h.hArray, 'Visible', 'off')
set(h.hPracticeRunArray, 'Visible', 'off')
set(h.hIntroArray , 'Visible', 'on')

%%% Initialize Pair Data
allCombinations             = nchoosek(1:ltData.nSounds,2);
nSets                       = size(allCombinations,1);

% generate random order of sets
[del randIDX]               = sort( rand( nSets, 1 ) );  %#ok<ASGLU>
playlist                    = allCombinations(randIDX,:);

% generate random order of signal A and B in each Set
swapAB = logical(round(rand(10,1)));
for k=1:nSets
    if swapAB(k)
        playlist(k,:) = playlist(k,[2,1]);
    end
end

h.data.currentLT.nSets      = nSets;
h.data.currentLT.playlist   = playlist;
h.data.currentLT.currentSet = 0;
h.data.currentLT.prefMat    = zeros(ltData.nSounds); % prefMat(i,j) = 1 => i is prefered over j. prefMat(i,j) = 0 => j is prefered over i.
if ltData.useAttributes
    h.data.currentLT.selectedAttributes   = zeros(ltData.nSounds,ltData.nSounds,numel(ltData.attributes)); % 3D array for selected attributes  
end

%%% Make GUI visible
guidata(h.f, h)
set(h.f,'Visible','on') 

end %function

%% Callback functions
function chooseSound(s,e)%#ok<INUSD>
h = guidata(s);

if get(s,'value') 
    set([h.selectionButtonA h.selectionButtonB] ,'Value', 0)
    set([h.selectionButtonA h.selectionButtonB],'BackgroundColor', h.data.defaultbuttonColor);
    set(s,'Value', 1)
    set(s,'BackgroundColor', h.data.choosedbuttonColor);
else
    set(s,'BackgroundColor', h.data.defaultbuttonColor);   
end

end %function

function continueAfterIntro(s,e)

h = guidata(s);

set(h.hIntroArray , 'Visible', 'off');

if h.ltData.doPracticeRun
       
    set(h.practiceRunPlayButtons ,'Value', 0);
    set(h.practiceRunPlayButtons ,'Enable', 'off');
    set(h.endPracticeRunButton ,'Enable', 'off');
    set(h.playAllPracRunButton, 'Enable', 'on');

    set(h.hPracticeRunArray, 'Visible', 'on');
    guidata(h.f, h);
else
    GUI_next(s,e);
end

end %function

function playAllPractice(s,e)

h = guidata(s);

set(s ,'Enable', 'off');
set(h.practiceRunPlayButtons ,'Value', 0);
set(h.practiceRunPlayButtons ,'Enable', 'off');
set(h.endPracticeRunButton ,'Enable', 'off');

pause(0.5);

for k=1:h.ltData.nSounds
    curSig = wavread(h.ltData.soundList{k});
    set(h.practiceRunPlayButtons(k) ,'Value', 1);
    set(h.practiceRunPlayButtons(k) ,'BackgroundColor', h.data.choosedbuttonColor);
    pause(0.01)
    wavplay(curSig, h.data.samplingRate);
    set(h.practiceRunPlayButtons(k) ,'Value', 0);
    set(h.practiceRunPlayButtons(k) ,'BackgroundColor', h.data.defaultbuttonColor);
    pause( 0.5 );
end

set(h.practiceRunPlayButtons ,'Enable', 'on');
set(h.endPracticeRunButton, 'Enable', 'on');
set(s ,'String', 'Zum nochmaligen Abspielen einzelner Samples auf Buttons klicken');

end %function

function practiceRunButtons(s,e)

h = guidata(s);

if get(s,'value') 
    set(h.practiceRunPlayButtons ,'Value', 0);
    set(h.practiceRunPlayButtons,'BackgroundColor', h.data.defaultbuttonColor);
    set(s,'Value', 1);
    set(s,'BackgroundColor', h.data.choosedbuttonColor);
    set(h.practiceRunPlayButtons ,'Enable', 'off');
    pause(0.01);
else 
    return;
end

for k=1:h.ltData.nSounds
    if s == h.practiceRunPlayButtons(k) 
        curSig = wavread(h.ltData.soundList{k});
        break;
    end
end
wavplay(curSig, h.data.samplingRate);

set(h.practiceRunPlayButtons ,'Enable', 'on');
set(s,'BackgroundColor', h.data.defaultbuttonColor);
set(s,'Value', 0);

end %function

function toggleAtEnd(s,e)%#ok<INUSD>

global onlinePar
onlinePar.toggleAtEnd = get(s,'Value');

end %function

function playSelection(s,e)%#ok<INUSD>

global onlinePar

h = guidata(s);

if ~get(s,'Value') % wenn Track gerade ausgeschaltet wurde => beenden
    onlinePar.track  = 0;
    onlinePar.stopIt = 1;
else
    if s == h.curPlayAButton
        onlinePar.track = 1;
    else % s == h.curPlayBButton
        onlinePar.track = 2;
    end
    
    if ~onlinePar.isPlaying  %gerade wird nichts abgespielt => start wiedergabe
        play(h);
        pause(0.1);
    end
end 

end %function

function repeat(s,e)%#ok<INUSD>

global onlinePar
onlinePar.repeat = get(s,'Value');

end %function

function startSlider(s,e)

global onlinePar

h = guidata(s);
onlinePar.startSample = max( 1 , min( round(get(s,'Value')*h.data.nSamples) , (onlinePar.endSample - h.ltData.frameSize + 1) ) );
set(s,'Value', onlinePar.startSample/h.data.nSamples);

end %function

function endSlider(s,e)

global onlinePar

h = guidata(s);
onlinePar.endSample = max( round(get(s,'Value')*h.data.nSamples) , (onlinePar.startSample + h.ltData.frameSize - 1) );
set(s,'Value', onlinePar.endSample/h.data.nSamples);

end %function

function GUI_next(s,e)%#ok<INUSD>

global onlinePar

h = guidata(s);
set(h.hPracticeRunArray, 'Visible', 'off');
set(h.hArray, 'Visible', 'on');

pause(0.01); % to update global vars

% interrupt playback if still playing
if onlinePar.isPlaying
    onlinePar.isPlaying   = 0;
    onlinePar.stopIt      = 1;
    d = warndlg('Wiedergabe wird zuerst beendet... bitte anschließend nochmals den WEITER Button betätigen');
    waitfor(d)
    return;
end

%%% Save selection from last set, if this ain't not the first set at all
if (h.data.currentLT.currentSet>0)
    
    idx2button = h.data.currentLT.playlist(h.data.currentLT.currentSet,:);
    
    if get(h.selectionButtonA, 'value')==1 && get(h.selectionButtonB, 'value')==0
        winner = 'A';
    elseif get(h.selectionButtonA, 'value')==0 && get(h.selectionButtonB, 'value')==1
        winner = 'B';
    elseif get(h.selectionButtonA, 'value')==0 && get(h.selectionButtonB, 'value')==0
        d = warndlg('Bitte eine Version auswählen.');
        waitfor(d)
        return
    elseif get(h.selectionButtonA, 'value')==1 && get(h.selectionButtonB, 'value')==1
        error('You selected A and B, how is this even possible??? There appears to be some error in the gui processing.');
    end
    
    if ~any(cell2mat(get(h.attribCbs,'Value')))
        d = warndlg('Bitte mindestens ein Diskriminierungsmerkmal auswählen.');
        waitfor(d)
        return
    end        
    
    switch winner
        case 'A'
            idxWinner = idx2button(1) ;
            idxLooser = idx2button(2);
        case 'B'
            idxWinner = idx2button(2) ;
            idxLooser = idx2button(1);
    end
    
    h.data.currentLT.prefMat(idxWinner, idxLooser) = 1; % prefMat(i,j) = 1 => i is prefered over j ; prefMat(i,j) = 0 => j is prefered over i
    h.data.currentLT.prefMat(idxLooser, idxWinner) = 0;
    if h.ltData.useAttributes
        attributeStringList= [];
        for k=1:numel(h.ltData.attributes)
            pairAttribVec(k) = get(h.attribCbs(k), 'Value');
            if pairAttribVec(k)
                attributeStringList = [attributeStringList, '  ', h.ltData.attributes{k}];
            end
        end
        h.data.currentLT.selectedAttributes(idx2button(1),idx2button(2),:)  = pairAttribVec; % selectedAttributes(i,j,k) = 1 ; attrib number k is important for discrimination of pair (i,j)
        h.data.currentLT.selectedAttributes(idx2button(2),idx2button(1),:)  = pairAttribVec; % selectedAttributes(i,j,k) = 1 ; attrib number k is important for discrimination of pair (i,j)
    end
    if h.ltData.writeLogFile
        if h.ltData.useAttributes
            fprintf(h.data.fid, '  Auswahl: %s\n Unterschiedsmerkmale für Paar AB:%s\n', winner, attributeStringList);
        else
            fprintf(h.data.fid, '  Auswahl: %s\n', winner);
        end
    end

end

%%% Go to next set, if if previous set was not the last one
if (h.data.currentLT.currentSet<h.data.currentLT.nSets) 
    
    h.data.currentLT.currentSet = h.data.currentLT.currentSet + 1;
    guidata(h.f, h);
    set(h.progress, 'string', sprintf('Set %i von %i', h.data.currentLT.currentSet, h.data.currentLT.nSets ))
    
    % reset GUI
    set([h.selectionButtonA h.selectionButtonB h.toggleAtEndButton h.repeatButton h.curPlayAButton h.curPlayBButton ], 'value', 0);
    set([h.selectionButtonA h.selectionButtonB h.curPlayAButton h.curPlayBButton],'BackgroundColor', h.data.defaultbuttonColor);
    set(h.startSlider, 'value', 0);
    set(h.endSlider, 'value', 1);
    set(h.progressTextBox, 'Position', getPos(49.5,28,0.1,4,'lb',h.data.figSize));
    
    if h.ltData.useAttributes
        set(h.attribCbs , 'Value', 0);
    end
    set(h.hArray, 'Visible', 'on', 'Enable', 'off');
    
    onlinePar.toggleAtEnd = 0;
    onlinePar.repeat      = 0;
    pause(1);
    
    % Play complete signal for A and B with initial number of repetitions
    buttonHandles = [h.curPlayAButton, h.curPlayBButton];
    
    fileNumbers      = h.data.currentLT.playlist(h.data.currentLT.currentSet,:);
    if h.ltData.writeLogFile
        fprintf(h.data.fid, '%i. Set\n  Sound A: %s\n  Sound B: %s\n', h.data.currentLT.currentSet,h.ltData.soundList{fileNumbers(1)}, h.ltData.soundList{fileNumbers(2)} );
    end
    
    for k=1:h.ltData.ABrepetitions
        set(buttonHandles(1), 'Value', 1);
        playSelection(buttonHandles(1),e);
        set(buttonHandles(1), 'Value', 0);
        pause(h.ltData.pauseBetween);
        set(buttonHandles(2), 'Value', 1);
        playSelection(buttonHandles(2),e);
        set(buttonHandles(2), 'Value', 0);
    end
    
    set(h.hArray, 'Enable', 'on');
    
else %%% We arrived at the end of the listening test
    set(h.hArray, 'Visible', 'off');
    set(h.introText,'String', h.ltData.endText);
    set(h.introButton, 'String', 'Fertig', 'Callback', {@CloseRequestFcn});
    set(h.hIntroArray , 'Visible', 'on');
    
    % save as mat files
    if h.ltData.useAttributes
        ltResult = struct('testPersonName', h.data.testPersonName, 'preferenceMatrix' , h.data.currentLT.prefMat, 'selectedAttributes', h.data.currentLT.selectedAttributes, 'attributeList', {h.ltData.attributes}, 'listeningTestData', h.ltData); %#ok<NASGU>
    else
        ltResult = struct('testPersonName', h.data.testPersonName, 'preferenceMatrix' , h.data.currentLT.prefMat, 'listeningTestData', h.ltData); %#ok<NASGU>
    end
    save(fullfile(h.ltData.savePath, ['result_'  h.data.runIdentifier '.mat',]), 'ltResult')
    
    
    if h.ltData.writeLogFile
        fprintf(h.data.fid, '\n\nTest completed successfully.');
        fclose(h.data.fid);
    end
end

guidata(h.f, h)

end %function

function CloseRequestFcn(s,e) %#ok<INUSD>
h = guidata(s);
if h.data.currentLT.currentSet == h.data.currentLT.nSets    % test finished
    delete(h.f)
else
    btn = questdlg('Wollen Sie wirklich den Test beenden?', 'Test abbrechen', 'Ja', 'Nein', 'Nein');
    
    if strcmp(btn, 'Ja')
        delete(h.f)
        if h.ltData.writeLogFile
            fprintf(h.data.fid, '\n\nCanceled by user. \n\n');
            fclose(h.data.fid);
        end
        
    end
end

end %function

%% Auxiliary Functions
%%% Positioning function for GUI Elements
function pos = getPos(relAnchorHor,relAnchorVert,relWidth,relHeight,anchorType,figSize)

width = relWidth/100 * figSize(1);
height = relHeight/100 * figSize(2);

switch anchorType
    case 'lb'
        left   = relAnchorHor/100  * figSize(1);
        bottom = relAnchorVert/100 * figSize(2);
    case 'c'
        left   = (relAnchorHor/100 - 0.5 * relWidth/100) * figSize(1);
        bottom = (relAnchorVert/100 - 0.5 * relHeight/100) * figSize(2);
end

pos = [left bottom width height];

end %function

%%% playback function
function play(h)

global onlinePar

% Init sound device
pageBufCount     = 2;
runMaxSpeed      = true;
Fs               = ita_preferences('samplingRate');
if playrec('isInitialised')
    playrec('reset');
end
playrec('init',Fs, ita_preferences('playDeviceID'), ita_preferences('recDeviceID'));
playrec('delPage');
pageNumList      = repmat(-1, [1 pageBufCount]);
firstTimeThrough = true;

% constant parameters
buttonHandles     = [h.curPlayAButton h.curPlayBButton];
fileNumbers       = h.data.currentLT.playlist(h.data.currentLT.currentSet,:);
nSamples          = h.data.nSamples;
frameSize         = h.ltData.frameSize;
nFadeFrames       = h.ltData.nFadeFrames;
fadeInWindow      = h.data.fadeInWindow;
fadeOutWindow     = h.data.fadeOutWindow;
playBackAmpFactor = h.ltData.playBackAmpFactor;
soundList         = h.ltData.soundList;

% Parameters for while loop
lastTrack = onlinePar.track;
lastFrame = 0;
curEndSample = 0;
onlinePar.isPlaying =1;
onlinePar.startSample = max(round(get(h.startSlider,'Value')*nSamples),1);
onlinePar.endSample = round(get(h.endSlider,'Value')*h.data.nSamples);
fadeFrame = 0;

% Hauptschleife
while ishandle(h.f)
    
    pause(0.00001)       % doof aber notwendig, damit globale var aktualisiert wird
    
    if onlinePar.stopIt % Wiedergabe beenden
        set(buttonHandles, 'Value', 0);     % alle "aus"
        set(buttonHandles,'BackgroundColor', h.data.defaultbuttonColor);
        set(h.progressTextBox, 'Position', getPos(49.5,28,0.1,4,'lb',h.data.figSize));
        break
    end
        
    % check if the audioSignal was changed in another function during playback
    if (onlinePar.track ~= lastTrack)
        fadeFrame = 1;
    end
        
    % get current sample position in track (account for possible changes induced via the start and end sliders)
    curStartSample   = curEndSample+1;
    curEndSample     = curStartSample+frameSize-1;
    
    playBackStartSample = onlinePar.startSample;
    playBackEndSample   = onlinePar.endSample;

    if curStartSample >= playBackEndSample
        curStartSample = playBackStartSample;
        curEndSample   = curStartSample+frameSize-1;
    end
    if curStartSample < playBackStartSample
        curStartSample = playBackStartSample;
        curEndSample   = curStartSample+frameSize-1;
    end
    if (curStartSample+frameSize-1) >= playBackEndSample
        % play rest of sound sample
        if (curStartSample+frameSize-1) <= nSamples;
            curEndSample = curStartSample + frameSize - 1;
        else
            curEndSample = nSamples;
        end
        lastFrame = 1;
    end
    
    Sig{1} = playBackAmpFactor * wavread(soundList{fileNumbers(1)}, [curStartSample curEndSample]);
    Sig{2} = playBackAmpFactor * wavread(soundList{fileNumbers(2)}, [curStartSample curEndSample]);
    
    if (curStartSample==playBackStartSample)  % never fade at beginning of signal
        fadeFrame = 0;
    end
    if fadeFrame
        startSample = (fadeFrame-1)*frameSize+1;
        winLen = (curEndSample-curStartSample)+1;
        fadeIn  = fadeInWindow ( startSample : startSample+winLen-1 );
        fadeOut = fadeOutWindow( startSample : startSample+winLen-1 );
        
        curSig = ( Sig{onlinePar.track} .* [fadeIn, fadeIn] ) + ( Sig{3-onlinePar.track} .* [fadeOut, fadeOut] );    
    else
        curSig = Sig{onlinePar.track};
    end
    
    set(h.progressTextBox, 'Position', getPos(49.5+(playBackStartSample/nSamples*45),28,((curStartSample-playBackStartSample)/nSamples*41)+eps,4,'lb',h.data.figSize));
    set(buttonHandles(onlinePar.track), 'Value', 1);
    set(buttonHandles(onlinePar.track),'BackgroundColor', h.data.choosedbuttonColor);
    
    % Play !!!
    pageNumList = [pageNumList playrec('play',curSig,[1 2])]; %#ok<AGROW>
    
    set(h.progressTextBox, 'Position', getPos(49.5+(playBackStartSample/nSamples*45),28,((curEndSample-playBackStartSample)/nSamples*41)+eps,4,'lb',h.data.figSize));
    pause(0.00001);

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

    %%% merken, welcher Track gerade abgespielt wurde, und aktualisieren wo wir im Fade sind
    lastTrack = onlinePar.track;
    if fadeFrame
        fadeFrame = mod(fadeFrame+1,nFadeFrames+1);
    end
    
    if lastFrame
        set(buttonHandles, 'Value', 0)     % alle "aus" und nur den gerade gedrückten Button "an"
        set(buttonHandles,'BackgroundColor', h.data.defaultbuttonColor);
        set(h.progressTextBox, 'Position', getPos(49.5,28,0.1,4,'lb',h.data.figSize));
        if ~onlinePar.repeat    
            break
        end
        if onlinePar.toggleAtEnd
            onlinePar.track = (3 - onlinePar.track); % toggle track
        end
        lastFrame = 0;
        curEndSample = onlinePar.startSample-1;
        fadeFrame = 0;
    end

end

onlinePar.isPlaying     = 0;
onlinePar.stopIt        = 0;

end %function



