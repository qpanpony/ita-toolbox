function varargout = bindb_gui_room_search(varargin)
% BINDB_GUI_ROOM_SEARCH MATLAB code for bindb_gui_room_search.fig
%      BINDB_GUI_ROOM_SEARCH, by itself, creates a new BINDB_GUI_ROOM_SEARCH or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_ROOM_SEARCH returns the handle to a new BINDB_GUI_ROOM_SEARCH or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_ROOM_SEARCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_ROOM_SEARCH.M with the given input arguments.
%
%      BINDB_GUI_ROOM_SEARCH('Property','Value',...) creates a new BINDB_GUI_ROOM_SEARCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_room_search_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_room_search_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_room_search

% Last Modified by GUIDE v2.5 27-May-2012 13:26:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_room_search_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_room_search_OutputFcn, ...
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


% --- Executes just before bindb_gui_room_search is made visible.
function bindb_gui_room_search_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_room_search (see VARARGIN)

% Choose default command line output for bindb_gui_room_search
handles.output = hObject;

% Register globals
global bindb_data;

% Add rooms to list
handles.Rooms = [bindb_data.Rooms_Outbox bindb_data.Rooms];

% Update list
display_rooms(handles);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_room_search_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in room_list.
function room_list_Callback(hObject, eventdata, handles)
% hObject    handle to room_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get selected index
index = get(handles.room_list, 'Value');

if ~isempty(index)
    % Display room image    
    bindb_drawroom(handles.room_canvas, handles.Rooms(index).Layout);

    % Display description
    set(handles.room_description, 'String', sprintf(handles.Rooms(index).Description));
end


% --- Executes on button press in actions_remove.
function actions_remove_Callback(hObject, eventdata, handles)
% hObject    handle to actions_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get selected index
index = get(handles.room_list, 'Value');

% Remove room
if ~isempty(index)
    waitfor(bindb_gui_room_remove(handles.Rooms(index).ID));
    
    % Get current rooms
    bindb_room_get();
    
    % Register globals
    global bindb_data;

    % Add rooms to list
    handles.Rooms = [bindb_data.Rooms_Outbox bindb_data.Rooms];

    % Update list
    display_rooms(handles);
    
    % Update handles structure
    guidata(hObject, handles);
end


function search_field_Callback(hObject, eventdata, handles)
% hObject    handle to search_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Register globals
global bindb_data;

% Get all rooms
rooms = [bindb_data.Rooms_Outbox bindb_data.Rooms];

% Get search string
search = lower(strtrim(get(handles.search_field, 'String')));

if strcmp(search, '')
    % Take all rooms
    handles.Rooms = rooms;
else
    handles.Rooms = struct('ID', {}, 'Name', {}, 'Description', {}, 'Layout', {});
    % Use search string to filter rooms
    for index = 1:length(rooms)
        if ~isempty(strfind(lower(rooms(index).Name), search)) || ~isempty(strfind(lower(rooms(index).Description), search)) || ~isempty(strfind(search, lower(rooms(index).Name))) || ~isempty(strfind(search, lower(rooms(index).Description)))
            handles.Rooms(end+1) = rooms(index);
        end
    end
end

% Update list
display_rooms(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in search_clc.
function search_clc_Callback(hObject, eventdata, handles)
% hObject    handle to search_clc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear search
set(handles.search_field, 'String', '');

% Execute callback
search_field_Callback(handles.search_field, eventdata, handles)


% --- Executes on button press in actions_save.
function actions_save_Callback(hObject, eventdata, handles)
% hObject    handle to actions_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get selected id
index = get(handles.room_list, 'Value');

% Get room name room
if ~isempty(index)
    filename = handles.Rooms(index).Name;
else
    return;
end

% Create new file path
[newfile, path] = uiputfile('*.png', 'Save room image', filename);

% Save layout to file
if newfile ~= 0
    imgframe = getframe(handles.room_canvas, [2 2 401 401]);
    imwrite(imgframe.cdata, fullfile(path, newfile), 'png');     
end


function display_rooms(handles)
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.Rooms)
    % Add '(local)' to local rooms
    names = {handles.Rooms.Name};
    for index = 1:length(names)
        if handles.Rooms(index).ID < 0
            names{index} = ['(local) ' names{index}];
        end
    end
    
    % Update list
    set(handles.room_list, 'String', names);

    % Display first room image
    bindb_drawroom(handles.room_canvas, handles.Rooms(1).Layout);

    % Display first description
    set(handles.room_description, 'String', sprintf(handles.Rooms(1).Description));
    
    % Select first item
    set(handles.room_list, 'Value', 1);
else
    % Update list
    set(handles.room_list, 'String', []);
    set(handles.room_list, 'Value', []);
    
    % Display grid
    bindb_drawroom(handles.room_canvas, '');
    
    % Display first description
    set(handles.room_description, 'String', '');
end


% --- Executes on button press in actions_measurement.
function actions_measurement_Callback(hObject, eventdata, handles)
% hObject    handle to actions_measurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get selected index
index = get(handles.room_list, 'Value');

% Start measurement add gui and close this one
if ~isempty(index)
   bindb_gui_measurement_add(handles.Rooms(index).ID);
   delete(handles.figure1);
end
