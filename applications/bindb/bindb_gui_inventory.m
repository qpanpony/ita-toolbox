function varargout = bindb_gui_inventory(varargin)
% BINDB_GUI_INVENTORY MATLAB code for bindb_gui_inventory.fig
%      BINDB_GUI_INVENTORY, by itself, creates a new BINDB_GUI_INVENTORY or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_INVENTORY returns the handle to a new BINDB_GUI_INVENTORY or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_INVENTORY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_INVENTORY.M with the given input arguments.
%
%      BINDB_GUI_INVENTORY('Property','Value',...) creates a new BINDB_GUI_INVENTORY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_inventory_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_inventory_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_inventory

% Last Modified by GUIDE v2.5 13-Dec-2011 15:15:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_inventory_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_inventory_OutputFcn, ...
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


% --- Executes just before bindb_gui_inventory is made visible.
function bindb_gui_inventory_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_inventory (see VARARGIN)

% Choose default command line output for bindb_gui_inventory
handles.output = hObject;

% Register globals
global bindb_data;

% Calculate and display size
bytes = 0;
files = [dir(bindb_folderpath('localdata')); dir(bindb_folderpath('measurements')); dir(bindb_folderpath('outbox'))];
for index = 1:size(files, 1)
    bytes = bytes + files(index).bytes;
end
set(handles.inventory_size, 'String', sprintf('Total size of local data: %0.3f MB', bytes / 1024 / 1024));

% Get server emasurements count
if bindb_isonline()
    num = bindb_queryrowsmat('SELECT COUNT(*) FROM Measurements', 1);
    set(handles.inventory_measurements, 'String', sprintf('Count of server measurements: %d', num));
else
    set(handles.inventory_measurements, 'String', 'Count of server measurements unknown');
end

% Local rooms
rooms = [bindb_data.Rooms bindb_data.Rooms_Outbox];
if ~isempty(rooms)
    col = {rooms.Name};
    data(1:length(col), 1) = col';
end 

% Local fields
if ~isempty(bindb_data.Fields)
    col =  {bindb_data.Fields.Name};
    data(1:length(col), 3) = col';
end

% Local measurements
col = bindb_data.Measurements;
for index = 1:length(col)
    mmt = col{index};
    col{index} = [datestr(mmt.Timestamp, 'yyyy-mm-dd') ', ' mmt.Author ' - ' mmt.Room.Name];
end
if ~isempty(col)
    data(1:length(col), 5) = col;
end

if bindb_isonline()
    % Online rooms
    col = bindb_query('SELECT Name FROM Rooms');
    if ~strcmp(col, 'No Data')
        data(1:size(col, 1), 2) = col;
    end
    
    % Online fields
    col = bindb_query('SELECT Name FROM Fields');
    if ~strcmp(col, 'No Data')
    data(1:size(col, 1), 4) = col;
    end
end  

% Fill table
set(handles.inventory_table, 'Data', data);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bindb_gui_inventory wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_inventory_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get new window size
newsize = get(handles.figure1, 'Position');

% Resize table and columns and background
set(handles.inventory_table, 'Position', [10 50 (newsize(3) - 20) (newsize(4) - 60)]);
columnwidth = (newsize(3) - 40) / 5;
set(handles.inventory_table, 'ColumnWidth', { columnwidth, columnwidth, columnwidth, columnwidth, columnwidth });
set(handles.inventory_background, 'Position', [0 0 newsize(3) 41]);
