function varargout = GUICreateMesh(varargin)
% GUICREATEMESH MATLAB code for GUICreateMesh.fig

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUICreateMesh_OpeningFcn, ...
                   'gui_OutputFcn',  @GUICreateMesh_OutputFcn, ...
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

%% Opening Function
% --- Executes just before GUICreateMesh is made visible.
function GUICreateMesh_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for GUICreateMesh
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

handles.xRange = 1;
handles.yRange = 1;
handles.zRange = 1;
handles.step = 0.1;

guidata(hObject,handles)

plotPreview(hObject, eventdata, handles);

uiwait
%% Output
% --- Outputs from this function are returned to the command line.
function varargout = GUICreateMesh_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);

varargout{1} = handles.coord;
varargout{2} = handles.elem;

close(handles.figure1)

%% Additional Functions

function plotPreview(hObject, eventdata, handles)

xRange = handles.xRange;
yRange = handles.yRange;
zRange = handles.zRange;
step = handles.step;
c = 343;
maxF = c/(10*step);

[a,b,c] = meshgrid(0:step:xRange, 0:step:yRange, 0:step:zRange);
x = a(:);   y = b(:);   z = c(:);

h = plot3(x,y,z);
set(h,'LineStyle','none')
set(h,'Marker','.')
set(h,'Color', 'g')
%p = patch('Vertices',[x,y,z],'FaceVertexCData',[0 0 0],'FaceColor','none');
%set(p,'EdgeColor',[0.75 0.75 1]);
grid on
title(['max. Frequency: ', num2str(maxF),' Hz'])

%% Callback Functions
% --- Executes on button press in createMeshButton.
function createMeshButton_Callback(hObject, eventdata, handles)

xRange = handles.xRange;
yRange = handles.yRange;
zRange = handles.zRange;
step = handles.step;

%create grid
[a,b,c] = meshgrid(0:step:xRange, 0:step:yRange, 0:step:zRange);
x = a(:);   y = b(:);   z = c(:);
%create triangulation
dt = DelaunayTri(x,y,z);

%create itaMeshNodes
coord = itaMeshNodes(length(dt.X(:,1)));
coord.ID = 1:length(dt.X(:,1));
coord.comment = 'Mesh Coordinates';
coord.x =  dt.X(:,1);
coord.y = dt.X(:,2);
coord.z = dt.X(:,3);
coord.cart = dt.X;

%create itaMeshElements
elem = itaMeshElements(length(dt.X(:,1)));
elem.ID = 1:length(dt.X(:,1));
elem.nodes = dt.Triangulation;
elem.shape = 'tetra';
elem.type = 'volume';
elem.order = 'parabolic';
elem.comment = 'Mesh Elements';

handles.elem = elem;
handles.coord = coord;
guidata(hObject,handles)

uiresume


function editStep_Callback(hObject, eventdata, handles)

step = str2double(get(hObject,'String'));
xRange = handles.xRange;
yRange = handles.yRange;
zRange = handles.zRange;

minRange = min(xRange,yRange);
minRange = min(minRange,zRange);

%correct Input?
if isa(step,'NaN')
    step = handles.step;
    set(handles.editStep, 'String', num2str(step))
    disp('Step must be a positiv number!')
    return
elseif step>minRange
    step = handles.step;
    set(handles.editStep, 'String', num2str(step))
    disp('Step must be less or equal x-Range, y-Range, z-Range!')
    return
end

handles.step = step;
guidata(hObject,handles)

plotPreview(hObject, eventdata, handles);



function editZRange_Callback(hObject, eventdata, handles)

step = handles.step;
zRange = str2double(get(hObject,'String'));

%correct Input?
if zRange <= 0 || imag(zRange) ~= 0
    disp('Z-Range must be positive and real!')
    set(handles.editZRange, 'String', num2str(handles.zRange))
    return
    
elseif zRange < step
    disp('Z-Range must be more of equal Step => changed Step')
    set(handles.editStep, 'String', num2str(zRange))
    handles.step = zRange;
end
    
handles.zRange = zRange;
guidata(hObject,handles)  

plotPreview(hObject, eventdata, handles);



function editYRange_Callback(hObject, eventdata, handles)

step = handles.step;
yRange = str2double(get(hObject,'String'));

%correct Input?
if yRange <= 0 || imag(yRange) ~= 0
    disp('Y-Range must be positive and real!')
    set(handles.editYRange, 'String', num2str(handles.yRange))
    return
    
elseif yRange < step
    disp('Y-Range must be more or equal Step => changed Step')
    set(handles.editStep, 'String', num2str(yRange))
    handles.step = yRange;
end

handles.yRange = yRange;
guidata(hObject,handles)

plotPreview(hObject, eventdata, handles);


function editXRange_Callback(hObject, eventdata, handles)

step = handles.step;
xRange = str2double(get(hObject,'String'));

%correct Input?
if xRange <= 0 || imag(xRange) ~= 0
    disp('X-Range must be positive and real!')
    set(handles.editXRange, 'String', num2str(handles.xRange))
    return
    
elseif xRange < step
    disp('X-Range must be more or equal Step => changed Step')
    set(handles.editStep, 'String', num2str(xRange))
    handles.step = xRange;
end

handles.xRange = xRange;
guidata(hObject,handles)

plotPreview(hObject, eventdata, handles);



%% Create Functions
% --- Executes during object creation, after setting all properties.
function editXRange_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editYRange_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editZRange_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editStep_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
