function varargout = ita_binauralMAA_subjectData(varargin)
% ITA_BINAURALMAA_SUBJECTDATA MATLAB code for ita_binauralMAA_subjectData.fig
%      ITA_BINAURALMAA_SUBJECTDATA, by itself, creates a new ITA_BINAURALMAA_SUBJECTDATA or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ITA_BINAURALMAA_SUBJECTDATA returns the handle to a new ITA_BINAURALMAA_SUBJECTDATA or the handle to
%      the existing singleton*.
%
%      ITA_BINAURALMAA_SUBJECTDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITA_BINAURALMAA_SUBJECTDATA.M with the given input arguments.
%
%      ITA_BINAURALMAA_SUBJECTDATA('Property','Value',...) creates a new ITA_BINAURALMAA_SUBJECTDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_binauralMAA_subjectData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_binauralMAA_subjectData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_binauralMAA_subjectData

% Last Modified by GUIDE v2.5 07-Jan-2014 10:41:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_binauralMAA_subjectData_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_binauralMAA_subjectData_OutputFcn, ...
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


% --- Executes just before ita_binauralMAA_subjectData is made visible.
function ita_binauralMAA_subjectData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_binauralMAA_subjectData (see VARARGIN)

% Init Data
subjectData.name = 'Hans';
str = get(handles.popupSex, 'String');
val = get(handles.popupSex, 'Value');
subjectData.sex = str{val};
subjectData.age = '5';
subjectData.fromITA = get(handles.popupFromITA, 'Value');
subjectData.hrtfExperienced = get(handles.checkHRTFExperience, 'Value');
subjectData.date = date;
c = clock;
c = c([4 5]);
subjectData.time = [num2str(c(1)),':', num2str(c(2))];
subjectData.group = '1';

handles.subjectData = subjectData;

handles.output = NaN;

% Update handles structure
guidata(hObject, handles);

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

% UIWAIT makes ita_binauralMAA_subjectData wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_binauralMAA_subjectData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1)



function editName_Callback(hObject, eventdata, handles)

handles.subjectData.name = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes on selection change in editGroup.
function editGroup_Callback(hObject, eventdata, handles)

str = get(hObject, 'String');

group = str2double(str);
if isnan(group)
    group = -1;
end

if mod(group, 1) || group < 1 || group > 24   %integer between 1 and 24?
   set(hObject, 'String', handles.subjectData.group)
   msgbox('Enter an integer between 1 and 24')
   return
end

handles.subjectData.group = group;
guidata(hObject, handles);

% --- Executes on selection change in editAge.
function editAge_Callback(hObject, eventdata, handles)

str = get(hObject, 'String');

age = str2double(str);
if isnan(age)
    age = -1;
end

if mod(age, 1) || age < 0 || age > 120   %integer between 1 and 120?
   set(hObject, 'String', handles.subjectData.age)
   msgbox('Enter an integer between 0 and 120')
   return
end

handles.subjectData.age = age;
guidata(hObject, handles);


% --- Executes on selection change in popupSex.
function popupSex_Callback(hObject, eventdata, handles)

str = get(hObject, 'String');
val = get(hObject, 'Value');
handles.subjectData.sex = str{val};
guidata(hObject, handles);

% --- Executes on selection change in popupFromITA.
function popupFromITA_Callback(hObject, eventdata, handles)

handles.subjectData.fromITA = get(hObject, 'Value');
%1 = extern, 2 = student, 3 = assistent
guidata(hObject, handles);

% --- Executes on button press in checkHRTFExperience.
function checkHRTFExperience_Callback(hObject, eventdata, handles)

handles.subjectData.hrtfExperienced = get(hObject, 'Value');


% --- Executes on button press in pushSubmit.
function pushSubmit_Callback(hObject, eventdata, handles)

if isempty(handles.subjectData.name) || isempty(handles.subjectData.age) || isempty(handles.subjectData.group)
    msgbox('Enter a name, the age and the group-number')
    return
end

%last check
button = questdlg('Are all the information correct?','Please check again...','yes','no','no');
if isempty(button)  || strcmp(button, 'no')
    return
end

handles.output = handles.subjectData;
guidata(hObject, handles)
uiresume



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

uiresume


%% Create Function

% --- Executes during object creation, after setting all properties.
function editName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editAge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popupFromITA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupFromITA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popupSex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
