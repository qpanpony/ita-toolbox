function varargout = ita_databaseGUI_insert(varargin)
% ITA_DATABASEGUI_INSERT MATLAB code for ita_databaseGUI_insert.fig
%      ITA_DATABASEGUI_INSERT, by itself, creates a new ITA_DATABASEGUI_INSERT or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ITA_DATABASEGUI_INSERT returns the handle to a new ITA_DATABASEGUI_INSERT or the handle to
%      the existing singleton*.
%
%      ITA_DATABASEGUI_INSERT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITA_DATABASEGUI_INSERT.M with the given input arguments.
%
%      ITA_DATABASEGUI_INSERT('Property','Value',...) creates a new ITA_DATABASEGUI_INSERT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_databaseGUI_insert_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_databaseGUI_insert_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_databaseGUI_insert

% Last Modified by GUIDE v2.5 26-Apr-2013 14:48:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_databaseGUI_insert_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_databaseGUI_insert_OutputFcn, ...
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


% --- Executes just before ita_databaseGUI_insert is made visible.
function ita_databaseGUI_insert_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_databaseGUI_insert (see VARARGIN)

% Choose default command line output for ita_databaseGUI_insert
handles.output = hObject;

%windowtitle
set(handles.figure1, 'name', 'ITA Signal Database - Insert')

%Database connection
handles.conn = database('signaldb', 'signaldb', 'signaldb');

%TableData
handles.columnNames = {'Bezeichnung', 'Geschlecht', 'Landessprache', 'Phonetik', 'Laenge', 'Wortart', 'Sprachtest', 'Kanaele';...
                    'Bezeichnung', 'Genre', 'Instrumente', 'Gesang', 'Landessprache', 'Aufnahmeart', 'Kanaele', ''};
handles.tableNames = {'Sprache'; 'Musik' ; 'Synthetische Töne'; 'Natürliche Geräusche'};

%Popupmenu strings
handles.languages = {''; 'deutsch'; 'spanisch'; 'französisch'; 'italienisch'; 'niederländisch'; 'russisch'; 'chinesisch';};
handles.gender = {'männlich';'weiblich'};
handles.channels = {'mono'; 'stereo'; 'binaural'};
handles.genre = {''; 'Klassik'; 'Jazz'; 'Rock'; 'Pop'; 'Metal'; 'Funk'; 'Elektro'; 'Techno'; 'Dubstep'};

%Category
handles.category = varargin{1};
set(handles.popupCategory, 'Value', handles.category)
handles.numOfColumns = 8;

%ID
% handles.ID = varargin{1}{2};

%file
handles.filepath = '';

%Signal - Data
handles.signalData = 0;


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



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ita_databaseGUI_insert wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_databaseGUI_insert_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Functions
function analyseProperties(handles, hObject, filepath)

signal = ita_read(filepath);

% get the filename
filename = strfind(filepath, '\');
if isempty(filename)
    filename = filepath;
else
    filename = filepath(filename(end)+1:end);
end

filetype = strfind(filename, '.');
if ~isempty(filetype)
    filename = filename(1:filetype(end)-1);
end

length = signal.trackLength;
% signal.plot_time

numOfChannels = numel(signal.channelNames);
channels = handles.channels;
% numOfChannels = numOfChannels(1);

% if numOfChannels == 1
%     channel = 'mono';
% else
%     channel = 'stereo';
% end
% handles.length = length;
% handles.channel = channel;

switch handles.category
    case 1
        %Speech
        set(handles.editColumn1, 'String', filename);
        handles.column1Data = filename;
        set(handles.editColumn5, 'String', length);
        handles.column5Data = length;
        set(handles.editColumn8, 'Value', numOfChannels);        
        handles.column8Data = channels{numOfChannels};
    case 2
        %Music
        set(handles.editColumn1, 'String', filename);
        handles.column1Data = filename;        
        set(handles.editColumn7, 'Value', numOfChannels);
        handles.column7Data = numOfChannels;
    case 3
        
    case 4
end

guidata(hObject, handles)

%% Callbacks

% --- Executes on selection change in popupCategory.
function popupCategory_Callback(hObject, eventdata, handles)
category = get(hObject, 'Value');

if category ~= 1 && category ~= 2
    set(hObject, 'Value', handles.category)
    msgbox('This category is not supported jet', 'Sorry')
    return
end

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


%Refresh Properties
set(handles.editColumn1, 'Value', 1);
set(handles.editColumn2, 'Value', 1);
set(handles.editColumn3, 'Value', 1);
set(handles.editColumn4, 'Value', 1);
set(handles.editColumn5, 'Value', 1);
set(handles.editColumn6, 'Value', 1);
set(handles.editColumn7, 'Value', 1);
set(handles.editColumn8, 'Value', 1);

set(handles.editColumn1, 'String', '');
set(handles.editColumn2, 'String', '');
set(handles.editColumn3, 'String', '');
set(handles.editColumn4, 'String', '');
set(handles.editColumn5, 'String', '');
set(handles.editColumn6, 'String', '');
set(handles.editColumn7, 'String', '');
set(handles.editColumn8, 'String', '');

handles.column1Data = '';
handles.column2Data = '';
handles.column3Data = '';
handles.column4Data = '';
handles.column5Data = '';
handles.column6Data = '';
handles.column7Data = '';
handles.column8Data = '';

%Change style
set(handles.editColumn1, 'Style', 'edit');
set(handles.editColumn2, 'Style', 'edit');
set(handles.editColumn3, 'Style', 'edit');
set(handles.editColumn4, 'Style', 'edit');
set(handles.editColumn5, 'Style', 'edit');
set(handles.editColumn6, 'Style', 'edit');
set(handles.editColumn7, 'Style', 'edit');
set(handles.editColumn8, 'Style', 'edit');

gender = handles.gender;
languages = handles.languages;
channels = handles.channels;
genre = handles.genre;


if category == 1
    set(handles.editColumn2, 'Style', 'popupmenu');
    set(handles.editColumn3, 'Style', 'popupmenu');
    set(handles.editColumn8, 'Style', 'popupmenu');
    set(handles.editColumn5, 'Style', 'text');
    
    set(handles.editColumn2, 'String', gender);
    set(handles.editColumn3, 'String', languages);    
    set(handles.editColumn8, 'String', channels);
    
    handles.column2Data = gender{1};
    handles.column3Data = languages{1};
    handles.column8Data = channels{1};
    
elseif category == 2
    set(handles.editColumn2, 'Style', 'popupmenu');
    set(handles.editColumn5, 'Style', 'popupmenu');
    set(handles.editColumn7, 'Style', 'popupmenu');
    
    set(handles.editColumn2, 'String', genre);
    set(handles.editColumn5, 'String', languages);    
    set(handles.editColumn7, 'String', channels);
    
    handles.column2Data = genre{1};
    handles.column5Data = languages{1};
    handles.column7Data = channels{1};
    
end


handles.numOfColumns = numOfColumns;
handles.category = category;
guidata(hObject, handles)

if ~isempty(handles.filepath)&& ~isempty(handles.filename)
    analyseProperties(handles, handles.pushOpenFile, [handles.filepath, handles.filename]);
end



function editColumn1_Callback(hObject, eventdata, handles)

if strcmp(get(hObject, 'Style'), 'popupmenu')
    data = get(hObject, 'String');
    data = data{get(hObject, 'Value')};
else
    data = get(hObject, 'String');
end

handles.column1Data = data;
guidata(hObject, handles)

function editColumn2_Callback(hObject, eventdata, handles)

if strcmp(get(hObject, 'Style'), 'popupmenu')
    data = get(hObject, 'String');
    data = data{get(hObject, 'Value')};
else
    data = get(hObject, 'String');
end

handles.column2Data = data;
guidata(hObject, handles)

function editColumn3_Callback(hObject, eventdata, handles)

if strcmp(get(hObject, 'Style'), 'popupmenu')
    data = get(hObject, 'String');
    data = data{get(hObject, 'Value')};
else
    data = get(hObject, 'String');
end

handles.column3Data = data;
guidata(hObject, handles)


function editColumn4_Callback(hObject, eventdata, handles)

if strcmp(get(hObject, 'Style'), 'popupmenu')
    data = get(hObject, 'String');
    data = data{get(hObject, 'Value')};
else
    data = get(hObject, 'String');
end

handles.column4Data = data;
guidata(hObject, handles)


function editColumn5_Callback(hObject, eventdata, handles)

if strcmp(get(hObject, 'Style'), 'popupmenu')
    data = get(hObject, 'String');
    data = data{get(hObject, 'Value')};
else
    data = get(hObject, 'String');
end

handles.column5Data = data;
guidata(hObject, handles)


function editColumn6_Callback(hObject, eventdata, handles)

if strcmp(get(hObject, 'Style'), 'popupmenu')
    data = get(hObject, 'String');
    data = data{get(hObject, 'Value')};
else
    data = get(hObject, 'String');
end

handles.column6Data = data;
guidata(hObject, handles)


function editColumn7_Callback(hObject, eventdata, handles)

if strcmp(get(hObject, 'Style'), 'popupmenu')
    data = get(hObject, 'String');
    data = data{get(hObject, 'Value')};
else
    data = get(hObject, 'String');
end

handles.column7Data = data;
guidata(hObject, handles)


function editColumn8_Callback(hObject, eventdata, handles)

if strcmp(get(hObject, 'Style'), 'popupmenu')
    data = get(hObject, 'String');
    data = data{get(hObject, 'Value')};
else
    data = get(hObject, 'String');
end

handles.column8Data = data;
guidata(hObject, handles)



% --- Executes on button press in pushOpenFile.
function pushOpenFile_Callback(hObject, eventdata, handles)

filefilter = {'*.wav; *.mp3', 'Audio Files (*.wav, *.mp3)'; '*.*', 'All Files'};
[filename,filepath] = uigetfile(filefilter,...
    'Chose the file, that you want to add', 'MultiSelect', 'off', '\\Verdi\Share\Audio Cds');

if isempty(filename) || isempty(filepath) || filename(1) == 0 || filepath(1) == 0
    return
end

try
    ita_read([filepath, filename]);
catch err
    
    msgbox({'This is not a ITA compatible file!';'Try again'},'Error','error');    
    return
end

if ~strncmpi(filepath, '\\verdi\share\', 14)
    msgbox({'The file must lay on \\Verdi\Share !!!';'Try again'},'Error','error');    
    return
end

handles.filename = filename;
handles.filepath = filepath;

guidata(hObject, handles)


%% Analyse
analyseProperties(handles, hObject, [filepath, filename]);

msgbox('Please fill the properties, that could not be filled automatically')


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

% --- Executes on button press in pushClose.
function pushClose_Callback(hObject, eventdata, handles)

close(handles.figure1);

%% Create Functions


% --- Executes during object creation, after setting all properties.
function popupCategory_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editColumn2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editColumn5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editColumn6_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editColumn7_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editColumn8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
