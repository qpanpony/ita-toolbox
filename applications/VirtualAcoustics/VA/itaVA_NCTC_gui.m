function varargout = itaVA_NCTC_gui(varargin)
% ITAVA_NCTC_GUI MATLAB code for itaVA_NCTC_gui.fig
%      ITAVA_NCTC_GUI, by itself, creates a new ITAVA_NCTC_GUI or raises the existing
%      singleton*.
%
%      H = ITAVA_NCTC_GUI returns the handle to a new ITAVA_NCTC_GUI or the handle to
%      the existing singleton*.
%
%      ITAVA_NCTC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITAVA_NCTC_GUI.M with the given input arguments.
%
%      ITAVA_NCTC_GUI('Property','Value',...) creates a new ITAVA_NCTC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before itaVA_NCTC_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to itaVA_NCTC_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help itaVA_NCTC_gui

% Last Modified by GUIDE v2.5 20-Jun-2017 15:50:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @itaVA_NCTC_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @itaVA_NCTC_gui_OutputFcn, ...
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


% --- Executes just before itaVA_NCTC_gui is made visible.
function itaVA_NCTC_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to itaVA_NCTC_gui (see VARARGIN)

% Choose default command line output for itaVA_NCTC_gui
handles.output = hObject;

handles.va = VA;
handles.repros = [];
handles.current_repro_params = struct();

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes itaVA_NCTC_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = itaVA_NCTC_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_connect.
function pushbutton_connect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.va.connect( handles.edit_va_server_ip.String )

if ~handles.va.isConnected
    error( 'Not connected to VA' )
end

repros = handles.va.getReproductionModules();
for n=1:numel( repros )
    repro = repros( n );
    if strcmp( repro.class, 'NCTC' )
        handles.repros = [ handles.repros repro ];
    end
end

if numel( handles.repros ) == 0
    error( 'No NCTC reproduction module found, please activate in VA configuration' )
end

in_args.info = true;
handles.current_repro_params = handles.va.callModule( [ 'NCTC:' handles.repros( 1 ).id ], in_args );

handles.slider_cross_talk_cancellation_factor;

% Update handles structure
guidata(hObject, handles);


function edit_va_server_ip_Callback(hObject, eventdata, handles)
% hObject    handle to edit_va_server_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_va_server_ip as text
%        str2double(get(hObject,'String')) returns contents of edit_va_server_ip as a double


% --- Executes during object creation, after setting all properties.
function edit_va_server_ip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_va_server_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_repros.
function listbox_repros_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_repros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_repros contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_repros


% --- Executes during object creation, after setting all properties.
function listbox_repros_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_repros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_cross_talk_cancellation_factor_Callback(hObject, eventdata, handles)
% hObject    handle to slider_cross_talk_cancellation_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_cross_talk_cancellation_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_cross_talk_cancellation_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
