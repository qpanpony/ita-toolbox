function successflag = forced_choice(varargin)
% ITA_LISTENINGTESTS_FORCEDCHOICE - similarity listening test with 3
% samples
% FORCED_CHOICE
%       FORCED_CHOICE performs a similarity listening test, each with 3
%       samples. Therefore survey.txt and introduction.txt (may be empty) are needed in
%       the current folder.
%       
%       AEHNLICHKEITSVERSUCH(blocklength) needs the number of sampels with
%       different RT-Quality as input.
% 
%       FORCED_CHOICE führt einen Ähnlichkeitshörversuch mit jeweils drei
%       Samples durch. Es werden die beiden Dateien survey.txt
%       und introduction.txt im aktuellen Verzeichnis benötigt, wobei
%       letztere ggf. leer sein darf. A
%
%       AEHNLICHKEITSVERSUCH(blocklength) benötigt
%       als Eingabeparameter die Anzahl der Samples mit unterschiedlicher
%       RT-Qualität
%
%
%       Subfunction play_sample() [siehe unten]
%
%       Die Funktionen der GUI wird selbstständig von der Funktion
%       FORCED_CHOICE  aufgerufen und befinden sich in der M-Datei
%       'versuch2_gui2.m'

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% LOAD DATA AND INITIALIZE

% Hier wird die Blocklänge bestimmt - in der Textdatei survey.txt muss die
% Anzahl der Dateien gleich einem Vielfachen dieser Blocklänge entsprechen.
% Die jeweils letzte Datei eines Blockes ist die Referenzdatei
ita_plottools_figure
set(gcf,'Units','normalized', 'Outerposition',[0 0 1 1], 'menubar', 'none');
set(gcf,'Name','Hörversuch')
set(gcf,'NumberTitle','off')


a_im = importdata(which('ita_toolbox_logo_wbg.png'));
image(a_im);
axis off;
set(gca,'Units','pixel', 'Position', [50 20 300 60]*2); %pdi new scaling


if (nargin == 1) && isinteger(varargin{1})
    blocklength= varargin{1};
else
    blocklength= 8;
end

% Repeat gibt an, wie häufig jeder Versuch (Einzelvergleich) ausgeführt werden soll
repeat=1;


% initialize random numbers generator
rand('twister', sum(100*clock));

% read representative test files from introduction.txt
% [introfiles] = textread('introduction.txt','%s');
% num_intro = length(introfiles);

% read test signal list from survey.txt
[files] = textread('survey.txt','%s');
num_files = length(files);
file_a = cell(1); % because number of pairs is unknown at this time
file_b = cell(1); % do.
ID_pairs = zeros(1, 2); % do.

% Bilde Paare (Das Referenz-Sample(Letzte) wird immer mit jedem anderen
% verknüpft)


blockpairs = blocklength -1;

% for i=1:(num_files*repeat)
%     % Paar mit sich selbst wird nicht gebildet
%     if ( i~=ceil(i/blocklength)*blocklength)
%
%         file_a(pairnumber) = files(i);
%         file_b(pairnumber) = files(ceil(i/blocklength)*blocklength);
%         ID_pairs(pairnumber, :) = [i (ceil(i/blocklength)*blocklength)];
%         pairnumber = pairnumber + 1;
%     end
% end

for i=1:(num_files/blocklength)
    for k=1:repeat
        for j=1:(blockpairs)
            pairnumber=j+(k-1)*blockpairs+(i-1)*repeat*blockpairs;
            file_index=j+(i-1)*blocklength;
            file_a(pairnumber)= files(file_index);
            file_b(pairnumber) = files(i*blocklength);
            ID_pairs(pairnumber,:)= [file_index i*blocklength];
        end
    end
end

% absolute number of repeated signals
num_pairs = length(file_a);


% Pair-Mixing
% Mischt jeweils immer in Blöcken

for k=1:(num_pairs/blockpairs)
    startmix_index=((k-1)*blockpairs+1);
    endmix_index=startmix_index+(blockpairs-1);
    for i=1:10007 % taken from original code by Nickolas
        
        % randomize pairs
        indexorigin=round(rand()*(endmix_index-startmix_index))+startmix_index;
        indexdestination=round(rand()*(endmix_index-startmix_index))+startmix_index;
        
        tmpa=file_a(indexdestination);
        tmpb=file_b(indexdestination);
        tmpID = ID_pairs(indexdestination, :);
        
        file_a(indexdestination)=file_a(indexorigin);
        file_b(indexdestination)=file_b(indexorigin);
        ID_pairs(indexdestination, :) = ID_pairs(indexorigin, :);
        
        file_a(indexorigin)=tmpa;
        file_b(indexorigin)=tmpb;
        ID_pairs(indexorigin,:) = tmpID;
        
    end
end


%% START SURVEY

% ask for name
prompt = {'Wie heißen Sie?'};
dlg_title = 'Name';
num_lines = 1;
def = {'[Vorname] [Nachnahme]'};
name = inputdlg(prompt,dlg_title,num_lines,def, 'on');

%generate user file
user_file=['user_' char(name) '.csv'];
user_start=clock;

timestamp=[int2str(user_start(3)) '/' int2str(user_start(2)) '/' int2str(user_start(1)) ';' int2str(user_start(4)) ':' int2str(user_start(5))];

%play representative test files from introduction.txt

playrec('getDevices')
if (playrec('isInitialised') == 0)
    playrec('init', 44100, ita_preferences('playDeviceID'), ita_preferences('recDeviceID'));
end
%channels = [1 2]

% if (num_intro ~= 0)
%     n = menu(['Sie werden zunächst eine Abfolge einiger repräsentativer Übungssignale hören, um sich über den Ähnlichkeitsgrad dieser bewusst zu werden. Drücken Sie bitte auf "Weiter".'],'Weiter');
%     for c = 1:num_intro
%         [data,fs]=wavread(char(introfiles(c)));
%         wi = waitbar(0,['Übungssignal ' num2str(c) ' von ' num2str(num_intro)]);
%         set(get(wi, 'Children'), 'Color', [0.95 0.95 0.95]);
%         hw = findobj(wi, 'Type', 'Patch');
%         set(hw, 'EdgeColor', [0.2 0.2 0.2], 'FaceColor', [0.95 0.95 0.95])
%         %playeri = audioplayer(data,fs);
%         %play(playeri);
%         playrec('play', data, [1 2]);
%         duration = size(data,1)/44100;          %playing time in seconds
%         while (playrec('isFinished')~=1)
%             for it = 1:duration+1                 %count from 0 to duration in seconds
%                 waitbar(it/duration);
%                 pause(1);
%             end
%            pause(0.01);
%         end
%         delete(wi);
%     end
% end


% Start des Hörversuchs

m = menu('Start des Hörversuchs. Sie werden jeweils drei Signale hintereinander hören, von denen zwei identisch sind. Identifizieren Sie das Signal, daß sich von den anderen beiden Stimuli unterscheidet. Drücken Sie auf "Weiter".','Weiter');

% Intialisierung der Ergebnis- und Lookup-Matrizzen (In der Lookup Matrix wird
% gespeichert, welches der 3 gespielten Samples das unterschiedliche ist)

ergebnis=zeros((num_files/blocklength)*repeat,blocklength);
ergebnis2=ergebnis;
lookup=ergebnis;

for i=1:num_pairs
    
    answered=0;
    
    % Einlesen der Samples
    [data_a,fsa]=wavread(char(file_a(i)));
    [data_b,fsb]=wavread(char(file_b(i)));
    
    %     Nur zur Tempoerhöhung beim Testen
    fsa= fsa*16;
    fsb= fsb*16;
    
    % ZV ist eine gleichverteilte Zufallsvariable, welche für alle 6
    % Permutation des Abspielens der drei Samples verwendet wird
    % (Basierend auf die bereits zufällig verteilte Anordnung von Paaren
    % (A,B) wird gleichverteilt AAB, ABA, AAB, BBA, BAB, BAA abgespielt
    
    ZV = ceil(rand()*6);
    
    % hier muss noch in einer Variable gespeichert werden, welche
    % Möglichkeit letztendlich eingetreten ist um danach von der Eingabe
    % das richtige Ergebnis zu erkennen
    % zeile=ID_pairs(i,2)/blocklength;
    zeile = ceil(i/blockpairs);
    spalte=ID_pairs(i,1)-(ID_pairs(i,2)-blocklength);
    
    switch ZV
        case (1)
            play_sample(1,i,num_pairs,data_a,fsa);
            %            char(file_a(i))
            play_sample(2,i,num_pairs,data_a,fsa);
            %            char(file_a(i))
            play_sample(3,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            comparisonType = 'SSR';
            lookup(zeile,spalte)=3;
        case (2)
            play_sample(1,i,num_pairs,data_a,fsa);
            %            char(file_a(i))
            play_sample(2,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            play_sample(3,i,num_pairs,data_a,fsb);
            %            char(file_a(i))
            comparisonType = 'SRS';
            lookup(zeile,spalte)=2;
        case (3)
            play_sample(1,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            play_sample(2,i,num_pairs,data_a,fsa);
            %            char(file_a(i))
            play_sample(3,i,num_pairs,data_a,fsa);
            %            char(file_a(i))
            comparisonType = 'RSS';
            lookup(zeile,spalte)=1;
        case (4)
            play_sample(1,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            play_sample(2,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            play_sample(3,i,num_pairs,data_a,fsa);
            %            char(file_a(i))
            comparisonType = 'RRS';
            lookup(zeile,spalte)=3;
        case (5)
            play_sample(1,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            play_sample(2,i,num_pairs,data_a,fsa);
            %            char(file_a(i))
            play_sample(3,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            comparisonType = 'RSR';
            lookup(zeile,spalte)=2;
        case (6)
            play_sample(1,i,num_pairs,data_a,fsa);
            %            char(file_a(i))
            play_sample(2,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            play_sample(3,i,num_pairs,data_b,fsb);
            %            char(file_b(i))
            comparisonType = 'SRR';
            lookup(zeile,spalte)=1;
    end
    
    
    % While-Schleife eigentlich nicht benötigt, da versuch2_gui2 nur bei
    % gültiger Rückgabe zurückkehr
    
    while(answered==0)
        
        [selectedButton, text, replaybutton] = versuch_gui2(['Versuch Nummer ' int2str(i) ' von ' int2str(num_pairs)]);
        switch (replaybutton)
            
            % Zunächst die Fälle, bei denen einer der Replay-Button gedrückt wurde
            
            case(1)
                if ( ZV==1 || ZV==2 || ZV==6 )
                    % In diesen Fällen wurde zuvor Sample1 an Stelle 1 gespielt
                    play_sample(replaybutton,i,num_pairs,data_a,fsa);
                else
                    play_sample(replaybutton,i,num_pairs,data_b,fsb);
                end
                
            case(2)
                if ( ZV==1 || ZV==3 || ZV==5 )
                    % In diesen Fällen wurde zuvor Sample1 an Stelle 2 gespielt
                    play_sample(replaybutton,i,num_pairs,data_a,fsa);
                else
                    play_sample(replaybutton,i,num_pairs,data_b,fsb);
                end
            case(3)
                if ( ZV==2 || ZV==3 || ZV==4 )
                    % In diesen Fällen wurde zuvor Sample1 an Stelle 3 gespielt
                    play_sample(replaybutton,i,num_pairs,data_a,fsa);
                else
                    play_sample(replaybutton,i,num_pairs,data_b,fsb);
                end
                
                % Kein Replay-Button gedrückt, irgendwann Sende-Button (=> replaybutton = 0)
                
            case(0)
                if ((selectedButton ~= '0'))
                    answered=1;
                    
                    % Der gedrückte Button wird mit dem in der Lookup-Matrix
                    % gespeichertern Wert für das einzelne Sample verglichen.
                    % selectedButton wird als String zurückgegeben, daher findet
                    % eine Konvertierung durch eine Subtraktion mit 48 statt
                    % In der Ergebnismatrix gibt eine 1 an, dass das
                    % unterschiedliche Sample richtig erkannt wurde. Eine -1 zeigt
                    % ein falsches an.
                    
                    if (lookup(zeile,spalte) == (selectedButton-48))
                        ergebnis(zeile,spalte) = 1;
                    else
                        ergebnis(zeile,spalte) = -1;
                    end
                    towrite=[timestamp ';' char(name) ';' int2str(i) '(' int2str(num_pairs) ');' char(comparisonType) '; Sample ' int2str(ID_pairs(i,1)) ';' char(file_a(i)) '_vs_' char(file_b(i)) ';' text ];
                    fid = fopen(user_file, 'a+');
                    fprintf(fid,towrite );
                    fprintf(fid,'\n');
                    fclose(fid);
                end
        end
    end
    pause(1)            %short pause between trials
end

% Ergebnischeck fürs debugging
% disp(ergebnis);


% permutiere Ergebnismatrix (damit zur Skizze entsprechend
% - 1. Sample Block unten)

ergebnis2(1:(num_pairs/blockpairs),:) = ergebnis((num_pairs/blockpairs):-1:1,:);



for i=1:repeat
    % Gebe Ergebnismatrizzen in Datei aus
    % Es werden jeweils die entsprechenden Zeilen aus der großen Ergebnismatrix
    % in die Datei geschrieben
    
    fid = fopen(user_file, 'a+');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    towrite=['Ergebnismatrix_' int2str(repeat-(i-1)) ' von ' char(name)];
    fprintf(fid,towrite);
    fprintf(fid,'\n');
    for k=1+(i-1):repeat:((num_files/blocklength)*repeat)
        fprintf(fid,int2str(ergebnis2(k,:)));
        fprintf(fid,'\n');
    end
    fclose(fid);
end


enddialog = menu(['Vielen Dank das war Teil 1.'],'Ende!');
disp('Teil 1 erfolgreich beendet. Vielen Dank!');

% Ergebniskontrolle - In der Spalte rechts stehen nur Nullen, in allen anderen Spalten befindet sich -1 oder 1.
try
save([name '.V1.mat'],'ergebnis2');
catch
    
end
disp(ergebnis2);

successflag = 1;
%ita_listeningtests_ranking(name,'sets')
HV(name)
function play_sample(sz,i,np,data,fsr)
% FUNCTION PLAY_SAMPLE
% Spielt gewünschtes Sample ab (inklusive Anzeige)
%
% Benötigt folgende Eingabeparameter:
%
% sz = Signalzahl
% i = Versuchszahl
% np = Paar- bzw. Versuchsgesamtzahl
% data = Sample-Data
% fsr = Abstastrate des Samples
%
%  Das Klick-Geräusch muss noch eingefügt werden. Zu Testzwecken derzeit
%  entfernt.
%
%         pause(0.3);
%         [klick,fs] = wavread('klick.wav');
%         wavplay(klick,fs);
%         pause(0.3);

% play click!
%     if(sz > 1)
%         pause(0.3);
%         [klick,fs] = wavread('klick.wav');
%         wavplay(klick,fs);
%         pause(0.3);
%     end
%channels = [1 2]
w1 = waitbar(0,['Signal ' num2str(sz) ' (Versuch ' num2str(i) ' von ' num2str(np) ')']);
set(get(w1, 'Children'), 'Color', [0.95 0.95 0.95]);
hw = findobj(w1, 'Type', 'Patch');
set(hw, 'EdgeColor', [0.2 0.2 0.2], 'FaceColor', [0.95 0.95 0.95])
%player1 = audioplayer(data,fsr);
%play(player1);
%while isplaying(player1)
%    waitbar(get(player1, 'CurrentSample')/get(player1, 'TotalSamples'));
%    pause(0.01);
%end
playrec('play', [data data], [1 2]);
duration = size(data,1)/44100;          %playing time in seconds
while (playrec('isFinished')~=1)
    for it = 1:duration+1                 %count from 0 to duration in seconds
        waitbar(it/duration);            %display waitbar in second-fractions
        pause(1);                        %set 1 seconds as step-width
    end
end
delete(w1);



%% ANALYSIS

% [date, time,user,file,genre,result,inv_result] = textread('total_log.csv','%s %s %s %s %s %d %d','delimiter',';')
% % [date, time,user,file,genre,result,inv_result] = textread(user_file,'%s %s %s %s %s %d %d','delimiter',';')
%
% [p,t,st] = anova1(result,genre,'off');
% [c,m,h,nms] = multcompare(st,'display','on');
% figure
% [p,t,st] = anova1(result,file,'off');
% [c,m,h,nms] = multcompare(st,'display','on');
