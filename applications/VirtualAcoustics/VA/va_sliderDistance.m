function varargout = va_sliderDistance(varargin)
% VA_SLIDERDISTANCE MATLAB code for va_sliderDistance.fig
%      VA_SLIDERDISTANCE, by itself, creates a new VA_SLIDERDISTANCE or raises the existing
%      singleton*.
%
%      H = VA_SLIDERDISTANCE returns the handle to a new VA_SLIDERDISTANCE or the handle to
%      the existing singleton*.
%
%      VA_SLIDERDISTANCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VA_SLIDERDISTANCE.M with the given input arguments.
%
%      VA_SLIDERDISTANCE('Property','Value',...) creates a new VA_SLIDERDISTANCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before va_sliderDistance_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to va_sliderDistance_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help va_sliderDistance

% Last Modified by GUIDE v2.5 19-Dec-2019 12:01:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @va_sliderDistance_OpeningFcn, ...
                   'gui_OutputFcn',  @va_sliderDistance_OutputFcn, ...
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


% --- Executes just before va_sliderDistance is made visible.
function va_sliderDistance_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to va_sliderDistance (see VARARGIN)

% Choose default command line output for va_sliderDistance
handles.output = hObject;

% Update handles structure
handles.va = varargin{1};
handles.S = varargin{2};
guidata(hObject, handles);


% UIWAIT makes va_sliderDistance wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = va_sliderDistance_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.angleText, 'String', [ 'Distance to receiver: ' num2str(get(hObject,'Value'),2) ' m' ]);
handles.va.set_sound_source_position( handles.S, [ 0.5 1.7 get(hObject,'Value') ] )


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
