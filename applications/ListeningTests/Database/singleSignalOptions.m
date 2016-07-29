function varargout = singleSignalOptions(varargin)
% SINGLESIGNALOPTIONS MATLAB code for singleSignalOptions.fig
%      SINGLESIGNALOPTIONS, by itself, creates a new SINGLESIGNALOPTIONS or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = SINGLESIGNALOPTIONS returns the handle to a new SINGLESIGNALOPTIONS or the handle to
%      the existing singleton*.
%
%      SINGLESIGNALOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLESIGNALOPTIONS.M with the given input arguments.
%
%      SINGLESIGNALOPTIONS('Property','Value',...) creates a new SINGLESIGNALOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before singleSignalOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to singleSignalOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help singleSignalOptions

% Last Modified by GUIDE v2.5 07-May-2013 10:27:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @singleSignalOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @singleSignalOptions_OutputFcn, ...
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


% --- Executes just before singleSignalOptions is made visible.
function singleSignalOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.


% Choose default command line output for singleSignalOptions
handles.output = hObject;

signal = varargin{1}{1};
handles.signal = signal;
handles.filepath = varargin{1}{2};

%Plot
signal.plot_spectrogram( 'figure_handle',handles.figure1,'axes_handle',handles.axes)

%Initiation
handles.lowFreq = 50;
handles.highFreq = 22000;
handles.length = min(3, signal.trackLength);
set(handles.editLength, 'String', num2str(handles.length))
handles.rateFreq = 0;
handles.sortOut = 0;

handles.signalSegment = 0;
handles.energyOctave = 0;
handles.energyTerz = 0;
handles.energyOctaveFull = 0;
handles.energyTerzFull = 0;
handles.segmentTimes = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes singleSignalOptions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = singleSignalOptions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%Functions

function tooltips(handles, headline, tooltip)

tooltip = {headline; tooltip};
set(handles.textTooltips, 'String', tooltip)

function energy = freqRating(energy, rating, rateFreqs)


for k = 1:length(energy.freq)
    if energy.freqVector(k) < (rateFreqs(1)+rateFreqs(2))/2
        energy.freq(k, :) = energy.freq(k, :) * rating(1);
        break
    end
    
        
    if energy.freqVector(k) >= (rateFreqs(end)+rateFreqs(end-1))/2
        energy.freq(k, :) = energy.freq(k, :) * rating(end);
        break
    end
    
    for i = 2:length(rating)-1
        if energy.freqVector(k) >= (rateFreqs(i-1)+rateFreqs(i))/2 && energy.freqVector(k) < (rateFreqs(i)+rateFreqs(i+1))/2
            energy.freq(k, :) = energy.freq(k, :) * rating(i);
            break
        end
    end

    
end

function [energyOctave] = energyRating(handles, signal)

lowFreq = handles.lowFreq;
highFreq = handles.highFreq;

energyOctave = ita_spk2frequencybands(signal,'bandsperoctave',1,'method','added','freqRange',[lowFreq highFreq]);
% energyTerz = ita_spk2frequencybands(signal,'bandsperoctave',3,'method','added','freqRange',[lowFreq highFreq]);

function [enoughEnergy] = isEnoughEnergy(energy)

avEnergy = mean(energy.freq);
energyDiff = abs(bsxfun(@minus, energy.freq ,avEnergy));

if energyDiff/avEnergy > 0.1
    enoughEnergy = 0;
else
    enoughEnergy = 1;
end


function [signal, segmentTimes] = segmentSignal(handles, jumpDiscont, signal)

%calc Windowparameter
endRise = jumpDiscont/signal.samplingRate;

if (handles.length == 0 || handles.length+endRise > signal.trackLength)
    endFall = signal.trackLength;
    
    windowEdges = (endFall-endRise)/20;
    if windowEdges > 0.1
        windowEdges = 0.1;
    end
    
    startFall = endFall-windowEdges;
    startRise = endRise-windowEdges;
    if startRise < 0
        startRise = 0;
    end
    
else
    startFall = endRise+handles.length;
    windowEdges = (startFall-endRise)/20;
    if windowEdges > 0.1
        windowEdges = 0.1;
    end
    
    startRise = endRise-windowEdges;
    if startRise < 0
        startRise = 0;
    end
    
    endFall = startFall+windowEdges;
    if endFall > signal.trackLength
        endFall = signal.trackLength;
    end
    
end

segmentTimes = [startRise, endFall];

%Use Window
signal = ita_time_window(signal,[endRise startRise startFall endFall],@hann,'time');

%shorten Signal
startSample = round(startRise*signal.samplingRate);
endSample = round(endFall*signal.samplingRate);
if endSample > signal.nSamples
    endSample = signal.nSamples;
end

signal.time = signal.time(startSample:endSample, :);





%% Callbacks

% --- Executes on button press in buttonPlay.
function buttonPlay_Callback(hObject, eventdata, handles)

signalNum = get(handles.popupSegment, 'Value');

if signalNum == 1
    signal = handles.signal;
else
    signal = handles.signalSegment{signalNum-1};
end

signal.play()


% --- Executes on button press in buttonAnalyse.
function buttonAnalyse_Callback(hObject, eventdata, handles)

signal = handles.signal;

%% Build Sample-Groups

maxSamples = signal.nSamples;
samplingRate = signal.samplingRate;
lengthSampleGroups = 400; %in samples

nOfSampleGroups = floor(maxSamples/lengthSampleGroups);

% nOfSampleGroups = 100;
% lengthSampleGroups = floor(maxSamples/nOfSampleGroups);

absAmplitude = abs(signal.time);

avEnergy = sum(signal.time)/maxSamples*samplingRate;


sampleGroups = cell(1, nOfSampleGroups);
groupEnergy = zeros(1, nOfSampleGroups);

%Calculate Energy of sampleGroups
for k = 1:nOfSampleGroups
    
    sampleGroups{k} = absAmplitude(lengthSampleGroups*(k-1) + 1 : lengthSampleGroups*(k));
    groupEnergy(k) = sum(sampleGroups{k})/lengthSampleGroups*samplingRate;
end

%Find Jump-Discontinuities

%% Check relative Energy
%Calc Energydifferences
energyDiff = groupEnergy(2:end)- groupEnergy(1:end-1);
%scale differences
scaledDiff = energyDiff./groupEnergy(1:end-1);

% 900% Energyraise means possible jump
jumps = find(scaledDiff > 1);

%% Check absolute Energy

jumpEnergyDiff = energyDiff(jumps);
jumpEnergyDiff = find(jumpEnergyDiff/max(groupEnergy) > 0.01);

jumps = jumps(jumpEnergyDiff);

%% check Energy before jumps
if jumps(1) == 1
    jumpGroupEnergy =  [10, groupEnergy(jumps(2:end)-1)/max(groupEnergy)];
else
    jumpGroupEnergy =  groupEnergy(jumps-1)/max(groupEnergy);
end
jumpGroupEnergy = find(jumpGroupEnergy < 0.03);
jumps = jumps(jumpGroupEnergy);
    

% jumpDiscont = (jumps-1)*lengthSampleGroups + 1;

%% Check distance between jumps
k = 1;
distancedJumps = 1;
while k <= length(jumps)
    distance = abs(jumps(k:end)-jumps(k)) >= 0.05*samplingRate/lengthSampleGroups;
    distance = find(distance) + k - 1;
    
    if isempty(distance)
        break
    end
    
    k = distance(1);
    distancedJumps = [distancedJumps; k];    
end

jumps = jumps(distancedJumps);

%Get back from sample-groups to samples
jumpDiscont = (jumps-1)*lengthSampleGroups + 1;


%Energy of Full Signal
energyOctaveFull = ita_spk2frequencybands(signal,'bandsperoctave',1,'method','added','freqRange',[handles.lowFreq handles.highFreq]);
% energyTerzFull = ita_spk2frequencybands(signal,'bandsperoctave',3,'method','added','freqRange', [handles.lowFreq handles.highFreq]);

if ~isempty(jumpDiscont)
    
    signalSegment = cell(1, length(jumpDiscont));
    energyOctave = signalSegment;
%     energyTerz = signalSegment;
    enoughEnergy = zeros(1, length(jumpDiscont));
    segmentTimes = zeros(length(jumpDiscont), 2);

    waitbarHandle = waitbar(0,'Calculating energy of several signal-segments... Please be patient') ;
    
    for k = 1:length(jumpDiscont)
       [signalSegment{k}, segmentTimes(k, :)] = segmentSignal(handles, jumpDiscont(k), signal);
%        [energyOctave{k}, energyTerz{k}] = energyRating(handles, signalSegment{k});
       energyOctave{k} = energyRating(handles, signalSegment{k});
       waitbar(k/length(jumpDiscont)) 
    end
    
    close(waitbarHandle)
    

    %A-Rating
    rateFreqs = [32 63 125 250 500 1000 2000 4000 8000 16000];
    rating = [-39.4 -26.2 -16.1 -8.6 -3.2 0 1.2 1.0 -1.1 -6.6];
    rating = 10.^(rating/20);

    %rate Energylevels
    if handles.rateFreq == 1
        energyOctaveFull = freqRating(energyOctaveFull, rating, rateFreqs);
%         energyTerzFull = freqRating(energyTerzFull, rating, rateFreqs);
    end
    
    for k = 1:length(jumpDiscont)
        if handles.rateFreq == 1 
            energyOctave{k} = freqRating(energyOctave{k}, rating, rateFreqs);
%             energyTerz{k} = freqRating(energyTerz{k}, rating, rateFreqs);    
        end
        enoughEnergy(k) = isEnoughEnergy(energyOctave{k}); 
    end
    
    %Refresh Tooltip
    tooltips(handles, 'Tooltips:', ''); 
    
    %Sort out segments without enough energy
    if handles.sortOut == 1
        
        enoughEnergy = find(enoughEnergy);
        signalSegment = signalSegment(enoughEnergy);

        if isempty(enoughEnergy)
           tooltips(handles, 'Error:', 'Sorry, the energylevels are too low for your frequency settings'); 
        end
    end
    
    numOfSegments = length(signalSegment);
    
else
    numOfSegments = 0;
    tooltips(handles, 'Error:', 'Sorry, could not find any jump discontinuities');
end


%Update Guidata
%popup-Strings
string = get(handles.popupSegment, 'String');
if isa(string, 'char')
   string = {string};
else
   string = string(1);
end

set(handles.popupSegment, 'String', string)

for k = 1:numOfSegments
   string{k+1} = ['Signal-Segment ' num2str(k)];    
end
set(handles.popupSegment, 'String', string)

handles.energyOctaveFull = energyOctaveFull;
% handles.energyTerzFull = energyTerzFull;
handles.energyOctave = energyOctave;
% handles.energyTerz = energyTerz;
handles.signalSegment = signalSegment;
handles.segmentTimes = segmentTimes;
guidata(hObject, handles);

%Plots
set(handles.popupSegment, 'Value', 1)
popupSegment_Callback(handles.popupSegment, 0, handles)


% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)

prompt = {'Enter variable name:'};
dlg_title = 'Input for variable name';
num_lines = 1;
def = {'signal'};
signalName = inputdlg(prompt,dlg_title,num_lines,def);

signalNum = get(handles.popupSegment, 'Value');

%pressed ok?
if ~isempty(signalName)
    if signalNum == 1
        assignin('base', signalName{1}, handles.signal)
    else
        assignin('base', signalName{1}, handles.signalSegment{signalNum-1})
    end
end


% --- Executes on button press in buttonOpen.
function buttonOpen_Callback(hObject, eventdata, handles)

filepath = handles.filepath;

%cut off filename
backSlash = strfind(filepath, '\');
filepath = filepath(1:backSlash(end)-1);
        
%mac or windows?
if ismac
    macopen(filepath)
else
    winopen(filepath)
end



function editLength_Callback(hObject, eventdata, handles)

length = str2double(get(hObject, 'String'));
signal = handles.signal;
trackLength = signal.trackLength;

if ~isa(length, 'double')&&~isa(length, 'int')
    set(hObject, 'String', num2str(handles.length))
    tooltips(handles, 'Error:', 'Length must be a real positive number'); 
    return
elseif length < 0
    set(hObject, 'String', num2str(handles.length))
    tooltips(handles, 'Error:', 'Length must be a real positive number');
    return
elseif  length > trackLength
    length = trackLength;
    tooltips(handles, 'Tooltips:', 'You reached the maximum length / tracklength');
    set(hObject, 'String', num2str(length))
elseif  length > 3
    length = 3;
    tooltips(handles, 'Tooltips:', 'Length is limited to 3 seconds');
    set(hObject, 'String', num2str(length))
end

%Update data
handles.length = length;
guidata(hObject, handles);


function editLowFreq_Callback(hObject, eventdata, handles)

lowFreq = str2double(get(hObject, 'String'));
if ~isa(lowFreq, 'double')&&~isa(lowFreq, 'int')
    set(hObject, 'String', num2str(handles.lowFreq))
    tooltips(handles, 'Error:', 'Low Frequency must be a real positive number');
    return
% elseif lowFreq <= 0
%     set(hObject, 'String', num2str(handles.lowFreq))
%     return
end

if lowFreq <= 0
    lowFreq = 1;
    set(hObject, 'String', num2str(lowFreq))
elseif lowFreq > 11000
    lowFreq = 11000;
    set(hObject, 'String', num2str(lowFreq))
end

if handles.highFreq < 2*lowFreq
    handles.highFreq = 2*lowFreq;
    set(handles.editHighFreq, 'String', num2str(2*lowFreq))
    tooltips(handles, 'Tooltip:', 'High Frequency must be a minimum of two times of Low Frequency');
end

%Update data
handles.lowFreq = lowFreq;
guidata(hObject, handles);



function editHighFreq_Callback(hObject, eventdata, handles)

highFreq = str2double(get(hObject, 'String'));
if ~isa(highFreq, 'double')&&~isa(highFreq, 'int')
    set(hObject, 'String', num2str(handles.highFreq))
    tooltips(handles, 'Error:', 'High Frequency must be a real positive number');
    return
elseif highFreq < 0
    set(hObject, 'String', num2str(handles.highFreq))
    tooltips(handles, 'Error:', 'High Frequency must be a real positive number');
    return
end

if highFreq < 2*handles.lowFreq
    handles.lowFreq = highFreq/2;
    set(handles.editLowFreq, 'String', num2str(highFreq/2))
    tooltips(handles, 'Tooltip:', 'High Frequency must be a minimum of two times of Low Frequency');
end

if highFreq > 22000
    highFreq = 22000;
    set(hObject, 'String', num2str(highFreq))
end

%Update data
handles.highFreq = highFreq;
guidata(hObject, handles);

% --- Executes on selection change in popupSegment.
function popupSegment_Callback(hObject, eventdata, handles)
% hObject    handle to popupSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupSegment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSegment

nOfSegment = get(hObject, 'Value');

if nOfSegment == 1
    energyOctave = handles.energyOctaveFull;
%     energyTerz = handles.energyTerzFull;
    signal = handles.signal;
    set(handles.textStartTime, 'String', '')
    set(handles.textEndTime, 'String', '')
else
    energyOctave = handles.energyOctave{nOfSegment-1};
%     energyTerz = handles.energyTerz{nOfSegment-1};
    signal = handles.signalSegment{nOfSegment-1};
    string1 = ['Start      ' num2str(handles.segmentTimes(nOfSegment-1, 1))];
    string2 = ['End        ' char(13), num2str(handles.segmentTimes(nOfSegment-1, 2))];
    set(handles.textStartTime, 'String', string1)
    set(handles.textEndTime, 'String', string2)
end


energyOctave.bar('figure_handle',handles.figure1, 'axes_handle', handles.axesOctave)
title(handles.axesOctave, 'Added Power in Octavebands')
% energyTerz.bar('figure_handle',handles.figure1, 'axes_handle', handles.axesTerz)
% title(handles.axesTerz, 'Added Power in Terzbands')
signal.plot_spectrogram('figure_handle',handles.figure1,'axes_handle',handles.axes)



% --- Executes on button press in checkRateFreq.
function checkRateFreq_Callback(hObject, eventdata, handles)

handles.rateFreq = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in checkSortOut.
function checkSortOut_Callback(hObject, eventdata, handles)

handles.sortOut = get(hObject,'Value');
guidata(hObject, handles);


%% Create Functions

% --- Executes during object creation, after setting all properties.
function editLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editHighFreq_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editLowFreq_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function popupSegment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
