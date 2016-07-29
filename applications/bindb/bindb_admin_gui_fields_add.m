function varargout = bindb_admin_gui_fields_add(varargin)
% BINDB_ADMIN_GUI_FIELDS_ADD MATLAB code for bindb_admin_gui_fields_add.fig
%      BINDB_ADMIN_GUI_FIELDS_ADD, by itself, creates a new BINDB_ADMIN_GUI_FIELDS_ADD or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_ADMIN_GUI_FIELDS_ADD returns the handle to a new BINDB_ADMIN_GUI_FIELDS_ADD or the handle to
%      the existing singleton*.
%
%      BINDB_ADMIN_GUI_FIELDS_ADD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_ADMIN_GUI_FIELDS_ADD.M with the given input arguments.
%
%      BINDB_ADMIN_GUI_FIELDS_ADD('Property','Value',...) creates a new BINDB_ADMIN_GUI_FIELDS_ADD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_admin_gui_fields_add_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_admin_gui_fields_add_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_admin_gui_fields_add

% Last Modified by GUIDE v2.5 26-Jan-2012 13:39:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_admin_gui_fields_add_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_admin_gui_fields_add_OutputFcn, ...
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


% --- Executes just before bindb_admin_gui_fields_add is made visible.
function bindb_admin_gui_fields_add_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_admin_gui_fields_add (see VARARGIN)

% Choose default command line output for bindb_admin_gui_fields_add
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bindb_admin_gui_fields_add wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_admin_gui_fields_add_OutputFcn(hObject, eventdata, handles) 
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

% Declare globals
global bindb_data;

% Check if name field is empty
name = strtrim(get(handles.name_field, 'String'));
if strcmp(name, '') == 0 
    % Check if column name is taken
    data = bindb_querymat(['SELECT COUNT(*) FROM `Fields` WHERE `Name`=''' name '''']);       
    if data > 0
        set(handles.name_field, 'BackgroundColor', [1.0, 0.8, 0.8]);
        req1 = 0;
        bindb_addlog('Add measurement field', 'column name must be unique', 1);
    else        
        set(handles.name_field, 'BackgroundColor', [1.0, 1.0, 1.0]);
        req1 = 1;
    end
else
    set(handles.name_field, 'BackgroundColor', [1.0, 0.8, 0.8]);
    req1 = 0;
end

% No requirements for description field
description = bindb_tostring(get(handles.description_field, 'String'));

% No requirements for type field
% id    nice name                           sql name
% 1     Numeric - Integer                   int
% 2     Numeric - Double                    double
% 3     String - no length limit            text
% 4     String - predefined values          text
types = {'int', 'real', 'text', 'text'};
typeid = get(handles.type_popup, 'Value');
type = types{typeid};

% Check values
if typeid == 4
    values = get(handles.values_field, 'String');
    vcount = size(values, 1); 
    
    % Build line  
    line = '';
    for index = 1:vcount
        line = [line '@' strtrim([values(index, :)])];
    end
    line = line(2:end);    
    req2 = (vcount > 1);
else
    req2 = 1;
end

if req1 && req2
    % Create column
    try
        if typeid == 4
            bindb_exec(['INSERT INTO `Fields` (`Name`, `Description`, `Type`, `Values`) VALUES (''' name ''', ''' description ''', ' num2str(typeid) ', ''' line ''')']);
        else
            bindb_exec(['INSERT INTO `Fields` (`Name`, `Description`, `Type`) VALUES (''' name ''', ''' description ''', ' num2str(typeid) ')']);
        end
        bindb_exec(['ALTER TABLE `Measurements` ADD COLUMN `' name '` ' type]);
    catch err
        bindb_addlog('Add measurement field', err.message, 1);
    end
    
    delete(handles.figure1);
else
    % Update handles structure
    guidata(hObject, handles);
end
 


% --- Executes on selection change in type_popup.
function type_popup_Callback(hObject, eventdata, handles)
% hObject    handle to type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') == 4
    set(handles.values_field, 'Enable', 'on');
else
    set(handles.values_field, 'Enable', 'off');
end
