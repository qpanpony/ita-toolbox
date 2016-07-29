function ita_asa_main
%Dies ist die main-funktion. Von hier aus werden die anderen Funktionen zum
%Durchlaufen des Versuchs aufgerufen
%clear all;

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

close all;
%Definition der Pfade um Daten zu laden und abzuspeichern
%TODO
generalPath = 'M:\AuditiveSelektiveWahrnehmung\Experiment_1402_schlechterRaum';
mainPath = [generalPath, '\Messskripte und GUIs\Durchführung'];
h.resultPath = [generalPath, '\Ergebnisse\rawResults'];


%Proband wird eine Nummer zugewiesen, damit alles anonymisiert ist
h.probandNumber = cell2mat(inputdlg( 'Welche Nummer hat der Proband?','Nummer', 1));
while isempty(h.probandNumber)
    h.probandNumber = cell2mat(inputdlg( 'Welche Nummer hat der Proband?','Nummer', 1));
end

h.trackerPath = [generalPath, '\Ergebnisse\rawResults\trackerData\' sprintf('VP%02i',str2num(h.probandNumber) )];
mkdir(h.trackerPath)

% Methode 3: LS (veraltet)
method = 3;

%Mit oder ohne Tracker
h.trackerOn = false;
%LS or HP?
h.HP_On = true;

if h.trackerOn
    %Initialisierung des Trackers
    try
        fprintf('Initializing the Polhemus tracker - please wait a few seconds...\n');
        %TODO
        ITAPolhemus('init', 'C:\Users\tarasova\ITAPolhemusMatlab_x64\PolhemusTracker.ini' );
        pause(5);
        fprintf('Initialized!!!\n');
    catch err
        fprintf('Not initialized!!!\n');
    end
    
    %Hut oder HP?
    if h.HP_On
        h.trackerHut = 2;
    else
        h.trackerHut = 1;
    end
    h.trackerFreq = 0.1;
    
    s = ITAPolhemus('getsensorstate', h.trackerHut);
    fprintf('Position=(%+0.3f, %+0.3f, %+0.3f), Orientation=(%+0.2f, %+0.2f, %+0.2f) \n',...
        s.pos(1), s.pos(2), s.pos(3),...
        s.orient(1)*180/3.141527, s.orient(2)*180/3.141527, s.orient(3)*180/3.141527);
    
    %Definition des Trackerbereichs
    h.ErrorLimit =[0.01, 0.01, 0.01, 2, 2, 2];
    
end

%Anzahl der Trainigs-Durchläufe
trainBlockSize = 50;
%Anzahl der echten Durchläufe
expBlockSize = 150;

%Zusammenstellung der Blöcke als gesamtes Experiment mit der Funktion
%create_block
blocks = {create_block(trainBlockSize), ...
    create_block(expBlockSize),...
    create_block(expBlockSize),...
    create_block(expBlockSize),...
    create_block(expBlockSize)};

%Einrichten des GUI-Bildschirms
SizeOfScreen = get(0, 'Screensize');
figSize = [SizeOfScreen(3)-20 SizeOfScreen(4)-20];
h.GUITitle = 'Attentional Switching';
h.f = figure('Visible','on','NumberTitle', 'on', 'Position',[0 0 figSize], 'Name', h.GUITitle, 'MenuBar', 'none', 'color', [0 0 0]);
%Close Request
set(h.f, 'CloseRequestFcn', {@CloseRequestFcn})
guidata(h.f, h);

h.textfeld =  uicontrol('Style','pushbutton', 'Fontunits', 'normalized', 'Foregroundcolor', [1 1 1], 'Fontsize', 0.05, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Backgroundcolor', [0 0 0], ...
    'Position', [0, 0, 1, 1], 'visible', 'off' );

%Einleitungstexte
txt = {'<html><P align="center">Sehr geehrte/r Versuchsteilnehmer/in, <br><br> in diesem Experiment geht es um Reaktionszeiten. <br><br> *Bitte einen beliebigen Knopf drücken*',...
    '<html><P align="center">In jedem Durchgang des folgenden Experiments hören <br> Sie gleichzeitig aus zwei verschiedenen Richtungen zwei verschiedene Zahlen. <br><br> Eine weibliche Stimme aus der einen Richtung <br> und eine männliche Stimme auf der anderen Richtung. <br><br> Vor jedem Durchgang bekommen Sie einen Hinweisreiz, <br> der anzeigt, auf welche Richtung Sie achten sollen. <br><br> *Bitte einen beliebigen Knopf drücken*',...
    '<html><P align="center">Die Reaktiontasten sind die beiden Knöpfe, <br> der rote (rechte Hand) und der grüne (linke Hand). <br><br> Ist die relevante Zahl kleiner als 5, <br> drücken Sie bitte den linken Knopf. <br> Ist die relevante Zahl größer als 5, <br> drücken Sie bitte den rechten Knopf. <br><br> *Bitte einen beliebigen Knopf drücken*',...
    '<html><P align="center">Zu Beginn jeden Durchgangs <br> erscheint eine Graphik, die anzeigt <br> auf welche Richtung Sie achten müssen. <br><br> Um die Vorschau der Graphik anzuzeigen, <br><br> *Bitte einen beliebigen Knopf drücken*'};
for iIntro = 1:size(txt,2)
    set(h.textfeld,'string',txt{iIntro}, 'Visible', 'on')
    refresh(h.f);
    ginput_job(h.f);
end
set(h.textfeld,'Visible','off')

%Visual Cue wird erklärt
h.bild =  axes('parent', h.f, 'units', 'normalized', 'position', [0 ,0 , 1, 1]) ;
visualCue = imread(sprintf('%s\\VisualCues\\VisualCue_F.png',mainPath));
image( visualCue);
axis off
h.textfeld3 = uicontrol('Style','text', 'Fontunits', 'normalized', 'Foregroundcolor', [1 1 1], 'Fontsize', 0.2, 'Fontweight', 'demi', ...
    'string', '  *Bitte einen beliebigen Knopf drücken*', 'Units', 'normalized', 'Backgroundcolor', [0 0 0], ...
    'Position', [0.8, 0.02, 0.2, 0.2], 'visible', 'on');
ginput_job(h.f);
set(h.textfeld3,'Visible', 'off');
h.textfeld2 =  uicontrol('Style','text', 'Fontunits', 'normalized', 'Foregroundcolor', [1 1 1], 'Fontsize', 0.3, 'Fontweight', 'demi', ...
    'string', '   Der ausgefüllte Punkt bedeutet hier: Achten Sie auf Vorne!', 'Units', 'normalized', 'Backgroundcolor', [0 0 0], ...
    'Position', [0, 0.05, 1, 0.3], 'visible', 'on' );
ginput_job(h.f);
set(h.textfeld2,'Visible', 'off')
visualCue = imread(sprintf('%s\\VisualCues\\VisualCue_R.png',mainPath));
image( visualCue);
axis off
set(h.textfeld3, 'visible', 'on')
ginput_job(h.f);
set(h.textfeld3,'Visible', 'off')
set(h.textfeld2, 'string', '   Der ausgefüllte Punkt bedeutet hier: Achten Sie auf Rechts!', 'visible', 'on')
ginput_job(h.f);
set(h.textfeld2,'Visible', 'off')
set(h.bild, 'Visible','off')

%Erklärungstexte zwischen den Blöcken ohne Variablen
txt_train = sprintf('<html><P align="center">Wenn Sie keine Fragen mehr haben, <br> beginnt nun der Übungsblock. <br> Er besteht aus %i Durchgängen. <br><br> Versuchen Sie so schnell wie möglich zu reagieren <br> und dabei so wenig Fehler wie möglich zu machen. <br><br> Um den Übungsblock zu starten, <br><br> *Bitte einen beliebigen Knopf drücken*.', trainBlockSize);
txt_startexp = sprintf('<html><P align="center">Wenn Sie keine Fragen mehr haben, <br> beginnt nun das Experiment. <br> Es besteht aus %i Blöcken mit je %i Durchgängen. <br> Um das Experiment zu starten, <br><br> *Bitte einen beliebigen Knopf drücken*.', size(blocks,2)-1, expBlockSize);
txt_pause = {'<html><P align="center">PAUSE <br><br> Bitte sagen Sie Bescheid, dass Sie mit dem Block fertig sind.'};
txt_end2 = {'<html><P align="center">Sie haben es geschafft. <br><br> Herzlichen Dank für Ihre Teilnahme! <br><br> *Zum Beenden bitte einen beliebigen Knopf drücken*'};

% Experimental Blocks
h.result = {};
for iBlock=1:size(blocks,2)
    %Trainingsblock
    if iBlock==1 
        set(h.textfeld,'string',txt_train, 'Visible', 'on')
        ginput_job(h.f)
        guidata(h.f, h)
        trial_block(mainPath, h, method, iBlock, blocks{iBlock}, h.probandNumber);
        set(h.textfeld,'string',txt_startexp, 'Visible', 'on')
        ginput_job(h.f)
    
    % Experimentalblock
    else
        if iBlock ~= 2
            txt_newblock = sprintf('<html><P align="center">Wenn Sie keine Fragen mehr haben, <br> beginnt nun der %i. Block des Experiments. <br> Um den Block zu starten, <br><br> *Bitte einen beliebigen Knopf drücken*.', iBlock-1);
            set(h.textfeld,'string',txt_newblock, 'Visible', 'on')
            ginput_job(h.f)
        end
        result_block = trial_block(mainPath, h, method, iBlock-1, blocks{iBlock}, h.probandNumber);
        h.result = vertcat(h.result, result_block);
        guidata(h.f, h);
        
        %Blockanzahlanzeige nach einem Block
        if iBlock-1==numel(blocks)-1
            txt_end1 = sprintf('<html><P align="center">Sie haben Block %i von insgesamt %i Blöcken absolviert. <br><br> *Bitte einen beliebigen Knopf drücken*.', iBlock-1, size(blocks,2)-1);
            set(h.textfeld,'string',txt_end1, 'Visible', 'on')
            ginput_job(h.f)
        else
            txt_endblock = sprintf('<html><P align="center">Sie haben Block %i von insgesamt %i Blöcken absolviert. <br><br> Bitte versuchen Sie weiterhin, schnell zu reagieren <br> und möglichst keine Fehler zu machen. <br><br> Um den nächsten Block zu beginnen, <br><br> *Bitte einen beliebigen Knopf drücken*.', iBlock-1, size(blocks,2)-1);
            set(h.textfeld,'string',txt_endblock, 'Visible', 'on')
            ginput_job(h.f)
            set(h.textfeld,'string',txt_pause, 'Visible', 'on')
            ginput_job(h.f)
        end
        
    end
end
%Benennung der Spalten der Resulttabelle
h.result(1,1:16) ={'VP', 'Wiedergabe', 'Block', 'Trial', 'Cue', 'Not Cue', 'Cong', 'Left', 'Right', 'CorrectKey', 'PressedKey', 'RT', 'CSI', 'RCI', 'Success', 'Kopf bewegt'};
result = h.result;
%Abspeichern der Ergebnisse
cl = clock;
identification = sprintf( '%04i%02i%02i_%02i%02i_%s', cl(1), cl(2), cl(3), cl(4), cl(5), num2str(h.probandNumber));
save(fullfile(h.resultPath, '\' , ['results_', identification, '.mat']), 'result');
xlswrite(fullfile(h.resultPath, '\' , ['results_', identification, '.xls']), result);

%Verabschiedung auf GUI
set(h.textfeld,'string',txt_end2, 'Visible', 'on')
ginput_job(h.f)
set(h.f, 'Visible', 'off');

end
function CloseRequestFcn(hObject, e)

h = guidata(hObject);
h.result(1,1:16) ={'VP', 'Wiedergabe', 'Block', 'Trial', 'Cue', 'Not Cue', 'Cong', 'Left', 'Right', 'CorrectKey', 'PressedKey', 'RT', 'CSI', 'RCI', 'Success', 'Kopf bewegt'};
result = h.result;

    btn = questdlg('Do you really want to terminate the listening-test? ', 'Termination', 'Yes', 'No', 'No');
    
    if strcmp(btn, 'Yes')
        delete(h.f)
        
        cl = clock;
        identification = sprintf( '%04i%02i%02i_%02i%02i_%s', cl(1), cl(2), cl(3), cl(4), cl(5), num2str(h.probandNumber));
        save(fullfile(h.resultPath, '\' , ['cancel_results_', identification, '.mat']), 'result');
        xlswrite(fullfile(h.resultPath, '\' , ['cancel_results_', identification, '.xls']), result);
        
    end

end
