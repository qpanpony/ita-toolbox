function varargout = ita_databaseGUI_options(varargin)
% ITA_DATABASEGUI_OPTIONS MATLAB code for ita_databaseGUI_options.fig
%      ITA_DATABASEGUI_OPTIONS, by itself, creates a new ITA_DATABASEGUI_OPTIONS or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ITA_DATABASEGUI_OPTIONS returns the handle to a new ITA_DATABASEGUI_OPTIONS or the handle to
%      the existing singleton*.
%
%      ITA_DATABASEGUI_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITA_DATABASEGUI_OPTIONS.M with the given input arguments.
%
%      ITA_DATABASEGUI_OPTIONS('Property','Value',...) creates a new ITA_DATABASEGUI_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_databaseGUI_options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_databaseGUI_options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_databaseGUI_options

% Last Modified by GUIDE v2.5 27-Feb-2013 16:42:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_databaseGUI_options_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_databaseGUI_options_OutputFcn, ...
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


% --- Executes just before ita_databaseGUI_options is made visible.
function ita_databaseGUI_options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_databaseGUI_options (see VARARGIN)

% Choose default command line output for ita_databaseGUI_options
handles.output = hObject;

%windowtitle
set(handles.figure1, 'name', 'ITA Signal Database - Options')

%Database connection
handles.conn = database('signaldb', 'signaldb', 'signaldb');

%TableData
handles.columnNames = {'Bezeichnung', 'Geschlecht', 'Landessprache', 'Phonetik', 'Laenge', 'Wortart', 'Sprachtest', 'Kanaele';...
                    'Bezeichnung', 'Genre', 'Instrumente', 'Gesang', 'Landessprache', 'Aufnahmeart', 'Kanaele', ''};
handles.tableNames = {'Sprache'; 'Musik' ; 'Synthetische Töne'; 'Natürliche Geräusche'};

%file
handles.filename = '';
handles.filepath = '';

%Category
handles.category = 1;
handles.numOfColumns = 8;


%Column Data
handles.column1Data = '';
handles.column2Data = '';
handles.column3Data = '';
handles.column4Data = '';
handles.column5Data = '';
handles.column6Data = '';
handles.column7Data = '';
handles.column8Data = '';

% Update handles structure
guidata(hObject, handles);

%Initialize Category
popupCategory_Callback(handles.popupCategory, 0, handles)

% UIWAIT makes ita_databaseGUI_options wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_databaseGUI_options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushInsert.
function pushInsert_Callback(hObject, eventdata, handles)

choice = questdlg('Do you really want to add the signal to the database?', ...
	'Insert Menu', ...
	'Yes','No','No');

if ~strcmp('Yes', choice)
    return
end


filepath = handles.filepath;
filename = handles.filename;
category = handles.category;

if isempty(filepath) || isempty(filename) || ~isa(filepath, 'char') || ~isa(filename, 'char')
   msgbox('Chose a File first!', 'No filepath detected', 'error')
   return
end

%Data
inputData = {handles.column1Data; handles.column2Data; handles.column3Data; handles.column4Data;...
    handles.column5Data; handles.column6Data; handles.column7Data; handles.column8Data};

if strcmp(get(handles.editColumn8, 'Visible'), 'off')
    inputData{8} = '';
end
if strcmp(get(handles.editColumn7, 'Visible'), 'off')
    inputData{7} = '';
end
if strcmp(get(handles.editColumn6, 'Visible'), 'off')
    inputData{6} = '';
end
if strcmp(get(handles.editColumn5, 'Visible'), 'off')
    inputData{5} = '';
end

%ID

sqlIDCommand = ['SELECT ID FROM ', handles.tableNames{1}, ' UNION SELECT ID FROM ' handles.tableNames{2}, ' order by ID'];

cursor = exec(handles.conn, sqlIDCommand);
cursor = fetch(cursor);
IDData = cursor.Data;


numOfElem = length(IDData);

if numOfElem < 2
    newID = numOfElem+1;
else

    k = 2;

    while(IDData{k} - IDData{k-1} == 1)
        k = k+1;
        if k > length(IDData)
            break
        end        
    end
    
    newID = k;
end

tableData = {newID};

for k = 1:handles.numOfColumns
   tableData = [tableData, inputData(k)];
end
%filepath
tableData = [tableData, {[filepath, filename]}];

%ColumnNames
columnNames = handles.columnNames;
columnNames = columnNames(category, :);
columnNames = columnNames(1:handles.numOfColumns);
columnNames = [{'ID'},columnNames, {'Dateipfad'}];

tableName = handles.tableNames{category};

fastinsert(handles.conn, tableName, columnNames, tableData)


% --- Executes on button press in pushExit.
function pushExit_Callback(hObject, eventdata, handles)

close(gcf)


% --- Executes on button press in pushDelete.
function pushDelete_Callback(hObject, eventdata, handles)

% ita_databaseGUI_music()



% --- Executes on button press in pushBack.
function pushBack_Callback(hObject, eventdata, handles)

h = gcf;
ita_databaseGUI()
close(h)


% --- Executes on selection change in popupCategory.
function popupCategory_Callback(hObject, eventdata, handles)

category = get(hObject, 'Value');

columnNames = handles.columnNames(category, :);

%Update headlines
set(handles.textColumn1, 'String', columnNames(1))
set(handles.textColumn2, 'String', columnNames(2))
set(handles.textColumn3, 'String', columnNames(3))
set(handles.textColumn4, 'String', columnNames(4))
set(handles.textColumn5, 'String', columnNames(5))
set(handles.textColumn6, 'String', columnNames(6))
set(handles.textColumn7, 'String', columnNames(7))
set(handles.textColumn8, 'String', columnNames(8))

%% Change Textfields

emptyColumns = 0;
for k = 1:8
    emptyColumns = emptyColumns + isempty(columnNames{k});
end
numOfColumns = 8 - emptyColumns;

%Make all editTxt visible
set(handles.editColumn1, 'Visible', 'on')
set(handles.editColumn2, 'Visible', 'on')
set(handles.editColumn3, 'Visible', 'on')
set(handles.editColumn4, 'Visible', 'on')
set(handles.editColumn5, 'Visible', 'on')
set(handles.editColumn6, 'Visible', 'on')
set(handles.editColumn7, 'Visible', 'on')
set(handles.editColumn8, 'Visible', 'on')

%Make editTxt that not represent columns invisible
if numOfColumns < 8
    set(handles.editColumn8, 'Visible', 'off')
end
if numOfColumns < 7
    set(handles.editColumn7, 'Visible', 'off')
end
if numOfColumns < 6
    set(handles.editColumn6, 'Visible', 'off')
end
if numOfColumns < 5
    set(handles.editColumn5, 'Visible', 'off')
end
if numOfColumns < 4
    set(handles.editColumn4, 'Visible', 'off')
end
if numOfColumns < 3
    set(handles.editColumn3, 'Visible', 'off')
end
if numOfColumns < 2
    set(handles.editColumn2, 'Visible', 'off')
end
if numOfColumns < 1
    set(handles.editColumn1, 'Visible', 'off')
end

handles.numOfColumns = numOfColumns;
handles.category = category;
guidata(hObject, handles)
    

function editColumn1_Callback(hObject, eventdata, handles)

handles.column1Data = get(hObject, 'String');
guidata(hObject, handles)

function editColumn2_Callback(hObject, eventdata, handles)

handles.column2Data = get(hObject, 'String');
guidata(hObject, handles)

function editColumn3_Callback(hObject, eventdata, handles)

handles.column3Data = get(hObject, 'String');
guidata(hObject, handles)

function editColumn4_Callback(hObject, eventdata, handles)

handles.column4Data = get(hObject, 'String');
guidata(hObject, handles)

function editColumn5_Callback(hObject, eventdata, handles)

handles.column5Data = get(hObject, 'String');
guidata(hObject, handles)

function editColumn6_Callback(hObject, eventdata, handles)

handles.column6Data = get(hObject, 'String');
guidata(hObject, handles)

function editColumn7_Callback(hObject, eventdata, handles)

handles.column7Data = get(hObject, 'String');
guidata(hObject, handles)

function editColumn8_Callback(hObject, eventdata, handles)

handles.column8Data = get(hObject, 'String');
guidata(hObject, handles)


% --- Executes on button press in pushOpen.
function pushOpen_Callback(hObject, eventdata, handles)

[filename,filepath] = uigetfile();

if isempty(filename) || isempty(filepath)
    return
end

handles.filename = filename;
handles.filepath = filepath;

guidata(hObject, handles)


%% Create Functions

% --- Executes during object creation, after setting all properties.
function editColumn1_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupCategory_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn2_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn5_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn3_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function editColumn4_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn6_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn7_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn8_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
