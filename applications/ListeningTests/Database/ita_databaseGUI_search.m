function varargout = ita_databaseGUI_search(varargin)
% ITA_DATABASEGUI_SEARCH MATLAB code for ita_databaseGUI_search.fig
%      ITA_DATABASEGUI_SEARCH, by itself, creates a new ITA_DATABASEGUI_SEARCH or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ITA_DATABASEGUI_SEARCH returns the handle to a new ITA_DATABASEGUI_SEARCH or the handle to
%      the existing singleton*.
%
%      ITA_DATABASEGUI_SEARCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITA_DATABASEGUI_SEARCH.M with the given input arguments.
%
%      ITA_DATABASEGUI_SEARCH('Property','Value',...) creates a new ITA_DATABASEGUI_SEARCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_databaseGUI_search_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_databaseGUI_search_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_databaseGUI_search

% Last Modified by GUIDE v2.5 03-May-2013 15:19:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_databaseGUI_search_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_databaseGUI_search_OutputFcn, ...
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


% --- Executes just before ita_databaseGUI_search is made visible.
function ita_databaseGUI_search_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_databaseGUI_search (see VARARGIN)

% Choose default command line output for ita_databaseGUI_search
handles.output = hObject;

%% Initialization

handles.searchTable = '';
handles.exactSearch = 0;

%windowsize
% scrsz  = get(0,'screensize');
% temp = get( handles.figure1, 'Units');
% set( handles.figure1, 'Units', 'Pixels',...
%           'OuterPosition', [scrsz(3)*0.05 scrsz(4)*0.1 scrsz(3)*0.9 scrsz(4)*0.85]);
% set( handles.figure1, 'Units', temp); 

%windowtitle
set(handles.figure1, 'name', 'ITA Signal Database - Search')

%ResizeFcn
set(handles.figure1, 'ResizeFcn', @changeWindowsize_Callback)

%TableProperties
set(handles.table, 'CellSelectionCallback',@(src,eventdata)tableSelection_Callback(hObject, eventdata))
set(handles.table, 'BusyAction', 'cancel')

columnFormat = {'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'bank', 'char', 'char'};
set(handles.table, 'columnformat',  columnFormat)

%Category
set(handles.popupCategory, 'Value', 1)
handles.category = 1;

%TableData
handles.columnNames = {'Bezeichnung', 'Geschlecht', 'Landessprache', 'Phonetik', 'Laenge', 'Wortart', 'Sprachtest', 'Kanaele', 'Dateipfad', 'Bewertung', 'anzBewertung', 'Kommentare';...
                    'Bezeichnung', 'Genre', 'Instrumente', 'Gesang', 'Landessprache', 'Aufnahmeart', 'Kanaele', '','Dateipfad', 'Bewertung', 'anzBewertung', 'Kommentare'};
handles.tableName = {'Sprache'; 'Musik' ; 'Synthetische Töne'; 'Natürliche Geräusche'};
handles.tableData = 0;
handles.IDData = 0;

handles.sortBy = 'Bezeichnung';

%Database connection
handles.conn = database('signaldb', 'signaldb', 'signaldb');

% Update handles structure
guidata(hObject, handles);

%Initialize table
popupCategory_Callback(hObject, eventdata, handles)

% UIWAIT makes ita_databaseGUI_search wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_databaseGUI_search_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Functions

function changeTooltip(handles, headline, tooltip)

tooltip = [{headline}; {tooltip}];
set(handles.tooltip, 'String', tooltip);

function changeWindowsize_Callback(hObject, eventdata)

handles = guidata(hObject);

set(handles.figure1, 'Units', 'pixels')
pos = get(handles.figure1, 'Position');
width = pos(3);

tablePos = get(handles.table, 'Position');
relativeWidth = tablePos(3);

tableWidth = width*relativeWidth;
columnWidth = {tableWidth*0.1 tableWidth*0.1 tableWidth*0.1 tableWidth*0.1 tableWidth*0.1 tableWidth*0.1 tableWidth*0.1...
    tableWidth*0.1 tableWidth*0.04 tableWidth*0.0703 tableWidth*0.0703};

set(handles.table, 'ColumnWidth', columnWidth)

 


%% Callback Functions

function editTable_Callback(hObject, eventdata, handles)

handles.searchTable = get(hObject, 'String');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkExactSearch.
function checkExactSearch_Callback(hObject, eventdata, handles)

handles.exactSearch = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);

function tableSelection_Callback(hObject, eventdata)

handles=guidata(hObject);


selection = eventdata.Indices;

%nothing selected?
if isempty(selection)
    return
%more than one cell selected?
elseif size(selection) ~= [1 2]
    return
elseif selection(1) == 0
    return
%last column?
%  elseif selection(2) ~= 9
%      return
end

%select TableElement
tableData = handles.tableData;
columnNames = handles.columnNames;
tableName = handles.tableName{handles.category};
ID = handles.IDData{selection(1)};
filepath = tableData{selection(1), 9};

signal = 0;



switch selection(2)
    %Rate
    case 9
        rateSignal(tableData(selection(1), :), {columnNames(handles.category, :)}, {tableName}, {ID})
    %Options
    case 10
        %signal.play()
        if ~isempty(filepath)
            signal = ita_read(filepath);
        end

        
        varInput = {signal, filepath};
        singleSignalOptions(varInput)
        
    %AdminOptions   
    case 11
        varInput = {handles.category, ID, filepath, tableData(selection(1), :)};
        singleSignalAdmin(varInput)
        
    otherwise
        return
end


%Deselect Cell
visibleData = get(handles.table, 'Data');
set(handles.table, 'Data', []);
set(handles.table, 'Data', visibleData);

% --- Executes on button press in pushSearch.
function pushSearch_Callback(hObject, eventdata, handles)

searchT = splitString(handles.searchTable, ',');
category = handles.category;
tableName = handles.tableName{category};
columnNames = handles.columnNames(category,:);
sortBy = handles.sortBy;


if isempty(searchT)
    sqlCommand = listTable(columnNames, tableName, sortBy);
    sqlIDCommand = listID(columnNames{1}, tableName);
    
elseif handles.exactSearch == 1;
    sqlCommand = searchTable(searchT, columnNames,tableName, sortBy);
    sqlIDCommand = searchID(searchT, columnNames,tableName);
else
    sqlCommand = searchTableWildcard(searchT,columnNames, tableName, sortBy);
    sqlIDCommand = searchIDWildcard(searchT, columnNames,tableName);
end

cursor = exec(handles.conn, sqlCommand);
cursor = fetch(cursor);
tableData = cursor.Data;

cursor = exec(handles.conn, sqlIDCommand);
cursor = fetch(cursor);
IDData = cursor.Data;

%Tooltips

%Search was not succsessful?
if strcmp(tableData, 'No Data')
    changeTooltip(handles,'Sorry:', 'There are no results for your keyword(s)')
    return
end
% if tableData == 0
%     changeTooltip(handles,'Sorry:', 'There are no results for your keyword(s)')
%     return    
% end

changeTooltip(handles,'', 'Search was successful')

handles.tableData = tableData;
handles.IDData = IDData;

% Update handles structure
guidata(hObject, handles)

%% refresh table
%deselect filepath
columnNames = columnNames([1:8]);
% columnNames = [columnNames; ' '];
visibleData = tableData(:,[1:8]);


%add Ratings
completeRating = cell2mat(tableData(:, 10));
numOfRatings = cell2mat(tableData(:, 11));
averageRating = completeRating./numOfRatings;
%NaN -> 0
averageRating(isnan(averageRating)) = 0;
%round
averageRating = round(averageRating.*100)/100;

addColumn = num2cell(averageRating);
visibleData = [visibleData, addColumn];

%add Click-Buttons
addColumn = {'+++++++'};
for k = 1:length(visibleData(:,1))-1
    addColumn = [addColumn;{'+++++++'}];
end
visibleData = [visibleData, addColumn];

%add LOAD-Buttons
% addColumn = {'+++++++'};
% for k = 1:length(visibleData(:,1))-1
%     addColumn = [addColumn;{'+++++++'}];
% end
visibleData = [visibleData, addColumn];

% % add OPEN-Buttons
% addColumn = {'OPEN'};
% for k = 1:length(visibleData(:,1))-1
%     addColumn = [addColumn;{'OPEN'}];
% end
% visibleData = [visibleData, addColumn];


%submit Data
set(handles.table, 'Data', visibleData)
set(handles.table, 'ColumnName', [columnNames, {'Bewertung'}, {'Use Signal'}, {'Change/Delete'}])


% --- Executes on button press in pushBack.
function pushBack_Callback(hObject, eventdata, handles)

h = gcf;
ita_databaseGUI()
close(h)


% --- Executes on selection change in popupCategory.
function popupCategory_Callback(hObject, eventdata, handles)

category = get(handles.popupCategory, 'Value');

%Kategorien noch nicht fertig
if category > 2
    set(handles.popupCategory, 'Value', handles.category)
    changeTooltip(handles,'Sorry', 'This category does not work yet!')
    return
end

handles.category = category;

sortTags = handles.columnNames(category, :);
if isempty(sortTags)
    sortTags = sortTags(1:find(isempty(sortTags))-1);
else
    sortTags = sortTags(1:8);
end

set(handles.popupSort, 'String', sortTags);

guidata(hObject, handles);

pushSearch_Callback(handles.pushSearch, eventdata, handles)


% --- Executes on selection change in popupSort.
function popupSort_Callback(hObject, eventdata, handles)

sortBy = get(hObject, 'Value');
strings = get(hObject, 'String');
sortBy = strings{sortBy};
handles.sortBy = sortBy;

guidata(hObject, handles);

pushSearch_Callback(handles.pushSearch, eventdata, handles)


% --------------------------------------------------------------------
function uiInsertTool_ClickedCallback(hObject, eventdata, handles)

ita_databaseGUI_insert(handles.category);


% --------------------------------------------------------------------
function uiRateTool_ClickedCallback(hObject, eventdata, handles)

rateDatabase();


%% Create Functions

% --- Executes during object creation, after setting all properties.
function editTable_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popupCategory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCategory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function popupSort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
