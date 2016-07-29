function varargout = bindb_admin_gui(varargin)
% BINDB_ADMIN_GUI MATLAB code for bindb_admin_gui.fig
%      BINDB_ADMIN_GUI, by itself, creates a new BINDB_ADMIN_GUI or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_ADMIN_GUI returns the handle to a new BINDB_ADMIN_GUI or the handle to
%      the existing singleton*.
%
%      BINDB_ADMIN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_ADMIN_GUI.M with the given input arguments.
%
%      BINDB_ADMIN_GUI('Property','Value',...) creates a new BINDB_ADMIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_admin_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_admin_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_admin_gui

% Last Modified by GUIDE v2.5 26-May-2012 09:31:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_admin_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_admin_gui_OutputFcn, ...
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


% --- Executes just before bindb_admin_gui is made visible.
function bindb_admin_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_admin_gui (see VARARGIN)

% Choose default command line output for bindb_admin_gui
handles.output = hObject;

% Disable delete if no connection
if ~bindb_isonline()
    set(handles.database_fields, 'Enable', 'off');
end

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_admin_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in local_reset.
function local_reset_Callback(hObject, eventdata, handles)
% hObject    handle to local_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(bindb_filepath('localdata', 'fields.mat'));
delete(bindb_filepath('localdata', 'measurements.mat'));
delete(bindb_filepath('localdata', 'rooms.mat'));
delete(bindb_filepath('localdata', 'system.mat'));


% --- Executes on button press in database_fields.
function database_fields_Callback(hObject, eventdata, handles)
% hObject    handle to database_fields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open measurement fields gui
bindb_admin_gui_fields();


% --- Executes on button press in database_tablestructure.
function database_tablestructure_Callback(hObject, eventdata, handles)
% hObject    handle to database_tablestructure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in sql_create.
function sql_create_Callback(hObject, eventdata, handles)
% hObject    handle to sql_create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bindb_admin_createsqltables();


% --- Executes on button press in sql_remove.
function sql_remove_Callback(hObject, eventdata, handles)
% hObject    handle to sql_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bindb_admin_dropsqltables();
