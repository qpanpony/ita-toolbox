function varargout = ita_binauralMAA_Gui(varargin)
% ITA_BINAURALMAA_GUI MATLAB code for ita_binauralMAA_Gui.fig
%      ITA_BINAURALMAA_GUI, by itself, creates a new ITA_BINAURALMAA_GUI or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ITA_BINAURALMAA_GUI returns the handle to a new ITA_BINAURALMAA_GUI or the handle to
%      the existing singleton*.
%
%      ITA_BINAURALMAA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITA_BINAURALMAA_GUI.M with the given input arguments.
%
%      ITA_BINAURALMAA_GUI('Property','Value',...) creates a new ITA_BINAURALMAA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_binauralMAA_Gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_binauralMAA_Gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_binauralMAA_Gui

% Last Modified by GUIDE v2.5 05-Jun-2014 09:30:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_binauralMAA_Gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_binauralMAA_Gui_OutputFcn, ...
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


% --- Executes just before ita_binauralMAA_Gui is made visible.
function ita_binauralMAA_Gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_binauralMAA_Gui (see VARARGIN)

% Choose default command line output for ita_binauralMAA_Gui
handles.output = 0;

%% Data Initialization
% Init personal data

%shuffle randoms
rng('shuffle')

%check for input
if isempty(varargin)
    
    handles.subjectData = ita_binauralMAA_subjectData;
    
    %check if data was submitted correctly, otherwise close GUI
    if ~isa(handles.subjectData, 'struct')
        handles.allowClosing = 1;
        guidata(hObject, handles)
        close(handles.figure1)
        return
    end
    handles.subjectData.preferedSide = [];      %after training source is only located on that side
    handles.subjectData.lastAbsolvedRound = [];  %last Round that has been completed by the subject
    handles.round = -1;                         %actual test-round (-1=first Traininground, 0=second Traininground)
    
    %randomly choose first side for Training
    handles.subjectData.firstTrainingSide = randi(0:1); %1=right, 0=left
    
elseif length(varargin) == 1
    if ~isa(varargin{1}, 'struct')
        error('input must be empty or a subjectData-struct')
    end
    handles.subjectData = varargin{1};
    handles.round = handles.subjectData.lastAbsolvedRound + 1;
else
   error('input must be empty or a subjectData-struct')
end

%..........................................................................
%..........................................................................
%Folder for Results and backups
%..........................................................................
path_listeningTest = [ita_toolbox_path '\applications\ListeningTests\Relative MAA\'];
% handles.saveFolder = [path_listeningTest  'Saves\'];
% if exist(handles.saveFolder,'dir') ==0,     mkdir(handles.saveFolder)
% end
handles.irFolder = [ path_listeningTest 'IRdata\'];
if exist(handles.irFolder,'dir') ==0,     
    mkdir(handles.irFolder)
    warndlg('No impulse responses found! Please copy them into the IRdata folder.','!! Warning !!')
end
handles.backupFolder = [ path_listeningTest 'Backups\'];
if exist(handles.backupFolder,'dir') ==0,     mkdir(handles.backupFolder)
end
handles.resultFolder = [ path_listeningTest 'Results\'];
if exist(handles.resultFolder,'dir') ==0,     mkdir(handles.resultFolder)
end



%..........................................................................
%..........................................................................
% Repetition and pause
%..........................................................................
%LT parameters
handles.maxRounds = 4;      %number of test-rounds
handles.roundLength = 10;   %n of signals per round, must be a multiple of 10
handles.pauseTime = 3;     %time between rounds in seconds
%handles.round              %actual test-round (-1=first Traininground, 0=second Traininground)
%..........................................................................


%used to prevent closing GUI unintentionally
handles.allowClosing = 0;

%loaded data from an already finished LT? Then Close GUI
if handles.round > handles.maxRounds
   handles.allowClosing = 1;
   guidata(hObject, handles)
   close(handles.figure1)
   msgbox('Loaded data is from an already finished LT', 'Choose a different dataset')
   return
end

%variables for groups
handles.groupPerm = perms(1:handles.maxRounds);
handles.group = str2double(handles.subjectData.group);

%used for buttons in normal Mode
handles.pressedButton = [];
handles.buttonsEnabled = 0;

%vars for adaptation
handles.correctInRow = 0;
handles.refAngle = 6;
handles.refAngleTrain = 4;

%Permutation Vectors
a = -2*ones(1, handles.roundLength/5);
b = -1*ones(1, handles.roundLength/5);
c = zeros(1, handles.roundLength/5);
d = ones(1, handles.roundLength/5);
e = 2*ones(1, handles.roundLength/5);
handles.spreadS1Angles = [a,b,c,d,e];   %used for small moving of the first source

a = -1*ones(1,handles.roundLength/2);
b = ones(1,handles.roundLength/2);
handles.s2Sides = [a,b];                %used to decide if second source is left or right of the first

%soundfiles
% handles.folder = 'C:\Users\pschaefer\Desktop\';
% handles.folder = '\\verdi\Scratch\bomhardt\fürPhilipp\WillemLT_GUI\SimulierteIRsNeu\';



% handles.folder = [fileparts(which('ita_binauralMAA_Gui')) '\IRdata\'];
handles.stimulus = ita_read([handles.irFolder, 'pinkNoise.ita']);
handles.roomTrainingIR = ita_read([handles.irFolder, 'IR_MAA_100.ita']);
% handles.roomTrainingIR = ita_read([handles.folder, 'IR_MAA_79.ita']);
handles.room75IR = ita_read([handles.irFolder, 'IR_MAA_75.ita']);         %room 1
handles.room79IR = ita_read([handles.irFolder, 'IR_MAA_79.ita']);         %room 2
handles.room83IR = ita_read([handles.irFolder, 'IR_MAA_83.ita']);         %room 3
handles.room86IR = ita_read([handles.irFolder, 'IR_MAA_86.ita']);         %room 4

% Update handles structure
guidata(hObject, handles);

%% Initialize Graphics

%Figure position and size
set(handles.figure1, 'Units', 'pixels')
scrsz = get(0,'ScreenSize');
maxWidth = scrsz(3);
maxHeight = scrsz(4);
figsize = get(handles.figure1, 'OuterPosition');
width = figsize(3);
height = figsize(4);

position = [(maxWidth-width)/2, (maxHeight-height)/2, width, height]; %[left, bottom, width, height]
set(handles.figure1,'Position', position)

%Change Layer/Color
chooseLayer('start', handles)
changeColor('green', handles)

%update text beneath start button
if handles.round == -1
    if handles.subjectData.firstTrainingSide
        str = 'Training for right Side';
    else
        str = 'Training for left Side';
    end
elseif handles.round == 0
    if handles.subjectData.firstTrainingSide
        str = 'Training for left Side';
    else
        str = 'Training for right Side';
    end
else
    str = ['Round ' num2str(handles.round)];
end
set(handles.textStart, 'String', str)
 set(handles.figure1,'WindowKeyPressFcn',@figure1_WindowKeyPressFcn)
% UIWAIT makes ita_binauralMAA_Gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_binauralMAA_Gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = 0;

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
        set(handles.textWaitTime, 'Visible', 'on')
        set(handles.pushStart, 'Visible', 'off')
        set(handles.textStart, 'Visible', 'off')
        set(handles.pushLeft, 'Visible', 'off')
        set(handles.pushRight, 'Visible', 'off')
        set(handles.pushRepeat, 'Visible', 'off')
        set(handles.textSamples, 'Visible', 'off')
        set(handles.textSampleCounter, 'Visible', 'off')
         set(handles.figure1,'WindowKeyPressFcn',@figure1_WindowKeyPressFcn)
        
    case 'start'
        set(handles.textWaitTime, 'Visible', 'off')
        set(handles.pushStart, 'Visible', 'on')
        set(handles.textStart, 'Visible', 'on')
        set(handles.pushLeft, 'Visible', 'off')
        set(handles.pushRight, 'Visible', 'off')
        set(handles.pushRepeat, 'Visible', 'off')
        set(handles.textSamples, 'Visible', 'off')
        set(handles.textSampleCounter, 'Visible', 'off')
        set(handles.figure1,'WindowKeyPressFcn',@figure1_WindowKeyPressFcn)
        
    case 'normal'
        set(handles.textWaitTime, 'Visible', 'off')
        set(handles.pushStart, 'Visible', 'off')
        set(handles.textStart, 'Visible', 'off')
        set(handles.pushLeft, 'Visible', 'on')
        set(handles.pushRight, 'Visible', 'on')
        set(handles.pushRepeat, 'Visible', 'on')
        set(handles.textSamples, 'Visible', 'on')
        set(handles.textSampleCounter, 'Visible', 'on')
        set(handles.figure1,'WindowKeyPressFcn',@figure1_WindowKeyPressFcn)
        
    otherwise %do nothing
end

function changeColor (color, handles)

%Changes the color of several buttons
%possible input for color:
%yellow, red, green

if ~isa(color, 'char')
    msgbox('first input has to be a string!')
    return
end

if strcmp(color, 'yellow') || strcmp(color, 'red') || strcmp(color, 'green')
    
    set(handles.pushStart, 'BackgroundColor', color)
    set(handles.pushLeft, 'BackgroundColor', color)
    set(handles.pushRight, 'BackgroundColor', color)
   
else
    msgbox('possible input for color: yellow, red, green')
end

function disableButtons(handles)

set(handles.pushRight,'Enable','off')
set(handles.pushLeft,'Enable','off') 
set(handles.pushRepeat,'Enable','off')

function enableButtons(handles)

set(handles.pushRight,'Enable','on')
set(handles.pushLeft,'Enable','on') 
set(handles.pushRepeat,'Enable','on')

%% Signalfunctions

function [index] =  findAngleInIR(arrayIR, angle)

%Finds a specific HRTF angle in an array of IRs

coord = arrayIR.channelCoordinates.n(1:2:arrayIR.dimensions);

[~, index] = min(abs(angle-mod(coord.phi_deg,360)));
% if angle == 288
%    disp('huhu') 
% end

if isempty(index)
    msgbox(['The angle ', num2str(angle), 'was not found for this room'])
end


%% LT functions

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

changeColor('green', handles)
chooseLayer('start', handles)

function countdownBeforeRound(handles)

%Starts a Countdown of three seconds
%Should be used before each round

chooseLayer('pause', handles)
set(handles.textWaitTime, 'backgroundcolor', 'red')

time = 3;
str = get(handles.textWaitTime, 'String');
str{1} = 'Round starts in:';
str{3} = '3';

while(time >= 0)
  
    str{3} = num2str(time);
    
    set(handles.textWaitTime, 'String', str)
    if time == 1
        set(handles.textWaitTime, 'backgroundcolor', 'yellow')
    end
    if time == 0
        set(handles.textWaitTime, 'backgroundcolor', 'green')
    end
    
    pause(1)
    time = time-1;
end

function calcPreferedSide(hObject, handles)

%calculates the prefered side for the first source
%after the second Trainingrounds

resultRight = handles.subjectData.resultTrainRight;
resultLeft = handles.subjectData.resultTrainLeft;

anglesRight = resultRight(:,3);
anglesLeft = resultLeft(:,3);

maaRight = calcMAA(anglesRight);
maaLeft = calcMAA(anglesLeft);

if maaLeft < maaRight
    preferedSide = 'left';
else
    preferedSide = 'right';
end

if isinf(maaRight)% added by rbo
    preferedSide = 'left';
elseif isinf(maaLeft)
    preferedSide = 'right';
end

handles.subjectData.preferedSide = preferedSide;
guidata(hObject, handles)

function [maa] = calcMAA(angles)

%calculates MAA of a vector of angles using midrun

idxFalling = find(diff(angles) ==-1);
idxRaising = find(diff(angles) ==1);
midrunAngles = zeros(1,length(idxFalling));

rememberRaisedIdx = 0;

for k = 1:length(idxFalling)
    %next idx after the actual fall, where angles raises again
    idxRaiseAfterFall = idxRaising(find(idxRaising > idxFalling(k), 1));
    
    %angles ends falling
    if isempty(idxRaiseAfterFall)
        midrunAngles(k) = ( angles(idxFalling(k)) + angles(end) ) / 2;
    %check for multiple fallings in a row
    elseif rememberRaisedIdx ~= idxRaiseAfterFall
        rememberRaisedIdx = [rememberRaisedIdx, idxRaiseAfterFall];    
        midrunAngles(k) = ( angles(idxFalling(k)) + angles(idxRaiseAfterFall) ) / 2;
    end
end

%delete zeros
emptyIdx = find(midrunAngles == 0);
midrunAngles(emptyIdx) = [];

maa = mean(midrunAngles);

function trainingRound(side, hObject, handles)
%% Init Round

%graphic
chooseLayer('pause', handles)
set(handles.textWaitTime, 'backgroundcolor', 'red')
str = get(handles.textWaitTime, 'String');
str{1} = 'Be patient!';
str{3} = 'Prepairing sounds...';
set(handles.textWaitTime, 'String', str);

pause(0.1)

if strcmp(side, 'right')
    basisAngle = -60 + 360;
    possibleAngles = [288:312];
elseif strcmp(side, 'left')
    basisAngle = 60;
    possibleAngles = [48:72];
else
    error('wrong input for side (only right and left)')
end

%calc rand order for sources
refAngle = handles.refAngleTrain;       %Angle between S1 and S2
spreadS1Angles = handles.spreadS1Angles(randperm(handles.roundLength)); %varies s1Angle
s2Sides = handles.s2Sides(randperm(handles.roundLength));               %S1 left or right of S2?

%calc source positions
s1Angles = basisAngle + spreadS1Angles;

%convolve signals
signals = itaAudio(length(possibleAngles), 1);   %TODO: define sizes before filling arrays

mergedIR = handles.roomTrainingIR.merge;

for idxAngles = 1:length(possibleAngles)    
    indexInIR = findAngleInIR(mergedIR, possibleAngles(idxAngles));
    signals(idxAngles) = ita_convolve(handles.roomTrainingIR(indexInIR), handles.stimulus);    
end

correctInRow = 0;    %3 correct ans => refAngle sinks

resultTrain = zeros(handles.roundLength,5);             %matrix-row-scheme: firstAngle, secondAngle, refAngle(only positive),...
                                                        %                   side (-1: right, 1: left), correct?

%Fill result matrix
resultTrain(:, 1) = s1Angles;
resultTrain(:, 4) = s2Sides;

%% start Countdown
countdownBeforeRound(handles)

%set graphic to normal
disableButtons(handles)
changeColor('red', handles)
chooseLayer('normal', handles)


%% Start TrainingRound
%Loop over all the signals
for idx = 1:handles.roundLength
    
    %Refresh SampleCounter
    set(handles.textSampleCounter, 'String', num2str(handles.roundLength + 1 - idx))
    
    %calc second Angle and Signal indices
    s2Angle = s1Angles(idx) + s2Sides(idx)*refAngle;
    idxS1 = s1Angles(idx) - possibleAngles(1) + 1;      %=> idxS1=1 means minimum possible Angle
    idxS2 = s2Angle - possibleAngles(1) + 1;
    
    %Listen to Signals maybe repeat them
    while isempty(handles.pressedButton) || strcmp(handles.pressedButton, 'repeat')
 
        signals(idxS1).play()
        pause(0.1)
        signals(idxS2).play()
        
        %activate Buttons and wait for userinput
        enableButtons(handles)
        changeColor('green', handles)
        uiwait
        
        %get pressed button
        handles = guidata(hObject);
        
        if strcmp(handles.pressedButton, 'repeat')
           set(handles.pushRepeat, 'Visible', 'off')    %only one repeat!
%            set(handles.textSampleCounter, 'String', '2')  %refresh LoopCounter
        end
        
        disableButtons(handles)
        changeColor('red', handles)        
    end
    
    %Check if answer is correct
    if strcmp(handles.pressedButton, 'left')
        pressedButton = 1;        
    elseif strcmp(handles.pressedButton, 'right')
        pressedButton = -1;
    else
        error('pressedButton should only be left or right here')
    end
    
    isCorrect = pressedButton==s2Sides(idx);
    
    %save Data in struct
    resultTrain(idx, 2) = s2Angle;
    resultTrain(idx, 3) = refAngle;
    resultTrain(idx, 5) = isCorrect;
    
    %Adaptation
    if isCorrect
        correctInRow = correctInRow+1;
        if correctInRow == 3;
            refAngle = max(refAngle-1, 1);  %reduce refAngle (but refAngle >= 1)
            correctInRow = 0;
        end
    else
        refAngle = min(refAngle+1, 10);  %increase refAngle (but refAngle <= 10)
        correctInRow = 0;
    end        
    

    %Reset things
    set(handles.pushRepeat, 'Visible', 'on') 
    handles.pressedButton = [];
    guidata(hObject, handles);
    
end


if strcmp(side, 'right')
    handles.subjectData.resultTrainRight = resultTrain;
else
    handles.subjectData.resultTrainLeft = resultTrain;
end

guidata(hObject, handles);

function startNextRound(hObject, handles)
%% Init Round

%graphic
chooseLayer('pause', handles)
set(handles.textWaitTime, 'backgroundcolor', 'red')
str = get(handles.textWaitTime, 'String');
str{1} = 'Be patient!';
str{3} = 'Prepairing sounds...';
set(handles.textWaitTime, 'String', str);

pause(0.1)

if strcmp(handles.subjectData.preferedSide, 'right')
    basisAngle = -60 + 360;
    possibleAngles = [288:312];
elseif strcmp(handles.subjectData.preferedSide, 'left')
    basisAngle = 60;
    possibleAngles = [48:72];
else
    error('wrong data in subjectData.preferedSide (only right and left)')
end

%calc rand order for sources
refAngle = handles.refAngleTrain;       %Angle between S1 and S2
spreadS1Angles = handles.spreadS1Angles(randperm(handles.roundLength)); %varies s1Angle
s2Sides = handles.s2Sides(randperm(handles.roundLength));               %S1 left or right of S2?

s1Angles = basisAngle + spreadS1Angles;
% s2Angles = s1Angles + refAngle.*s2Sides;

%convolve signals
room = handles.groupPerm(handles.group,handles.round);
signals = itaAudio(length(possibleAngles), 1);   %TODO: define sizes before filling arrays

switch (room)
    case 1
        roomIR = handles.room75IR;
    case 2
        roomIR = handles.room79IR;
    case 3
        roomIR = handles.room83IR;
    case 4
        roomIR = handles.room86IR;
end

%mergedIR = handles.roomIR.merge; %rbo what's this??
mergedIR = roomIR.merge; %new

for idxAngles = 1:length(possibleAngles)    
    indexInIR = findAngleInIR(mergedIR, possibleAngles(idxAngles));
    signals(idxAngles) = ita_convolve(roomIR(indexInIR), handles.stimulus);    
end

correctInRow = 0;    %3 correct ans => refAngle sinks

result = zeros(handles.roundLength,5);             %matrix-row-scheme: firstAngle, secondAngle, refAngle(only positive),...
                                                   %                   side (-1: right, 1: left), correct?

%Fill result matric
result(:, 1) = s1Angles;
result(:, 4) = s2Sides;

%% start Countdown
countdownBeforeRound(handles)

%set graphic to normal
disableButtons(handles)
changeColor('red', handles)
chooseLayer('normal', handles)


%% Start Round
%Loop over all the signals
for idx = 1:handles.roundLength
    
    %Refresh LoopCounter
    set(handles.textSampleCounter, 'String', num2str(handles.roundLength + 1 - idx))
    
    %calc second Angle and Signal indices
    s2Angle = s1Angles(idx) + s2Sides(idx)*refAngle;
    idxS1 = s1Angles(idx) - possibleAngles(1) + 1;      %=> idxS1=1 means minimum possible Angle
    idxS2 = s2Angle - possibleAngles(1) + 1;
    
    %Listen to Signals maybe repeat them
    while isempty(handles.pressedButton) || strcmp(handles.pressedButton, 'repeat')
 
        signals(idxS1).play()
        pause(0.1)
        signals(idxS2).play()
        
        %activate Buttons and wait for userinput
        enableButtons(handles)
        changeColor('green', handles)
        uiwait
        
        %get pressed button
        handles = guidata(hObject);
        
        if strcmp(handles.pressedButton, 'repeat')
           set(handles.pushRepeat, 'Visible', 'off')    %only one repeat!
%            set(handles.textSampleCounter, 'String', '2')  %refresh LoopCounter
        end
        
        disableButtons(handles)
        changeColor('red', handles)        
    end
    
    %Check if answer is correct
    if strcmp(handles.pressedButton, 'left')
        pressedButton = 1;        
    elseif strcmp(handles.pressedButton, 'right')
        pressedButton = -1;
    else
        error('pressedButton should only be left or right here')
    end
    
    isCorrect = pressedButton==s2Sides(idx);
    
    %save Data in struct
    result(idx, 3) = refAngle;
    result(idx, 2) = s2Angle;
    result(idx, 5) = isCorrect;
    
    %Adaptation
    if isCorrect
        correctInRow = correctInRow+1;
        if correctInRow == 3;
            refAngle = max(refAngle-1, 1);  %reduce refAngle (but refAngle >= 1)
            correctInRow = 0;
        end
    else
        refAngle = min(refAngle+1, 10);  %increase refAngle (but refAngle <= 10)
        correctInRow = 0;
    end        
    
    
    %Reset things
    set(handles.pushRepeat, 'Visible', 'on') 
    handles.pressedButton = [];
    guidata(hObject, handles);
    
end

%update handles
switch(room)
    case 1
        handles.subjectData.resultRoom75 = result;
    case 2
        handles.subjectData.resultRoom79 = result;
    case 3
        handles.subjectData.resultRoom83 = result;
    case 4
        handles.subjectData.resultRoom86 = result;
end

guidata(hObject, handles);

function finishLT(hObject, handles)

%Graphics
str = {'The Listening Test is now finished';'';'Thanks for your participation!'};
set(handles.textWaitTime, 'String', str)
chooseLayer('pause', handles)
changeColor('green', handles)

%savefile
subjectData = handles.subjectData;
filepath = handles.resultFolder;


filename = ['resultMAA_', subjectData.date, '_', subjectData.time]; %filescheme: resultMAA_date_time
idxColon = strfind(filename, ':');
filename(idxColon) = '-';
save([filepath, filename],'subjectData')

%Closing the GUI is now allowed
handles.allowClosing = 1;
guidata(hObject, handles)

pause(5)

%close GUI
close(handles.figure1)


% --- Executes on button press in pushStart.
function pushStart_Callback(hObject, eventdata, handles)

%first Traininground
if handles.round == -1
    if handles.subjectData.firstTrainingSide        
        trainingRound('right', hObject, handles);
    else
        trainingRound('left', hObject, handles);
    end
    
%second Traininground
elseif handles.round == 0
    if handles.subjectData.firstTrainingSide
        trainingRound('left', hObject, handles);
    else
        trainingRound('right', hObject, handles);
    end
    
    %update handles and calculate prefered Side
    handles = guidata(hObject);
    calcPreferedSide(hObject, handles)
    
%normal Rounds    
elseif handles.round <= handles.maxRounds
    if handles.round == 1
        questdlg(['From now on Sound will only come from ', handles.subjectData.preferedSide, ' Side'], ...
            'Information on regular rounds', ...
            'OK','OK');
    end
    startNextRound(hObject, handles)
end

%update handles
handles = guidata(hObject);

%Round absolved!
handles.subjectData.lastAbsolvedRound = handles.round;

%secure Data
subjectData = handles.subjectData;
filepath = handles.backupFolder;
filename = ['backupAfterRound_', num2str(handles.round)];
save([filepath, filename],'subjectData')

%update Round
handles.round = handles.round + 1;
guidata(hObject, handles)

%Finished?  
if handles.round > 4
    finishLT(hObject, handles)
    return
end

%update text beneath start button
if handles.round == 0
    if handles.subjectData.firstTrainingSide
        str = 'Training for left Side';
    else
        str = 'Training for right Side';
    end
else
    str = ['Round ' num2str(handles.round)];
end
set(handles.textStart, 'String', str)

%break between Rounds
pauseListeningTest(handles.pauseTime, handles);

% --- Executes on button press in pushLeft.
function pushLeft_Callback(hObject, eventdata, handles)

% if handles.buttonsEnabled == 0
%     return
% end

handles.pressedButton = 'left';
guidata(hObject, handles)
uiresume(handles.figure1)

% --- Executes on button press in pushRight.
function pushRight_Callback(hObject, eventdata, handles)

% if handles.buttonsEnabled == 0
%     return
% end

handles.pressedButton = 'right';
guidata(hObject, handles)
uiresume(handles.figure1)


% --- Executes on button press in pushRepeat.
function pushRepeat_Callback(hObject, eventdata, handles)

% if handles.buttonsEnabled == 0
%     return
% end

handles.pressedButton = 'repeat';
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


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(varargin)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(varargin{1,2}.Key, 'leftarrow')
    pushLeft_Callback(varargin{:})
elseif strcmp(varargin{1,2}.Key, 'rightarrow')
    pushRight_Callback(varargin{:})
elseif strcmp(varargin{1,2}.Key, 'uparrow')
    pushRepeat_Callback(varargin{:})
end