function varargout = ita_listeningtests_ranking(varargin)
% ITA_LISTENINGTESTS_RANKING - listeningtests with ranking options
% Syntax: ita_listeningtests_ranking(usernameString, datafolder)
%
% Author: Martin Guski - 2010
% Editor: Pascal Dietrich - 2011

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HV_OpeningFcn, ...
    'gui_OutputFcn',  @HV_OutputFcn, ...
    'gui_LayoutFcn',  @ita_listeningtests_ranking_LayoutFcn, ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


%% opening
function HV_OpeningFcn(hObject, eventdata, handles, varargin)
name = genvarname(varargin{1});
folder = varargin{2};

handles.output = hObject;

%
%screen_size = get(0,'ScreenSize');
%set(handles.figure1, 'Position', [0 0 screen_size(3) screen_size(4) ] );

global onlinePar
onlinePar.Track     = 0;
onlinePar.isPlaying = 0;
onlinePar.stopIt    = 0;
onlinePar.next      = 0;

handles.data.zuordnung      = {'V1','V2','V3'}; % zuordnung der werte zu den Versionen
handles.data.nSets          = 7;
handles.data.iSet           = 1;
handles.data.result         = zeros(handles.data.nSets,3);

[dummy randIDX]             = sort( rand(handles.data.nSets,1));
% disp(randIDX)
handles.data.setOrder       = randIDX;

% [dummy randIDX]             = sort( reshape(rand(handles.data.nSets*3,1), handles.data.nSets,3),2);
% handles.data.subSetOrder    = randIDX;
% besserer zufall:
handles.data.subSetOrder = zeros(handles.data.nSets ,3);
for i = 1:handles.data.nSets       % schleife damit rand auch immer zufällig
    pause(rand/10)
    [dummy randIDX]             = sort( rand(3,1));
    handles.data.subSetOrder(i,:) = randIDX';
end

if false
    handles.data.setOrder       = (1:handles.data.nSets).';
    %     handles.data.subSetOrder    = repmat([1 2 3], handles.data.nSets,1);
    disp('WARNUNG: ZUFÄLLIGE WIEDERGABE DEAKTIVIERT!!!!!!!!!!!!!!!!!!!!!!!!!!!')
end

handles.data.path           = [folder filesep];

cl = clock;

% name = inputdlg( 'Bitte geben Sie Ihren Namen ein.','Name', 1);
menu('Zweiter Teil des Hörversuchs. Stellen sie bitte mit Hilfe der "hoch" "runter" Buttons eine Rangfolge der Maschinensimulationen her. Die Signale können beliebig oft durch drücken der "A" "B" "C" Buttons verglichen werden. Drücken Sie jetzt auf "Weiter".','Weiter');
if isempty(name) % TODO: feherlmeldung verhindern
    guidata(hObject, handles);
    close(handles.figure1)
else
    if iscell(name)
        name = name{1};
    end
    
    handles.data.LogFileName = sprintf( 'LOG_%04i%02i%02i_%02i%02i_%s.txt', cl(1), cl(2), cl(3), cl(4), cl(5),strrep(name, ' ', ''));
    handles.data.fid = fopen(handles.data.LogFileName, 'wt');
    
    % falls Ausgabe der LOG Datei in der Konsole erfolgen soll
    %   handles.data.fid = 1; fprintf('Dateiname: %s\n\n', handles.data.LogFileName);
    
    header = 'Hörversuch LOG Datei \n';
    header = [header, sprintf( ' Datum:                 %02i.%02i.%04i %02i:%02i Uhr\n', cl(3), cl(2), cl(1), cl(4), cl(5))];
    header = [header, sprintf( ' Versuchsperson:        %s \n',name)];
    header = [header, sprintf( ' Abspielfolge der Sets: %s \n',num2str(handles.data.setOrder'))];
    header = [header, sprintf( ' Subsetordnung:         (Position entspricht Buttons A,B,C --- Nummer steht für Version: 1=%s | 2=%s | 3=%s ) \n',handles.data.zuordnung{1},handles.data.zuordnung{2},handles.data.zuordnung{3})];
    fprintf( handles.data.fid, header );
    subSetOrderStr = ['     Button:  A, B, C\n'; repmat('     Set ',handles.data.nSets,1), num2str((1:handles.data.nSets)','%02i'), repmat(':  ',handles.data.nSets,1), num2str(handles.data.subSetOrder(:,1)), repmat(', ',handles.data.nSets,1),num2str(handles.data.subSetOrder(:,2)), repmat(', ',handles.data.nSets,1),num2str(handles.data.subSetOrder(:,3)), repmat('\n',handles.data.nSets,1)];
    fprintf( handles.data.fid, subSetOrderStr' );
    fprintf( handles.data.fid, '\n\n\n=================================================================\n' );
    
    handles.output = 11;
    guidata(hObject, handles);
end

%% Output dummy
function varargout = HV_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function tb_A_Callback(hObject, eventdata, handles)
global onlinePar
if ~get(hObject,'Value') % wenn Track gerade noch lief => beenden
    onlinePar.stopIt = 1;
    %     pause(10)
else
    set([handles.tb_A handles.tb_B handles.tb_C], 'Value', 0) % alle aus und HObject an, damit gleicher
    set(hObject, 'Value', 1)                                 % Code für alle ToggleButtons verwedet werden kann
    onlinePar.Track     = get(hObject,'string') -64;          % name des Button hoffentlich Großbuchstabe
    
    if ~onlinePar.isPlaying  %gerade wird nichts abgespielt => start wiedergabe
        play(handles)
    end
    
    %     rf = get(handles.lb_rangfolge, 'String');
end


function tb_C_Callback(hObject, eventdata, handles)
global onlinePar
if ~get(hObject,'Value') % wenn Track gerade noch lief => beenden
    onlinePar.stopIt = 1;
else
    set([handles.tb_A handles.tb_B handles.tb_C], 'Value', 0) % alle aus und HObject an, damit gleicher
    set(hObject, 'Value', 1)                                 % Code für alle ToggleButtons verwedet werden kann
    onlinePar.Track     = get(hObject,'string') -64;          % name des Button hoffentlich Großbuchstabe
    
    if ~onlinePar.isPlaying  %gerade wird nichts abgespielt => start wiedergabe
        play(handles)
    end
end
function tb_B_Callback(hObject, eventdata, handles)
global onlinePar
if ~get(hObject,'Value') % wenn Track gerade noch lief => beenden
    onlinePar.stopIt = 1;
else
    set([handles.tb_A handles.tb_B handles.tb_C], 'Value', 0) % alle aus und HObject an, damit gleicher
    set(hObject, 'Value', 1)                                 % Code für alle ToggleButtons verwedet werden kann
    onlinePar.Track     = get(hObject,'string') -64;          % name des Button hoffentlich Großbuchstabe
    
    if ~onlinePar.isPlaying  %gerade wird nichts abgespielt => start wiedergabe
        play(handles)
    end
end

function lb_rangfolge_Callback(hObject, eventdata, handles)
function lb_rangfolge_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pb_up_Callback(hObject, eventdata, handles)
pos = get(handles.lb_rangfolge, 'Value');
if pos ~= 1
    rf = get(handles.lb_rangfolge,'String');
    tmp = rf{pos};
    rf{pos} = rf{pos-1};
    rf{pos-1} = tmp;
    set(handles.lb_rangfolge,'String',rf);
    set(handles.lb_rangfolge,'Value',pos-1);
end
function pb_down_Callback(hObject, eventdata, handles)
pos = get(handles.lb_rangfolge, 'Value');
if pos ~= 3
    rf = get(handles.lb_rangfolge,'String');
    tmp = rf{pos};
    rf{pos} = rf{pos+1};
    rf{pos+1} = tmp;
    set(handles.lb_rangfolge,'String',rf);
    set(handles.lb_rangfolge,'Value',pos+1);
end

function pb_next_Callback(hObject, eventdata, handles)
global onlinePar
if onlinePar.isPlaying
    onlinePar.next = 1;
else
    writeLogFile(handles)
end

%% playback function
function play(handles)
global onlinePar

partFileName = [handles.data.path , sprintf('set%02i_',handles.data.setOrder(handles.data.iSet))];
fileList = {[partFileName,handles.data.zuordnung{handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),1)}], [partFileName,handles.data.zuordnung{handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),2)}],[partFileName, handles.data.zuordnung{handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),3)}]};

%% Parameter
frameSize = 2048*4;
nFrames2Fade = 2;

%% Init sound device
pageBufCount = 1	;
runMaxSpeed  = true;
Fs = ita_preferences('samplingRate');
if playrec('isInitialised')
    playrec('reset');
end
playrec('init',Fs, ita_preferences('playDeviceID'), ita_preferences('recDeviceID'));
playrec('delPage');
pageNumList = repmat(-1, [1 pageBufCount]);
firstTimeThrough = true;

%% wav Parameter bestimmen
[m d] = wavfinfo([fileList{1} '.wav']);
if strcmp(m, 'Sound (WAV) file')
    xLength = str2double(d(findstr(d, 'Sound (WAV) file containing: ') + 28: findstr(d, ' samples')));
else
    errordlg('wav Datei konnte nicht gelesen werden. Programm wird abgebrochen.', 'Fehler')
    return
end

iFrame = 1;
nFrames =  floor(xLength/frameSize);
onlinePar.isPlaying =1;

ampFaktor = 1.4;


% fadeWin = hanning(frameSize*nFrames2Fade);
fadeWin = reshape(((1:frameSize*nFrames2Fade)/(frameSize*nFrames2Fade)), frameSize, []);
lastTrack = onlinePar.Track;

%% Hauptschleife
while (iFrame <= nFrames) && ishandle(handles.figure1)    % TODO: letztes Frame auch spielen
    
    pause(0.00001)       % doof aber notwendig, damit globale var aktualisiert wird
    if onlinePar.stopIt || onlinePar.next% Simulation beenden
        break
    end
    
    
    % SIGNAL einlesen
    if onlinePar.Track ~= lastTrack
        iFrame =1;
        lastTrack = onlinePar.Track;
    end
    
    x  = ampFaktor * wavread(fileList{onlinePar.Track}, [(iFrame-1)*frameSize+1 (iFrame)*frameSize] );
    
    %     f1 = zeros(1,frameSize)+1;
    %     f2 = zeros(1,frameSize);
    
    if iFrame >= nFrames - nFrames2Fade +1 % wenn wir am ende angekommen sind
        
        otherFrame = iFrame - nFrames + nFrames2Fade;
        x2  = ampFaktor * wavread(fileList{onlinePar.Track}, [(otherFrame-1)*frameSize+1 (otherFrame)*frameSize] );
        x = x.*fadeWin(end:-1:1,nFrames -iFrame  +1) + x2.*fadeWin(:, otherFrame);
        %         f1 = fadeWin(end:-1:1,nFrames - iFrame  +1)';
        %         f2 = fadeWin(:, otherFrame)';
        
    end
    
    pageNumList = [pageNumList playrec('play',[x x],[1 2])]; %#ok<AGROW>
    
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
    
    
    if iFrame ==  nFrames    % loop
        iFrame = 1 +nFrames2Fade;
    end
    iFrame = iFrame +1;
    
end


% playrec('reset')
set([handles.tb_A handles.tb_B handles.tb_C], 'Value', 0)
onlinePar.isPlaying     = 0;
onlinePar.stopIt        = 0;

if onlinePar.next
    writeLogFile(handles)
end


%% Write a log file
function writeLogFile(handles)

global onlinePar
zuordnung = handles.data.zuordnung;

fprintf(handles.data.fid, sprintf('%02i. abgespieltes Set \n',handles.data.iSet));
fprintf(handles.data.fid, sprintf('Nummer des Sets:    %02i\n',handles.data.setOrder(handles.data.iSet)));
fprintf(handles.data.fid, sprintf('Buttonzuordnung:    A->%s  |  B->%s  |  C->%s\n',zuordnung{handles.data.subSetOrder(handles.data.iSet,1)},zuordnung{handles.data.subSetOrder(handles.data.iSet,2)},zuordnung{handles.data.subSetOrder(handles.data.iSet,3)}));

rangfolge_blind = get(handles.lb_rangfolge,'String');
fprintf(handles.data.fid,        ['Blinde Rangfolge:   ' rangfolge_blind{:} '\n']);
rangfolge_decodiert = [handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),rangfolge_blind{1}-64),handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),rangfolge_blind{2}-64),handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),rangfolge_blind{3}-64)];
fprintf(handles.data.fid, sprintf('Rangfolge:          %s -> %s -> %s (%i %i %i)\n\n\n', zuordnung{rangfolge_decodiert(1)},zuordnung{rangfolge_decodiert(2)},zuordnung{rangfolge_decodiert(3)},rangfolge_decodiert(1),rangfolge_decodiert(2),rangfolge_decodiert(3)));

handles.data.result(handles.data.setOrder(handles.data.iSet),:) = rangfolge_decodiert;

handles.data.iSet    = handles.data.iSet    +1;
set(handles.lb_rangfolge,'String',{'A';'B';'C'});
guidata(handles.pb_next, handles);
onlinePar.next = 0;
set(handles.tx_set, 'String', sprintf('Set %i:', handles.data.iSet));

if handles.data.iSet > handles.data.nSets  % letztes Set ferig => Ergebnisse speichern
    %     set([handles.pb_next handles.tb_A, handles.tb_B handles.tb_C, handles.lb_rangfolge, handles.pb_up, handles.pb_down, handles.tx_set handles.pb_back5 tx_rangfolge], 'Visible', 'off');
    set([handles.pb_next handles.ui_versionen  handles.ui_bewertung handles.tx_set ], 'Visible', 'off');
    set(handles.tx_ende, 'Visible', 'on');
    drawnow
    fprintf(handles.data.fid,'=================================================================\n\n');
    fprintf(handles.data.fid, sprintf('Ergebnisse: (Zuordnung: 1=%s | 2=%s | 3=%s ) \n\n',handles.data.zuordnung{1},handles.data.zuordnung{2},handles.data.zuordnung{3}));
    ergStr = num2str(handles.data.result);
    fprintf(handles.data.fid, [['  Rang  :  1  2  3';'  ================'; repmat('  Set ',handles.data.nSets,1), num2str((1:handles.data.nSets)','%02i'), repmat(':  ',handles.data.nSets,1),ergStr], repmat('\n', handles.data.nSets+2,1)]');
    fprintf( [['  Rang  :  1  2  3';'  ================'; repmat('  Set ',handles.data.nSets,1), num2str((1:handles.data.nSets)','%02i'), repmat(':  ',handles.data.nSets,1),ergStr], repmat('\n', handles.data.nSets+2,1)]');
    fprintf(handles.data.fid, '\n\n\n End of Logfile\n');
    if handles.data.fid ~= 1 % wenn ausgabe nicht in Konsole, dann datei schließen
        fclose(handles.data.fid);
    end
    
    
    kennung = ['result_' handles.data.LogFileName(5:end-4)];
    
    tmpRes.data = handles.data.result;
    tmpRes.id   = handles.data.LogFileName(5:end-4);
    tmpRes.rfSet= handles.data.setOrder;
    
    eval(sprintf('%s = tmpRes;',kennung)); %TODO: badly coded!
    eval(['save ' kennung ' ' kennung]);
    
end

%% ************** CREATE NICE GUI *************
function h1 = ita_listeningtests_ranking_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

taginfo.figure= 2;
taginfo.togglebutton= 4;
taginfo.listbox= 2;
taginfo.pushbutton= 5;
taginfo.text= 7;
taginfo.uipanel= 4;

% define this mat cell
mat.active_h= [];
mat.taginfo= taginfo;
mat.override= 0;
mat.release= 13;
mat.resize= 'none';
mat.accessibility= 'callback';
mat.mfile= 1;
mat.callbacks= 1;
mat.singleton= 1;
mat.syscolorfig= 0;
mat.blocking= 0;
mat.lastSavedFile= '';
mat.lastFilename= '';

appdata = [];
appdata.GUIDEOptions = mat;
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
'Units','characters',...
'PaperUnits',get(0,'defaultfigurePaperUnits'),...
'IntegerHandle','off',...
'MenuBar','none',...
'Name','ITA Listening Test - Ranking',...
'NumberTitle','off',...
'Position',[103.714285714286 2.92857142857143 232.571428571429 58.5714285714286],...
'Resize','off',...
'HandleVisibility','callback',...
'UserData',[],...
'Tag','figure1',...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

%% logo

appdata = [];
appdata.lastValidTag = 'tx_ende';

h2 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'FontSize',20,...
'Position',[13.4285714285714 3.64285714285714 70.1428571428571 4.71428571428571],...
'String','Ende. Vielen Dank!',...
'Style','text',...
'Tag','tx_ende',...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pb_next';

h3 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)HV('pb_next_Callback',hObject,eventdata,guidata(hObject)),...
'FontSize',14,...
'Position',[88.7142857142857 4.57142857142857 20.1428571428571 3.92857142857143],...
'String','Weiter',...
'Tag','pb_next',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'tx_set';

h4 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'FontSize',24,...
'HorizontalAlignment','left',...
'Position',[38.4285714285714 44.8571428571429 24 4.21428571428571],...
'String','Set 1',...
'Style','text',...
'Tag','tx_set',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'tx_hoerversuch';

h5 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'FontSize',20,...
'Position',[13.7142857142857 52.9285714285714 70.1428571428571 3.07142857142857],...
'String','Hörversuch Teil 2',...
'Style','text',...
'Tag','tx_hoerversuch',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ui_versionen';

h6 = uipanel(...
'Parent',h1,...
'Units','characters',...
'FontSize',12,...
'Title','Versionen',...
'Tag','ui_versionen',...
'Clipping','on',...
'Position',[8.42857142857143 29.7142857142857 80.1428571428571 11.6428571428571],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'tb_A';

h7 = uicontrol(...
'Parent',h6,...
'Units','characters',...
'Callback',@(hObject,eventdata)ita_listeningtests_ranking('tb_A_Callback',hObject,eventdata,guidata(hObject)),...
'FontSize',12,...
'Position',[7.4 3.87362637362637 20.2 3.84615384615384],...
'String','A',...
'Style','togglebutton',...
'Tag','tb_A',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'tb_B';

h8 = uicontrol(...
'Parent',h6,...
'Units','characters',...
'Callback',@(hObject,eventdata)HV('tb_B_Callback',hObject,eventdata,guidata(hObject)),...
'FontSize',12,...
'Position',[29.6 3.87362637362637 20.2 3.84615384615384],...
'String','B',...
'Style','togglebutton',...
'Tag','tb_B',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'tb_C';

h9 = uicontrol(...
'Parent',h6,...
'Units','characters',...
'Callback',@(hObject,eventdata)HV('tb_C_Callback',hObject,eventdata,guidata(hObject)),...
'FontSize',12,...
'Position',[52.8 3.87362637362637 20.2 3.84615384615384],...
'String','C',...
'Style','togglebutton',...
'Tag','tb_C',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ui_bewertung';

h10 = uipanel(...
'Parent',h1,...
'Units','characters',...
'FontSize',12,...
'Title','Bewertung',...
'Tag','ui_bewertung',...
'Clipping','on',...
'Position',[14.1428571428571 7.42857142857143 70.1428571428571 18.5714285714286],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'tx_rangfolge';

h11 = uicontrol(...
'Parent',h10,...
'Units','characters',...
'FontSize',14,...
'FontWeight','bold',...
'HorizontalAlignment','left',...
'Position',[5.8 4.87912087912089 31.2 11.6153846153846],...
'String',{  'Rangfolge:'; blanks(0); '1.'; '2.'; '3.' },...
'Style','text',...
'Tag','tx_rangfolge',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'lb_rangfolge';

h12 = uicontrol(...
'Parent',h10,...
'Units','characters',...
'Callback',@(hObject,eventdata)HV('lb_rangfolge_Callback',hObject,eventdata,guidata(hObject)),...
'FontSize',14,...
'Position',[9.8 4.03296703296704 16.6 9.30769230769231],...
'String',{  'A'; 'B'; 'C' },...
'Style','listbox',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)HV('lb_rangfolge_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','lb_rangfolge');

appdata = [];
appdata.lastValidTag = 'pb_up';

h13 = uicontrol(...
'Parent',h10,...
'Units','characters',...
'Callback',@(hObject,eventdata)HV('pb_up_Callback',hObject,eventdata,guidata(hObject)),...
'FontSize',14,...
'Position',[39.6 11.7252747252747 20.2 3.84615384615384],...
'String','hoch',...
'Tag','pb_up',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pb_down';

h14 = uicontrol(...
'Parent',h10,...
'Units','characters',...
'Callback',@(hObject,eventdata)HV('pb_down_Callback',hObject,eventdata,guidata(hObject)),...
'FontSize',14,...
'Position',[39.6 4.03296703296704 20.2 3.92307692307692],...
'String','runter',...
'Tag','pb_down',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error('MATLAB:gui_mainfcn:FieldNotFound', 'Could not find field %s in the gui_State struct in GUI M-file %s', gui_StateFields{i}, gui_Mfile);
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % ITA_LISTENINGTESTS_ranking
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % ITA_LISTENINGTESTS_ranking(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % ITA_LISTENINGTESTS_ranking('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % ITA_LISTENINGTESTS_ranking(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~isa(handle(fig),'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end


