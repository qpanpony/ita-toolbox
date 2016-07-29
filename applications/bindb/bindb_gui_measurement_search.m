function varargout = bindb_gui_measurement_search(varargin)
% BINDB_GUI_MEASUREMENT_SEARCH MATLAB code for bindb_gui_measurement_search.fig
%      BINDB_GUI_MEASUREMENT_SEARCH, by itself, creates a new BINDB_GUI_MEASUREMENT_SEARCH or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_MEASUREMENT_SEARCH returns the handle to a new BINDB_GUI_MEASUREMENT_SEARCH or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_MEASUREMENT_SEARCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_MEASUREMENT_SEARCH.M with the given input arguments.
%
%      BINDB_GUI_MEASUREMENT_SEARCH('Property','Value',...) creates a new BINDB_GUI_MEASUREMENT_SEARCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_measurement_search_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_measurement_search_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_measurement_search

% Last Modified by GUIDE v2.5 31-Mar-2012 19:26:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_measurement_search_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_measurement_search_OutputFcn, ...
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


% --- Executes just before bindb_gui_measurement_search is made visible.
function bindb_gui_measurement_search_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_measurement_search (see VARARGIN)

% Choose default command line output for bindb_gui_measurement_search
handles.output = hObject;

% Register globals
global bindb_data;

% Add rooms
if isempty(bindb_data.Rooms)
    set(handles.filters_rooms, 'String', 'no filter');  
else
    handles.Rooms = bindb_data.Rooms;
    set(handles.filters_rooms, 'String', {'no filter', handles.Rooms.Name});   
end

% Add microphones
devListHandle = ita_device_list_handle;
handles.Microphones = devListHandle('sensor');
set(handles.filters_microphones, 'String', {'no filter', handles.Microphones{:, 1}});

% Add fields
if isempty(bindb_data.Fields)
    set(handles.filters_fields, 'Data', {});
else
    handles.NumericalFields = struct('Name', {}, 'Description', {}, 'Type', {}, 'Values', {});
    handles.TextFields = struct('Name', {}, 'Description', {}, 'Type', {}, 'Values', {});
    for index = 1:length(bindb_data.Fields)
        if bindb_data.Fields(index).Type < 3
            handles.NumericalFields(end+1) = bindb_data.Fields(index);
        else
            handles.TextFields(end+1) = bindb_data.Fields(index);
        end
    end
    data = {handles.NumericalFields.Name}';
    data(:, [2, 3]) = {0};
    set(handles.filters_fields, 'Data', data);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bindb_gui_measurement_search wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_measurement_search_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function filters_age_Callback(hObject, eventdata, handles)
% hObject    handle to filters_age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get value
value = get(hObject,'Value');

% Update hint
if value == 0
    set(handles.filters_age_hint, 'String', 'no filter');
elseif value <= 200
    set(handles.filters_age_hint, 'String', sprintf('younger than %.0f days', value));
end


% --- Executes on button press in filters_Search.
function filters_Search_Callback(hObject, eventdata, handles)
% hObject    handle to filters_Search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use filters
usefilters = false;

% Get order
orders = { '`Measurements`.`Date`', '`Rooms`.`Name`', '`Responses`.`Hardware`', '`Measurements`.`Comment`' };
directions = { 'DESC', 'ASC' };
order = ['ORDER BY ' orders{get(handles.filters_order, 'Value')} ' ' directions{get(handles.filters_ascending, 'Value') + 1}];

% Get room filter
indices = get(handles.filters_rooms, 'Value') - 1;
if ~ismember(0, indices)
    usefilters = true;
    l_rooms = length(indices);
    if l_rooms == 1
        f_rooms = ['`Measurements`.`O_ID`=' num2str(handles.Rooms(indices).ID)];
    else
        f_rooms = '(';
        s_rooms = {handles.Rooms(indices).ID};
        for index = fliplr(1:l_rooms)
            if index > 1
                f_rooms = [f_rooms '`Measurements`.`O_ID`=' num2str(s_rooms{index}) ' OR '];
            else
                f_rooms = [f_rooms '`Measurements`.`O_ID`=' num2str(s_rooms{index}) ')'];
            end
        end
    end
else
    f_rooms = '';
end

% Get mircophone filter
indices = get(handles.filters_microphones, 'Value') - 1;
if ~ismember(0, indices)
    usefilters = true;
    l_microphones = length(indices);
    if l_microphones == 1
        f_microphones = ['`Responses`.`Hardware`=''' handles.Microphones{indices, 1} ''''];
    else
        f_microphones = '(';
        s_microphones = handles.Microphones(indices, 1);
        for index = fliplr(1:l_microphones)
            if index > 1
                f_microphones = [f_microphones '`Responses`.`Hardware`=''' s_microphones{index} ''' OR '];
            else
                f_microphones = [f_microphones '`Responses`.`Hardware`=''' s_microphones{index} ''')'];
            end
        end
    end
else
    f_microphones = '';
end

% Get age filter
value = get(handles.filters_age, 'Value');
if value > 0 && value <= 200
    usefilters = true;
    f_age = sprintf('DATEDIFF(CURDATE(), `Measurements`.`Date`)<%.0f', value);
else
    f_age = '';
end

% Get keyword filter
value = strtrim(get(handles.filters_keyword, 'String'));
if ~isempty(value)
    usefilters = true;
    f_keyword = ['(`Measurements`.`Comment` LIKE ''%' value '%'' OR `Measurements`.`Author` LIKE ''%' value '%'''];
    for index = 1:size(handles.TextFields, 1);
        f_keyword = [f_keyword ' OR `Measurements`.`' handles.TextFields(index).Name '` LIKE ''%' value '%'''];
    end
    f_keyword = [f_keyword ')'];
else
    f_keyword = '';  
end

% Get fields filters
s_fields = cell(0, 3);
data = get(handles.filters_fields, 'Data');
for index = 1:size(data, 1)
    if ~(data{index, 2} == 0 && data{index, 3} == 0)
        s_fields(end+1, :) = data(index, :);
    end
end
l_fields = size(s_fields, 1);
if l_fields == 1
    usefilters = true;
    f_fields = ['(`Measurements`.`' s_fields{1, 1} '` >= ' num2str(s_fields{1, 2}) ' AND `Measurements`.`' s_fields{1, 1} '` <= ' num2str(s_fields{1, 3}) ')'];    
elseif l_fields > 1
    f_fields = '(';
    usefilters = true;
    for index = fliplr(1:l_fields)
        f_fields = [f_fields '(`Measurements`.`' s_fields{1, 1} '` >= ' num2str(s_fields{1, 2}) ' AND `Measurements`.`' s_fields{1, 1} '` <= ' num2str(s_fields{1, 3}) ')'];         
        
        if index > 1
            f_fields = [f_fields ' AND '];
        else
            f_fields = [f_fields ')'];
        end
    end
else
    f_fields = '';
end

% Start building query
query = 'SELECT `Measurements`.`M_ID`, `Responses`.`R_ID`, `Measurements`.`Version`, `Measurements`.`Date`, `Measurements`.`Author`, `Rooms`.`Name`, `Responses`.`Hardware`, `Measurements`.`Comment` FROM `Measurements` INNER JOIN `Rooms` ON `Rooms`.`O_ID`=`Measurements`.`O_ID` INNER JOIN `Responses` ON `Responses`.`M_ID`=`Measurements`.`M_ID`';

% Collect filters
filters = { f_rooms, f_microphones, f_age, f_keyword, f_fields };

if usefilters
    % Use while clause if filters are used
    useand = false;
    query = [query ' WHERE '];
    for index = 1:length(filters)
        if ~isempty(filters{index})
            % Add filters to query
            if useand
                query = [query ' AND '];
            end
            query = [query filters{index}];
            useand = true;
        end
    end
end              
      
% Add order and limit to query
query = [query ' ' order ' LIMIT 100'];

% Execute query
measurements = [];
try
    measurements = bindb_query(query);
catch err
    bindb_addlog('Search measurement', err.message, 1);
    measurements = 'No Data';
end

% Open results
handles.Results = bindb_gui_measurement_results(measurements);

% Update handles structure
guidata(hObject, handles);    


% --- Executes on button press in filters_reset.
function filters_reset_Callback(hObject, eventdata, handles)
% hObject    handle to filters_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset filters
set(handles.filters_age, 'Value', 0);
set(handles.filters_age_hint, 'String', 'no filter');
set(handles.filters_rooms, 'Value', 1);
set(handles.filters_microphones, 'Value', 1);
set(handles.filters_keyword, 'String', '');
set(handles.filters_order, 'Value', 1);
set(handles.filters_ascending, 'Value', 1);

% Reset field filters
data = get(handles.filters_fields, 'Data');
data(:, [2, 3]) = {0};
set(handles.filters_fields, 'Data', data);


% --- Executes when entered data in editable cell(s) in filters_fields.
function filters_fields_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to filters_fields (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Get data
data = get(hObject, 'Data');

% Check boundaries
if eventdata.Indices(2) == 2 
    if data{eventdata.Indices(1), 3} < data{eventdata.Indices(1), 2}
        data{eventdata.Indices(1), 3} = data{eventdata.Indices(1), 2};
    end
elseif eventdata.Indices(2) == 3
    if data{eventdata.Indices(1), 2} > data{eventdata.Indices(1), 3}
        data{eventdata.Indices(1), 2} = data{eventdata.Indices(1), 3};
    end
end

% Update table
set(hObject, 'Data', data);
