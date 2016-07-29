function varargout = bindb_admin_gui_fields_remove(varargin)
% BINDB_ADMIN_GUI_FIELDS_REMOVE MATLAB code for bindb_admin_gui_fields_remove.fig
%      BINDB_ADMIN_GUI_FIELDS_REMOVE, by itself, creates a new BINDB_ADMIN_GUI_FIELDS_REMOVE or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_ADMIN_GUI_FIELDS_REMOVE returns the handle to a new BINDB_ADMIN_GUI_FIELDS_REMOVE or the handle to
%      the existing singleton*.
%
%      BINDB_ADMIN_GUI_FIELDS_REMOVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_ADMIN_GUI_FIELDS_REMOVE.M with the given input arguments.
%
%      BINDB_ADMIN_GUI_FIELDS_REMOVE('Property','Value',...) creates a new BINDB_ADMIN_GUI_FIELDS_REMOVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_admin_gui_fields_remove_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_admin_gui_fields_remove_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_admin_gui_fields_remove

% Last Modified by GUIDE v2.5 01-Dec-2011 18:47:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_admin_gui_fields_remove_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_admin_gui_fields_remove_OutputFcn, ...
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


% --- Executes just before bindb_admin_gui_fields_remove is made visible.
function bindb_admin_gui_fields_remove_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_admin_gui_fields_remove (see VARARGIN)

% Choose default command line output for bindb_admin_gui_fields_remove
handles.output = hObject;

% Get fields that are nullable
data = bindb_query('SHOW COLUMNS FROM `Measurements`');    
handles.fields = [];
fid = 1;
for index = 1:size(data, 1)
    % Add field if column is nullable
    if strcmp(data{index, 3}, 'YES')
        handles.fields{fid} = data{index, 1};
        fid = fid + 1;
    end
end

% Remove comment field
handles.fields(1) = [];

if ~isempty(handles.fields)
    % Display fields in popup
    set(handles.field_popup, 'String', handles.fields);

    % Update warning
    updateWarning(hObject, handles);
else
    set(handles.actions_OK, 'Enable', 'off');
end

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = bindb_admin_gui_fields_remove_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in actions_OK.
function actions_OK_Callback(hObject, eventdata, handles)
% hObject    handle to actions_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get field
field = handles.fields{get(handles.field_popup, 'Value')};

% Remove column
try
    bindb_exec(['ALTER TABLE `Measurements` DROP COLUMN `' field '`']);
    bindb_exec(['DELETE FROM `Fields` WHERE `Name`=''' field ''' ']);
catch err
    bindb_addlog('Remove measurement field', err.message, 1);
end

% Close gui
delete(handles.figure1);


% --- Executes on selection change in field_popup.
function field_popup_Callback(hObject, eventdata, handles)
% hObject    handle to field_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateWarning(hObject, handles);


function updateWarning(hObject, handles)
% Update the warning to show affected rows count
field = handles.fields{get(handles.field_popup, 'Value')};
data = bindb_querymat(['SELECT COUNT(`' field '`) FROM `Measurements`']);    
set(handles.field_warning, 'String', [num2str(data) ' measurements will loose information']);

% Update handles structure
guidata(hObject, handles);
