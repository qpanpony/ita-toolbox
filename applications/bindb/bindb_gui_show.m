function varargout = bindb_gui_show(varargin)
% BINDB_GUI_SHOW MATLAB code for bindb_gui_show.fig
%      BINDB_GUI_SHOW, by itself, creates a new BINDB_GUI_SHOW or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_SHOW returns the handle to a new BINDB_GUI_SHOW or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_SHOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_SHOW.M with the given input arguments.
%
%      BINDB_GUI_SHOW('Property','Value',...) creates a new BINDB_GUI_SHOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_show_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_show_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_show

% Last Modified by GUIDE v2.5 31-Mar-2012 14:21:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_show_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_show_OutputFcn, ...
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


% --- Executes just before bindb_gui_show is made visible.
function bindb_gui_show_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_show (see VARARGIN)

% Choose default command line output for bindb_gui_show
handles.output = hObject;
mmt = varargin{1};

% Draw room
bindb_drawroom(handles.room_canvas, mmt.Room.Layout);

% Set figure title
set(handles.figure1, 'Name', mmt.Room.Name);

% Add data and annotations
data = cell(0, 3);
index = 1;
for hwindex=1:length(mmt.Microphones)
    text(mmt.Microphones(hwindex).Location.X, mmt.Microphones(hwindex).Location.Y, num2str(index), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'BackgroundColor', [1 0.784 0.588]);
    data(index, 1:3) = { ['Microphone' num2str(hwindex) ': ' mmt.Microphones(hwindex).Location.Description], mmt.Microphones(hwindex).Location.Height, mmt.Microphones(hwindex).Hardware };  
    index = index + 1;
end
for hwindex=1:length(mmt.Sources)
    text(mmt.Sources(hwindex).Location.X, mmt.Sources(hwindex).Location.Y, num2str(index), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'BackgroundColor', [1 0.784 0.588]);
    data(index, 1:3) = { ['Source' num2str(hwindex) ': ' mmt.Sources(hwindex).Location.Description], mmt.Sources(hwindex).Location.Height, mmt.Sources(hwindex).Hardware };  
    index = index + 1;
end

% Update table
set(handles.equipment_table, 'Data', data);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bindb_gui_show wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_show_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
