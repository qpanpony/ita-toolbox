function varargout = HV(varargin)
% ITA_LISTENING_TESTS_RANKING_MAC - old version, but works with MacOS
% (slow)
%old version of Martin Guskis listening test, and it works with mac OS, but
%the buttons are slower

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HV_OpeningFcn, ...
    'gui_OutputFcn',  @HV_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function HV_OpeningFcn(hObject, eventdata, handles, varargin)


name = genvarname(varargin{1});
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
 for i = 1:handles.data.nSets       % schleife damit rand auch immer zuf‰llig
     pause(rand/10)
     [dummy randIDX]             = sort( rand(3,1));
     handles.data.subSetOrder(i,:) = randIDX';
 end




if false
    handles.data.setOrder       = (1:handles.data.nSets).';
%     handles.data.subSetOrder    = repmat([1 2 3], handles.data.nSets,1);
    disp('WARNUNG: ZUFƒLLIGE WIEDERGABE DEAKTIVIERT!!!!!!!!!!!!!!!!!!!!!!!!!!!')
end

handles.data.path           = './dritterTEST/';




cl = clock;

% name = inputdlg( 'Bitte geben Sie Ihren Namen ein.','Name', 1);
m = menu('Zweiter Teil des Hˆrversuchs. Stellen sie bitte mit Hilfe der "hoch" "runter" Buttons eine Rangfolge der Maschinensimulationen her. Die Signale kˆnnen beliebig oft durch dr¸cken der "A" "B" "C" Buttons verglichen werden.','Weiter');
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
    
    
    header = 'Hˆrversuch LOG Datei \n';
    header = [header, sprintf( ' Datum:                 %02i.%02i.%04i %02i:%02i Uhr\n', cl(3), cl(2), cl(1), cl(4), cl(5))];
    header = [header, sprintf( ' Versuchsperson:        %s \n',name)];
    header = [header, sprintf( ' Abspielfolge der Sets: %s \n',num2str(handles.data.setOrder'))];
    header = [header, sprintf( ' Subsetordnung:         (Position entspricht Buttons A,B,C --- Nummer steht f¸r Version: 1=%s | 2=%s | 3=%s ) \n',handles.data.zuordnung{1},handles.data.zuordnung{2},handles.data.zuordnung{3})];
    fprintf( handles.data.fid, header );
    subSetOrderStr = ['     Button:  A, B, C\n'; repmat('     Set ',handles.data.nSets,1), num2str((1:handles.data.nSets)','%02i'), repmat(':  ',handles.data.nSets,1), num2str(handles.data.subSetOrder(:,1)), repmat(', ',handles.data.nSets,1),num2str(handles.data.subSetOrder(:,2)), repmat(', ',handles.data.nSets,1),num2str(handles.data.subSetOrder(:,3)), repmat('\n',handles.data.nSets,1)];
    fprintf( handles.data.fid, subSetOrderStr' );
    fprintf( handles.data.fid, '\n\n\n=================================================================\n' );
    
    handles.output = 11;
    guidata(hObject, handles);
end
function varargout = HV_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function tb_A_Callback(hObject, eventdata, handles)
global onlinePar
if ~get(hObject,'Value') % wenn Track gerade noch lief => beenden
    onlinePar.stopIt = 1;
%     pause(10)
else
    set([handles.tb_A handles.tb_B handles.tb_C], 'Value', 0) % alle aus und HObject an, damit gleicher
    set(hObject, 'Value', 1)                                 % Code f¸r alle ToggleButtons verwedet werden kann
    onlinePar.Track     = get(hObject,'string') -64;          % name des Button hoffentlich Groﬂbuchstabe
    
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
    set(hObject, 'Value', 1)                                 % Code f¸r alle ToggleButtons verwedet werden kann
    onlinePar.Track     = get(hObject,'string') -64;          % name des Button hoffentlich Groﬂbuchstabe
    
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
    set(hObject, 'Value', 1)                                 % Code f¸r alle ToggleButtons verwedet werden kann
    onlinePar.Track     = get(hObject,'string') -64;          % name des Button hoffentlich Groﬂbuchstabe
    
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


function play(handles)
global onlinePar

partFileName = [handles.data.path , sprintf('set%02i_',handles.data.setOrder(handles.data.iSet))];
fileList = {[partFileName,handles.data.zuordnung{handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),1)}], [partFileName,handles.data.zuordnung{handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),2)}],[partFileName, handles.data.zuordnung{handles.data.subSetOrder(handles.data.setOrder(handles.data.iSet),3)}]};
%% Parameter
frameSize = 2048*4;
nFrames2Fade = 2;


%% Init sound device
pageBufCount = 1	;
runMaxSpeed = false;
Fs = 44100;
if playrec('isInitialised')
    playrec('reset');
end
 playrec('init',Fs, ita_preferences('playDeviceID'), ita_preferences('recDeviceID'));
%  playrec('init',Fs, 1, 1);

playrec('delPage');
pageNumList = repmat(-1, [1 pageBufCount]);
firstTimeThrough = true;


%% wav Parameter bestimmen
[m d] = wavfinfo(fileList{1});
if strcmp(m, 'Sound (WAV) file')
    xLength = str2double(d(findstr(d, 'Sound (WAV) file containing: ') + 28: findstr(d, ' samples')));
else
    errordlg('wav Datei konnte nicht gelsesen werden. Programm wird abgebrochen.', 'Fehler')
    return
end

iFrame = 1;
nFrames =  floor(xLength/frameSize);
onlinePar.isPlaying =1;

ampFaktor = 1.4;


% fadeWin = hanning(frameSize*nFrames2Fade);
fadeWin = reshape(((1:frameSize*nFrames2Fade)/(frameSize*nFrames2Fade)), frameSize, []);
lastTrack = onlinePar.Track;

debug = [];
%% Hauptschleife
while (iFrame <= nFrames) && ishandle(handles.figure1)    % TODO: letztes Frame auch spielen
    
    
    
    pause(0.01)       % doof aber notwendig, damit globlae var aktualisiert wird
    global onlinePar
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
%     
    
    if iFrame >= nFrames - nFrames2Fade +1 % wenn wir am ende angekommen sind
       
        otherFrame = iFrame - nFrames + nFrames2Fade;
        x2  = ampFaktor * wavread(fileList{onlinePar.Track}, [(otherFrame-1)*frameSize+1 (otherFrame)*frameSize] );
        x = x.*fadeWin(end:-1:1,nFrames -iFrame  +1) + x2.*fadeWin(:, otherFrame);
%         f1 = fadeWin(end:-1:1,nFrames - iFrame  +1)';
%         f2 = fadeWin(:, otherFrame)';
        

    end
    

%          if onlinePar.Track == 2
%             1
%         end
 
    pageNumList = [pageNumList playrec('play',[x x],[1 2])];
    
%     debug = [debug , [x'; f1;  f2]];
    
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


playrec('reset')
set([handles.tb_A handles.tb_B handles.tb_C], 'Value', 0)
onlinePar.isPlaying     = 0;
onlinePar.stopIt        = 0;

if onlinePar.next
    writeLogFile(handles)
end
%%
% if false
%     n = 4000;
%     win = (1:n) /n;
%     xfade = [x(1:end-n); x(end-n:end)
%%

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
    if handles.data.fid ~= 1 % wenn ausgabe nicht in Konsole, dann datei schlieﬂen
        fclose(handles.data.fid);
    end
    
    
    kennung = ['result_' handles.data.LogFileName(5:end-4)];
    
    tmpRes.data = handles.data.result;
    tmpRes.id   = handles.data.LogFileName(5:end-4);
    tmpRes.rfSet= handles.data.setOrder;
    
    eval(sprintf('%s = tmpRes;',kennung));
    eval(['save ' kennung ' ' kennung]);
    
    
end
