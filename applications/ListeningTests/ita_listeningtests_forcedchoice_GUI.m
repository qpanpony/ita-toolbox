function varargout = versuch_gui2(varargin)
% ITA_LISTENING_TESTS_FORCEDCHOICE_GUI - gui for
% ita_listening_tests_forcedchoice
%VERSUCH_GUI2 M-file for versuch_gui2.fig
%      VERSUCH_GUI2, by itself, creates a new VERSUCH_GUI2 or raises the existing
%      singleton*.
%
%      H = VERSUCH_GUI2 returns the handle to a new VERSUCH_GUI2 or the handle to
%      the existing singleton*.
%
%      VERSUCH_GUI2('Property','Value',...) creates a new VERSUCH_GUI2 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to versuch_gui2_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VERSUCH_GUI2('CALLBACK') and VERSUCH_GUI2('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VERSUCH_GUI2.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Edit the above text to modify the response to help versuch_gui2

% Last Modified by GUIDE v2.5 23-Oct-2009 16:02:47

% because next str2func will give warning when first input argument is a
% string (why???)
warning off all

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @versuch_gui2_OpeningFcn, ...
                   'gui_OutputFcn',  @versuch_gui2_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before versuch_gui2 is made visible.
function versuch_gui2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% set(handles.figure1, 'Name', varargin{1});



% Choose default command line output for versuch_gui2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes versuch_gui2 wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = versuch_gui2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.input_choice;
varargout{2} = handles.entered_text;
varargout{3} = handles.replaybutton;

delete(hObject);


% --- Executes on button press in sample1PButton.
function sample1PButton_Callback(hObject, eventdata, handles)
% hObject    handle to sample1PButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'BackgroundColor',[.831 .816 .99]);
set(handles.sample2PButton,'BackgroundColor',[.831 .816 .784]);
set(handles.sample3PButton,'BackgroundColor',[.831 .816 .784]);
set(handles.display_choice,'String',1);
set(handles.display_choice,'ForegroundColor',[.0 .0 .0]);
guidata(hObject, handles);



% --- Executes on button press in sample2PButton.
function sample2PButton_Callback(hObject, eventdata, handles)
% hObject    handle to sample2PButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'BackgroundColor',[.831 .816 .99]);
set(handles.sample1PButton,'BackgroundColor',[.831 .816 .784]);
set(handles.sample3PButton,'BackgroundColor',[.831 .816 .784]);
set(handles.display_choice,'String',2);
set(handles.display_choice,'ForegroundColor',[.0 .0 .0]);
guidata(hObject, handles);



% --- Executes on button press in sample3PButton.
function sample3PButton_Callback(hObject, eventdata, handles)
% hObject    handle to sample3PButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'BackgroundColor',[.831 .816 .99]);
set(handles.sample1PButton,'BackgroundColor',[.831 .816 .784]);
set(handles.sample2PButton,'BackgroundColor',[.831 .816 .784]);
set(handles.display_choice,'String',3);
set(handles.display_choice,'ForegroundColor',[.0 .0 .0]);
guidata(hObject, handles);



% --- Executes on button press in sendPButton.
function sendPButton_Callback(hObject, eventdata, handles)
% hObject    handle to sendPButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.replaybutton = 0;
handles.input_choice = get(handles.display_choice,'String');
handles.entered_text = get(handles.edit1,'String');
if (handles.input_choice == '0')
     set(handles.display_choice,'ForegroundColor',[.831 .0 .0]);
     guidata(hObject, handles);
     uiwait(handles.figure1);
else
     guidata(hObject, handles);
     uiresume(handles.figure1);
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function display_choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in replay1.
function replay1_Callback(hObject, eventdata, handles)
% hObject    handle to replay1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.replaybutton=1;
handles.input_choice=0;
handles.entered_text=get(handles.edit1,'String');
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in replay2.
function replay2_Callback(hObject, eventdata, handles)
% hObject    handle to replay2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.replaybutton=2;
handles.input_choice=0;
handles.entered_text=get(handles.edit1,'String');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in replay3.
function replay3_Callback(hObject, eventdata, handles)
% hObject    handle to replay3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.replaybutton=3;
handles.input_choice=0;
handles.entered_text=get(handles.edit1,'String');
guidata(hObject, handles);
uiresume(handles.figure1);
