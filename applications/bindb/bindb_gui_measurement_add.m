function varargout = bindb_gui_measurement_add(varargin)
% BINDB_GUI_MEASUREMENT_ADD MATLAB code for bindb_gui_measurement_add.fig
%      BINDB_GUI_MEASUREMENT_ADD, by itself, creates a new BINDB_GUI_MEASUREMENT_ADD or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_MEASUREMENT_ADD returns the handle to a new BINDB_GUI_MEASUREMENT_ADD or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_MEASUREMENT_ADD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_MEASUREMENT_ADD.M with the given input arguments.
%
%      BINDB_GUI_MEASUREMENT_ADD('Property','Value',...) creates a new BINDB_GUI_MEASUREMENT_ADD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_measurement_add_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_measurement_add_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_measurement_add

% Last Modified by GUIDE v2.5 14-Apr-2012 12:45:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_measurement_add_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_measurement_add_OutputFcn, ...
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


% --- Executes just before bindb_gui_measurement_add is made visible.
function bindb_gui_measurement_add_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_measurement_add (see VARARGIN)

% Choose default command line output for bindb_gui_measurement_add
handles.output = hObject;

% Register globals
global bindb_data;

% Get rooms
handles.Rooms = [bindb_data.Rooms_Outbox bindb_data.Rooms];

% Init comments
handles.Comments = { '' };
handles.ActiveComment = 1;

% Abort if no rooms
if ~isempty(handles.Rooms)    
    % Add '(local)' to local rooms
    names = {handles.Rooms.Name};
    for index = 1:length(names)
        if handles.Rooms(index).ID < 0
            names{index} = ['(local) ' names{index}];
        end
    end
    
    % Fill popup
    set(handles.room_popup, 'String', names);

    % Choose room
    if length(varargin) == 1
        for index = 1:length(handles.Rooms)
            if handles.Rooms(index).ID == varargin{1}
                rindex = index;
                break;
            end
        end
    else
        rindex = 1;
    end   
    
    % Select room
    bindb_drawroom(handles.room_canvas, handles.Rooms(rindex).Layout);
    set(handles.room_popup, 'Value', rindex);    
else
    set(handles.room_popup, 'String', 'no rooms');
    set(handles.locations_add, 'Enable', 'off');
    set(handles.measurement_save, 'Enable', 'off');
end

% Create remove states
handles.remove_measurement = 0;
handles.remove_location = 0;
handles.remove_microphone = 0;
handles.remove_source = 0;
handles.run_measurement = 0;

% Get sensors
devListHandle = ita_device_list_handle;
sensor = devListHandle('sensor');
bindb_updateuielement(handles.equipment_microphones, 'ColumnFormat', 4, sensor(:, 1)');

% Get sensors
actuator = devListHandle('actuator');
bindb_updateuielement(handles.equipment_sources, 'ColumnFormat', 4, actuator(:, 1)');

% Push workspace button
equipment_workspace_Callback(handles.equipment_workspace, eventdata, handles);

% Get author
set(handles.measurement_author, 'String', ita_preferences('AuthorStr'));

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_measurement_add_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in room_popup.
function room_popup_Callback(hObject, eventdata, handles)
% hObject    handle to room_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Abort if no rooms
if strcmp(get(handles.room_popup, 'String'), 'no')
    return;
end

% Get selected index
index = get(handles.room_popup, 'Value');

% Show selected room image
bindb_drawroom(handles.room_canvas, handles.Rooms(index).Layout);

% Reset locations and table
set(handles.locations_table, 'Data', cell(0, 3));

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in locations_add.
function locations_add_Callback(hObject, eventdata, handles)
% hObject    handle to locations_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set current axis and get point
axes(handles.room_canvas);
[x, y, button] = ginput(1);

% Abort if points not in axes
if x < 1 || x > 401 || y < 1 || y > 401
    return;
end;

% Round values
x = round(x);
y = round(y);

% Move to grid of 20 around 201 on rightclick
if button ~= 1
    % Fix x
    rest = mod(x - 1, 20);
    if rest < 10
        x = x - rest;
    else
        x = x - rest + 20;
    end
    % Fix y
    rest = mod(y - 1, 20);
    if rest < 10
        y = y - rest;
    else
        y = y - rest + 20;
    end
end

% Get locations
data = get(handles.locations_table, 'Data');

% Add row
data(end+1,:) = { '', x, y };

% Add annotation, [0.703 0.902 0.980] as color alternative
annotation = text(x, y, num2str(size(data, 1)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'BackgroundColor', [1 0.784 0.588]);

% Save annotation handle
handles.annotations(size(data, 1)) = annotation;

% Update location table
set(handles.locations_table, 'Data', data);

% Update equipment tables
bindb_updateuielement(handles.equipment_microphones, 'ColumnFormat', 2, bindb_indexcells(size(data, 1), 'no location'));
bindb_updateuielement(handles.equipment_sources, 'ColumnFormat', 2, bindb_indexcells(size(data, 1), 'no location'));

% Enable microphone/source adding
set(handles.equipment_addmicrophone, 'Enable', 'on');
set(handles.equipment_addsource, 'Enable', 'on');

% Enable remove
set(handles.locations_remove, 'Enable', 'on');
   
% Update handles structure
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in locations_table.
function locations_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to locations_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Update locations if no error
if isempty(eventdata.Error) && ~isempty(eventdata.NewData)
    % Get data       
    data = get(handles.locations_table, 'Data');        

    % Update annotaion id and position
    set(handles.annotations(eventdata.Indices(1)), 'String', num2str(eventdata.Indices(1)), 'Position', [data{eventdata.Indices(1), 2} data{eventdata.Indices(1), 3}]);
end
    
% Update handles structure
guidata(hObject, handles);  


% --- Executes on button press in locations_remove.
function locations_remove_Callback(hObject, eventdata, handles)
% hObject    handle to locations_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.remove_location == 1
    % Change button text
    set(handles.locations_remove, 'String', 'Remove location');
    
    % Cancel remove 
    handles.remove_location = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Change button text
    set(handles.locations_remove, 'String', 'Cancel remove');
    
    % Start remove 
    handles.remove_location = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in locations_table.
function locations_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to locations_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Remove row
if handles.remove_location == 1 && ~isempty(eventdata.Indices)
    % Change button text
    set(handles.locations_remove, 'String', 'Remove location');
    
    % Finish remove 
    handles.remove_location = 0;
    set(handles.figure1, 'Pointer', 'arrow');
    
    % Delete annotation
    delete(handles.annotations(eventdata.Indices(1)));
    handles.annotations(eventdata.Indices(1)) = [];
    
    % Delete row
    data = get(handles.locations_table, 'Data');
    data(eventdata.Indices(1), :) = [];
    set(handles.locations_table, 'Data', data);   
    
    % Update annotations
    if size(data, 1) >= eventdata.Indices(1)
        for index = eventdata.Indices(1):size(data, 1)
            % Update annotaion id and position
            set(handles.annotations(index), 'String', num2str(index), 'Position', [data{index, 2} data{index, 3}]);
        end
    end    
    
    if isempty(data)
        % Disable microphone/source adding/removing if no locations
        set(handles.equipment_addmicrophone, 'Enable', 'off');
        set(handles.equipment_addsource, 'Enable', 'off');
        set(handles.equipment_removemicrophone, 'Enable', 'off');
        set(handles.equipment_removesource, 'Enable', 'off');
        
        % Disable remove if no rows
        set(handles.locations_remove, 'Enable', 'off');
        
        % Remove microphones/sources
        set(handles.equipment_microphones, 'Data', cell(0, 5));
        set(handles.equipment_sources, 'Data', cell(0, 4));
    else
        % Update microphones
        bindb_updateuielement(handles.equipment_microphones, 'ColumnFormat', 2, bindb_indexcells(size(data, 1), 'no location'));
        
        % Update sources
        bindb_updateuielement(handles.equipment_sources, 'ColumnFormat', 2, bindb_indexcells(size(data, 1), 'no location'));        
    end
end

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function measurement_script_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measurement_script (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

files = what(bindb_folderpath('scripts'));
set(hObject, 'String', files.m);


% --- Executes on button press in measurements_add.
function measurements_add_Callback(hObject, eventdata, handles)
% hObject    handle to measurements_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add row
data = get(handles.measurements_table, 'Data');
data(end+1,:) = handles.Fields(3, :);
set(handles.measurements_table, 'Data', data);

% Add comment
handles.Comments(end+1) = { '' };

% Update equipment tables
bindb_updateuielement(handles.equipment_microphones, 'ColumnFormat', 1, bindb_indexcells(size(data(:,1)), 'no measurement'));
bindb_updateuielement(handles.equipment_sources, 'ColumnFormat', 1, bindb_indexcells(size(data(:,1)), 'no measurement'));

% Enable remove
set(handles.measurements_remove, 'Enable', 'on');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in measurements_remove.
function measurements_remove_Callback(hObject, eventdata, handles)
% hObject    handle to measurements_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.remove_measurement == 1
    % Change button text
    set(handles.measurements_remove, 'String', 'Remove measurement');
    
    % Cancel remove 
    handles.remove_measurement = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Cancel run
    set(handles.measurements_run, 'String', 'Run script');       
    handles.run_measurement = 0;
    
    % Change button text
    set(handles.measurements_remove, 'String', 'Cancel remove');
    
    % Start remove 
    handles.remove_measurement = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in measurements_run.
function measurements_run_Callback(hObject, eventdata, handles)
% hObject    handle to measurements_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.run_measurement == 1
    % Change button text
    set(handles.measurements_run, 'String', 'Run script');
    
    % Cancel remove 
    handles.run_measurement = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Cancel remove
    set(handles.measurements_remove, 'String', 'Remove measurement');
    handles.remove_measurement = 0;
    
    % Change button text
    set(handles.measurements_run, 'String', 'Cancel run');
    
    % Start remove 
    handles.run_measurement = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in equipment_addmicrophone.
function equipment_addmicrophone_Callback(hObject, eventdata, handles)
% hObject    handle to equipment_addmicrophone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add new row
data = get(handles.equipment_microphones, 'Data');
data(end + 1, :) = {size(get(handles.measurements_table, 'Data'), 1) size(get(handles.locations_table, 'Data'), 1) 0 'no hardware' 'no variables'};
set(handles.equipment_microphones, 'Data', data);

% Enable remove
set(handles.equipment_removemicrophone, 'Enable', 'on');


% --- Executes when selected cell(s) is changed in equipment_microphones.
function equipment_microphones_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to equipment_microphones (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Remove row
if handles.remove_microphone == 1 && ~isempty(eventdata.Indices)
    % Change button text
    set(handles.equipment_removemicrophone, 'String', 'Remove microphone');
    
    % Finish remove 
    handles.remove_microphone = 0;
    set(handles.figure1, 'Pointer', 'arrow');
    
    % Delete row
    data = get(handles.equipment_microphones, 'Data');
    data(eventdata.Indices(1), :) = [];
    set(handles.equipment_microphones, 'Data', data); 
    
    % Disable remove if no rows
    if isempty(data)
        set(handles.equipment_removemicrophone, 'Enable', 'off');
    end
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in equipment_removemicrophone.
function equipment_removemicrophone_Callback(hObject, eventdata, handles)
% hObject    handle to equipment_removemicrophone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.remove_microphone == 1
    % Change button text
    set(handles.equipment_removemicrophone, 'String', 'Remove microphone');
    
    % Cancel remove 
    handles.remove_microphone = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Change button text
    set(handles.equipment_removemicrophone, 'String', 'Cancel remove');
    
    % Start remove 
    handles.remove_microphone = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in equipment_sources.
function equipment_sources_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to equipment_sources (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Remove row
if handles.remove_source == 1 && ~isempty(eventdata.Indices)
    % Change button text
    set(handles.equipment_removesource, 'String', 'Remove source');
    
    % Finish remove 
    handles.remove_source = 0;
    set(handles.figure1, 'Pointer', 'arrow');
    
    % Delete row
    data = get(handles.equipment_sources, 'Data');
    data(eventdata.Indices(1), :) = [];
    set(handles.equipment_sources, 'Data', data);  
    
    % Disable remove if no rows
    if isempty(data)
        set(handles.equipment_removesource, 'Enable', 'off');
    end
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in equipment_addsource.
function equipment_addsource_Callback(hObject, eventdata, handles)
% hObject    handle to equipment_addsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add new row
data = get(handles.equipment_sources, 'Data');
data(end + 1, :) = {size(get(handles.measurements_table, 'Data'), 1) size(get(handles.locations_table, 'Data'), 1) 0 'no hardware'};
set(handles.equipment_sources, 'Data', data);

% Enable remove
set(handles.equipment_removesource, 'Enable', 'on');


% --- Executes on button press in equipment_removesource.
function equipment_removesource_Callback(hObject, eventdata, handles)
% hObject    handle to equipment_removesource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.remove_source == 1
    % Change button text
    set(handles.equipment_removesource, 'String', 'Remove microphone');
    
    % Cancel remove 
    handles.remove_source = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Change button text
    set(handles.equipment_removesource, 'String', 'Cancel remove');
    
    % Start remove 
    handles.remove_source = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in equipment_workspace.
function equipment_workspace_Callback(hObject, eventdata, handles)
% hObject    handle to equipment_workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get vars
vars = evalin('base', 'whos');

% Get rirs
rirs = cell(0, 1);
for index = 1:length(vars)
    if strcmp(vars(index).class, 'itaAudio')
        rirs{end+1} = vars(index).name;
    end
end

% Add error if no variables
if isempty(rirs)
    rirs = { 'no variables' };
end

% Update equipment tables
bindb_updateuielement(handles.equipment_microphones, 'ColumnFormat', 5, rirs);


% --- Executes on button press in room_relations.
function room_relations_Callback(hObject, eventdata, handles)
% hObject    handle to room_relations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lines = [];

% Get data
locations = get(handles.locations_table, 'Data');
microphones = get(handles.equipment_microphones, 'Data');
sources = get(handles.equipment_sources, 'Data');
measurements = get(handles.measurements_table, 'Data');
   
% Abort is data is missing
if isempty(locations) || isempty(microphones) || isempty(sources)
    return;
end

% Draw lines
for mea = 1:size(measurements, 1) 
    color = rand(1, 3);
    for mic = 1:size(microphones, 1)
        if microphones{mic, 1} == mea
            for src = 1:size(sources, 1)
                if sources{src, 1} == mea
                    % microphone and source belong to measurement
                    lines = [lines; line([locations{microphones{mic, 2}, 2} locations{sources{src, 2}, 2}], [locations{microphones{mic, 2}, 3} locations{sources{src, 2}, 3}], 'Color', color)];
                end
            end
        end
    end
end

% Wait 1 second
uiwait(handles.figure1, 1);

% Remove lines
delete(lines);
                        


% --- Executes on button press in fields_show.
function fields_show_Callback(hObject, eventdata, handles)
% hObject    handle to fields_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show fields
bindb_gui_measurement_add_fields();


% --- Executes during object creation, after setting all properties.
function measurements_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measurements_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Register globals
global bindb_data;

% Get fields
fieldcount = length(bindb_data.Fields);
fields = cell(4, fieldcount);
for index = 1:fieldcount
    % Column name 
    fields{1, index} = bindb_data.Fields(index).Name;
    % Column type
    if bindb_data.Fields(index).Type == 3
        fields{2, index} = 'char';
        fields{3, index} = '';
    elseif bindb_data.Fields(index).Type == 4
        % Create cell
        values = cell(0);
        valstr = bindb_data.Fields(index).Values;
        while ~isempty(valstr)
            [values{end+1}, valstr] = strtok(valstr, '@');
        end
        fields{2, index} = values;
        fields{3, index} = values{1};
    else
        fields{2, index} = 'numeric';
        fields{3, index} = [];
    end
    % Column description
    fields{4, index} = [bindb_data.Fields(index).Name ': ' bindb_data.Fields(index).Description];
end

% Update fields table
set(hObject, 'ColumnName', fields(1, :));
set(hObject, 'ColumnFormat', fields(2, :));
set(hObject, 'ColumnEditable', true(1, fieldcount));
set(hObject, 'ColumnWidth', 'auto');

% Store
handles.Fields = fields;

% Create forst row
set(hObject, 'Data', handles.Fields(3, :));

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in measurements_table.
function measurements_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to measurements_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(eventdata.Indices)
    % Show field description
    set(handles.measurements_description, 'String', sprintf(handles.Fields{4, eventdata.Indices(2)}));
    
    % Load and save comment
    handles.Comments{handles.ActiveComment} = bindb_tostring(get(handles.comment_field, 'String'));
    handles.ActiveComment = eventdata.Indices(1);
    set(handles.comment_field, 'String', sprintf(handles.Comments{handles.ActiveComment}));
    set(handles.comment_label, 'String', sprintf('Comment for \nmeasurement %d ', handles.ActiveComment));
end

% Remove row
if handles.remove_measurement == 1 && ~isempty(eventdata.Indices)
    % Change button text
    set(handles.measurements_remove, 'String', 'Remove measurement');
    
    % Finish remove 
    handles.remove_measurement = 0;
    set(handles.figure1, 'Pointer', 'arrow');
    
    % Delete row
    data = get(handles.measurements_table, 'Data');
    data(eventdata.Indices(1), :) = [];
    set(handles.measurements_table, 'Data', data);
    
    % Delete comment
    handles.Comments(eventdata.Indices(1)) = [];
    handles.ActiveComment = 1;
    set(handles.comment_field, 'String', sprintf(handles.Comments{handles.ActiveComment}));
    set(handles.comment_label, 'String', sprintf('Comment for \nmeasurement %d ', handles.ActiveComment));
    
    % Update equipment tables
    bindb_updateuielement(handles.equipment_microphones, 'ColumnFormat', 1, bindb_indexcells(size(data(:,1)), 'no measurement'));
    bindb_updateuielement(handles.equipment_sources, 'ColumnFormat', 1, bindb_indexcells(size(data(:,1)), 'no measurement'));

    % Can't delete last
    if size(data(:,1)) == 1
        set(handles.measurements_remove, 'Enable', 'off');
    end
end

% Run script
if handles.run_measurement == 1 && ~isempty(eventdata.Indices)
    % Change button text
    set(handles.measurements_run, 'String', 'Run script');
    
    % Finish run 
    handles.run_measurement = 0;
    set(handles.figure1, 'Pointer', 'arrow');
    
    % Create mdata
    global bindb_data;
    data = get(handles.measurements_table, 'Data');
    ldata = length(bindb_data.Fields);
    mdata(1, 1:ldata) = {bindb_data.Fields(1:end).Name};
    mdata(2, 1:ldata) = data(eventdata.Indices(1), 1:ldata);
    
    % Get measurements
    mmts = createMeasurements(handles);    

    if ~isempty(mmts)    
        mmt = mmts(eventdata.Indices(1));
        % Run selected script
        scriptlist = get(handles.measurement_script, 'String');
        script = scriptlist{get(handles.measurement_script, 'Value')};
        try        
        run(bindb_filepath('scripts', script));
        catch err
            bindb_addlog(['Script: ' script], err.message, 1);
        end

        % Apply changes
        data(eventdata.Indices(1), 1:ldata) = mdata(2, 1:ldata);
        set(handles.measurements_table, 'Data', data); 
    end
end

% Update handles structure
guidata(hObject, handles);


% --- Create measurement from collected data
function mmts = createMeasurements(handles)
% handles    structure with handles and user data (see GUIDATA)

% Register globals
global bindb_data;

% Get tables data
locations = get(handles.locations_table, 'Data');
microphones = get(handles.equipment_microphones, 'Data');
sources = get(handles.equipment_sources, 'Data');
measurements = get(handles.measurements_table, 'Data');

% Save latest comment
handles.Comments{handles.ActiveComment} = bindb_tostring(get(handles.comment_field, 'String'));

for index = 1:size(measurements, 1)
    mmt = bindb_measurement(-1, get(handles.measurement_author, 'String'), handles.Comments{index}, datestr(now, 'yyyy-mm-dd HH:MM:SS'), 1);
	% Gather responses    
    for mic = 1:size(microphones, 1)
        if microphones{mic, 1} == index
            % Not a valid location?
            if microphones{mic, 2} > size(locations, 1)
                bindb_addlog('Add measurement', 'equipment and location entries are not consistent', 1);
                return;
            end                       
            
            hwm.ID = -1;
            hwm.Location.X = locations{microphones{mic, 2}, 2};
            hwm.Location.Y = locations{microphones{mic, 2}, 3};
            hwm.Location.Height = microphones{mic, 3};
            hwm.Location.Description = locations{microphones{mic, 2}, 1};
            hwm.Hardware = microphones{mic, 4};
            
            if strcmp(microphones{mic, 5}, 'no variables')
                hwm.ImpulseResponse = [];
            else
                hwm.ImpulseResponse = evalin('base', microphones{mic, 5});
            end
            
            mmt.addHardware('mic', hwm);
        end
    end
    
    % Gather sources
    for src = 1:size(sources, 1)
        if sources{src, 1} == index
            % Not a valid location?
            if sources{src, 2} > size(locations, 1)
                bindb_addlog('Add measurement', 'equipment and location entries are not consistent', 1);
                return;
            end

            hws.ID = -1;
            hws.Location.X = locations{sources{src, 2}, 2};
            hws.Location.Y = locations{sources{src, 2}, 3};
            hws.Location.Height = sources{src, 3};
            hws.Location.Description = locations{sources{src, 2}, 1};
            hws.Hardware = sources{src, 4};
            
            mmt.addHardware('source', hws);
        end                 
    end  
    
    % Room 
    mmt.Room = handles.Rooms(get(handles.room_popup, 'Value'));
    
    % Room properties
    mmt.addData('Humidity', str2num(get(handles.measurement_humidity, 'String')));
    mmt.addData('Volume', str2num(get(handles.measurement_volume, 'String')));
    mmt.addData('Temperature', str2num(get(handles.measurement_temperature, 'String')));
    
    % Fields
    for fid = 1:size(handles.Fields, 2)
        mmt.addData(handles.Fields{1, fid}, measurements{index, fid});        
    end
    
    mmts(index) = mmt;
end

% Check volume
if isempty(mmts(1).Data{2, 2})
    set(handles.measurement_volume, 'BackgroundColor', [1.0, 0.8, 0.8]);
    req1 = 0;
else
    set(handles.measurement_volume, 'BackgroundColor', [1.0, 1.0, 1.0]);
    req1 = 1;
end

% Check temperature
if isempty(mmts(1).Data{3, 2})
    set(handles.measurement_temperature, 'BackgroundColor', [1.0, 0.8, 0.8]);
    req2 = 0;
else
    set(handles.measurement_temperature, 'BackgroundColor', [1.0, 1.0, 1.0]);
    req2 = 1;
end

% Check humidity
if isempty(mmts(1).Data{1, 2})
    set(handles.measurement_humidity, 'BackgroundColor', [1.0, 0.8, 0.8]);
    req3 = 0;
else
    set(handles.measurement_humidity, 'BackgroundColor', [1.0, 1.0, 1.0]);
    req3 = 1;
end

req4 = 1;
req5 = 1;
for index = 1:length(mmts)
    srcc = length(mmts(index).Sources);
    micc = length(mmts(index).Microphones);
    req4 = req4 * srcc;
    req5 = req5 * micc;
end

% Change equipment colors
if req4
    set(handles.equipment_sources_header, 'ForegroundColor', [0, 0, 0]);        
else
    set(handles.equipment_sources_header, 'ForegroundColor', [1.0, 0, 0]);
    bindb_addlog('Add measurement', 'each emasurement needs at least one source', 1);
end    
if req5
    set(handles.equipment_microphones_header, 'ForegroundColor', [0, 0, 0]);     
else
    set(handles.equipment_microphones_header, 'ForegroundColor', [1.0, 0, 0]);
    bindb_addlog('Add measurement', 'each emasurement needs at least one microphone', 1);
end

if (req1 * req2 * req3 * req4 * req5) == 0
    mmts = {};
end


% --- Executes on button press in measurement_save.
function measurement_save_Callback(hObject, eventdata, handles)
% hObject    handle to measurement_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get measurements
mmts = createMeasurements(handles);

if isempty(mmts)
    return;
else
    for index = 1:length(mmts)
        % Commit emasurement
        [result, id] = bindb_measurement_commit(mmts(index), true);
        
        % Error
        if result == 0
            bindb_addlog('Add Measurement', 'The measurement could not be saved.', 1);            
        end                
    end
    
    % Close gui
    delete(handles.figure1);
end
