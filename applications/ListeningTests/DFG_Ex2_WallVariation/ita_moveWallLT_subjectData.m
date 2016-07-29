function varargout = ita_moveWallLT_subjectData(varargin)
% ita_moveWallLT_subjectData MATLAB code for ita_moveWallLT_subjectData.fig
%      ita_moveWallLT_subjectData, by itself, creates a new ita_moveWallLT_subjectData or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ita_moveWallLT_subjectData returns the handle to a new ita_moveWallLT_subjectData or the handle to
%      the existing singleton*.
%
%      ita_moveWallLT_subjectData('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ita_moveWallLT_subjectData.M with the given input arguments.
%
%      ita_moveWallLT_subjectData('Property','Value',...) creates a new ita_moveWallLT_subjectData or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_moveWallLT_subjectData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_moveWallLT_subjectData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_moveWallLT_subjectData

% Last Modified by GUIDE v2.5 03-Sep-2014 15:44:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_moveWallLT_subjectData_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_moveWallLT_subjectData_OutputFcn, ...
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


% --- Executes just before ita_moveWallLT_subjectData is made visible.
function ita_moveWallLT_subjectData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_moveWallLT_subjectData (see VARARGIN)

% Init Data
subjectData.name = [];
str = get(handles.popupSex, 'String');
val = get(handles.popupSex, 'Value');
subjectData.sex = str{val};
subjectData.age = '';
subjectData.fromITA = get(handles.popupFromITA, 'Value');
subjectData.hrtfExperienced = get(handles.checkHRTFExperience, 'Value');
subjectData.date = date;
c = clock;
c = c([4 5]);
subjectData.time = [num2str(c(1)),':', num2str(c(2))];
subjectData.ID = '';
subjectData.group = '';

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

% UIWAIT makes ita_moveWallLT_subjectData wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_moveWallLT_subjectData_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on selection change in editID.
function editID_Callback(hObject, eventdata, handles)

str = get(hObject, 'String');

ID = str2double(str);
if isnan(ID)
    ID = -1;
end

if mod(ID, 1) || ID < 1   %integer greater than 0?
   set(hObject, 'String', handles.subjectData.ID)
   msgbox('Enter an integer greater 0')
   return
end

handles.subjectData.ID = ID;
guidata(hObject, handles);

function editGroup_Callback(hObject, eventdata, handles)

str = get(hObject, 'String');

group = str2double(str);
if isnan(group)
    group = -1;
end

if mod(group, 1) || group < 1 || group > 18  %integer between 1 and 18?
   set(hObject, 'String', handles.subjectData.group)
   msgbox('Enter an integer between 1 and 18')
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

if isempty(handles.subjectData.name) || isempty(handles.subjectData.age) ||...
        isempty(handles.subjectData.ID) || isempty(handles.subjectData.group)
    msgbox('Enter a name, the age and the ID')
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
function editID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editID (see GCBO)
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




% --- Executes during object creation, after setting all properties.
function editGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
