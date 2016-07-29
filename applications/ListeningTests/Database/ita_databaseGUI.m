function varargout = ita_databaseGUI(varargin)
% ITA_DATABASEGUI MATLAB code for ita_databaseGUI.fig
%      ITA_DATABASEGUI, by itself, creates a new ITA_DATABASEGUI or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ITA_DATABASEGUI returns the handle to a new ITA_DATABASEGUI or the handle to
%      the existing singleton*.
%
%      ITA_DATABASEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITA_DATABASEGUI.M with the given input arguments.
%
%      ITA_DATABASEGUI('Property','Value',...) creates a new ITA_DATABASEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_databaseGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_databaseGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_databaseGUI

% Last Modified by GUIDE v2.5 03-May-2013 13:45:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_databaseGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_databaseGUI_OutputFcn, ...
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


% --- Executes just before ita_databaseGUI is made visible.
function ita_databaseGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_databaseGUI (see VARARGIN)

% Choose default command line output for ita_databaseGUI
handles.output = hObject;

%windowtitle
set(handles.figure1, 'name', 'ITA Signal Database')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ita_databaseGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_databaseGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushBrowse.
function pushBrowse_Callback(hObject, eventdata, handles)

h = handles.figure1;
ita_databaseGUI_search()
close(h)


% --- Executes on button press in pushNoise.
function pushNoise_Callback(hObject, eventdata, handles)

h = handles.figure1;
ita_GUICreateNoise();
close(h)


% --- Executes on button press in pushExit.
function pushExit_Callback(hObject, eventdata, handles)

h = handles.figure1;
close(h)
