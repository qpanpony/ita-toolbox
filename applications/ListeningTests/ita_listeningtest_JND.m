function ita_listeningtest_JND(soundPath, soundPathTrain, fileType)


% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% mkdir(soundPath)
% morseNumbers = test_mgu_morseCode();
% for iNumber = 1:10
%     ita_write(morseNumbers(iNumber), fullfile(soundPath, sprintf('Morse Code Number %i.ita', rem(iNumber, 10))));
% end

% Usage:
% ita_listeningtest_JND(soundPath, soundPathTrain, fileType)
% soundPath is the path with your sound files are of file type fileType
% soundPathTrain is the path containing your training files
% BE AWARE that files will be taken pair wise; means that always two
% subsequent files will be taken as a couple that is compared during the
% experiment. 

%%
%%% INITIALIZATION OF GUI INPUT DATA
br = newline;

% General parameters
ltData.testName         = 'JND Listening Test EDT';
ltData.introParameter         = [ br br 'Herzlich Willkommen zum Hˆrversuch' br br ...
                             'Im Rahmen dieses Hˆrversuches bekommen sie Paare von raumakustischen Stimuli ' ...
                             'vorgespielt,' 'wobei Sie f¸r jedes Paar entscheiden sollen, welches Stimuli den grˆﬂeren Nachhall hat.' br br ...
                             'Zun‰chst werden Sie ein ungewertetes Training absolvieren, gefolgt von dem eigentlichen Hˆrversuch.'...
                             'Im Training bekommen Sie Angaben ¸ber die Richtigkeit ihrer Wahl der Stimuli,' 'in dem Versuch hingegen nicht.' br br...
                             'Viel Spaﬂ!' 
                             ];

ltData.introAufgabe         = [ br br 'Definition:' br br ' "Nachhall" nennt sich der Schall der in einem Raum, der nach dem ein Ton' br ' plˆtzlich gestoppt hat, weiterhin besteht.' br br...
                             'Je lebendiger und l‰nger der Schall wirkt, desto grˆﬂer ist der Nachhall.' br 'Je k¸rzer und trockener der Schall wirkt, desto geringer ist der Nachhall.' br  br br... 
                              'Frage:' br br ' In welchem der beiden Beispiele ist der Nachhall st‰rker ausgepr‰gt?' br br ...
                             ];
                         
ltData.txtEndeTraining      = [ br 'Das Training ist beendet, der Versuch beginnt jetzt. ' br br ];

ltData.trainingPath  = soundPathTrain;
folderContentTrain = dir(fullfile(ltData.trainingPath, ['*.', fileType])); % only .wav files are considered!
fileNames = {folderContentTrain.name};

ltData.trainingFiles = {fileNames{1} fileNames{2};
                        fileNames{3} fileNames{4};
                        };
% ltData.trainingFiles         = {'Var_EDT K03-R05-P12.ita' 'Var_EDT K04-R04-P01.ita'; ...%3
%                                 'Var_EDT K02-R05-P02.ita' 'Var_EDT K04-R04-P01.ita'; ...%2
%                                 'Var_EDT K02-R04-P05.ita' 'Var_EDT K04-R04-P01.ita'; ...%1
%                                 'Var_EDT K03-R05-P12_Tr10.ita' 'Var_EDT K04-R04-P01_Tr10.ita'; ...%3
%                                 'Var_EDT K02-R05-P02_Tr10.ita' 'Var_EDT K04-R04-P01_Tr10.ita'; ...%2
%                                 'Var_EDT K02-R04-P05_Tr10.ita' 'Var_EDT K04-R04-P01_Tr10.ita'; ...%1
%                                 };


ltData.trainingCorrectAnswer = [ 1 1 1 1 1 1 ];


ltData.compareQuestion   = [ br 'In welchem der beiden Beispiele ist der Nachhall st‰rker ausgepr‰gt?'];              

folderContent = dir(fullfile(ltData.trainingPath, '*.wav')); % only .wav files are considered! % 2do: select file type in "creating GUI"
fileNames = {folderContent.name};
ltData.testPath  =  soundPath;
ltData.testFiles =  {fileNames{1} fileNames{2};
                     fileNames{3} fileNames{4};
                    };

% ltData.testFiles =  reshape(ita_sprintf('Morse Code Number %i.ita', 0:9), [], 2);

ltData.pauseBefore = 2;  % 2do: as input parameter with default value
ltData.pauseBetween = 0.5; % 2do: as input parameter with default value

ltData.txtEndeTest  = [br 'Der Hˆrversuch endent hier, vielen Dank f¸r Ihre Teilnahme.'];

ltData.resultPath = fullfile(fileparts(ltData.testPath), 'Results');
%%
ita_preferences('portAudioMonitor', 0)
if ~exist(ltData.resultPath, 'dir' )
    mkdir(ltData.resultPath )
end
%%


vpNumber = ita_str2num(inputdlg('Versuchtsperson Nummer:'));

if isempty(vpNumber)
    return
end
%  if ~isnumeric(vpNumber)
%      errordlg(sprintf('no number !'))
%      error(sprintf('no number !'))
%  end

ltData.testPerson.number = vpNumber;
ltData.testPerson.start = now;




%% generate GUI
screenSize = get(0, 'ScreenSize');


h.f = figure('Visible','on','NumberTitle', 'off', 'Position', screenSize, 'Name',ltData.testName  ,'MenuBar', 'none');
movegui(h.f,'center')

h.text          = uicontrol('Style','text','String','', 'Units', 'normalized', 'Position',  [0.1 0.35 0.8 0.55], 'HorizontalAlignment', 'center' , 'fontsize', 20);

h.buttonA    = uicontrol('Style','pushbutton', 'String','A','units', 'normalized', 'Position',[0.3 0.2 0.1 0.1], 'Callback', {@nextStep});
h.buttonB    = uicontrol('Style','pushbutton', 'String','B','units', 'normalized', 'Position',[0.6 0.2 0.1 0.1], 'Callback', {@nextStep});

h.nextButton    = uicontrol('Style','pushbutton', 'String','Weiter','units', 'normalized', 'Position',[0.8 0.1 0.1 0.1], 'Callback', {@nextStep});

% if ltData.showProgress
%     h.progress  =   uicontrol('Style','text','String',' 0 / 0', 'Position',[ layout.defaultSpace  layout.defaultSpace  120 20]);
%     h.hArray    = [h.hArray h.progress ];
% end

%% handles data

gData.ltData       = ltData;
gData.h = h;

gData.nextPhase = 'IntroParameter';



% allCombinations             = nchoosek(1:ltData.nSounds,2);
% h.data.currentLT.nSets      = size(allCombinations,1);
% [del, randIDX]               = sort(rand(h.data.currentLT.nSets,1));  
% h.data.currentLT.playlist   = allCombinations(randIDX,:);
% h.data.currentLT.currentSet = 0;
% h.data.currentLT.prefMat    = zeros(ltData.nSounds);              % prefMat(i,j) = is i prefered over j ?
% if ltData.useAttributes
%     h.data.currentLT.selectedAttribute   = zeros(ltData.nSounds);                % selectedAttribute(i,j) = attrib for i ; selectedAttribute(j,i) = attrib for j  
% end


% set(h.hArray, 'Visible', 'off')
% set([h.bigText h.nextButton] , 'Visible', 'on')


guidata(gData.h.f, gData)
set(gData.h.f,'Visible','on')%, 'CloseRequestFcn', {@CloseRequestFcn}) 

nextStep(gData.h.f, [])


end





function nextStep(obj, ~)
gData = guidata(obj);


switch gData.nextPhase
    
    case 'IntroParameter'
        set([gData.h.buttonA gData.h.buttonB ] , 'visible', 'off');
        set([gData.h.nextButton  gData.h.text ] , 'visible', 'on');
        set(gData.h.text, 'string', gData.ltData.introParameter );
        gData.nextPhase = 'IntroAufgabe';
    case 'IntroAufgabe'
        set([gData.h.buttonA gData.h.buttonB ] , 'visible', 'off');
        set([gData.h.nextButton  gData.h.text ] , 'visible', 'on');
        set(gData.h.text, 'string', gData.ltData.introAufgabe );
        set(gData.h.nextButton, 'string', 'Training starten');
        gData.nextPhase = 'Training';
        gData.currentSet = 0;
    case 'Training'
        
        % letzte auswahl speichern
        if gData.currentSet > 1
            set([gData.h.buttonA gData.h.buttonB ] , 'visible', 'off');
            auswahl = find(strcmpi({'A' 'B'}, get(obj, 'string')));
            gData.output.trainingAuswahl(gData.currentSet-1) = auswahl;
            
            % FEEDBACK
            currCorrectAuswahl = gData.ltData.trainingCorrectAnswer(gData.currentSet-1);
            if gData.changeABorder(gData.currentSet-1)
                currCorrectAuswahl = 3 - currCorrectAuswahl;
            end
            
            if currCorrectAuswahl == auswahl
                set(gData.h.text, 'string',  'Richtig ! ' );
            else
                set(gData.h.text, 'string',  'Falsch ! ' );
            end
            
            pause(2)
            
            
        end
        
        if gData.currentSet  == 0 % vorbereiten
            set(gData.h.nextButton, 'visible', 'off');
             set(gData.h.text  , 'string', 'Lade Daten....');
             pause(0.1)
            [nTrainingSets, nSoundsPerSet] = size(gData.ltData.trainingFiles);
            
            if nSoundsPerSet ~= 2
                error('trainingFiles cell muss nSets x 2 groﬂ sein!')
            end
            
            gData.trainingSounds = itaAudio(nTrainingSets, 2);
            
            for iSound = 1:nTrainingSets*2
               gData.trainingSounds(iSound) = ita_read(fullfile(gData.ltData.trainingPath, gData.ltData.trainingFiles{iSound}));
            end
            set(gData.h.text  , 'visible', 'off');
            set(gData.h.nextButton, 'string', 'Abspielen', 'fontweight', 'bold', 'visible', 'on');
            gData.trainingsSetOrder = randperm(nTrainingSets);
            gData.changeABorder = round(rand(nTrainingSets,1));
            gData.currentSet  = 1;
            gData.output.trainingPlayList = cell(nTrainingSets,2);
            gData.output.trainingAuswahl = zeros(nTrainingSets,1);
        elseif gData.currentSet > size(gData.trainingSounds,1)      % n‰chste phase
            
            gData.trainingSounds = [];
            
            set([gData.h.buttonA gData.h.buttonB ] , 'visible', 'off');
            set([gData.h.nextButton  gData.h.text ] , 'visible', 'on');
            set(gData.h.text, 'string',  gData.ltData.txtEndeTraining  );
            set(gData.h.nextButton, 'string',  'Hˆrversuch starten' );
            
            gData.nextPhase = 'ListeningTest';
            gData.currentSet  = 0;
            
            
        else
            set([gData.h.buttonA gData.h.buttonB  gData.h.nextButton  gData.h.text ] , 'visible', 'off');

            currSounds    = gData.trainingSounds(gData.trainingsSetOrder(gData.currentSet),:);
            currFileNames = gData.ltData.trainingFiles(gData.trainingsSetOrder(gData.currentSet),:);
            
            if gData.changeABorder(gData.currentSet)
                currSounds = currSounds(end:-1:1);
                currFileNames = currFileNames(end:-1:1);
            end
%             currFileNames
            gData.output.trainingPlayList(gData.currentSet,:) = currFileNames;
            
            % wait for
            nSteps = 50;
            wbh = waitbar(0, 'Wiedergabe beginnt ...');
            for iStep = 1:nSteps
                waitbar(iStep / nSteps, wbh);
                pause(gData.ltData.pauseBefore / nSteps)
            end
            close(wbh)
            
            % show text
            set( gData.h.text , 'string', gData.ltData.compareQuestion)
            % show buttons and disable them
            set([gData.h.buttonA gData.h.buttonB  gData.h.text ] , 'visible', 'on');
            set([gData.h.buttonA gData.h.buttonB] , 'enable', 'off');
            
            % set colour of currently played sound to green
            set(gData.h.buttonA, 'BackgroundColor', 'g');
            % play stimulus
            ita_portaudio_run(currSounds(1), 'OutputChannels', 1:2, 'Block')
            % reset colour again
            set(gData.h.buttonA, 'BackgroundColor', [0.94 0.94 0.94]);
            
            % ... and the same for the second stimulus / button
            set(gData.h.buttonB, 'BackgroundColor', 'g');
            ita_portaudio_run(currSounds(2), 'OutputChannels', 1:2, 'Block')
            set(gData.h.buttonB, 'BackgroundColor', [0.94 0.94 0.94]);
            % enable both buttons
            set([gData.h.buttonA gData.h.buttonB] , 'enable', 'on');

            gData.currentSet  = gData.currentSet  + 1;
        end
        
%     case 'TxtEndeTraining'
%         set([gData.h.buttonA gData.h.buttonB ] , 'visible', 'off');
%         set([gData.h.nextButton  gData.h.text ] , 'visible', 'on');
%         set(gData.h.text, 'string',  gData.ltData.txtEndeTraining  )
%         set(gData.h.nextButton, 'string',  'Hˆrversuch starten' );
%         
%         gData.nextPhase = 'ListeningTest';
%         gData.currentSet  = 0;
    case 'ListeningTest'
           % letzte auswahl speichern
        if gData.currentSet > 1
            find(strcmpi({'A' 'B'}, get(obj, 'string')))
            gData.output.testAuswahl(gData.currentSet-1) = find(strcmpi({'A' 'B'}, get(obj, 'string')));
        end
        
        if gData.currentSet  == 0 % vorbereiten
            set(gData.h.nextButton, 'string', 'Abspielen');
            set(gData.h.text  , 'visible', 'off');
            [nSets, nSoundsPerSet] = size(gData.ltData.testFiles);
            
            if nSoundsPerSet ~= 2
                error('testFiles cell muss nSets x 2 groﬂ sein!')
            end
            
            gData.testSounds = itaAudio(nSets, 2);
            
            for iSound = 1:nSets*2
               gData.testSounds(iSound) = ita_read(fullfile(gData.ltData.testPath, gData.ltData.testFiles{iSound}));
            end
            
            gData.testSetOrder = randperm(nSets);
            gData.changeABorder = round(rand(nSets,1));
            gData.currentSet  = 1;
            gData.output.testPlayList = cell(nSets,2);
            gData.output.testAuswahl = zeros(nSets,1);
        elseif gData.currentSet > size(gData.testSounds,1) % n‰chste phase
            % save data
            gData.testSounds = [];
            save(fullfile(gData.ltData.resultPath, sprintf('VP%02i_%s.mat', gData.ltData.testPerson.number, datestr(now, 'yyyy-mm-dd_HHMM') )), 'gData')

            %
            gData.nextPhase = 'EndOfTest';
            set([gData.h.buttonA gData.h.buttonB ] , 'visible', 'off');
            set([gData.h.nextButton  gData.h.text ] , 'visible', 'on');
            set(gData.h.text, 'string',  gData.ltData.txtEndeTest  )
            set(gData.h.nextButton, 'string',  'Schlieﬂen' );

        else
            
            set([gData.h.buttonA gData.h.buttonB  gData.h.nextButton  gData.h.text ] , 'visible', 'off');

            currSounds    = gData.testSounds(gData.testSetOrder(gData.currentSet),:);
            currFileNames = gData.ltData.testFiles(gData.testSetOrder(gData.currentSet),:);
            
            if gData.changeABorder(gData.currentSet)
                currSounds = currSounds(end:-1:1);
                currFileNames = currFileNames(end:-1:1);
            end
            
            gData.output.testPlayList(gData.currentSet,:) = currFileNames;
            
            % wait for
            nSteps = 50;
            wbh = waitbar(0, 'Wiedergabe beginnt ...');
            for iStep = 1:nSteps
                waitbar(iStep / nSteps, wbh);
                pause(gData.ltData.pauseBefore / nSteps)
            end
            close(wbh)
            
            
            set( gData.h.text , 'string', gData.ltData.compareQuestion)
            set([gData.h.buttonA gData.h.buttonB  gData.h.text ] , 'visible', 'on');
            set([gData.h.buttonA gData.h.buttonB] , 'enable', 'off');
            
            % first stimulus
            set(gData.h.buttonA, 'BackgroundColor', 'g');
            ita_portaudio_run(currSounds(1), 'OutputChannels', 1:2, 'Block')
            set(gData.h.buttonA, 'BackgroundColor', [0.94 0.94 0.94]);
            
            % second stimulus
            set(gData.h.buttonB, 'BackgroundColor', 'g');
            ita_portaudio_run(currSounds(2), 'OutputChannels', 1:2, 'Block')
            set(gData.h.buttonB, 'BackgroundColor', [0.94 0.94 0.94]);
            
            % enable both buttons
            set([gData.h.buttonA gData.h.buttonB] , 'enable', 'on');

            gData.currentSet  = gData.currentSet  + 1;
            

        end
        
    case 'EndOfTest'
        close(gData.h.f)
        return
        
    otherwise 
        error('unkown phase: %s', gData.nextPhase)
end



guidata(gData.h.f, gData)
end

