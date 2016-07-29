function varargout = rateSignal(varargin)
% RATEDATABASE MATLAB code for rateDatabase.fig
%      RATEDATABASE, by itself, creates a new RATEDATABASE or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = RATEDATABASE returns the handle to a new RATEDATABASE or the handle to
%      the existing singleton*.
%
%      RATEDATABASE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RATEDATABASE.M with the given input arguments.
%
%      RATEDATABASE('Property','Value',...) creates a new RATEDATABASE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rateDatabase_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rateDatabase_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rateDatabase

% Last Modified by GUIDE v2.5 03-May-2013 13:38:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rateDatabase_OpeningFcn, ...
                   'gui_OutputFcn',  @rateDatabase_OutputFcn, ...
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


% --- Executes just before rateDatabase is made visible.
function rateDatabase_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rateDatabase (see VARARGIN)

% Choose default command line output for rateDatabase
handles.output = hObject;

set(handles.figure1, 'name', 'ITA Signal Database - Rating')


picturepath = mfilename('fullpath');
picturepath = picturepath(1:strfind(picturepath, 'rateSignal')-1);

% Grafiken  einfügen
axes(handles.axes5);            % Auswahl des entsprechenden Axes-Objekts
G1=imread([picturepath, 'Bilder\5Sterne.jpg'],'jpg');    % Einlesen der Grafik
image (G1);                     % Grafik ausgeben,
axis image;                     % Grafik entzerren
axis off                          % Koordinatenachsen ausblenden

axes(handles.axes4);         
G1=imread([picturepath, 'Bilder\4Sterne.jpg'],'jpg');  
image (G1);                  
axis image;                     
axis off 

axes(handles.axes3);         
G1=imread([picturepath, 'Bilder\3Sterne.jpg'],'jpg');   
image (G1);                  
axis image;                     
axis off

axes(handles.axes2);         
G1=imread([picturepath, 'Bilder\2Sterne.jpg'],'jpg');   
image (G1);                  
axis image;                     
axis off

axes(handles.axes1);         
G1=imread([picturepath, 'Bilder\1Sterne.jpg'],'jpg');  
image (G1);                  
axis image;                     
axis off

axes(handles.axes0);         
G1=imread([picturepath, 'Bilder\0Sterne.jpg'],'jpg');   
image (G1);                  
axis image;                     
axis off

% handle data
handles.comment = '';
handles.rating = -1;
handles.overwrite = 0;
handles.conn = database('signaldb', 'signaldb', 'signaldb');

handles.signalData = varargin{1};
handles.columnNames = varargin{2}{:};
handles.tableName = varargin{3}{1};
handles.ID = varargin{4}{1};

% Update handles structure
guidata(hObject, handles);

%comments
comments = varargin{1}{12};
comments = splitString(comments, ';');
set(handles.listComments, 'String', comments);


% UIWAIT makes rateDatabase wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rateDatabase_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radio5.
function radio5_Callback(hObject, eventdata, handles)

set(handles.radio0, 'Value', 0)
set(handles.radio1, 'Value', 0)
set(handles.radio2, 'Value', 0)
set(handles.radio3, 'Value', 0)
set(handles.radio4, 'Value', 0)
set(handles.radio5, 'Value', 1)

handles.rating = 5;
guidata(hObject, handles);




% --- Executes on button press in radio4.
function radio4_Callback(hObject, eventdata, handles)

set(handles.radio0, 'Value', 0)
set(handles.radio1, 'Value', 0)
set(handles.radio2, 'Value', 0)
set(handles.radio3, 'Value', 0)
set(handles.radio4, 'Value', 1)
set(handles.radio5, 'Value', 0)

handles.rating = 4;
guidata(hObject, handles);


% --- Executes on button press in radio3.
function radio3_Callback(hObject, eventdata, handles)

set(handles.radio0, 'Value', 0)
set(handles.radio1, 'Value', 0)
set(handles.radio2, 'Value', 0)
set(handles.radio3, 'Value', 1)
set(handles.radio4, 'Value', 0)
set(handles.radio5, 'Value', 0)

handles.rating = 3;
guidata(hObject, handles);


% --- Executes on button press in radio2.
function radio2_Callback(hObject, eventdata, handles)

set(handles.radio0, 'Value', 0)
set(handles.radio1, 'Value', 0)
set(handles.radio2, 'Value', 1)
set(handles.radio3, 'Value', 0)
set(handles.radio4, 'Value', 0)
set(handles.radio5, 'Value', 0)

handles.rating = 2;
guidata(hObject, handles);


% --- Executes on button press in radio0.
function radio0_Callback(hObject, eventdata, handles)

set(handles.radio0, 'Value', 1)
set(handles.radio1, 'Value', 0)
set(handles.radio2, 'Value', 0)
set(handles.radio3, 'Value', 0)
set(handles.radio4, 'Value', 0)
set(handles.radio5, 'Value', 0)

handles.rating = 0;
guidata(hObject, handles);

% --- Executes on button press in radio1.
function radio1_Callback(hObject, eventdata, handles)

set(handles.radio0, 'Value', 0)
set(handles.radio1, 'Value', 1)
set(handles.radio2, 'Value', 0)
set(handles.radio3, 'Value', 0)
set(handles.radio4, 'Value', 0)
set(handles.radio5, 'Value', 0)

handles.rating = 1;
guidata(hObject, handles);



% --- Executes on button press in checkOverwrite.
function checkOverwrite_Callback(hObject, eventdata, handles)

handles.overwrite = get(hObject, 'Value');
guidata(hObject, handles);

% --- Executes on button press in pushSubmit.
function pushSubmit_Callback(hObject, eventdata, handles)

%already rated?
if handles.rating == -1
    msgbox('You have to rate the signal first', 'Sorry')
    return
end

%receive Data
signalData = handles.signalData;
columnNames = handles.columnNames;
columnNames = [{'ID'}, columnNames];
ID = handles.ID;

completeRating = signalData{10};
numOfRatings = signalData{11};
comments = signalData{12};

%update Data
completeRating = completeRating + handles.rating;
numOfRatings = numOfRatings + 1;
if numOfRatings == 1
    comments = handles.comment;
else
    comments = [comments ,'; ' , handles.comment];
end

signalData{10} = completeRating;
signalData{11} = numOfRatings;
signalData{12} = comments;

signalData = [{ID}, signalData];

exec(handles.conn, deleteSQLData(ID, handles.tableName));
fastinsert(handles.conn, handles.tableName, columnNames, signalData)

msgbox('Thank you for your rating ;-)')

% choice = questdlg('What do you want to do now?', ...
% 	'Dessert Menu', ...
% 	'Ice cream','Cake','No thank you','No thank you');

close(fig);


function editComment_Callback(hObject, eventdata, handles)

handles.comment = get(hObject, 'String');
guidata(hObject, handles);



% --- Executes on selection change in listComments.
function listComments_Callback(hObject, eventdata, handles)
% hObject    handle to listComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listComments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listComments


%% Create Functions

% --- Executes during object creation, after setting all properties.
function editComment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function listComments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
