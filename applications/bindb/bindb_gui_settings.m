function varargout = bindb_gui_settings(varargin)
% BINDB_GUI_SETTINGS MATLAB code for bindb_gui_settings.fig
%      BINDB_GUI_SETTINGS, by itself, creates a new BINDB_GUI_SETTINGS or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_SETTINGS returns the handle to a new BINDB_GUI_SETTINGS or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_SETTINGS.M with the given input arguments.
%
%      BINDB_GUI_SETTINGS('Property','Value',...) creates a new BINDB_GUI_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_settings

% Last Modified by GUIDE v2.5 04-Jan-2012 13:26:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_settings_OutputFcn, ...
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


% --- Executes just before bindb_gui_settings is made visible.
function bindb_gui_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_settings (see VARARGIN)

% Choose default command line output for bindb_gui_settings
handles.output = hObject;

% Register globals
global bindb_data;

% Load current values
set(handles.system_keeplog, 'Value', bindb_data.Settings.KeepLog);
set(handles.system_autoupdate, 'Value', bindb_data.Settings.AutoUpdate);
set(handles.system_measurementspath, 'String', bindb_data.Settings.MeasurementsPath);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in action_save.
function action_save_Callback(hObject, eventdata, handles)
% hObject    handle to action_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Register globals
global bindb_data;

% Save values
bindb_data.Settings.KeepLog = get(handles.system_keeplog, 'Value');
bindb_data.Settings.AutoUpdate = get(handles.system_autoupdate, 'Value');
bindb_data.Settings.MeasurementsPath = get(handles.system_measurementspath, 'String');
bindb_store();

% Close gui
delete(handles.figure1);


% --- Executes on button press in system_measurementspath_browse.
function system_measurementspath_browse_Callback(hObject, eventdata, handles)
% hObject    handle to system_measurementspath_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path = uigetdir(fileparts(which('bindb_setup.m')), 'Select directory in which all measurements will be stored.');
if path ~= 0
    set(handles.system_measurementspath, 'String', path);
end
