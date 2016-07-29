function varargout = bindb_gui_measurement_newversion(varargin)
% BINDB_GUI_MEASUREMENT_NEWVERSION MATLAB code for bindb_gui_measurement_newversion.fig
%      BINDB_GUI_MEASUREMENT_NEWVERSION, by itself, creates a new BINDB_GUI_MEASUREMENT_NEWVERSION or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_MEASUREMENT_NEWVERSION returns the handle to a new BINDB_GUI_MEASUREMENT_NEWVERSION or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_MEASUREMENT_NEWVERSION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_MEASUREMENT_NEWVERSION.M with the given input arguments.
%
%      BINDB_GUI_MEASUREMENT_NEWVERSION('Property','Value',...) creates a new BINDB_GUI_MEASUREMENT_NEWVERSION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_measurement_newversion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_measurement_newversion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_measurement_newversion

% Last Modified by GUIDE v2.5 26-May-2012 10:45:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_measurement_newversion_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_measurement_newversion_OutputFcn, ...
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


% --- Executes just before bindb_gui_measurement_newversion is made visible.
function bindb_gui_measurement_newversion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_measurement_newversion (see VARARGIN)

% Choose default command line output for bindb_gui_measurement_newversion
handles.output = hObject;

% Display new measurement information
if length(varargin) == 1
   handles.Measurement = varargin{1};
   data = bindb_query(['SELECT `Measurements`.`Author`, `Measurements`.`Version`, `Measurements`.`Comment`, `Measurements`.`Date`, `Rooms`.`Name` FROM `Measurements` INNER JOIN `Rooms` ON `Rooms`.`O_ID`=`Measurements`.`O_ID` WHERE `Measurements`.`M_ID`=' num2str(handles.Measurement.ID)]);
   set(handles.measurement_author, 'String', data{1}); 
   set(handles.measurement_room, 'String', data{5});   
   set(handles.measurement_version, 'String', ['local: ' num2str(handles.Measurement.Version) ' online: ' num2str(data{2})]);
   if length(data{3}) ~= 0
        set(handles.measurement_comment, 'String', sprintf(data{3}));
   else
       set(handles.measurement_comment, 'String', 'no comment');
   end   
   set(handles.measurement_timestamp, 'String', data{4});
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bindb_gui_measurement_newversion wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_measurement_newversion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in actions_cancel.
function actions_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to actions_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Close
delete(handles.figure1);


% --- Executes on button press in actions_ok.
function actions_ok_Callback(hObject, eventdata, handles)
% hObject    handle to actions_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load measurement
[mmt, success] = bindb_measurement_load(handles.Measurement.ID);
     
if success
    % Save measurement
    bindb_measurement_save(mmt);        
else
    bindb_addlog('Update measurement', 'Could not update measurement!', 1);    
end

% Close
delete(handles.figure1);
