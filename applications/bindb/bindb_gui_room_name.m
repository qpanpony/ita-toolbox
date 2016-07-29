function varargout = bindb_gui_room_name(varargin)
% BINDB_GUI_ROOM_NAME MATLAB code for bindb_gui_room_name.fig
%      BINDB_GUI_ROOM_NAME, by itself, creates a new BINDB_GUI_ROOM_NAME or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_ROOM_NAME returns the handle to a new BINDB_GUI_ROOM_NAME or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_ROOM_NAME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_ROOM_NAME.M with the given input arguments.
%
%      BINDB_GUI_ROOM_NAME('Property','Value',...) creates a new BINDB_GUI_ROOM_NAME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_room_name_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_room_name_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_room_name

% Last Modified by GUIDE v2.5 20-Dec-2011 15:40:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_room_name_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_room_name_OutputFcn, ...
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


% --- Executes just before bindb_gui_room_name is made visible.
function bindb_gui_room_name_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_room_name (see VARARGIN)

% Wait for output
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_room_name_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.Name;
delete(hObject);


% --- Executes on button press in actions_update.
function actions_update_Callback(hObject, eventdata, handles)
% hObject    handle to actions_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

name = strtrim(get(handles.name_field, 'String'));

if strcmp(name, '') == 0
    % Check if name is already in database
    if bindb_queryrowsmat(['SELECT COUNT(*) FROM Rooms WHERE Name=''' name ''''], 1) ~= 0
        set(handles.name_field, 'BackgroundColor', [1.0, 0.8, 0.8]);
        bindb_addlog('Update room name', 'room name already used', 1);
    else        
        set(handles.name_field, 'BackgroundColor', [1.0, 1.0, 1.0]);
        
        % Save name
        handles.Name = name;
        
        % Update handles structure
        guidata(handles.figure1, handles);
        
        % Procees with output
        uiresume(handles.figure1);
    end
else
    set(handles.name_field, 'BackgroundColor', [1.0, 0.8, 0.8]);
end
