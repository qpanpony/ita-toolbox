function varargout = ita_moveWallLT_GUI(varargin)
% ita_moveWallLT_GUI MATLAB code for ita_moveWallLT_GUI.fig
%      ita_moveWallLT_GUI, by itself, creates a new ita_moveWallLT_GUI or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ita_moveWallLT_GUI returns the handle to a new ita_moveWallLT_GUI or the handle to
%      the existing singleton*.
%
%      ita_moveWallLT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ita_moveWallLT_GUI.M with the given input arguments.
%
%      ita_moveWallLT_GUI('Property','Value',...) creates a new ita_moveWallLT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_moveWallLT_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_moveWallLT_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_moveWallLT_GUI

% Last Modified by GUIDE v2.5 24-Oct-2014 15:32:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_moveWallLT_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_moveWallLT_GUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before ita_moveWallLT_GUI is made visible.
function ita_moveWallLT_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

%% Shuffle Randoms
rng('shuffle')

%% Data Initialization - Folder

%Data folder
handles.folder = 'C:\Users\bomhardt\Documents\WallMove\';

% Check if folder is existant
if ~exist(handles.folder, 'dir')
    
    handles.folder = uigetdir([],'Choose Listening Test Path');
    
    %If aborded by user, Close GUI
    if isa(handles.folder, 'double')
        handles.allowClosing = 1;
        guidata(hObject, handles)
        close(handles.figure1)
        return
    end
    
    handles.folder = [handles.folder '\'];
end
handles.saveFolder = [handles.folder, 'Saves\'];

%% Data Initialization - Subject Data

%Check for Input
if isempty(varargin)
    %Subject Data
    handles.subjectData = ita_moveWallLT_subjectData; 
    
%     tmp = load('C:\Users\bomhardt\Documents\ITA-Data\2014_DFG\2015_DFG_MovedWall\subj.mat');
%     handles.subjectData = tmp.ans;
    pause(0.1)
    
    %check if data was submitted correctly, otherwise close GUI
    if ~isa(handles.subjectData, 'struct')
        handles.allowClosing = 1;
        guidata(hObject, handles)
        close(handles.figure1)
        return
    end
    
    %Get the Configuration order depending on the group of the subject
    blockOrder = [5	6	7	3	4	1	2;...
        6	7	5	2	1	4	3;...
        3	4	7	5	6	1	2;...
        4	3	2	1	5	6	7;...
        1	2	3	4	5	7	6;...
        2	1	7	5	6	4	3;...
        5	6	7	3	4	1	2;...
        6	7	5	2	1	4	3;...
        3	4	7	5	6	1	2;...
        4	3	2	1	5	6	7;...
        1	2	3	4	6	7	5;...
        2	1	7	5	6	4	3];

    configBlocks = {'Noise pulsed short','Noise pulsed long', 'Speech Zahl','Speech Schreck',...
        'Music guitar','Music drum','Music trumpet'};

    %configBlocks = {'Noise','Speech','Music'};
    configBlockOrder = blockOrder(handles.subjectData.group, :); %/3???
    handles.subjectData.configBlockOrder = configBlocks(configBlockOrder);
    
%     groupOrder = [3	2 1; 3 1 2; 2 3 1; 2 1 3; 1 2 3; 1 3 2];
%     handles.subjectData.configOrder = groupOrder(handles.subjectData.group, :);
    handles.subjectData.configOrder = configBlockOrder;
    
    handles.subjectData.lastAvsolvedRound = -1;     %last Round that has been completed by the subject
    handles.round = 1;                              %actual test-round (0 = Traininground) 
    
    %ResultCell
    handles.subjectData.quests = cell(1,7);         %Quest Structs of Configurations {1 2 ... 8}
    handles.subjectData.trainingResult = [];        %Result of the Training Round
    %results{idx} is a matrix with following collumns:
    %Order of Room configuration, Signal with a difference (0->A 1->B), correct answer?
    
    handles.subjectData.results = cell(1,7);        %Results of Configurations {1 2 3 ... 8}
    %results{idx} is a matrix with following collumns:
    %Wall angle, Signal with a difference (0->A 1->B), correct answer?
    
    
%is Input only a subjectData struct?
elseif length(varargin) == 1
    if ~isa(varargin{1}, 'struct')
        error('input must be empty or a subjectData-struct')
    end
    handles.subjectData = varargin{1};
    handles.round = handles.subjectData.lastAbsolvedRound + 1;
    
%Wrong Input    
else
   error('input must be empty or a subjectData-struct')
end

%% Data Initialization - LT Parameters

% hMsg = msgbox({'Prepairing Listening Test Parameters...';'Please be patient!'}, 'Initializing');
% hMsg = figure('position',[500 500 200 100],'Visible','on');
% txt =  uicontrol('Style','text',...
%         'Position',[20 20 150 20],...
%         'String','Prepairing listening test...');
% To Do
stimuli = ita_read([handles.folder '\stimuli.ita']);     %itaAudio(8, 31)signals4LTe
signals = load([handles.folder '\binIRsB.mat']); 

handles.signals = signals.binIRs;
handles.stimuli = stimuli;
numIR = size(handles.signals,2)-1;
handles.dWall = zeros(numIR+1,1);
for idxS = 1:numIR+1
    handles.dWall(idxS) = handles.signals(1,idxS).channelCoordinates.n(1).x;
end
%LT parameters
handles.maxRounds = stimuli.dimensions;              %number of test-rounds

%TODO: Set this to 50 after Check for errors
handles.roundLength = 5;            %n of signals per round
handles.nRepeat = 2;                %Each signal can be played nRepeat times
handles.pauseTime = 10;%210;             %time between rounds in seconds
handles.pauseBetweenSignals = 0.01; %Time between Reference signal and Signal A/B
 handles.round = 0;                %actual test-round (0 = Traininground)

%used to prevent closing GUI unintentionally
handles.allowClosing = 0;

%Used for buttons in normal Mode
handles.buttonsDisabled = [0 0 0]; %Buttons: A B OK
handles.pressedButton = [];

%Configuration of LT-Rounds
handles.configStr = configBlocks;% %To Do


%Signals
%signals = load([handles.folder, 'Input\signalsForLT.mat']);     %itaAudio(8, 31)
%handles.signals = signals.signalsForLT;

%% Data Initialization - Quest Algorithm
pThreshold  = 0.75;
beta        = 3;
delta       = 0.15;
gamma       = 0.5;

tGuess      = mean(handles.dWall);
tGuessSd    = mean(handles.dWall);

grain = 0.1;
range = handles.dWall(end)- handles.dWall(1);

q           = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma, grain, range);
q.normalizePdf = 1; 

handles.quest = q;
%% Data Initialization -  Callbacks
% Keyboard Callback
set(handles.figure1, 'KeyPressFcn', @keyPress_Callback)

%% Update handles structure
guidata(hObject, handles);


%% Data Initialization -  Graphics

%Delete the be-patient-box
%delete(hMsg)

%Change Layer/Color
chooseLayer('start', handles)
changeColor('green', 'start',  handles)

%update text beneath start push
if handles.round == 0    
    str = 'Training-Round';    
else
    str = ['Round ' num2str(handles.round)];
end
set(handles.textStart, 'String', str)

% --- Outputs from this function are returned to the command line.
function  ita_moveWallLT_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;

%% Functions for graphics
function chooseLayer(str, handles)

%Changes the visible layer of the GUI
%possible input for str:
%normal, pause, start

if ~isa(str, 'char')
    msgbox('first input has to be string!')
    return
end


switch str
    case 'pause'
        set(handles.pushA, 'Visible', 'off')
        set(handles.pushB, 'Visible', 'off')
        set(handles.pushOK_A, 'Visible', 'off')
        set(handles.pushOK_B, 'Visible', 'off')
        set(handles.textA, 'Visible', 'off')
        set(handles.textB, 'Visible', 'off')
        set(handles.textTurns, 'Visible', 'off')
        
        set(handles.pushStart, 'Visible', 'off')
        set(handles.textStart, 'Visible', 'off')
        
        set(handles.textWaitTime, 'Visible', 'on')
        
    case 'start'
        set(handles.pushA, 'Visible', 'off')
        set(handles.pushB, 'Visible', 'off')
        set(handles.pushOK_A, 'Visible', 'off')
        set(handles.pushOK_B, 'Visible', 'off')
        set(handles.textA, 'Visible', 'off')
        set(handles.textB, 'Visible', 'off')
        set(handles.textTurns, 'Visible', 'off')
        
        set(handles.pushStart, 'Visible', 'on')
        set(handles.textStart, 'Visible', 'on')
        
        set(handles.textWaitTime, 'Visible', 'off')
        
    case 'normal'
        set(handles.pushA, 'Visible', 'on')
        set(handles.pushB, 'Visible', 'on')
        set(handles.pushOK_A, 'Visible', 'on')
        set(handles.pushOK_B, 'Visible', 'on')
        set(handles.textA, 'Visible', 'on')
        set(handles.textB, 'Visible', 'on')
        set(handles.textTurns, 'Visible', 'on')
        
        set(handles.pushStart, 'Visible', 'off')
        set(handles.textStart, 'Visible', 'off')
        
        set(handles.textWaitTime, 'Visible', 'off')
        
    otherwise %do nothing
end

function changeColor (color, button,  handles)

%Changes the color of one or several buttons or texts
%possible input for color:
%yellow, red, green

if ~isa(color, 'char') || ~isa(button, 'char')
    msgbox('first two inputs have to be a string!')
    return
end

if ~(strcmp(color, 'yellow') || strcmp(color, 'red') || strcmp(color, 'green') ||...
        strcmp(color, 'grey') || strcmp(color, 'orange') || strcmp(color, 'cyan'))
    msgbox('possible input for color: yellow, red, green, grey', 'orange', 'cyan')
    return
end

%Convert String to RGB if neccessary
if strcmp(color, 'grey')
    color = [0.9412 0.9412 0.9412] ;
elseif strcmp(color, 'orange')
    color = [1 0.65 0];
end

switch button
   
    case 'A'
        set(handles.pushA, 'BackgroundColor', color)
    case 'B'
        set(handles.pushB, 'BackgroundColor', color)
    case 'AB'
        set(handles.pushA, 'BackgroundColor', color)
        set(handles.pushB, 'BackgroundColor', color)
    case 'Diff. A'
        set(handles.pushOK_A, 'BackgroundColor', color)
    case 'Diff. B'
        set(handles.pushOK_B, 'BackgroundColor', color)
    case 'normal'
        set(handles.pushA, 'BackgroundColor', color)
        set(handles.pushB, 'BackgroundColor', color)
        set(handles.pushOK_A, 'BackgroundColor', color)
         set(handles.pushOK_B, 'BackgroundColor', color)
    case 'start'
        set(handles.pushStart, 'BackgroundColor', color)
    case 'wait'
        set(handles.textWaitTime, 'BackgroundColor', color)
        
    otherwise
        msgbox('possible input for push: A, B, OK, AB, normal, start, wait')
        
end

function disableButtons(button, handles)

if ~isa(button, 'char')
    msgbox('first input has to be a string!')
    return
end

switch button
    case 'AB'
        set(handles.pushA,'Enable','off')
        set(handles.pushB,'Enable','off')
        handles.buttonsDisabled(1:2) = [1 1];
    case 'Diff. A'
        set(handles.pushOK_A,'Enable','off')
        handles.buttonsDisabled(3) = 1;
    case 'Diff. B'
        set(handles.pushOK_B,'Enable','off')
        handles.buttonsDisabled(4) = 1;
    case 'all'
        set(handles.pushA,'Enable','off')
        set(handles.pushB,'Enable','off')
        set(handles.pushOK_A,'Enable','off')
        set(handles.pushOK_B,'Enable','off')
        handles.buttonsDisabled = [1 1 1 1];
end

guidata(handles.figure1, handles)

function enableButtons(button, handles)

if ~isa(button, 'char')
    msgbox('first input has to be a string!')
    return
end

switch button
    case 'AB'
        set(handles.pushA,'Enable','on')
        set(handles.pushB,'Enable','on')
        handles.buttonsDisabled(1:2) = [0 0];
    case 'Diff. A'
        set(handles.pushOK_A,'Enable','on')
        handles.buttonsDisabled(3) = 0;
    case 'Diff. B'
        set(handles.pushOK_B,'Enable','on')
        handles.buttonsDisabled(4) = 0;
    case 'all'
        set(handles.pushA,'Enable','on')
        set(handles.pushB,'Enable','on')
        set(handles.pushOK_A,'Enable','on')
        set(handles.pushOK_B,'Enable','on')
        handles.buttonsDisabled = [0 0 0 0];
end

guidata(handles.figure1, handles)

%% LT functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pauseListeningTest(duration, handles)

%pauses the Listeningtest (should be used after each round)
%duration = wait-time in seconds

chooseLayer('pause', handles)
set(handles.textWaitTime, 'backgroundcolor', 'red')

time = duration;
str = get(handles.textWaitTime, 'String');
str{1} = 'It is time for a break';
str{3} = '0:00';

while(time >= 0)
  
    strMinutes = num2str(floor(time/60));
    strSecs = mod(time, 60);    
    if strSecs > 9
        strSecs = num2str(strSecs);
    else
        strSecs = ['0', num2str(strSecs)];  %make it like Y:0X here
    end
    str{3} = [strMinutes, ':', strSecs];
    
    set(handles.textWaitTime, 'String', str)
    if time == 10
        set(handles.textWaitTime, 'backgroundcolor', 'yellow')
    end
    
    pause(1)
    time = time-1;
end

% function countdownBeforeRound(handles)
% 
% %Starts a Countdown of three seconds
% %Should be used before each round
% 
% chooseLayer('pause', handles)
% set(handles.textWaitTime, 'backgroundcolor', 'red')
% 
% time = 3;
% str = get(handles.textWaitTime, 'String');
% str{1} = 'Round starts in:';
% str{3} = '3';
% 
% while(time >= 0)
%   
%     str{3} = num2str(time);
%     
%     set(handles.textWaitTime, 'String', str)
%     if time == 1
%         set(handles.textWaitTime, 'backgroundcolor', 'yellow')
%     end
%     if time == 0
%         set(handles.textWaitTime, 'backgroundcolor', 'green')
%     end
%     
%     pause(1)
%     time = time-1;
% end

function startTraining(hObject, handles)

%Starts the training-round of the Listening Test
%% Init Round

% %graphics
% chooseLayer('pause', handles)
% changeColor('red', 'wait', handles)
% str = get(handles.textWaitTime, 'String');
% str{1} = 'Be patient!';
% str{3} = 'Prepairing sounds...';
% set(handles.textWaitTime, 'String', str);
% 
% pause(0.1)
disp('..............................................')
disp([ 'Current subject: ' handles.subjectData.name])
disp('..............................................')
nConfig = length(handles.configStr);

%Randomly choose order of configurations
order = [randperm(nConfig) randperm(nConfig)];

%Init Signals
%Always choose signal with max angle as different signal
maxA = size(handles.signals,2);
refSignals = itaAudio(numel(order),1);
signals = itaAudio(numel(order),1);
for idxS = 1:numel(order)
    refSignals(idxS,1) = ita_convolve(handles.stimuli.ch(order(idxS)),handles.signals(1, 1));
    signals(idxS,1) = ita_convolve(handles.stimuli.ch(order(idxS)),handles.signals(1, maxA));
end

%Choose the correct answers randomly (0 -> A    1 -> B)
correctAnswers = randi(2,[1,2*nConfig]);
correctAnswers = correctAnswers - 1;

%Result Matrix
%Config-order, Signal with a difference (0->A 1->B), correct answer?
result = zeros(2*nConfig, 3);
result(:,1) = order;
result(:,2) = correctAnswers;

%% Start Countdown
% countdownBeforeRound(handles)

%set graphics to normal
disableButtons('all', handles)
handles = guidata(hObject);
changeColor('red', 'normal', handles)
chooseLayer('normal', handles)

%% Start Round

%Loop over all Signals
for idx = 1:2*nConfig
    
    %Show how many times user is allowed to play A/B
    str = get(handles.textA, 'String');
    str{2} = num2str(handles.nRepeat);
    set(handles.textA, 'String', str)
    str{2} = num2str(handles.nRepeat);
    set(handles.textB, 'String', str)
        
    %Show how many turns (decisions) are left
    strTurns = get(handles.textTurns, 'String');
    strTurns{2} = num2str(2*nConfig+1-idx);
    set(handles.textTurns, 'String', strTurns)
    
    %Reset variables
    nPlayedA = 0;
    nPlayedB = 0;
    pressedOK_A = 0;
    pressedOK_B = 0;
    chosenSignal = [];      %0 -> A   1 -> B
%     correct = [];
    
    %Actual reference-signal
    refSignal = refSignals(idx);
    
    %Actual Signals:
    %The Different Signal is B
    if correctAnswers(idx)
        signalA = refSignal;
        signalB = signals(idx);
        
        %The Different Signal is A
    else
        signalA = signals(idx);
        signalB = refSignal;
    end
    
    
    %reset Buttons
    enableButtons('AB', handles)
    handles = guidata(hObject);
    changeColor('green', 'AB', handles)
    disableButtons('Diff. A', handles)
    handles = guidata(hObject);
    disableButtons('Diff. B', handles)
    handles = guidata(hObject);
    changeColor('red', 'Diff. A', handles)
    changeColor('red', 'Diff. B', handles)
    
    %User Listens to Signal-Pairs and chooses the one with a difference
    %......................................................................
    %......................................................................
    while ~pressedOK_A && ~pressedOK_B 
    %......................................................................
    %......................................................................
        
        %Wait for Userinput
        uiwait
        
        %get pressed button
        handles = guidata(hObject);
        
        switch handles.pressedButton
            case 'A'
                %chosenSignal = 0;
                %Only Play if maximum of allowed repeats not reached
                if nPlayedA < handles.nRepeat
                    nPlayedA = nPlayedA + 1;
                    
                    %Disable Buttons while playing
                    disableButtons('all', handles)
                    handles = guidata(hObject);
                    changeColor('orange', 'normal', handles)
                    
                    %Update String for left Repeats
                    str{2} = num2str(handles.nRepeat-nPlayedA);
                    set(handles.textA, 'String', str)
                    
                    %Play
                    refSignal.play
                    pause(handles.pauseBetweenSignals)
                    signalA.play
                end
            case 'B'
                %chosenSignal = 1;
                %Only Play if maximum of allowed repeats not reached
                if nPlayedB < handles.nRepeat
                    nPlayedB = nPlayedB + 1;
                    
                    %Disable Buttons while playing
                    disableButtons('all', handles)
                    handles = guidata(hObject);                    
                    changeColor('orange', 'normal', handles)
                    
                    %Update String for left Repeats
                    str{2} = num2str(handles.nRepeat-nPlayedB);
                    set(handles.textB, 'String', str)
                    
                    %Play
                    refSignal.play
                    pause(handles.pauseBetweenSignals)
                    signalB.play
                end
            case 'Diff. A'
                pressedOK_A = 1;
                chosenSignal = 0;
            case 'Diff. B'
                pressedOK_B = 1;
                chosenSignal = 1;
        end
        
        %Enable Buttons and change their Colors
        %(Chosen Signal gets a different Color)
        enableButtons('AB', handles)
        handles = guidata(hObject);

        %Activate OK Button only if each Signal was at least played once
        if nPlayedA || nPlayedB
            enableButtons('Diff. A', handles)
            enableButtons('Diff. B', handles)
            handles = guidata(hObject);
            changeColor('green', 'Diff. A', handles)
            changeColor('green', 'Diff. B', handles)
        end
        
    end
    
    %Check if the answer was correct
    correct = correctAnswers(idx) == chosenSignal;
    
    %Save Data in Result-Matrix
    result(idx,3) = correct;
end

%% Finish Round

%Updata handles (Results)
handles.subjectData.trainingResult = result;
guidata(hObject, handles)


function startNextRound(hObject, handles)

%Starts a round of the Listening Test
%% Init Round

% %graphics
% chooseLayer('pause', handles)
% changeColor('red', 'wait', handles)
% str = get(handles.textWaitTime, 'String');
% str{1} = 'Be patient!';
% str{3} = 'Prepairing sounds...';
% set(handles.textWaitTime, 'String', str);
% 
% pause(0.1)

%Configuration
config = handles.subjectData.configOrder(handles.round); 

%Load the needed signals
IR = handles.signals;
stimuli = handles.stimuli.ch(config);
refSignal = ita_convolve(stimuli,IR(1,1));

signals = itaAudio(size(handles.signals,2)-1,1);
for idx = 2:size(handles.signals,2)
    signals(idx-1,1) = ita_convolve(stimuli, IR(1, idx));
end

%Choose the correct answers randomly (0 -> A    1 -> B)
idxRand = randperm(handles.roundLength);
cAnsSorted = [zeros(1,ceil(handles.roundLength/2)) ones(1,floor(handles.roundLength/2))];
correctAnswers = cAnsSorted(idxRand);
%correctAnswers = randi(2,[1,handles.roundLength]);
%correctAnswers = correctAnswers - 1;

%Quest Class
quest = handles.quest;

%Result Matrix
%Wall angle, Signal with a difference (0->A 1->B), correct answer?
result = zeros(handles.roundLength, 3);
result(:,2) = correctAnswers;

%% Start Countdown
% countdownBeforeRound(handles)

%set graphics to normal
disableButtons('all', handles)
handles = guidata(hObject);
changeColor('red', 'normal', handles)
chooseLayer('normal', handles)


%% Start Round
%Loop over all the signals
tic
for idx = 1:handles.roundLength
        
    %Get the next Angle of the Wall via Quest algorithm (only integers)
    testq=QuestQuantile(quest,0.55);
    
    [~,distOfWallIdx ] = min(abs(testq-handles.dWall));
    
%   limit distOfWallIdx
    if distOfWallIdx< 1
        distOfWallIdx = 1;
        disp('Wall distance index is smaller than 2')
    elseif distOfWallIdx> numel(handles.signals)-1
        distOfWallIdx = numel(handles.signals)-1;
        disp('Wall distance index is bigger than 40')
    end
    
    %Show how many times user is allowed to play A/B
    str = get(handles.textA, 'String');
    str{2} = num2str(handles.nRepeat);
    set(handles.textA, 'String', str)
    str{2} = num2str(handles.nRepeat);
    set(handles.textB, 'String', str)
    
    %Show how many turns (decisions) are left
    strTurns = get(handles.textTurns, 'String');
    strTurns{2} = num2str(handles.roundLength+1-idx);
    set(handles.textTurns, 'String', strTurns)
    
    %Reset variables
    nPlayedA = 0;
    nPlayedB = 0;
    pressedOK_A = 0;
    pressedOK_B = 0;
    chosenSignal = [];      %0 -> A   1 -> B
%     correct = [];
    
    %Actual Signals:
    %The Different Signal is B
    if correctAnswers(idx)
        signalA = refSignal;
        signalB = signals(distOfWallIdx);
        
        %The Different Signal is A
    else
        signalA = signals(distOfWallIdx);
        signalB = refSignal;
    end
    
    
    %reset Buttons
    enableButtons('AB', handles)
    handles = guidata(hObject);
    changeColor('green', 'AB', handles)
    disableButtons('Diff. A', handles)
    disableButtons('Diff. B', handles)
    handles = guidata(hObject);
    changeColor('red', 'Diff. A', handles)
    changeColor('red', 'Diff. B', handles)
    
    %User Listens to Signal-Pairs and chooses the one with a difference
    while ~pressedOK_A && ~pressedOK_B % CHANGED
        
        %Wait for Userinput
        uiwait
        
        %get pressed button
        handles = guidata(hObject);
        
        switch handles.pressedButton
            case 'A'
                %chosenSignal = 0;
                %Only Play if maximum of allowed repeats not reached
                if nPlayedA < handles.nRepeat
                    nPlayedA = nPlayedA + 1;
                    
                    %Disable Buttons while playing
                    disableButtons('all', handles)
                    handles = guidata(hObject);
                    changeColor('orange', 'normal', handles)
                    
                    %Update String for left Repeats
                    str{2} = num2str(handles.nRepeat-nPlayedA);
                    set(handles.textA, 'String', str)
                    
                    %Play
                    refSignal.play
                    pause(handles.pauseBetweenSignals)
                    signalA.play
                end
            case 'B'
                %chosenSignal = 1;
                %Only Play if maximum of allowed repeats not reached
                if nPlayedB < handles.nRepeat
                    nPlayedB = nPlayedB + 1;
                    
                    %Disable Buttons while playing
                    disableButtons('all', handles)
                    handles = guidata(hObject);                    
                    changeColor('orange', 'normal', handles)
                    
                    %Update String for left Repeats
                    str{2} = num2str(handles.nRepeat-nPlayedB);
                    set(handles.textB, 'String', str)
                    
                    %Play
                    refSignal.play
                    pause(handles.pauseBetweenSignals)
                    signalB.play
                end
            case 'Diff. A'
                chosenSignal = 0; %CHANGED
                pressedOK_A = 1;
            case 'Diff. B'
                chosenSignal = 1;%CHANGED
                pressedOK_B = 1;
        end
        
        %Enable Buttons and change their Colors
        %(Chosen Signal gets a different Color)
        enableButtons('AB', handles)
        handles = guidata(hObject);
        
        %Activate OK Button only if each Signal was atleast played once
        if nPlayedA || nPlayedB
            enableButtons('Diff. A', handles)
            enableButtons('Diff. B', handles)
            handles = guidata(hObject);
            changeColor('green', 'Diff. A', handles)
            changeColor('green', 'Diff. B', handles)
        end
        
    end
    
    %Check if the answer was correct
    correct = correctAnswers(idx) == chosenSignal;
    
    %Save Data in Result-Matrix
    result(idx,3) = correct;
    result(idx,1) = handles.dWall(distOfWallIdx+1);
    
    %Update Quest
    quest = QuestUpdate(quest, handles.dWall(distOfWallIdx+1), correct);
    
end

%% Finish Round

% Optionally, reanalyze the data with beta as a free parameter.
QuestBetaAnalysis(quest); % optional
disp(['Round ' num2str(handles.round) ' finished! '])

t = toc;
disp(['Time: ' num2str(round(t)) 's'])
disp(num2str([(result(:,1)) result(:,3)]));
%Updata handles (Results)
handles.subjectData.results{config} = result;
handles.subjectData.quests{config} = quest;

guidata(hObject, handles)


function finishLT(hObject, handles)

%Graphics
str = {'The Listening Test is now finished';'';'Thanks for your participation!'};
set(handles.textWaitTime, 'String', str)
chooseLayer('pause', handles)
changeColor('green', 'wait', handles)

%savefile
subjectData = handles.subjectData;
filepath = [handles.saveFolder, 'Results\'];
filename = ['resultID_', num2str(subjectData.ID), '_', subjectData.date, '_', subjectData.time]; %filescheme: resultLT_date_time
idxColon = strfind(filename, ':');
filename(idxColon) = '-';
save([filepath, filename],'subjectData')

%Closing the GUI is now allowed
handles.allowClosing = 1;
guidata(hObject, handles)

disp('Listening test is done!')
disp('                       ')
pause(3)

%close GUI
close(handles.figure1)


%% Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This Button starts the Listening-Test-Rounds
function pushStart_Callback(hObject, eventdata, handles) %#ok<DEFNU>

%Traininground
if handles.round == 0
    startTraining(hObject, handles) %To Do: enable!!!

%Normal Round
elseif handles.round <= handles.maxRounds
    startNextRound(hObject, handles)
end

%update handles
handles = guidata(hObject);

%Round absolved!
handles.subjectData.lastAbsolvedRound = handles.round;

%secure Data
subjectData = handles.subjectData;
filepath = [handles.saveFolder, 'Backups\'];
filename = ['backupAfterRound_', num2str(handles.round)];
save([filepath, filename],'subjectData')

%update Round
handles.round = handles.round + 1;
guidata(hObject, handles)

%Finished?  
if handles.round > handles.maxRounds
    finishLT(hObject, handles)
    return
end

%update text beneath start button
str = ['Round ' num2str(handles.round)];
set(handles.textStart, 'String', str)

%Break every second Round (but not after Training)
if mod(handles.subjectData.lastAbsolvedRound, 2) == 0 && handles.subjectData.lastAbsolvedRound ~= 0
    pauseListeningTest(handles.pauseTime, handles);
end

% changeColor('green', handles)
chooseLayer('start', handles)

%Keyboard Callback (Alternative to Pushbuttons
function keyPress_Callback(hObject, eventdata)

%These keys represent the three buttons during normal mode:
%Left Arrow, Down Arrow, Right Arrow
%    A           OK           B

handles = guidata(hObject);
buttonsDisabled = handles.buttonsDisabled;
key = eventdata.Key;

%Check which key was pressed and if refering button is disabled
if strcmp(key, 'leftarrow') && ~buttonsDisabled(1)
    pushA_Callback(handles.pushA, 0, handles)
    
elseif strcmp(key, 'rightarrow') && ~buttonsDisabled(2)
    pushB_Callback(handles.pushB, 0, handles)
    
elseif strcmp(key, 'y') && ~buttonsDisabled(3)
    pushOK_A_Callback(handles.pushOK_A, 0, handles)
    
    elseif strcmp(key, 'x') && ~buttonsDisabled(4)
    pushOK_B_Callback(handles.pushOK_B, 0, handles)
end

% --- Executes on push press in pushA.
function pushA_Callback(hObject, eventdata, handles)

handles.pressedButton = 'A';
guidata(hObject, handles)
uiresume(handles.figure1)

% --- Executes on push press in pushB.
function pushB_Callback(hObject, eventdata, handles)

handles.pressedButton = 'B';
guidata(hObject, handles)
uiresume(handles.figure1)

% --- Executes on push press in pushOK_A.
function pushOK_A_Callback(hObject, eventdata, handles)

handles.pressedButton = 'Diff. A';
guidata(hObject, handles)
uiresume(handles.figure1)

function pushOK_B_Callback(hObject, eventdata, handles)
% hObject    handle to pushOK_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pressedButton = 'Diff. B';
guidata(hObject, handles)
uiresume(handles.figure1)

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if handles.allowClosing
    delete(hObject);
else
    button = questdlg({'The Listining Test is not finished yet!';'Do you really want to quit?'},'Close Request','Yes','No','No');
    if strcmp(button, 'Yes')
        delete(hObject)
    end
end


% --- Executes on button press in pushOK_B.
