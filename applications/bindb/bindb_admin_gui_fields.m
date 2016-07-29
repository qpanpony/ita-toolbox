function varargout = bindb_admin_gui_fields(varargin)
% BINDB_ADMIN_GUI_FIELDS MATLAB code for bindb_admin_gui_fields.fig
%      BINDB_ADMIN_GUI_FIELDS, by itself, creates a new BINDB_ADMIN_GUI_FIELDS or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_ADMIN_GUI_FIELDS returns the handle to a new BINDB_ADMIN_GUI_FIELDS or the handle to
%      the existing singleton*.
%
%      BINDB_ADMIN_GUI_FIELDS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_ADMIN_GUI_FIELDS.M with the given input arguments.
%
%      BINDB_ADMIN_GUI_FIELDS('Property','Value',...) creates a new BINDB_ADMIN_GUI_FIELDS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_admin_gui_fields_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_admin_gui_fields_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_admin_gui_fields

% Last Modified by GUIDE v2.5 12-Dec-2011 14:30:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_admin_gui_fields_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_admin_gui_fields_OutputFcn, ...
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


% --- Executes just before bindb_admin_gui_fields is made visible.
function bindb_admin_gui_fields_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_admin_gui_fields (see VARARGIN)

% Choose default command line output for bindb_admin_gui_fields
handles.output = hObject;

% Register globals
global bindb_data;

% Update list
handles = updateList(hObject, handles);

% Update handles structure
guidata(hObject, handles);

% Admin mode
if bindb_data.Settings.AdminMode ~= 1
    set(handles.actions_add, 'Enable', 'off');
    set(handles.actions_remove, 'Enable', 'off');
    bindb_addlog('Measurement fields', 'Window functionality requires admin mode.', 1);
end


% --- Outputs from this function are returned to the command line.
function varargout = bindb_admin_gui_fields_OutputFcn(hObject, eventdata, handles) 
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

close(handles.figure1);


% --- Executes on button press in actions_add.
function actions_add_Callback(hObject, eventdata, handles)
% hObject    handle to actions_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open add field gui and wait
waitfor(bindb_admin_gui_fields_add());

% Update list
handles = updateList(hObject, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in actions_remove.
function actions_remove_Callback(hObject, eventdata, handles)
% hObject    handle to actions_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open remove field gui and wait
waitfor(bindb_admin_gui_fields_remove());

% Update list
handles = updateList(hObject, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in fields_list.
function fields_list_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to fields_list (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(eventdata.Indices)
    set(handles.fields_description, 'String', sprintf(handles.Fields{eventdata.Indices(1), 3}));
end


function handles = updateList(hObject, handles)
% hObject    handle to GCBO
% handles    structure with handles and user data (see GUIDATA)

% Load and store current fields
bindb_fields_get();
bindb_fields_store();

% Declare globals
global bindb_data;

if ~isempty(bindb_data.Fields)
    handles.Fields = cell(length(bindb_data.Fields), 3);    
    for index = 1:length(bindb_data.Fields)
        % Store name
        handles.Fields{index, 1} = bindb_data.Fields(index).Name;
        % Store type 
        types = { 'Numeric - Integer', 'Numeric - Double', 'String - no length limit', 'String - predefined values' };
        handles.Fields{index, 2} = types{bindb_data.Fields(index).Type};
        % Store description
        handles.Fields{index, 3} = bindb_data.Fields(index).Description;                
    end  
    
    % Display fields in table
    set(handles.fields_list, 'Data', handles.Fields(:, 1:2));  
else
    handles.Fields = {};
    set(handles.fields_list, 'Data', {}); 
end   


% --- Executes on button press in health_check.
function health_check_Callback(hObject, eventdata, handles)
% hObject    handle to health_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if bindb_fields_check == 1
    set(handles.health_status, 'String', 'field tables are healty');
else
    set(handles.health_status, 'String', 'maintenance required');
end
