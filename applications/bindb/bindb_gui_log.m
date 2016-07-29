function varargout = bindb_gui_log(varargin)
% BINDB_GUI_LOG MATLAB code for bindb_gui_log.fig
%      BINDB_GUI_LOG, by itself, creates a new BINDB_GUI_LOG or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_LOG returns the handle to a new BINDB_GUI_LOG or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_LOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_LOG.M with the given input arguments.
%
%      BINDB_GUI_LOG('Property','Value',...) creates a new BINDB_GUI_LOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_log_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_log_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_log

% Last Modified by GUIDE v2.5 30-Nov-2011 13:53:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_log_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_log_OutputFcn, ...
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


% --- Executes just before bindb_gui_log is made visible.
function bindb_gui_log_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_log (see VARARGIN)

% Choose default command line output for bindb_gui_log
handles.output = hObject;

% update talbe data
global bindb_data;
set(handles.log_table, 'Data', bindb_data.Log);

% create global handle to update
global bindb_logtable;
bindb_logtable = handles.log_table;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_log_OutputFcn(hObject, eventdata, handles) 
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

% Resize table and columns
set(handles.log_table, 'Position', [10 10 (newsize(3) - 20) (newsize(4) - 20)]);
set(handles.log_table, 'ColumnWidth', {50 100 (newsize(3) - 189)});
