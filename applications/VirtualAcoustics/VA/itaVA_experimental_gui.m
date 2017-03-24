function varargout = itaVA_experimental_gui(varargin)
% ITAVA_EXPERIMENTAL_GUI MATLAB code for itaVA_experimental_gui.fig
%      ITAVA_EXPERIMENTAL_GUI, by itself, creates a new ITAVA_EXPERIMENTAL_GUI or raises the existing
%      singleton*.
%
%      H = ITAVA_EXPERIMENTAL_GUI returns the handle to a new ITAVA_EXPERIMENTAL_GUI or the handle to
%      the existing singleton*.
%
%      ITAVA_EXPERIMENTAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITAVA_EXPERIMENTAL_GUI.M with the given input arguments.
%
%      ITAVA_EXPERIMENTAL_GUI('Property','Value',...) creates a new ITAVA_EXPERIMENTAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before itaVA_experimental_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to itaVA_experimental_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help itaVA_experimental_gui

% Last Modified by GUIDE v2.5 24-Mar-2017 11:30:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @itaVA_experimental_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @itaVA_experimental_gui_OutputFcn, ...
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


% --- Executes just before itaVA_experimental_gui is made visible.
function itaVA_experimental_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to itaVA_experimental_gui (see VARARGIN)

% Choose default command line output for itaVA_experimental_gui
handles.output = hObject;
handles.va = itaVA;

% Update handles structure
guidata(hObject, handles);

refresh_workspace_vars( hObject, handles );
refresh_sourcesignals( hObject, handles );


% UIWAIT makes itaVA_experimental_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = itaVA_experimental_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in connect_connect_va.
function connect_connect_va_Callback(hObject, eventdata, handles)
% hObject    handle to connect_connect_va (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.va.isConnected
    handles.va.disconnect;
end
handles.va.connect;
handles.va.reset;

for n=1:numel( handles.va.getRenderingModules )
    if strcmp( handles.va.getRenderingModules( n ).class, 'PrototypeGenericPath' )
        gpg_renderer = handles.va.getRenderingModules( n );
        break;
    end
end

if ~exist( 'gpg_renderer', 'var' )
    error( 'No prototype generic path renderer found, please add or enable in VA configuration.' )
else
    disp( [ 'Using channel prototype generic path renderer with identifier: ' gpg_renderer.id ] )
end

% Classic VA module call with input and output arguments
handles.mod_id = [ gpg_renderer.class ':' gpg_renderer.id ];
in_args.info = true;
out_args = handles.va.callModule( handles.mod_id, in_args );
disp( [ 'Your experimental renderer has ' num2str( out_args.numchannels ) ' channels and an FIR filter length of ' num2str( out_args.irfilterlengthsamples ) ' samples' ] )

handles.edit_va_channels.String = out_args.numchannels;
handles.edit_va_fir_taps.String = out_args.irfilterlengthsamples;
handles.edit_va_fs.String = '44.100';

% Very simple scene with one path
L = handles.va.createListener( 'itaVA_ExperimentalListener' );
S = handles.va.createSoundSource( 'itaVA_ExperimentalListener' );

function edit_va_channels_CreateFcn(hObject, eventdata, handles)

function edit_va_fir_taps_CreateFcn(hObject, eventdata, handles)

% --- Executes on selection change in listbox_filters.
function listbox_filters_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_filters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_filters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_filters


% --- Executes during object creation, after setting all properties.
function listbox_filters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_filters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_sourcesignals.
function listbox_sourcesignals_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_sourcesignals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_sourcesignals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_sourcesignals


% --- Executes during object creation, after setting all properties.
function listbox_sourcesignals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_sourcesignals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_start_va.
function pushbutton_start_va_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start_va (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
itaVA_experimental_start_server

function refresh_workspace_vars( hObject, handles )
base_ws_vars = evalin( 'base', 'whos' ); 

stringlist = '';
for i=1:numel( base_ws_vars )
    if( strcmp( base_ws_vars( i ).class, 'itaAudio' ) )
        stringlist = [ stringlist; { base_ws_vars( i ).name } ];
    end
end

handles.listbox_filters.String = stringlist;


function refresh_sourcesignals( hObject, handles )
filelist = dir( pwd );

stringlist = '';
fullfile_stringlist = '';
for i=1:numel( filelist )
    filepath_abs = fullfile( pwd, filelist( i ).name );
    [ ~, fbn, ft ] = fileparts(  );
    if( strcmpi( ft, '.wav' ) )
        stringlist = [ stringlist; { fbn } ];
        fullfile_stringlist = [ fullfile_stringlist; { filepath_abs } ];
    end
end

handles.listbox_sourcesignals.String = stringlist;
handles.listbox_sourcesignals.Userdata = fullfile_stringlist;


% --- Executes on button press in pushbutton_refresh_workspace_vars.
function pushbutton_refresh_workspace_vars_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refresh_workspace_vars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_workspace_vars( hObject, handles );

% --- Executes on button press in pushbutton_va_setup.
function pushbutton_va_setup_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_va_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
itaVA_setup

function edit_va_channels_Callback(hObject, eventdata, handles)
% hObject    handle to edit_va_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_va_channels as text
%        str2double(get(hObject,'String')) returns contents of edit_va_channels as a double



function edit_va_fir_taps_Callback(hObject, eventdata, handles)
% hObject    handle to edit_va_fir_taps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_va_fir_taps as text
%        str2double(get(hObject,'String')) returns contents of edit_va_fir_taps as a double



function edit_va_fs_Callback(hObject, eventdata, handles)
% hObject    handle to edit_va_fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_va_fs as text
%        str2double(get(hObject,'String')) returns contents of edit_va_fs as a double


% --- Executes during object creation, after setting all properties.
function edit_va_fs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_va_fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_refresh_input_files.
function pushbutton_refresh_input_files_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refresh_input_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_sourcesignals( hObject, handles )
