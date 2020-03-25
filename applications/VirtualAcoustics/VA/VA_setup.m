function varargout = VA_setup(varargin)
% VA_SETUP MATLAB code for VA_setup.fig
%      VA_SETUP, by itself, creates a new VA_SETUP or raises the existing
%      singleton*.
%
%      H = VA_SETUP returns the handle to a new VA_SETUP or the handle to
%      the existing singleton*.
%
%      VA_SETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VA_SETUP.M with the given input arguments.
%
%      VA_SETUP('Property','Value',...) creates a new VA_SETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VA_setup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VA_setup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VA_setup

% Last Modified by GUIDE v2.5 05-Dec-2018 16:00:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VA_setup_OpeningFcn, ...
                   'gui_OutputFcn',  @VA_setup_OutputFcn, ...
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


% --- Executes just before VA_setup is made visible.
function VA_setup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VA_setup (see VARARGIN)

% Choose default command line output for VA_setup
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% VAMatlab
current_va_mex_dir = which( 'VAMatlab' );
if ~isempty( current_va_mex_dir )
    [ va_mex_path, ~, ~ ] = fileparts( current_va_mex_dir );
    [ va_path, ~, ~ ] = fileparts( va_mex_path );
    set( handles.va_search_dir, 'String', fullfile( va_path ) );
    
    set( handles.edit_vamatlab_full_path, 'String', current_va_mex_dir )
    try
        v = VAMatlab( 'get_version' );
        set( handles.edit_vamatlab_version, 'String', v )
    catch
        set( handles.edit_vamatlab_version, 'String', 'Failed to execute VAMatlab, probably a depending library is missing.' )
    end
end

% VAServer
current_va_server_dir = which( 'VAServer.exe' );
if ~isempty( current_va_server_dir )
    set( handles.edit_vaserver_full_path, 'String', current_va_server_dir )
    [ ~, v ] = system( [ current_va_server_dir ' --version' ] );
    vs = strsplit( v, '\n' );
    for i = 1:numel( vs )
        vss = vs{ 1, i };
        if numel( vss ) > 6
            if strcmpi( vss( 3:10 ), 'VAServer' )
                server_version = vss( 15:end );
                set( handles.edit_vaserver_version, 'String', strcat( server_version ) )
            end
        end
    end
end

% NatNetML
current_natnet_dir = which( 'NatNetML.dll' );
if ~isempty( current_natnet_dir )
    ainfo = NET.addAssembly( current_natnet_dir );
    natnetversion_raw = NatNetML.NatNetClientML( 0 ).NatNetVersion();
    vs = sprintf( 'NatNetML (OptiTrack) %d.%d', natnetversion_raw(1), natnetversion_raw(2) );
    set( handles.edit_natnet_version, 'String', vs )
end

uiwait( handles.figure1 );


% --- Outputs from this function are returned to the command line.
function varargout = VA_setup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if ~isempty( handles )
    varargout{1} = handles.output;
end


% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close( gcf )


function edit_vamatlab_full_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vamatlab_full_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vamatlab_full_path as text
%        str2double(get(hObject,'String')) returns contents of edit_vamatlab_full_path as a double


% --- Executes during object creation, after setting all properties.
function edit_vamatlab_full_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vamatlab_full_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_vaserver_full_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vaserver_full_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vaserver_full_path as text
%        str2double(get(hObject,'String')) returns contents of edit_vaserver_full_path as a double


% --- Executes during object creation, after setting all properties.
function edit_vaserver_full_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vaserver_full_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function va_search_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to va_search_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_recursively_Callback(hObject, eventdata, handles)
function checkbox_permanently_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton_va_dir_browse.
function pushbutton_va_dir_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_va_dir_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

start_path = get( handles.va_search_dir, 'String' );
if exist( start_path, 'file' ) ~= 7
    start_path = pwd;
end

va_search_dir = uigetdir( start_path );

if ~isempty( va_search_dir )
    set( handles.va_search_dir, 'String', va_search_dir )
    find_VA( va_search_dir, handles )
end

function find_VA( va_search_dir, handles )

recursive_flag = get( handles.checkbox_recursively, 'Value' );
permanent_flag = get( handles.checkbox_permanently, 'Value' );

set( handles.edit_vamatlab_full_path, 'String', 'Scanning ... ' )
set( handles.edit_vaserver_full_path, 'String', 'Scanning ... ' )

% VAMatlab
[ vamatlab_found, vamatlab_dir ] = find_VA_Component( va_search_dir, [ 'VAMatlab.' mexext ], recursive_flag );
if vamatlab_found
    addpath( vamatlab_dir )
    if permanent_flag
        savepath
    end
    set( handles.edit_vamatlab_full_path, 'String', fullfile( vamatlab_dir, [ 'VAMatlab.' mexext ] ) )
    v = VAMatlab( 'get_version' );
    set( handles.edit_vamatlab_version, 'String', v )
else
    set( handles.edit_vamatlab_full_path, 'String', 'not found' )
end

% VAServer
[ vaserver_found, vaserver_dir ] = find_VA_Component( va_search_dir, 'VAServer.exe', recursive_flag );
if vaserver_found
    addpath( vaserver_dir )
    if permanent_flag
        savepath
    end
    vaserver_path = fullfile( vaserver_dir, 'VAServer.exe' );
    set( handles.edit_vaserver_full_path, 'String', vaserver_path )
    [ ~, v ] = system( [ vaserver_path ' --version' ] );
    vs = strsplit( v, '\n' );
    for i = 1:numel( vs )
        vss = vs{ 1, i };
        if numel( vss ) > 6
            if strcmpi( vss( 3:10 ), 'VAServer' )
                server_version = vss( 15:end );
                set( handles.edit_vaserver_version, 'String', strcat( server_version ) )
            end
        end
    end
else
    set( handles.edit_vaserver_full_path, 'String', 'not found' )
end

% NatNetML
current_natnet_dir = which( 'NatNetML.dll' );
if ~isempty( current_natnet_dir )
    ainfo = NET.addAssembly( current_natnet_dir );
    natnetversion_raw = NatNetML.NatNetClientML( 0 ).NatNetVersion();
    vs = sprintf( 'NatNetML (OptiTrack) %d.%d', natnetversion_raw(1), natnetversion_raw(2) );
    set( handles.edit_natnet_version, 'String', vs )
end


function [ found, va_component_dir ] = find_VA_Component( va_search_dir, component, recursive )
found = false;
va_component_dir = '';

if isempty( va_search_dir )
    return % something went wrong
end
if ~va_search_dir
    return;
end

if exist( fullfile( va_search_dir, component ), 'file' )
    found = true;
    va_component_dir = fullfile( va_search_dir ); % Base path is one folder up
end

if ~found && recursive
    listing = dir( va_search_dir );    
    for idx = 1:length( listing )
        current_file_name = listing( idx ).name;
        if listing( idx ).isdir && current_file_name(1) ~= '.'
            [ found, va_component_dir ] = find_VA_Component( fullfile( va_search_dir, current_file_name ), component, recursive );
            if found
                break % Find first
            end
        end 
    end
end



function va_search_dir_Callback(hObject, eventdata, handles)
% hObject    handle to va_search_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of va_search_dir as text
%        str2double(get(hObject,'String')) returns contents of va_search_dir as a double


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_close.
function pushbutton_close_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close( handles.gui )



function edit_vamatlab_version_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vamatlab_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vamatlab_version as text
%        str2double(get(hObject,'String')) returns contents of edit_vamatlab_version as a double


% --- Executes during object creation, after setting all properties.
function edit_vamatlab_version_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vamatlab_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vaserver_version_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vaserver_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vaserver_version as text
%        str2double(get(hObject,'String')) returns contents of edit_vaserver_version as a double


% --- Executes during object creation, after setting all properties.
function edit_vaserver_version_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vaserver_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_natnet_version_Callback(hObject, eventdata, handles)
% hObject    handle to edit_natnet_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_natnet_version as text
%        str2double(get(hObject,'String')) returns contents of edit_natnet_version as a double


% --- Executes during object creation, after setting all properties.
function edit_natnet_version_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_natnet_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
