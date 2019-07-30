function varargout = itaVA_experimental_gui(varargin)
% ITAVA_EXPERIMENTAL_GUI VirtualAcoustics (VA) GUI adapter for simple FIR filter switch auralization
%       
%       Connect to a running VA server instance, play back sounds and
%       exchange filters of your workspace to make an FIR filter set of aribatrary channel number
%       audible. Input data is only considered if current workspace
%       variable is of itaAudio type and time data can be accessed.
%       
%       This GUI requires an enabled generic path prototype renderer in
%       VACore. The number of channels is fixed and has to match the channels provided in
%       the renderer. Basically, a real-time convolution engine is set up
%       and it's FIR filters can be exchanged instantaneously using Matlab
%       and the VAMatlab TCP/IP network interface.
%
%       To configure itaVA, call itaVA_setup. To run the experimental
%       VA server, call itaVA_experimental_renderer_prepare and itaVA_experimental_start_server
%
%       If the VA server is printing a lot of "empty output" warnings, you
%       can ignore them. It is a hint that the rendering processor produces
%       zeros, which is normal if your initial FIR filter is empty. This is
%       the default behaviour.
%
% Edit the above text to modify the response to help itaVA_experimental_gui

% Last Modified by GUIDE v2.5 04-Apr-2017 22:31:45

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
function itaVA_experimental_gui_OpeningFcn( hObject, ~, handles, varargin )
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to itaVA_experimental_gui (see VARARGIN)

% Choose default command line output for itaVA_experimental_gui
handles.output = hObject;
handles.va = itaVA;
handles.module_id = 'PrototypeGenericPath:MyGenericRenderer';
handles.va_source_id = -1;
handles.va_signal_id = '';
handles.va_listener_id = -1;
handles.module_channels = -1;
handles.module_filter_length_samples = -1;
handles.listbox_sourcesignals_last_index = -1;

refresh_workspace_vars( hObject, handles );
refresh_sourcesignals( hObject, handles );

% Update handles structure
guidata( hObject, handles );



% UIWAIT makes itaVA_experimental_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = itaVA_experimental_gui_OutputFcn( ~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{ 1 } = handles.output;


% --- Executes on button press in connect_connect_va.
function connect_connect_va_Callback( hObject, ~, handles )
% hObject    handle to connect_connect_va (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.va.get_connected
    handles.va.disconnect;
end
handles.va.connect;
handles.va.reset;

gpg_renderer_list = [];
for n=1:numel( handles.va.get_rendering_modules )
    if strcmp( handles.va.get_rendering_modules( n ).class, 'PrototypeGenericPath' )
        gpg_renderer_list = [ gpg_renderer_list handles.va.get_rendering_modules( n ) ];
    end
end

if numel( gpg_renderer_list ) == 1
    gpg_renderer = gpg_renderer_list( 1 );
elseif numel( gpg_renderer_list ) > 1
    gpg_renderer = gpg_renderer_list( 1 );
    warning( 'More than one prototype generic path renderer found. Using first.' )
else
    error( 'No prototype generic path renderer found, please add or enable in VA configuration.' )
end

disp( [ 'Using channel prototype generic path renderer with identifier: ' gpg_renderer.id ] )

% Classic VA module call with input and output arguments
handles.module_id = [ gpg_renderer.class ':' gpg_renderer.id ];
handles.renderer_id = gpg_renderer.id;

in_args.info = true;
out_args = handles.va.get_rendering_module_parameters( gpg_renderer.id, in_args );
handles.module_channels = out_args.numchannels;
handles.module_filter_length_samples = out_args.irfilterlengthsamples;
disp( [ 'Your experimental renderer "'  gpg_renderer.id '" has ' num2str( handles.module_channels ) ' channels and an FIR filter length of ' num2str( out_args.irfilterlengthsamples ) ' samples' ] )

handles.edit_va_channels.String = handles.module_channels;
handles.edit_va_fir_taps.String = handles.module_filter_length_samples;
handles.edit_va_fs.String = '44.100'; % @todo get from VA audio streaming settings

% Useful FIRs
global ita_impulse;
if ~exist( 'ita_all_dirac', 'var' )
    ita_impulse = ita_merge( ita_generate_impulse, ita_generate_impulse );
end
global ita_silence;
if ~exist( 'ita_all_silence', 'var' )
    ita_silence = ita_merge( ita_generate_impulse, ita_generate_impulse ) * 0;
end

% Very simple scene with one path
handles.va_listener_id = handles.va.create_sound_receiver( 'itaVA_ExperimentalListener' );
handles.va_source_id = handles.va.create_sound_source( 'itaVA_ExperimentalSource' );
handles.va_signal_id = '';

% VA control
handles.va.set_output_muted( handles.checkbox_global_muted.Value );
handles.va.set_output_muted( handles.slider_volume.Value );

refresh_sourcesignals( hObject, handles );
refresh_workspace_vars( hObject, handles );

% Update handles (store values)
guidata( hObject, handles );




function edit_va_channels_CreateFcn(hObject, eventdata, handles)

function edit_va_fir_taps_CreateFcn(hObject, eventdata, handles)

% --- Executes on selection change in listbox_filters.
function listbox_filters_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_filters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_filters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_filters
index_selected = handles.listbox_filters.Value;

if isempty( index_selected )
    return
end

filter_list = handles.listbox_filters.String;
filter_selected = filter_list{ index_selected };


if handles.va.get_connected
    
    num_channels = str2double( handles.edit_va_channels.String );

    mStruct = struct;
    mStruct.receiver = handles.va_listener_id;
    mStruct.source = handles.va_source_id;
    mStruct.verbose = true;
    
    newfilter = evalin( 'base', filter_selected );
    
    for n=1:num_channels
        idx_channel_name = [ 'ch' num2str( n ) ];
        mStruct.( idx_channel_name ) = double( newfilter.ch( n ).timeData )';
    end
    
    handles.va.set_rendering_module_parameters( handles.renderer_id, mStruct );
end

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
function listbox_sourcesignals_Callback( hObject, ~, handles )
% hObject    handle to listbox_sourcesignals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_sourcesignals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_sourcesignals
index_selected = handles.listbox_sourcesignals.Value;
filename_list = handles.listbox_sourcesignals.String;
filepath_list = handles.listbox_sourcesignals.UserData;
filepath_selected = filepath_list{ index_selected };
filename_selected = filename_list{ index_selected };

if handles.va.get_connected
    
    last_index = handles.listbox_sourcesignals_last_index;
    
    if last_index == index_selected
        % play/pause current
        va_signal_id = handles.va.get_sound_source_signal_source( handles.va_source_id );
        assert( ~isempty( va_signal_id ) )
        playstate = handles.va.get_signal_source_buffer_playback_state( va_signal_id );
        if strcmpi( playstate, 'playing' )
            handles.va.set_signal_source_buffer_playback_action( va_signal_id, 'pause' );
        else
            handles.va.set_signal_source_buffer_playback_action( va_signal_id, 'play' );
        end
    else
        % new selected, remove old?
        if last_index ~= -1
            va_signal_id = handles.va.get_sound_source_signal_source( handles.va_source_id );
            handles.va.set_sound_source_signal_source( handles.va_source_id, '' );
            handles.va.delete_signal_source( va_signal_id );
        end
        
        % create new
        handles.va_signal_id = handles.va.create_signal_source_buffer_from_file( filepath_selected, filename_selected );
        handles.va.set_sound_source_signal_source( handles.va_source_id, handles.va_signal_id );
        handles.va.set_signal_source_buffer_playback_action( handles.va_signal_id, 'play' );
        is_looping = handles.checkbox_loop.Value;
        handles.va.set_signal_source_buffer_looping( handles.va_signal_id, is_looping );
        
        handles.listbox_sourcesignals_last_index = index_selected;

    end
end

% Update handles structure
guidata( hObject, handles );


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
% Updates workspace variables in listbox
base_ws_vars = evalin( 'base', 'whos' ); 

stringlist = '';
for i=1:numel( base_ws_vars )
    if( strcmp( base_ws_vars( i ).class, 'itaAudio' ) )
        audio_var = evalin( 'base', base_ws_vars( i ).name );
        if handles.module_channels == audio_var.nChannels
            stringlist = [ stringlist; { base_ws_vars( i ).name } ];
        end
    end
end

if ~isempty( stringlist )
    handles.listbox_filters.String = stringlist;
else
    if handles.va.get_connected
        warning( [ 'No itaAudio objects with matching ' handles.module_channels ' channels found in current workspace' ] )
    else
        %warning( [ 'No itaAudio objects found in current workspace' ] )
    end
end


function refresh_sourcesignals( hObject, handles )
filelist = dir( pwd );
handles.listbox_sourcesignals_last_index = -1;

stringlist = '';
fullfile_stringlist = '';
for i=1:numel( filelist )
    filepath_abs = fullfile( pwd, filelist( i ).name );
    [ ~, fbn, ft ] = fileparts( filepath_abs );
    if( strcmpi( ft, '.wav' ) )
        stringlist = [ stringlist; { fbn } ];
        fullfile_stringlist = [ fullfile_stringlist; { filepath_abs } ];
    end
end

if ~isempty( stringlist )
    handles.listbox_sourcesignals.String = stringlist;
else
    %warning( [ 'No WAV files found in current workfolder (' pwd ')' ] )
end
if ~isempty( fullfile_stringlist )
    handles.listbox_sourcesignals.UserData = fullfile_stringlist;
end

% Update handles structure
guidata( hObject, handles );



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
function edit_va_fs_CreateFcn( hObject, eventdata, handles )
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


% --- Executes on button press in checkbox_loop.
function checkbox_loop_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.va.get_connected && ~isempty( handles.va_signal_id )
    handles.va.setAudiofileSignalSourceIsLooping( handles.va_signal_id, get( hObject, 'Value' ) );
end


% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.va.get_connected && ~isempty( handles.va_signal_id )
    handles.va.set_signal_source_buffer_playback_action( handles.va_signal_id, 'stop' );
end


% --- Executes on button press in checkbox_global_muted.
function checkbox_global_muted_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_global_muted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.va.get_connected
    handles.va.set_output_muted( get( hObject, 'Value' ) );
end


% --- Executes on slider movement.
function slider_volume_Callback(hObject, ~, handles)
% hObject    handle to slider_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.va.get_connected
    handles.va.set_output_gain( get( hObject, 'Value' ) );
end
handles.edit_output_volume.String = num2str( get( hObject, 'Value' ) );


% --- Executes during object creation, after setting all properties.
function slider_volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_output_volume_Callback(hObject, eventdata, handles)
% hObject    handle to edit_output_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_output_volume as text
%        str2double(get(hObject,'String')) returns contents of edit_output_volume as a double


% --- Executes during object creation, after setting all properties.
function edit_output_volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_output_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
