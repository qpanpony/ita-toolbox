function varargout = ita_GUICreateNoise(varargin)
% ITA_GUICREATENOISE MATLAB code for ita_GUICreateNoise.fig
%      ITA_GUICREATENOISE, by itself, creates a new ITA_GUICREATENOISE or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ITA_GUICREATENOISE returns the handle to a new ITA_GUICREATENOISE or the handle to
%      the existing singleton*.
%
%      ITA_GUICREATENOISE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITA_GUICREATENOISE.M with the given input arguments.
%
%      ITA_GUICREATENOISE('Property','Value',...) creates a new ITA_GUICREATENOISE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_GUICreateNoise_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_GUICreateNoise_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_GUICreateNoise

% Last Modified by GUIDE v2.5 23-May-2013 10:44:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_GUICreateNoise_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_GUICreateNoise_OutputFcn, ...
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


% --- Executes just before ita_GUICreateNoise is made visible.
function ita_GUICreateNoise_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for ita_GUICreateNoise
handles.output = hObject;

%Initiate Data
handles.amplitude = str2double(get(handles.editAmplitude , 'String'));
handles.startTime = str2double(get(handles.editStartTime , 'String'));
handles.length = str2double(get(handles.editLength , 'String'));

handles.startRise = str2double(get(handles.editStartRise , 'String'));
handles.endRise = str2double(get(handles.editEndRise , 'String'));
handles.startFall = str2double(get(handles.editStartFall , 'String'));
handles.endFall = str2double(get(handles.editEndFall , 'String'));

handles.repeatQuantity = str2double(get(handles.editRepeatQuantity , 'String'));
handles.repeatPause = str2double(get(handles.editRepeatPause , 'String'));

handles.sampleRate = 44100;
handles.noiseSignal = 0;

handles.lowFreq = str2double(get(handles.editLowFreq , 'String'));
handles.highFreq = handles.sampleRate/2;
set(handles.editHighFreq, 'String', num2str(handles.highFreq))

% Update handles structure
guidata(hObject, handles);

%Initialize Noise Signal
createSingleSignal(hObject, eventdata, handles)

% UIWAIT makes ita_GUICreateNoise wait for user response (see UIRESUME)
uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = ita_GUICreateNoise_OutputFcn(hObject, eventdata, handles) 
% return NoiseSignal
%varargout{1} = handles.noiseSignal;
%close(handles.figure1)

%% Functions

function createSingleSignal(hObject, eventdata, handles)

%Get Data
startRise = handles.startRise;
endRise = handles.endRise;
startFall = handles.startFall;
endFall = handles.endFall;
lowFreq = handles.lowFreq;
highFreq = handles.highFreq;

startTime = handles.startTime;

%Get windowType
popupNum = get(handles.popupWindowType,'Value');

switch popupNum
    case 1
        windowHandle = @bartlett;
    case 2
        windowHandle = @barthannwin;
    case 3
        windowHandle = @blackman;
    case 4
        windowHandle = @blackmanharris;
    case 5
        windowHandle = @bohmanwin;
    case 6
        windowHandle = @chebwin;
    case 7
        windowHandle = @flattopwin;
    case 8
        windowHandle = @gausswin;
    case 9
        windowHandle = @hamming;
    case 10
        windowHandle = @hann;
    case 11
        windowHandle = @kaiser;
    case 12
        windowHandle = @nuttallwin;
    case 13
        windowHandle = @parzenwin;
    case 14
        windowHandle = @rectwin;
    case 15
        windowHandle = @taylorwin;
    case 16
        windowHandle = @tukeywin;
    case 17
        windowHandle = @triang;
        
    otherwise
        windowHandle = @hann;
end

%Get noiseType
popupNum = get(handles.popupNoise,'Value');

switch popupNum
    case 1
        noiseType = 'noise';
    case 2
        noiseType = 'pinknoise';
    otherwise
        noiseType = 'noise';
end

%Calculate numOfBits
sampleRate = handles.sampleRate;
numOfSamples = endFall*sampleRate;
bits = round(log2(1.5*numOfSamples));


%Create simple noise
noiseSignal = ita_generate(noiseType,handles.amplitude,sampleRate,bits);

%Bandpassfilter
if lowFreq ~= 0 || highFreq ~= sampleRate/2
    noiseSignal = ita_mpb_filter(noiseSignal,[handles.lowFreq handles.highFreq]);
end

%Use Window
noiseSignal = ita_time_window(noiseSignal,[endRise startRise startFall endFall],windowHandle,'time');

%Extend Signal
noiseSignal = ita_extend_dat(noiseSignal,numOfSamples);

%Update GuiData
handles.noiseSignal = noiseSignal;
guidata(hObject, handles);

%Repeat Signal
if handles.repeatQuantity ~= 0
   noiseSignal = createRepeatedSignal(hObject, eventdata, handles);
end


%Extend and shift Signal to create StartTime
startSample = startTime*sampleRate;
noiseSignal = ita_extend_dat(noiseSignal,noiseSignal.nSamples + startSample);
noiseSignal = ita_time_shift(noiseSignal, startTime,'time');

%Update GuiData
handles.noiseSignal = noiseSignal;
guidata(hObject, handles);


plotSignal(hObject, eventdata, handles)

function [repeatedNoiseSignal] = createRepeatedSignal(hObject, eventdata, handles)
noiseSignal = handles.noiseSignal;
repeatPause = handles.repeatPause;
repeatQuantity = handles.repeatQuantity;
length = handles.length;
sampleRate = handles.sampleRate;

%Extend signal / Prepair to repeat signal
pauseSamples = repeatPause*sampleRate;
noiseSignal = ita_extend_dat(noiseSignal,noiseSignal.nSamples*(repeatQuantity+1) + repeatQuantity*pauseSamples);

repeatedNoiseSignal = noiseSignal;

%Repeat signal
for i = 1:repeatQuantity
    repeatedNoiseSignal = repeatedNoiseSignal + ita_time_shift(noiseSignal,i*(length + repeatPause),'time');
end

%Update GUIData
handles.noiseSignal = noiseSignal;
guidata(hObject, handles);

function plotSignal(hObject, eventdata, handles)
noiseSignal = handles.noiseSignal;

noiseSignal.plot_time( 'figure_handle',gcf,'axes_handle',handles.axesTime)
title( handles.axesTime, 'Plot over Time', 'FontSize', 12)
grid (handles.axesTime,'on')
noiseSignal.plot_freq( 'figure_handle',gcf,'axes_handle',handles.axesFreq)
title(handles.axesFreq, 'Plot over Frequency')
legend('hide')

function tooltip(handles, text)

set(handles.textInfo, 'String',{'Tooltips:' ; text})

function tooltipError(handles, text)

set(handles.textInfo, 'String',{'Error:' ; text})

%% Callback Functions

% --- Executes on button press in buttonPlay.
function buttonLoad_Callback(hObject, eventdata, handles)

prompt = {'Enter variable name:'};
dlg_title = 'Input for variable name';
num_lines = 1;
def = {'noise'};
signalName = inputdlg(prompt,dlg_title,num_lines,def);

%pressed ok?
if ~isempty(signalName)
    assignin('base', signalName{1}, handles.noiseSignal)
end



function buttonPlay_Callback(hObject, eventdata, handles)

noiseSignal = handles.noiseSignal;
noiseSignal.play


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)

noiseSignal = handles.noiseSignal;

button = questdlg('How do you want to save the noise:','Save noise...', 'mat-File', 'ita-File','Cancel','mat-File');

switch button
    case 'mat-File'
        [noiseFilename,noiseFilepath] = uiputfile('*.mat', 'Save noise as *.mat file');
        noiseFilename=[noiseFilepath,noiseFilename];
        save(noiseFilename, 'noiseSignal')
        tooltip(handles,['Saved noise in: ' noiseFilename '!']);
        
    case 'ita-File'
        [noiseFilename,noiseFilepath] = uiputfile('*.ita', 'Save noise as *.ita file');
        noiseFilename=[noiseFilepath,noiseFilename];
        % save data
        findIta = findstr(noiseFilename,'.ita');

        if isempty(findIta)
            tooltipError(handles, 'The file must be an *.ita file!');
            return
        end

        ita_write(noiseSignal,noiseFilename);
        tooltip(handles,['Saved noise in: ' noiseFilename '!']);
        
    otherwise
        tooltip(handles,'');
        return
end


function editStartRise_Callback(hObject, eventdata, handles)

startRise = str2double(get(handles.editStartRise, 'String'));
endRise = handles.endRise;
startFall = handles.startFall;
endFall = handles.endFall;

if startRise < 0 || imag(startRise) ~= 0
    set(hObject, 'String', num2str(handles.startRise))
    tooltipError(handles,'Start Rise Time must a positive real number')
    return
end

%Start Rise < End Rise < Start Fall < End Fall ?
if startRise > endFall
    handles.endRise = startRise;
    set(handles.editEndRise, 'String', num2str(startRise))
    handles.startFall = startRise;
    set(handles.editStartFall, 'String', num2str(startRise))
    handles.endFall = startRise;
    handles.length = startRise;
    set(handles.editLength, 'String', num2str(startRise))
    set(handles.editEndFall, 'String', num2str(startRise))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
elseif startRise > startFall
    handles.endRise = startRise;
    set(handles.editEndRise, 'String', num2str(startRise))
    handles.startFall = startRise;
    set(handles.editStartFall, 'String', num2str(startRise))  
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
elseif startRise > endRise
   handles.endRise = startRise;
   set(handles.editEndRise, 'String', num2str(startRise))
   tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
else
   tooltip(handles,'')
end

handles.startRise = startRise;

%Refresh Signal
createSingleSignal(hObject, eventdata, handles);


function editStartFall_Callback(hObject, eventdata, handles)

startRise = handles.startRise;
endRise = handles.endRise;
startFall = str2double(get(handles.editStartFall, 'String'));
endFall = handles.endFall;

if startRise < 0 || imag(startRise) ~= 0
    set(hObject, 'String', num2str(handles.startFall))
    tooltipError(handles,'Start Fall Time must a positive real number')
    return
end

%Start Rise < End Rise < Start Fall < End Fall ?
if startFall < startRise
    handles.startRise = startFall;
    set(handles.editStartRise, 'String', num2str(startFall))
    handles.endRise = startFall;
    set(handles.editEndRise, 'String', num2str(startFall))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
elseif startFall < endRise
    set(handles.editEndRise, 'String', num2str(startFall))
    handles.endRise = startFall;
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
elseif startFall > endFall
    set(handles.editEndFall, 'String', num2str(startFall))
    handles.endFall = startFall;
    handles.length = startFall;
    set(handles.editLength, 'String', num2str(startFall))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
else
   tooltip(handles,'')
end

handles.startFall = startFall;

%Refresh Signal
createSingleSignal(hObject, eventdata, handles);


function editEndRise_Callback(hObject, eventdata, handles)

%Start Rise < End Rise < Start Fall < End Fall ?
startRise = handles.startRise;
endRise = str2double(get(handles.editEndRise, 'String'));
startFall = handles.startFall;
endFall = handles.endFall;

if endRise < 0 || imag(endRise) ~= 0
    set(hObject, 'String', num2str(handles.endRise))
    tooltipError(handles,'End Rise Time must a positive real number')
    return
end

if endRise > endFall
    handles.endFall = endRise;
    set(handles.editEndFall, 'String', num2str(endRise))
    handles.length = endRise;
    set(handles.editLength, 'String', num2str(endRise))
    handles.startFall = endRise;
    set(handles.editStartFall, 'String', num2str(endRise))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
elseif endRise > startFall
    handles.startFall = endRise;
    set(handles.editStartFall, 'String', num2str(endRise))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
elseif endRise < startRise
    handles.startRise = endRise;
    set(handles.editStartRise, 'String', num2str(endRise))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
else
   tooltip(handles,'')
end

handles.endRise = endRise;


%Refresh Signal
createSingleSignal(hObject, eventdata, handles);


function editEndFall_Callback(hObject, eventdata, handles)

startRise = handles.startRise;
endRise = handles.endRise;
startFall = handles.startFall;
endFall = str2double(get(handles.editEndFall, 'String'));

if endFall < 0 || imag(endFall) ~= 0
    set(hObject, 'String', num2str(handles.endFall))
    tooltipError(handles,'End Fall Time must a positive real number')
    return
end

%Start Rise < End Rise < Start Fall < End Fall ?
if endFall < startRise
    handles.startRise = endFall;
    set(handles.editStartRise, 'String', num2str(endFall))
    handles.endRise = endFall;
    set(handles.editEndRise, 'String', num2str(endFall))
    handles.startFall = endFall;
    set(handles.editStartFall, 'String', num2str(endFall))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
elseif endFall < endRise
    handles.endRise = endFall;
    set(handles.editEndRise, 'String', num2str(endFall))
    handles.startFall = endFall;
    set(handles.editStartFall, 'String', num2str(endFall))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
elseif endFall < startFall
    handles.startFall = endFall;
    set(handles.editStartFall, 'String', num2str(endFall))
    tooltip(handles,'Start Rise < End Rise < Start Fall < End Fall')
else
   tooltip(handles,'')
end

handles.endFall = endFall;
handles.length = endFall;

%Refresh Signal
set(handles.editLength, 'String', num2str(endFall))

createSingleSignal(hObject, eventdata, handles);



function editLowFreq_Callback(hObject, eventdata, handles)

lowFreq = str2double(get(hObject, 'String'));
highFreq = handles.highFreq;

if isnan(lowFreq) || imag(lowFreq) ~= 0
   set(handles.editLowFreq, 'String', num2str(handles.lowFreq))
   tooltipError(handles,['High Frequency must be a real positive number between 0 and ' num2str(handles.sampleRate/2)])
   return
   
elseif lowFreq > handles.sampleRate/2
    set(handles.editLowFreq, 'String', num2str(handles.lowFreq))
    tooltip(handles,['Maximum frequency for filter is ' num2str(handles.sampleRate/2)])
    return
   
elseif lowFreq < 0
    lowFreq = 0;
    set(handles.editLowFreq, 'String', num2str(lowFreq))
    tooltip(handles,'Minimum frequency for filter is 0')
    
elseif lowFreq > highFreq
    set(handles.editHighFreq, 'String', num2str(lowFreq))
    handles.highFreq = lowFreq;
    tooltip(handles,'Low Frequency must me smaller than High Frequency')
else
   tooltip(handles,'')
end

handles.lowFreq = lowFreq;

%Refresh Signal
createSingleSignal(hObject, eventdata, handles);

function editHighFreq_Callback(hObject, eventdata, handles)

highFreq = str2double(get(hObject, 'String'));
lowFreq = handles.lowFreq;

if isnan(highFreq) || imag(highFreq) ~= 0
   set(handles.editHighFreq, 'String', num2str(handles.highFreq))
   tooltipError(handles,['High Frequency must be a real positive number between 0 and ' num2str(handles.sampleRate/2)])
   return
   
elseif highFreq < 0
   set(handles.editHighFreq, 'String', num2str(handles.highFreq))
   tooltipError(handles,'Minimum frequency for filter is 0')
   return
   
elseif highFreq > handles.sampleRate/2
    highFreq = handles.sampleRate/2;
    set(handles.editHighFreq, 'String', num2str(highFreq))
    tooltip(handles,['Maximum frequency for filter is ' num2str(handles.sampleRate/2)])

elseif highFreq < lowFreq
    set(handles.editLowFreq, 'String', num2str(highFreq))
    handles.lowFreq = highFreq;
    tooltip(handles,'Low Frequency must me smaller than High Frequency')
else
   tooltip(handles,'')
end

handles.highFreq = highFreq;

%Refresh Signal
createSingleSignal(hObject, eventdata, handles);


function editAmplitude_Callback(hObject, eventdata, handles)

amplitude = str2double(get(hObject, 'String'));

if amplitude < 0 || amplitude > 1 || isnan(amplitude) || imag(amplitude) ~= 0
   set(handles.editAmplitude, 'String', num2str(handles.amplitude))
   tooltipError(handles,'Amplitude must be a real positive number between 0 and 1')
   return
end

tooltip(handles,'')
handles.amplitude = amplitude;

%Refresh Signal
createSingleSignal(hObject, eventdata, handles);



function editStartTime_Callback(hObject, eventdata, handles)

startTime = str2double(get(hObject, 'String'));

if startTime < 0 || imag(startTime) ~= 0
    set(hObject, 'String', num2str(handles.startTime))
    tooltipError(handles,'Start Time must a positive real number')
    return
end


handles.startTime = startTime;
tooltip(handles,'')

%Refresh Signal
createSingleSignal(hObject, eventdata, handles);


function editLength_Callback(hObject, eventdata, handles)

length = str2double(get(hObject, 'String'));
startRise = handles.startRise;
endRise = handles.endRise;
startFall = handles.startFall;

if length < 0 || imag(length) ~= 0
    set(hObject, 'String', num2str(handles.length))
    tooltipError(handles,'Length must a positive real number')
    return
end

%Start Rise < End Rise < Start Fall < End Fall ?
if length < startRise
    handles.startRise = length;
    set(handles.editStartRise, 'String', num2str(length))
    handles.endRise = length;
    set(handles.editEndRise, 'String', num2str(endFall))
    handles.startFall = length;
    set(handles.editStartFall, 'String', num2str(length))
    tooltip(handles,'Start Rise < End Rise < Start Fall < Length')
elseif length < endRise
    handles.endRise = length;
    set(handles.editEndRise, 'String', num2str(length))
    handles.startFall = length;
    set(handles.editStartFall, 'String', num2str(length))
    tooltip(handles,'Start Rise < End Rise < Start Fall < Length')
elseif length < startFall
    handles.startFall = length;
    set(handles.editStartFall, 'String', num2str(length))
    tooltip(handles,'Start Rise < End Rise < Start Fall < Length')
else
    tooltip(handles,'')
end

handles.length = length;
handles.endFall = length;
set(handles.editEndFall, 'String', num2str(length))

%Refresh Signal
createSingleSignal(hObject, eventdata, handles);

function editRepeatQuantity_Callback(hObject, eventdata, handles)

repeatQuantity = str2double(get(hObject, 'String'));

if  imag(repeatQuantity) ~= 0 || repeatQuantity < 0
    tooltipError(handles,'Quantity must be a real positive integer')
    set(hObject, 'String', num2str(handles.repeatQuantity))
    return
%Integer?    
elseif rem(repeatQuantity,1) ~= 0
    tooltip(handles,'Quantity must be a real positive integer')
    repeatQuantity = round(repeatQuantity);
    set(hObject, 'String', num2str(repeatQuantity));
else
    tooltip(handles,'')
end

handles.repeatQuantity = repeatQuantity;
createSingleSignal(hObject, eventdata, handles);

function editRepeatPause_Callback(hObject, eventdata, handles)

repeatPause = str2double(get(hObject, 'String'));

if  imag(repeatPause) ~= 0 || repeatPause < 0
    tooltipError(handles,'Pause must be a real positive number')
    set(hObject, 'String', num2str(handles.repeatPause))
    return
end

tooltip(handles,'')
handles.repeatPause = repeatPause;

if handles.repeatQuantity ~= 0
    createSingleSignal(hObject, eventdata, handles);
end

%% Popups
function popupWindowType_Callback(hObject, eventdata, handles)

tooltip(handles,'')
createSingleSignal(hObject, eventdata, handles);


function popupNoise_Callback(hObject, eventdata, handles)

tooltip(handles,'')
createSingleSignal(hObject, eventdata, handles);


%% Create Functions

% --- Executes during object creation, after setting all properties.
function editStartRise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartRise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editStartFall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartFall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editEndRise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndRise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editEndFall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndFall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupWindowType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupWindowType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editLowFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLowFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
% hObject    handle to editHighFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editRepeatQuantity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRepeatQuantity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editAmplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editStartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editRepeatPause_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRepeatPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function popupNoise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
