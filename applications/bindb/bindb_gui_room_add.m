function varargout = bindb_gui_room_add(varargin)
% BINDB_GUI_ROOM_ADD MATLAB code for bindb_gui_room_add.fig
%      BINDB_GUI_ROOM_ADD, by itself, creates a new BINDB_GUI_ROOM_ADD or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_ROOM_ADD returns the handle to a new BINDB_GUI_ROOM_ADD or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_ROOM_ADD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_ROOM_ADD.M with the given input arguments.
%
%      BINDB_GUI_ROOM_ADD('Property','Value',...) creates a new BINDB_GUI_ROOM_ADD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_room_add_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_room_add_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_room_add

% Last Modified by GUIDE v2.5 05-Dec-2011 17:26:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_room_add_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_room_add_OutputFcn, ...
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


% --- Executes just before bindb_gui_room_add is made visible.
function bindb_gui_room_add_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_room_add (see VARARGIN)

% Choose default command line output for bindb_gui_room_add
handles.output = hObject;

% Draw grid
axes(handles.layout_canvas);
imshow(imread(bindb_filepath('root', 'grid.png')));

% Create layers
handles.layers = [];
handles.currentlayer = -1;
set(handles.layers_list, 'String', []);
handles.layerannotation = line([1 1], [1 1], 'Color', [1, 0.8, 0.8], 'LineWidth', 6);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_room_add_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in layers_list.
function layers_list_Callback(hObject, eventdata, handles)
% hObject    handle to layers_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get selection index
index = get(hObject, 'Value');

if ~isempty(index)
    % Set new current layer
    handles = setCurrentLayer(hObject, index, handles);

    % Update handles structure
    guidata(hObject, handles);
end
    

% --- Executes on button press in tools_line.
function tools_line_Callback(hObject, eventdata, handles)
% hObject    handle to tools_line (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x, y, mode] = ginput(2);

% Abort if points not in axes
if x(1) < 1 || x(1) > 401 || x(2) < 1 || x(2) > 401 || y(1) < 1 || y(1) > 401 || y(2) < 1 || y(2) > 401
    return;
end;

% Round values
x = round(x);
y = round(y);

% Move to grid of 20 around 201 on rightclick
if mode(1) ~= 1
    % Fix x(1)
    rest = mod(x(1) - 1, 20);
    if rest < 10
        x(1) = x(1) - rest;
    else
        x(1) = x(1) - rest + 20;
    end
    % Fix y(1)
    rest = mod(y(1) - 1, 20);
    if rest < 10
        y(1) = y(1) - rest;
    else
        y(1) = y(1) - rest + 20;
    end
end
if mode(2) ~= 1
    % Fix x(2)
    rest = mod(x(2) - 1, 20);
    if rest < 10
        x(2) = x(2) - rest;
    else
        x(2) = x(2) - rest + 20;
    end    
    % Fix y(2)
    rest = mod(y(2) - 1, 20);
    if rest < 10
        y(2) = y(2) - rest;
    else
        y(2) = y(2) - rest + 20;
    end   
end

% Create properties
properties = {
    x(1), y(1);
    x(2), y(2);
    1, 1;
    1, 0};

% Create layer
handle = line([1, 1], [1, 1]);

% Save layer
handles.layers = [handles.layers; {'tmp' handle properties}];

% Save properties
handles = saveProperties(hObject, properties, size(handles.layers, 1), handles);

% Set current layer
handles = setCurrentLayer(hObject, size(handles.layers, 1), handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in tools_rectangle.
function tools_rectangle_Callback(hObject, eventdata, handles)
% hObject    handle to tools_rectangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x, y, mode] = ginput(2);

% Abort if points not in axes
if x(1) < 1 || x(1) > 401 || x(2) < 1 || x(2) > 401 || y(1) < 1 || y(1) > 401 || y(2) < 1 || y(2) > 401
    return;
end;

% Move to grid of 20 around 201
if mode(1) ~= 1
    % Fix x(1)
    rest = mod(x(1) - 1, 20);
    if rest < 10
        x(1) = x(1) - rest;
    else
        x(1) = x(1) - rest + 20;
    end
    % Fix y(1)
    rest = mod(y(1) - 1, 20);
    if rest < 10
        y(1) = y(1) - rest;
    else
        y(1) = y(1) - rest + 20;
    end
end
if mode(2) ~= 1
    % Fix x(2)
    rest = mod(x(2) - 1, 20);
    if rest < 10
        x(2) = x(2) - rest;
    else
        x(2) = x(2) - rest + 20;
    end    
    % Fix y(2)
    rest = mod(y(2) - 1, 20);
    if rest < 10
        y(2) = y(2) - rest;
    else
        y(2) = y(2) - rest + 20;
    end   
end

% Top line
properties_top = {...
    x(1), y(1); ...
    x(2), y(1); ...
    1, 1;
    1, 0};

% Right line
properties_right = {...
    x(2), y(1); ...
    x(2), y(2); ...
    1, 1;
    1, 0};

% Bottom line
properties_bottom = {...
    x(1), y(2); ...
    x(2), y(2); ...
    1, 1;
    1, 0};

% Left line
properties_left = {...
    x(1), y(1); ...
    x(1), y(2); ...
    1, 1;
    1, 0};

% Create layer
handle_top = line([1 1], [1 1]);
handle_right = line([1 1], [1 1]);
handle_bottom = line([1 1], [1 1]);
handle_left = line([1 1], [1 1]);

% Save layer
handles.layers = [handles.layers; {'tmp' handle_top properties_top; 'tmp' handle_right properties_right; 'tmp' handle_bottom properties_bottom; 'tmp' handle_left properties_left}];

% Save properties
handles = saveProperties(hObject, properties_top, size(handles.layers, 1) - 3, handles);
handles = saveProperties(hObject, properties_right, size(handles.layers, 1) - 2, handles);
handles = saveProperties(hObject, properties_bottom, size(handles.layers, 1) - 1, handles);
handles = saveProperties(hObject, properties_left, size(handles.layers, 1), handles);

% Set current layer
handles = setCurrentLayer(hObject, size(handles.layers, 1), handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in layers_duplicate.
function layers_duplicate_Callback(hObject, eventdata, handles)
% hObject    handle to layers_duplicate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Can't duplicate no layer!
if handles.currentlayer == -1
    return;
end

% Get properties
properties = handles.layers{handles.currentlayer, 3};
    
% Create layer
handle = line([1 1], [1 1]);

%Save layer
handles.layers = [handles.layers; {handles.layers{handles.currentlayer, 1} handle properties}];

% Save properties
handles = saveProperties(hObject, properties, size(handles.layers, 1), handles);

% Set layer
handles = setCurrentLayer(hObject, size(handles.layers, 1), handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in layers_delete.
function layers_delete_Callback(hObject, eventdata, handles)
% hObject    handle to layers_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
% Can't delete no layer!
if handles.currentlayer == -1
    return;
end

% Get new current layer
if size(handles.layers, 1) == 1
    newlayer = -1;
else
    if handles.currentlayer == size(handles.layers, 1)        
        newlayer = size(handles.layers, 1) - 1;
    else
        newlayer = handles.currentlayer;
    end
end

% Delete layer
delete(handles.layers{handles.currentlayer, 2});

% Delete data
handles.layers(handles.currentlayer,:) = [];

% Update layers
set(handles.layers_list, 'String', handles.layers(:,1));

% Set current layer
handles = setCurrentLayer(hObject, newlayer, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in tools_center.
function tools_center_Callback(hObject, eventdata, handles)
% hObject    handle to tools_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Declare boundaries
xmin = 401;
ymin = 401;
xmax = 1;
ymax = 0;

% Get real boundaries
for index = 1:size(handles.layers, 1)  
    % Get properties
    properties = handles.layers{index, 3};
    
    if properties{4, 2} == 0
        % Update boundaries for line
        
        % Get positions
        positions = getTranslatedPositions(properties);

        % Update x boundaries
        if positions{1, 1} < xmin
            xmin = positions{1, 1};
        end
        if positions{1, 1} > xmax
            xmax = positions{1, 1};
        end
        if positions{2, 1} < xmin
            xmin = positions{2, 1};
        end
        if positions{2, 1} > xmax
            xmax = positions{2, 1};
        end

        % Update y boundaries
        if positions{1, 2} < ymin
            ymin = positions{1, 2};
        end
        if positions{1, 2} > ymax
            ymax = positions{1, 2};
        end
        if positions{2, 2} < ymin
            ymin = positions{2, 2};
        end
        if positions{2, 2} > ymax
            ymax = positions{2, 2};
        end
    else
        % Update boundaries for arc
        
        % Get data
        xdata = get(handles.layers{index, 2}, 'XData');
        ydata = get(handles.layers{index, 2}, 'YData');
        
        % Update x boundaries
        for xi = 1:length(xdata)
            if xdata(xi) < xmin
                xmin = xdata(xi);
            end
            if xdata(xi) > xmax
                xmax = xdata(xi);
            end
        end
        
        % Update y boundaries
        for yi = 1:length(ydata)
            if ydata(yi) < ymin
                ymin = ydata(yi);
            end
            if ydata(yi) > ymax
                ymax = ydata(yi);
            end
        end
    end
end

% Get displacement
xdis = round(((401 - xmax) - xmin) / 2);
ydis = round(((401 - ymax) - ymin) / 2);

% Move layers by displacement
for index = 1:size(handles.layers, 1)
    % Get properties
    properties = handles.layers{index, 3};
    
    % Change positions
    if properties{3, 1} == 1
        properties{1, 1} = properties{1, 1} + xdis;
        properties{1, 2} = properties{1, 2} + ydis;
    elseif properties{3, 1} == 2
        properties{1, 1} = properties{1, 1} + xdis;
        properties{1, 2} = properties{1, 2} - ydis;
    elseif properties{3, 1} == 3
        properties{1, 1} = properties{1, 1} - xdis;
        properties{1, 2} = properties{1, 2} - ydis;
    else
        properties{1, 1} = properties{1, 1} - xdis;
        properties{1, 2} = properties{1, 2} + ydis;
    end    
    if properties{3, 2} == 1
        properties{2, 1} = properties{2, 1} + xdis;
        properties{2, 2} = properties{2, 2} + ydis;
    elseif properties{3, 2} == 2
        properties{2, 1} = properties{2, 1} + xdis;
        properties{2, 2} = properties{2, 2} - ydis;
    elseif properties{3, 2} == 3
        properties{2, 1} = properties{2, 1} - xdis;
        properties{2, 2} = properties{2, 2} - ydis;
    else
        properties{2, 1} = properties{2, 1} - xdis;
        properties{2, 2} = properties{2, 2} + ydis;
    end
    
    % Save properties
    handles = saveProperties(hObject, properties, index, handles);
end

% Set current layer
handles = setCurrentLayer(hObject, handles.currentlayer, handles);

% Update handles structure
guidata(hObject, handles);


function properties_startx_Callback(hObject, eventdata, handles)
% hObject    handle to properties_startx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ignore if no layer
if handles.currentlayer == -1
    return;
end

% Get new value
value = str2double(get(handles.properties_startx, 'String'));

% Get properties
properties = handles.layers{handles.currentlayer, 3};

if ~isnan(value)
    % Update properties    
    properties{1, 1} = value;

    % Save properties
    handles = saveProperties(hObject, properties, handles.currentlayer, handles);
else
    % Reset
    set(handles.properties_startx, 'String', properties{1, 1});
end

% Update handles structure
guidata(hObject, handles);


function properties_starty_Callback(hObject, eventdata, handles)
% hObject    handle to properties_starty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ignore if no layer
if handles.currentlayer == -1
    return;
end

% Get new value
value = str2double(get(handles.properties_starty, 'String'));

% Get properties
properties = handles.layers{handles.currentlayer, 3};

if ~isnan(value)
    % Update properties    
    properties{1, 2} = value;

    % Save properties
    handles = saveProperties(hObject, properties, handles.currentlayer, handles);
else
    % Reset
    set(handles.properties_starty, 'String', properties{1, 2});
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in properties_startalign.
function properties_startalign_Callback(hObject, eventdata, handles)
% hObject    handle to properties_startalign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ignore if no layer
if handles.currentlayer == -1
    return;
end

% Get new value
value = get(handles.properties_startalign, 'Value');

% Get properties
properties = handles.layers{handles.currentlayer, 3};

% Update properties    
properties{3, 1} = value;

% Save properties
handles = saveProperties(hObject, properties, handles.currentlayer, handles);

% Update handles structure
guidata(hObject, handles);


function properties_endx_Callback(hObject, eventdata, handles)
% hObject    handle to properties_endx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ignore if no layer
if handles.currentlayer == -1
    return;
end

% Get new value
value = str2double(get(handles.properties_endx, 'String'));

% Get properties
properties = handles.layers{handles.currentlayer, 3};

if ~isnan(value)
    % Update properties    
    properties{2, 1} = value;

    % Save properties
    handles = saveProperties(hObject, properties, handles.currentlayer, handles);
else
    % Reset
    set(handles.properties_endx, 'String', properties{2, 1});
end

% Update handles structure
guidata(hObject, handles);


function properties_endy_Callback(hObject, eventdata, handles)
% hObject    handle to properties_endy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ignore if no layer
if handles.currentlayer == -1
    return;
end

% Get new value
value = str2double(get(handles.properties_endy, 'String'));

% Get properties
properties = handles.layers{handles.currentlayer, 3};

if ~isnan(value)
    % Update properties    
    properties{2, 2} = value;

    % Save properties
    handles = saveProperties(hObject, properties, handles.currentlayer, handles);
else
    % Reset
    set(handles.properties_endy, 'String', properties{2, 2});
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in properties_endalign.
function properties_endalign_Callback(hObject, eventdata, handles)
% hObject    handle to properties_endalign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ignore if no layer
if handles.currentlayer == -1
    return;
end

% Get new value
value = get(handles.properties_endalign, 'Value');

% Get properties
properties = handles.layers{handles.currentlayer, 3};

% Update properties    
properties{3, 2} = value;

% Save properties
handles = saveProperties(hObject, properties, handles.currentlayer, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in properties_type.
function properties_type_Callback(hObject, eventdata, handles)
% hObject    handle to properties_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ignore if no layer
if handles.currentlayer == -1
    return;
end

% Get new value
value = get(handles.properties_type, 'Value');

% Get properties
properties = handles.layers{handles.currentlayer, 3};

% Update properties    
properties{4, 1} = value;

% Save properties
handles = saveProperties(hObject, properties, handles.currentlayer, handles);

% Update handles structure
guidata(hObject, handles);


function properties_arc_Callback(hObject, eventdata, handles)
% hObject    handle to properties_arc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ignore if no layer
if handles.currentlayer == -1
    return;
end

% Get new value
value = str2double(get(handles.properties_arc, 'String'));

% Get properties
properties = handles.layers{handles.currentlayer, 3};

if ~isnan(value)
    % Update properties    
    properties{4, 2} = value;

    % Save properties
    handles = saveProperties(hObject, properties, handles.currentlayer, handles);
else
    % Reset
    set(handles.properties_arc, 'String', properties{4, 2});
end

% Update handles structure
guidata(hObject, handles);


function positions = getTranslatedPositions(properties)
% properties    cell array containing layer properties

positions = cell(2);
% Get positions
if properties{3, 1} ==  1
	positions{1, 1} = properties{1, 1};
    positions{1, 2} = properties{1, 2};
elseif properties{3, 1} == 2
    positions{1, 1} = properties{1, 1};
    positions{1, 2} = 401 - properties{1, 2};
elseif properties{3, 1} == 3
    positions{1, 1} = 401 - properties{1, 1};
    positions{1, 2} = 401 - properties{1, 2};
else
    positions{1, 1} = 401 - properties{1, 1};
    positions{1, 2} = properties{1, 2};
end    
if properties{3, 2} == 1
    positions{2, 1} = properties{2, 1};
    positions{2, 2} = properties{2, 2};
elseif properties{3, 2} == 2
    positions{2, 1} = properties{2, 1};
    positions{2, 2} = 401 - properties{2, 2};
elseif properties{3, 2} == 3
    positions{2, 1} = 401 - properties{2, 1};
    positions{2, 2} = 401 - properties{2, 2};
else
    positions{2, 1} = 401 - properties{2, 1};
    positions{2, 2} = properties{2, 2};
end
    
    
function handles = saveProperties(hObject, properties, layer, handles)
% hObject    handle to GCBO
% properties cell array with layer properties
% layer      layer that properties are saved to
% handles    structure with handles and user data (see GUIDATA)

% Get positions
positions = getTranslatedPositions(properties);

% Draw arc
if properties{4, 2} ~= 0
    % Get end points
    e1 = [positions{1, 1}, positions{1, 2}];
    e2 = [positions{2, 1}, positions{2, 2}];
    % Get arc stregnth and limit min
    strength = properties{4, 2};
    if abs(strength) < norm(e1 - e2) / 2
        if sign(strength) == 1
            strength = norm(e1 - e2) / 2;
        else
            strength = -norm(e1 - e2) / 2;
        end
        
        % Update arc value
        set(handles.properties_arc, 'String', strength);
        properties{4, 2} = strength;
    end
    % Get angle between endpoints at center
    arcangle = acos(1 - norm(e1 - e2)^2 / 2 / abs(strength)^2);
    
    % Get normal vector to e1e2
    n = (e1 - e2) * [0, -1; 1, 0];
    n = n/norm(n);
    
    % Make space
    k = 200;
    t = linspace(0, arcangle, k)';
    
    % Cet arc center
    c = (e1 + e2) / 2 + n * strength * cos(arcangle / 2);
    
    % Get arc data
    if sign(strength) == 1
        % Calc data
        phi = atan2(e1(2) - c(2), e1(1) - c(1));
        xy = repmat(c, k, 1) + strength * [cos(t + phi), sin(t + phi)];
    else
        % Calc data
        phi = atan2(e1(2) - c(2), e1(1) - c(1));
        xy = repmat(c, k, 1) + abs(strength) * [cos(-t + phi), sin(-t + phi)];
    end
    
    % Update line data - arc style
    set(handles.layers{layer, 2}, 'XData', xy(:,1), 'YData', xy(:,2));
    
    % Set layer type
    type = 'arc';
    
    % Update annotation
    set(handles.layerannotation, 'XData', xy(:,1), 'YData', xy(:,2));
 else   
    % Update line data - line style
    set(handles.layers{layer, 2}, 'XData', [positions{:,1}], 'YData', [positions{:,2}]);
    
    % Set layer type
    type = 'line';
    
    % Update annotation
    set(handles.layerannotation, 'XData', [positions{:,1}], 'YData', [positions{:,2}]); 
end

% Update layer type
if properties{4, 1} == 1
    set(handles.layers{layer, 2}, 'Color', [0.642, 0.642, 0.642], 'LineWidth', 2);
    handles.layers{layer, 1} = [type ' - wall'];
elseif properties{4, 1} == 2
    set(handles.layers{layer, 2}, 'Color', [0, 0.8, 1], 'LineWidth', 3);
    handles.layers{layer, 1} = [type ' - window'];
else
    set(handles.layers{layer, 2}, 'Color', [0.5, 0, 0], 'LineWidth', 3);
    handles.layers{layer, 1} = [type ' - door'];
end

% Save properties
handles.layers{layer, 3} = properties;

% Update layer list
set(handles.layers_list, 'String', handles.layers(:,1));
    

function handles = setCurrentLayer(hObject, layer, handles)
% hObject    handle to GCBO
% layer      new current layer
% handles    structure with handles and user data (see GUIDATA)

% Set layer
handles.currentlayer = layer;

if layer ~= -1
    % Select layer
    set(handles.layers_list, 'Value', layer);
    
    % Get properties
    properties = handles.layers{layer, 3};

    % Update annotation
    set(handles.layerannotation, 'XData', get(handles.layers{layer, 2}, 'XData'), 'YData', get(handles.layers{layer, 2}, 'YData'));

    % Show properties
    set(handles.properties_startx, 'String', properties{1, 1});
    set(handles.properties_starty, 'String', properties{1, 2});
    set(handles.properties_endx, 'String', properties{2, 1});
    set(handles.properties_endy, 'String', properties{2, 2});
    set(handles.properties_startalign, 'Value', properties{3, 1});
    set(handles.properties_endalign, 'Value', properties{3, 2});
    set(handles.properties_type, 'Value', properties{4, 1});
    set(handles.properties_arc, 'String', properties{4, 2});        
else
    % Clear properties
    set(handles.properties_startx, 'String', '');
    set(handles.properties_starty, 'String', '');
    set(handles.properties_endx, 'String', '');
    set(handles.properties_endy, 'String', '');
    set(handles.properties_startalign, 'Value', 1);
    set(handles.properties_endalign, 'Value', 1);
    set(handles.properties_type, 'Value', 1);
    set(handles.properties_arc, 'String', 0);
        
    % Hide annotation
    set(handles.layerannotation, 'XData', [1 1], 'YData', [1 1]);
end


% --- Executes on button press in action_save.
function action_save_Callback(hObject, eventdata, handles)
% hObject    handle to action_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Declare globals
global bindb_data;

% Check if name field is empty
name = strtrim(get(handles.name_field, 'String'));
if strcmp(name, '') == 0
    set(handles.name_field, 'BackgroundColor', [1.0, 1.0, 1.0]);
    req1 = 1;
else
    set(handles.name_field, 'BackgroundColor', [1.0, 0.8, 0.8]);
    req1 = 0;
end

% No requirements for description field
description = bindb_tostring(get(handles.description_field, 'String'));

% Check number of layers
if ~isempty(handles.layers) && size(handles.layers, 1) > 2
    set(handles.layers_list, 'BackgroundColor', [1.0, 1.0, 1.0]);
    req2 = 1;
else
    set(handles.layers_list, 'BackgroundColor', [1.0, 0.8, 0.8]);
    bindb_addlog('Add room', 'room must have at least 3 layers', 1);
    req2 = 0;
end

% Check if form is complete
if req1 && req2  
    
    % Cosntruct layout data
    layout = '';
    for index = 1:size(handles.layers, 1)
        properties = handles.layers{index, 3};
        layout = [layout num2str(properties{1, 1}) ',' num2str(properties{1, 2}) ',' num2str(properties{2, 1}) ',' num2str(properties{2, 2}) ',' num2str(properties{3, 1}) ',' num2str(properties{3, 2}) ',' num2str(properties{4, 1}) ',' num2str(properties{4, 2}) ';']; 
    end
    
    % Commit room
    [success, id] = bindb_room_commit(name, description, layout, true);
    
    % Error
    if success == 0
        bindb_addlog('Add Room', 'The room could not be saved.', 1);
    elseif success == 1
        bindb_addlog('Add Room', [name ' stored'], 0);
    else
        bindb_addlog('Add Room', [name ' stored local'], 0);
    end
    
    % Close gui
    delete(handles.figure1); 
else
    % Update handles structure
    guidata(hObject, handles);
end
