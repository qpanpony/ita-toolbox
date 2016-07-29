function varargout = bindb_gui(varargin)
% bindb_gui MATLAB code for bindb_gui.fig
%      bindb_gui, by itself, creates a new bindb_gui or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = bindb_gui returns the handle to a new bindb_gui or the handle to
%      the existing singleton*.
%
%      bindb_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in bindb_gui.M with the given input arguments.
%
%      bindb_gui('Property','Value',...) creates a new bindb_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui

% Last Modified by GUIDE v2.5 26-May-2012 09:33:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_OutputFcn, ...
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


% --- Executes just before bindb_gui is made visible.
function bindb_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui (see VARARGIN)

% Choose default command line output for bindb_gui
handles.output = hObject;

% Declare globals
global bindb_data;

% Connect to database and ftp
[sqlres, ftpres] = bindb_connect();
if sqlres == 1
    set(handles.connectivity_database, 'String', 'connected to database');
    set(handles.connectivity_database, 'ForegroundColor', [0.2,0.8,0]);     
    
    % Activate transfer buttons
    set(handles.localdata_update, 'Enable', 'on');
    set(handles.localdata_commit, 'Enable', 'on');
    
    % Activate search button
    set(handles.measurement_search, 'Enable', 'on');
    set(handles.measurement_update, 'Enable', 'on');
else
    set(handles.connectivity_database, 'String', 'no connection to database');
    set(handles.connectivity_database, 'ForegroundColor', [0.8,0,0]);
    
    % Deactivate transfer buttons
    set(handles.localdata_update, 'Enable', 'off');
    set(handles.localdata_commit, 'Enable', 'off');
    
    % Deactivate search button
    set(handles.measurement_search, 'Enable', 'off');
    set(handles.measurement_update, 'Enable', 'off');
end
if ftpres == 1
    set(handles.connectivity_fileserver, 'String', 'filestorage found');
    set(handles.connectivity_fileserver, 'ForegroundColor', [0.2,0.8,0]);    
else
    set(handles.connectivity_fileserver, 'String', 'filestorage not found');
    set(handles.connectivity_fileserver, 'ForegroundColor', [0.8,0,0]);
end

% Update local data status
set(handles.localdata_status, 'String', bindb_data.Timestamp);

% Calculate age
days = etime(clock, datevec(bindb_data.Timestamp)) / 86400;

% Update local data hint
if days > 7
    set(handles.localdata_hint, 'String', 'Local data is older than a week, update before adding data.');
elseif days > 3
    set(handles.localdata_hint, 'String', 'Local data is older than 3 days, update is recommended.');
else
    set(handles.localdata_hint, 'String', 'Local data is fairly new.');
end

% Autocheckout
if bindb_data.Settings.AutoUpdate
    set(handles.localdata_autoupdate, 'Value', 1);
    localdata_update_Callback(handles.localdata_update, eventdata, handles);
end

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in localdata_update.
function localdata_update_Callback(hObject, eventdata, handles)
% hObject    handle to localdata_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update rooms and fields
bindb_update();

% Register globals
global bindb_data;

% Update local data status
set(handles.localdata_status, 'String', bindb_data.Timestamp);
set(handles.localdata_hint, 'String', 'Local data is up to date.');


% --- Executes on button press in room_add.
function room_add_Callback(hObject, eventdata, handles)
% hObject    handle to room_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show room add gui
bindb_gui_room_add();


% --- Executes on button press in measurement_add.
function measurement_add_Callback(hObject, eventdata, handles)
% hObject    handle to measurement_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show measurement add gui
bindb_gui_measurement_add();


% --- Executes on button press in room_seach.
function room_seach_Callback(hObject, eventdata, handles)
% hObject    handle to room_seach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show room search gui
bindb_gui_room_search();


% --- Executes on button press in statistics_showlog.
function statistics_showlog_Callback(hObject, eventdata, handles)
% hObject    handle to statistics_showlog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show log gui
bindb_gui_log();


% --- Executes on button press in configuration_settings.
function configuration_settings_Callback(hObject, eventdata, handles)
% hObject    handle to configuration_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show settings gui
bindb_gui_settings();


% --- Executes on button press in configuration_administration.
function configuration_administration_Callback(hObject, eventdata, handles)
% hObject    handle to configuration_administration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Register globals
global bindb_data;

% Show administration gui
if bindb_data.Settings.AdminMode == 1
    bindb_admin_gui();
else
    bindb_addlog('system', 'admin mode required', 1);
    fprintf('This action requires admin mode.\n<a href="matlab:bindb_setadmin(1)">Enter admin mode</a> <a href="matlab:bindb_setadmin(0)">Exit admin mode</a>\n');
end


% --- Executes on button press in statistics_inventory.
function statistics_inventory_Callback(hObject, eventdata, handles)
% hObject    handle to statistics_inventory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show inventory gui
bindb_gui_inventory();


% --- Executes on button press in localdata_commit.
function localdata_commit_Callback(hObject, eventdata, handles)
% hObject    handle to localdata_commit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show commit gui
bindb_gui_commit();


% --- Executes on button press in measurement_search.
function measurement_search_Callback(hObject, eventdata, handles)
% hObject    handle to measurement_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show measurement search gui
bindb_gui_measurement_search();


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save settings
bindb_store();

% Close figure
delete(hObject);


% --- Executes on button press in measurement_update.
function measurement_update_Callback(hObject, eventdata, handles)
% hObject    handle to measurement_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show update gui
bindb_gui_measurement_commit();
