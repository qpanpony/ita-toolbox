function varargout = ita_listeningtest_AB_comparison(varargin)
%ITA_LISTENINGTEST_AB_COMPARISON - compare A to B
%  This function performs a listening test with A-B-comparison
%
%  Syntax:
%   audioObjOut = ita_listeningtest_AB_comparison(audioObjIn)
%
%
%  Example:
%   audioObjOut = ita_listeningtest_AB_comparison(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_listeningtest_AB_comparison">doc ita_listeningtest_AB_comparison</a>

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  04-Mar-2011 


%% Get Function String
% thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
% [input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

fprintf('\n ==================\n Please contact me before using. Not fully tested. MGU \n ==================\n')

% TODO:
%  - testen ob alles richtig gespeichert wird
%  - parameter einmal im mat spreichern und dann immer lesen
%  - datum der mat datei in die logfile schreiben
%  - testRun schreiben
%  - force attributes?
%  - uiwait?

br = sprintf('\n');

ltData.introText        = [ 'Herzlich Willkommen zum Hörversuch' br br 'Ihnen werden im Folgenden akustische Aufnahmen vorgespielt, welche in einem Fahrzeug gemacht wurden. Das Fahrzeug befindet sich dabei in unterschiedlichen Fahrsituationen und durch das Infotainment-System werden unterschiedliche Musik- oder Sprachprogramme wiedergegeben. ' br br...
                            'Für jede Situation gibt es drei verschiedene Versionen, welche sich bezüglich der Einstellung der Lautstärkeregelung der Musikanlage unterscheiden. '];
ltData.intoButtonString = 'Hörversuch starten'                    ;

ltData.doPracticeRun    = false;

ltData.compareQuestion  = 'Welche der Beiden gehörten Versionen bevorzugen sie? ';
ltData.endText          = 'Danke für die Teilnahme am Hörversuch.';
                       
ltData.showProgress = true;

% attribute parameter
ltData.useAttributes    = false;
ltData.attributes       = {'Lautheit', 'Tonhöhe' 'Länge' 'Volumen' 'Angenehmheit' 'Hochwertigkeit' 'Aufdriglichkeit'};
ltData.attribQuestion   = 'Was zeichte das Geräusch besonders aus?';



% sound files
ltData.soundList        = {'D:\Dokumente und Einstellungen\guski\Eigene Dateien\MATLAB\ITA-Toolbox\applications\ListeningTests\3AFC\testfiles\flatnoise.wav', ...
                           'D:\Dokumente und Einstellungen\guski\Eigene Dateien\MATLAB\ITA-Toolbox\applications\ListeningTests\3AFC\testfiles\pinknoise.wav', ...
                           'D:\Dokumente und Einstellungen\guski\Eigene Dateien\MATLAB\ITA-Toolbox\applications\ListeningTests\3AFC\testfiles\impulsetrain.wav', ...
                           'D:\Dokumente und Einstellungen\guski\Eigene Dateien\MATLAB\ITA-Toolbox\applications\ListeningTests\3AFC\testfiles\sinus.wav', ... 
                           'D:\Dokumente und Einstellungen\guski\Eigene Dateien\MATLAB\ITA-Toolbox\applications\ListeningTests\3AFC\testfiles\whitenoise.wav'};
ltData.nSounds          = numel(ltData.soundList);                       
                       
% play parameter                       
ltData.pauseStartPlay   = 0.5;
ltData.pauseBetween     = 0.05;
ltData.ABrepetitions    = 1;

% save results
ltData.savePath         = 'D:\Dokumente und Einstellungen\guski\Eigene Dateien\MATLAB\ITA-Toolbox\applications\ListeningTests\3AFC\testfiles\results';
ltData.writeLogFile     = true;




%% check data
[y, ltData.samplingRate] = wavread(ltData.soundList{1});
ltData.nChannels = size(y,2);
for iSound = 1:ltData.nSounds
    [y, fs] = wavread(ltData.soundList{iSound});
    if ~isequal(fs, ltData.samplingRate)
        error('Different sampling rates in wav files')
    elseif ~isequal(ltData.nChannels, size(y,2)) 
        error('Different number of channels in wav files')
    end
end
ltData.attributes  =[ {''}, ltData.attributes{:}];

if ltData.useAttributes 
    if ~iscell(ltData.attributes) || ~ischar(ltData.attribQuestion)
        error('Inconsistencies in ltData struct found: useAttributes = true but ltData.attribQuestion or ltData.attributes wrong.')
    end
end

if ~exist(ltData.savePath, 'dir')
    mkdir(ltData.savePath)
end

clear y fs iSound
%% get name of person

cl = clock;
h.data.testPersonName = cell2mat(inputdlg( 'Bitte geben Sie Ihren Namen ein.','Name', 1));
if isempty(h.data.testPersonName )
    error('Name is empty')
end
h.data.runIdetifier = sprintf( '%04i%02i%02i_%02i%02i_%s', cl(1), cl(2), cl(3), cl(4), cl(5),genvarname(h.data.testPersonName));
    
%%
if ltData.writeLogFile 
    h.data.fid = fopen(fullfile(ltData.savePath , ['LOG_' h.data.runIdetifier '.txt']), 'wt');
    
    % falls Ausgabe der LOG Datei in der Konsole erfolgen soll
    %   handles.data.fid = 1; fprintf('Dateiname: %s\n\n', handles.data.LogFileName);
    
    header = 'Hörversuch LOG Datei \n';
    header = [header, sprintf( ' Datum:                 %02i.%02i.%04i %02i:%02i Uhr\n', cl(3), cl(2), cl(1), cl(4), cl(5))];
    header = [header, sprintf( ' Versuchsperson:        %s \n',h.data.testPersonName)];
%     header = [header, sprintf( ' Abspielfolge der Sets: %s \n',num2str(handles.data.setOrder'))];
%     header = [header, sprintf( ' Subsetordnung:         (Position entspricht Buttons A,B,C --- Nummer steht für Version: 1=%s | 2=%s | 3=%s ) \n',handles.data.zuordnung{1},handles.data.zuordnung{2},handles.data.zuordnung{3})];
    fprintf( h.data.fid, header );
%     subSetOrderStr = ['     Button:  A, B, C\n'; repmat('     Set ',handles.data.nSets,1), num2str((1:handles.data.nSets)','%02i'), repmat(':  ',handles.data.nSets,1), num2str(handles.data.subSetOrder(:,1)), repmat(', ',handles.data.nSets,1),num2str(handles.data.subSetOrder(:,2)), repmat(', ',handles.data.nSets,1),num2str(handles.data.subSetOrder(:,3)), repmat('\n',handles.data.nSets,1)];
%     fprintf( handles.data.fid, subSetOrderStr' );
    fprintf( h.data.fid, '\n\n\n=================================================================\n' );

end




%% generate GUI

layout.figSize          = [450 300];
layout.defaultSpace     = 20;
layout.compTxtHeight    = 40;
layout.tbSize           = [120 30];
layout.tbPosition       = [layout.figSize(1)/2-170 layout.figSize(2) - 2*layout.defaultSpace-layout.compTxtHeight-layout.tbSize(2) layout.tbSize; layout.figSize(1)/2+170-120 layout.figSize(2)-2*layout.defaultSpace-layout.compTxtHeight-layout.tbSize(2) layout.tbSize];



h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[360,500 layout.figSize], 'Name','Listening Test','MenuBar', 'none');
movegui(h.f,'center')

h.text          = uicontrol('Style','text','String',ltData.compareQuestion, 'Position',  [layout.defaultSpace layout.figSize(2)-layout.defaultSpace-layout.compTxtHeight layout.figSize(1)-2*layout.defaultSpace layout.compTxtHeight] );

h.togglebuttonA    = uicontrol('Style','togglebutton', 'String','Version A','Position',layout.tbPosition(1,:), 'Callback', {@chooseSound});
h.togglebuttonB    = uicontrol('Style','togglebutton', 'String','Version B','Position',layout.tbPosition(2,:), 'Callback', {@chooseSound});

h.defaultbuttonColor =  get(h.togglebuttonA , 'BackgroundColor');
h.choosedbuttonColor =  [1 1 1]*.5;


h.nextButton    = uicontrol('Style','pushbutton', 'String',ltData.intoButtonString,'Position',[layout.figSize(1)-130-layout.defaultSpace, layout.defaultSpace, 130, 30], 'Callback', {@GUI_next});
h.bigText       = uicontrol('Style','text','String',ltData.introText, 'Position', [layout.defaultSpace,layout.defaultSpace+40,layout.figSize-2*layout.defaultSpace - [0 40] ], 'Visible' , 'off', 'fontsize', 11); 
h.hArray = [h.text  h.togglebuttonA  h.togglebuttonB  h.nextButton   ];


if ltData.useAttributes 
    h.attribAtext       = uicontrol('Style','text','String',ltData.attribQuestion, 'Position',layout.tbPosition(1,:)- [10 60 -20 0]);
    h.attribBtext       = uicontrol('Style','text','String',ltData.attribQuestion, 'Position',layout.tbPosition(2,:)- [10 60 -20 0]);
    
    h.attribA       = uicontrol('Style','popupmenu','String',ltData.attributes, 'Position',  layout.tbPosition(1,:)- [10 100 -20 0] );
    h.attribB       = uicontrol('Style','popupmenu','String',ltData.attributes, 'Position',  layout.tbPosition(2,:)- [10 100 -20 0] );
    
    h.hArray = [h.hArray h.attribAtext h.attribBtext h.attribA h.attribB ];
end

if ltData.showProgress
    h.progress  =   uicontrol('Style','text','String',' 0 / 0', 'Position',[ layout.defaultSpace  layout.defaultSpace  120 20]);
    h.hArray    = [h.hArray h.progress ];
end

%% handles data

h.data.ltData       = ltData;

allCombinations             = nchoosek(1:ltData.nSounds,2);
h.data.currentLT.nSets      = size(allCombinations,1);
[del randIDX]               = sort(rand(h.data.currentLT.nSets,1));  %#ok<ASGLU>
h.data.currentLT.playlist   = allCombinations(randIDX,:);
h.data.currentLT.currentSet = 0;
h.data.currentLT.prefMat    = zeros(ltData.nSounds);              % prefMat(i,j) = is i prefered over j ?
if ltData.useAttributes
    h.data.currentLT.selectedAttribute   = zeros(ltData.nSounds);                % selectedAttribute(i,j) = attrib for i ; selectedAttribute(j,i) = attrib for j  
end


set(h.hArray, 'Visible', 'off')
set([h.bigText h.nextButton] , 'Visible', 'on')


guidata(h.f, h)
set(h.f,'Visible','on', 'CloseRequestFcn', {@CloseRequestFcn}) 



% sample use of the ita warning/ informing function
% ita_verbose_info([thisFuncStr 'Testwarning'],0);
% input = ita_metainfo_add_historyline(input,mfilename,varargin);
% varargout(1) = {input}; 

%end function
end


function chooseSound(s,e)%#ok<INUSD>
h = guidata(s);

if get(s,'value') 
    set([h.togglebuttonA h.togglebuttonB] ,'Value', 0)
    set(s,'Value', 1)
end

end



function GUI_next(s,e)%#ok<INUSD>
h = guidata(s);

set([h.bigText h.hArray], 'Visible', 'off')
pause(0.1)


if h.data.ltData.doPracticeRun 
    error('haha')
else
   if h.data.currentLT.currentSet 
       idx2button =h.data.currentLT.lastFileNumerbs2buttons;
       
       % TODO: wennn nix ausgewählt oder kein attribut=> dialog
        btnAorB = [1 2] * cell2mat( get([h.togglebuttonA h.togglebuttonB], 'value'));
       if btnAorB == 0
            d = warndlg('Bitte eine Version auswählen.'); 
            waitfor(d)
            set( h.hArray, 'Visible', 'on')
            return
       end
       
       idxWinner    = idx2button(btnAorB ) ;
       idxLooser    = idx2button(3-btnAorB);
       
       h.data.currentLT.prefMat(idxWinner, idxLooser) = 1; % prefMat(i,j) = is i prefered over j ?
       h.data.currentLT.prefMat(idxLooser, idxWinner) = 0;
       if h.data.ltData.useAttributes
           h.data.currentLT.selectedAttribute(idx2button(1),idx2button(2))  = get(h.attribA, 'Value'); % selectedAttribute(i,j) = attrib for i ; selectedAttribute(j,i) = attrib for j
           h.data.currentLT.selectedAttribute(idx2button(2),idx2button(1))  = get(h.attribB, 'Value');
       end
       if h.data.ltData.writeLogFile
           helpStr = 'AB';
           if h.data.ltData.useAttributes
                fprintf(h.data.fid, '  Auswahl: %s\n  Attribut für A: %s\n  Attribut für B: %s\n', helpStr(btnAorB), h.data.ltData.attributes{get(h.attribA, 'Value')}, h.data.ltData.attributes{get(h.attribB, 'Value')});
           else
                fprintf(h.data.fid, '  Auswahl: %s\n', helpStr(btnAorB));
           end
       end
       
   end

   h.data.currentLT.currentSet = h.data.currentLT.currentSet + 1;
   set(h.progress, 'string', sprintf('Set %i von %i', h.data.currentLT.currentSet, h.data.currentLT.nSets ))
   
   % reset GUI
   set([h.togglebuttonA h.togglebuttonB], 'value', 0);
   if h.data.ltData.useAttributes
       set([h.attribA h.attribB] , 'Value', 1);
   end
   
   
   % END OF LT, SAVE DATA
   if h.data.currentLT.currentSet > h.data.currentLT.nSets               
       set(h.hArray, 'Visible', 'off');
       set(h.bigText, 'Visible', 'on', 'String', h.data.ltData.endText);
       set(h.nextButton, 'Callback', {@CloseRequestFcn}, 'String', 'Fertig', 'Visible', 'on')
       
       
       % save as mat files
       if h.data.ltData.useAttributes
            ltResult = struct('testPersonName', h.data.testPersonName, 'preferenceMatrix' , h.data.currentLT.prefMat, 'selectedAttribute', h.data.currentLT.selectedAttribute, 'attributeList', {h.data.ltData.attributes}, 'listeningTestData', h.data.ltData); %#ok<NASGU>
       else
            ltResult = struct('testPersonName', h.data.testPersonName, 'preferenceMatrix' , h.data.currentLT.prefMat, 'listeningTestData', h.data.ltData); %#ok<NASGU>
       end
       save(fullfile(h.data.ltData.savePath, ['result_'  h.data.runIdetifier '.mat',]), 'ltResult')
       
       
       if h.data.ltData.writeLogFile
           fprintf(h.data.fid, '\n\nTest completed successfully.');
           fclose(h.data.fid);
       end
    
   else   % NEXT SET
       [del randIDX]               = sort(rand(2,1)); %#ok<ASGLU>
       fileNumbers      = h.data.currentLT.playlist(h.data.currentLT.currentSet,randIDX);
       
       
        sigA = wavread(h.data.ltData.soundList{fileNumbers(1)});
        sigB = wavread(h.data.ltData.soundList{fileNumbers(2)});
       
        
        if h.data.ltData.writeLogFile
            fprintf(h.data.fid, '%i. Set\n  Sound A: %s\n  Sound B: %s\n', h.data.currentLT.currentSet,h.data.ltData.soundList{fileNumbers(1)}, h.data.ltData.soundList{fileNumbers(2)} );
        end
        
        audio2play = [  zeros(round(h.data.ltData.samplingRate* h.data.ltData.pauseStartPlay),h.data.ltData.nChannels); ...
                        sigA; ...
                        zeros(round(h.data.ltData.samplingRate* h.data.ltData.pauseBetween),h.data.ltData.nChannels); ...
                        sigB ];
        audio2play = repmat(audio2play,h.data.ltData.ABrepetitions,1);
        
        % TODO: evtl fenster / text oder so
        wavplay(audio2play, h.data.ltData.samplingRate);
        
        h.data.currentLT.lastFileNumerbs2buttons = fileNumbers;
        
        
        
        set(h.hArray, 'Visible', 'on')
        set(h.nextButton , 'string', 'Weiter')
   end
   

end
   guidata(h.f, h)
end



function CloseRequestFcn(s,e) %#ok<INUSD>
h = guidata(s);
if h.data.currentLT.currentSet > h.data.currentLT.nSets    % test finished
    delete(h.f)
else
    btn = questdlg('Wollen Sie wirklich den Test beenden?', 'Test abbrechen', 'Ja', 'Nein', 'Nein');
    
    if strcmp(btn, 'Ja')
        delete(h.f)
        if h.data.ltData.writeLogFile
            fprintf(h.data.fid, '\n\nCanceled by user. \n\n');
            fclose(h.data.fid);
        end
        
    end
end
end
