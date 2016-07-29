function varargout = bindb_gui_room_remove(varargin)
% BINDB_GUI_ROOM_REMOVE MATLAB code for bindb_gui_room_remove.fig
%      BINDB_GUI_ROOM_REMOVE, by itself, creates a new BINDB_GUI_ROOM_REMOVE or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_ROOM_REMOVE returns the handle to a new BINDB_GUI_ROOM_REMOVE or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_ROOM_REMOVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_ROOM_REMOVE.M with the given input arguments.
%
%      BINDB_GUI_ROOM_REMOVE('Property','Value',...) creates a new BINDB_GUI_ROOM_REMOVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_room_remove_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_room_remove_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_room_remove

% Last Modified by GUIDE v2.5 13-Dec-2011 13:19:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_room_remove_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_room_remove_OutputFcn, ...
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


% --- Executes just before bindb_gui_room_remove is made visible.
function bindb_gui_room_remove_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_room_remove (see VARARGIN)

% Choose default command line output for bindb_gui_room_remove
handles.output = hObject;

% Declare globals
global bindb_data;

% Get rooms
handles.Rooms = [bindb_data.Rooms_Outbox bindb_data.Rooms];

if ~isempty(handles.Rooms)
    % Mark local rooms
    names = {handles.Rooms.Name};
    for index = 1:length(names)
        if handles.Rooms(index).ID < 0
            names{index} = ['(local) ' names{index}];
        end
    end
    % Display rooms
    set(handles.room_popup, 'String', names);

    % Select room
    for index = 1:length(handles.Rooms)
        if handles.Rooms(index).ID == varargin{1}
            set(handles.room_popup, 'Value', index);
            break;
        end
    end    
    
    % Update warning
    updateWarning(hObject, handles);
else
    set(handles.room_popup, 'String', 'no rooms');
    set(handles.actions_OK, 'Enable', 'off');
end

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_room_remove_OutputFcn(hObject, eventdata, handles) 
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

% Register globals
global bindb_data;

% Get id
id = handles.Rooms(get(handles.room_popup, 'Value')).ID;

% Remove room
if id < 0
    for index = 1:length(bindb_data.Rooms_Outbox)
        if bindb_data.Rooms_Outbox(1).ID == id
           bindb_data.Rooms_Outbox(1) = []; 
        end
    end
else
    try
        % Remove db entry    
        bindb_exec(['DELETE FROM Rooms WHERE O_ID=' num2str(id)]);    

        % Load and save rooms
        bindb_rooms_get();
        bindb_rooms_store();
    catch err
        bindb_addlog('Remove room', err.message, 1);
    end
end

% Close gui
delete(handles.figure1);


% --- Executes on selection change in room_popup.
function room_popup_Callback(hObject, eventdata, handles)
% hObject    handle to room_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateWarning(hObject, handles);


function updateWarning(hObject, handles)
% Update the warning to show affected rows count

% Get id
id = handles.Rooms(get(handles.room_popup, 'Value')).ID;

% Register globals
global bindb_data;

if id < 0
    commt = length(bindb_data.Measurements_Outbox);
    if commt == 0
        set(handles.room_warning, 'String', 'unused local room');
        set(handles.actions_OK, 'Enable', 'on');
    else
        used = false;
        for index = 1:commt
            if bindb_data.Measurements_Outbox(index).Room.ID == id
                used = true;
                break;
            end
        end
        
        if used
            set(handles.room_warning, 'String', 'local measurement is using this room');
            set(handles.actions_OK, 'Enable', 'off');
        else
            set(handles.room_warning, 'String', 'unused local room');
            set(handles.actions_OK, 'Enable', 'on');
        end
    end
else
    if bindb_isonline()
        % Show warning
        num = bindb_queryrowsmat(['SELECT COUNT(*) FROM Measurements WHERE O_ID=' num2str(id)], 1);    
        if num == 0
            set(handles.room_warning, 'String', 'this room is unused');
            set(handles.actions_OK, 'Enable', 'on');
        elseif num == 1
            set(handles.room_warning, 'String', 'one measurement is using this room');
            set(handles.actions_OK, 'Enable', 'off');
        else
            set(handles.room_warning, 'String', [num2str(num) ' measurements are using this room']);
            set(handles.actions_OK, 'Enable', 'off');
        end
    else
        set(handles.room_warning, 'String', 'database connection required');
        set(handles.actions_OK, 'Enable', 'off');
    end
end
