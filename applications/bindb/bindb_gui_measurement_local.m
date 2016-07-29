function varargout = bindb_gui_measurement_local(varargin)
% BINDB_GUI_MEASUREMENT_LOCAL MATLAB code for bindb_gui_measurement_local.fig
%      BINDB_GUI_MEASUREMENT_LOCAL, by itself, creates a new BINDB_GUI_MEASUREMENT_LOCAL or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_MEASUREMENT_LOCAL returns the handle to a new BINDB_GUI_MEASUREMENT_LOCAL or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_MEASUREMENT_LOCAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_MEASUREMENT_LOCAL.M with the given input arguments.
%
%      BINDB_GUI_MEASUREMENT_LOCAL('Property','Value',...) creates a new BINDB_GUI_MEASUREMENT_LOCAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_measurement_local_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_measurement_local_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_measurement_local

% Last Modified by GUIDE v2.5 07-Feb-2012 14:59:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_measurement_local_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_measurement_local_OutputFcn, ...
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


% --- Executes just before bindb_gui_measurement_local is made visible.
function bindb_gui_measurement_local_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_measurement_local (see VARARGIN)

% Choose default command line output for bindb_gui_measurement_local
handles.output = hObject;

% Update table
handles = updateTable(handles)

% Create action states
handles.load_item = 0;
handles.loadshow_item = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bindb_gui_measurement_local wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_measurement_local_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in actions_load.
function actions_load_Callback(hObject, eventdata, handles)
% hObject    handle to actions_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Cancel loadshow and delete
handles.laodshow_item = 0;
set(handles.actions_loadshow, 'String', 'Load + Show room');

if handles.load_item == 1
    % Change button text
    set(handles.actions_load, 'String', 'Load');
    
    % Cancel load 
    handles.load_item = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Change button text
    set(handles.actions_load, 'String', 'Cancel load');
    
    % Start load 
    handles.load_item = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in actions_loadshow.
function actions_loadshow_Callback(hObject, eventdata, handles)
% hObject    handle to actions_loadshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Cancel load and delete 
handles.load_item = 0;
set(handles.actions_load, 'String', 'Load');

if handles.loadshow_item == 1
    % Change button text
    set(handles.actions_loadshow, 'String', 'Load + Show room');
    
    % Cancel loadshow 
    handles.loadshow_item = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Change button text
    set(handles.actions_loadshow, 'String', 'Cancel load');
    
    % Start loadshow 
    handles.loadshow_item = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in actions_reload.
function actions_reload_Callback(hObject, eventdata, handles)
% hObject    handle to actions_reload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reload measurements
bindb_measurement_get();

% Update table
handles = updateTable(handles);

% Update handles structure
guidata(hObject, handles);


% Update handles structure
guidata(hObject, handles);


function handles = updateTable(handles)

% Register globals
global bindb_data;

% Read measurements
handles.Measurements = cell(size(bindb_data.Measurements, 1), 6);
for index = 1:size(bindb_data.Measurements, 1)
    handles.Measurements(index, :) = {bindb_data.Measurements{index}.Timestamp, bindb_data.Measurements{index}.Author, bindb_data.Measurements{index}.Version, bindb_data.Measurements{index}.Room.Name, bindb_data.Measurements{index}.Comment, index};
end

% Update table
set(handles.measurements_table, 'Data', handles.Measurements(:, 1:5));


% --- Executes when selected cell(s) is changed in measurements_table.
function measurements_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to measurements_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Register globals
global bindb_data;

if ~isempty(eventdata.Indices)
    if handles.load_item == 1
        % Make measurement avaliable in workspace
        global mmt;
        mmt = bindb_data.Measurements{handles.Measurements{eventdata.Indices(1), 6}};                
        evalin('base', 'global mmt;');
        
        % Change button text
        set(handles.actions_load, 'String', 'Load');

        % End load 
        handles.load_item = 0;
        set(handles.figure1, 'Pointer', 'arrow');
    elseif handles.loadshow_item == 1
        
        
    elseif handles.delete_item == 1
        % Change button text
        set(handles.actions_delete, 'String', 'Delete');

        % End delete
        handles.delete_item = 0;
        set(handles.figure1, 'Pointer', 'arrow');
    end
end
