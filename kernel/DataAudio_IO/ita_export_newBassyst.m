function varargout = ita_export_newBassyst(varargin)
% ita_export_newBassyst  Used to export Loudspeaker measurements into a file for the new bassyst.
%
%   ita_export_newBassyst()
%   Opens the GUI for the bassyst file export.
%
%   ita_export_newBassyst(itaTransferFuntion, itaInputImpedance, strBSName)
%   ita_export_newBassyst(itaTransferFuntion, itaInputImpedance, strBSName, strOutFile)
%   Exports two ITA - Classes and string with the intern Name for the bassyst without opening the GUI.
%   Additionally the name of the output file can be specified.

% Edit the above text to modify the response to help ita_export_newBassyst

% Last Modified by GUIDE v2.5 19-May-2016 16:36:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_export_newBassyst_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_export_newBassyst_OutputFcn, ...
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


% --- Executes just before ita_export_newBassyst is made visible.
function ita_export_newBassyst_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_export_newBassyst (see VARARGIN)


numInputs = nargin-3;

boolStartGUI = 1;

%Not enough Arguments
if(numInputs < 3)
    if(numInputs ~=0)
        answer = questdlgStartGUI('Not enough input arguments!');
        boolStartGUI = strcmp(answer, 'Yes');
    end
    
%Enough Arguments: Check their class    
else    
    if(numInputs>4)
        warning('Too many input arguments (maximum of 4). Ignoring additional arguments.')
    end
    
    transFunc = varargin{1};
    inputImp = varargin{2};
    bsName = varargin{3};
    
    outFile = [];
    if(numInputs==4)
        if(isa(varargin{4}, 'char'))
            outFile = varargin{4};
        end
    end    
    outFile = getOutFileWithExtension(outFile, bsName);
    
    if( isa(transFunc,'itaSuper') && isa(inputImp, 'itaSuper') && isa(bsName, 'char') )
        exportBSFile(transFunc, inputImp, bsName, outFile);
        boolStartGUI = 0;
    else
        answer = questdlgStartGUI('Correct number but wrong type of input arguments!');
        boolStartGUI = strcmp(answer, 'Yes');
    end
end

if(boolStartGUI)
    startGUI(hObject, handles);
else
    abordGUI(hObject);
end

function answer = questdlgStartGUI(strWarning)
strQuestion = {strWarning; 'Do you want to open the GUI?'};
answer = questdlg(strQuestion, 'Input Argument Error', 'Yes', 'No', 'No');

function exportBSFile(transFunc, inputImp, bsName, outFile)

docNode = getDocNode(transFunc, inputImp, bsName);
xmlwrite(outFile,docNode);

function abordGUI(figure)
close(figure);

function startGUI(hObject, handles)

handles.tfFile = '';
handles.impFile = '';
handles.outFile = '';
handles.bsName = '';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ita_export_newBassyst wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.figure1, 'name', 'Export LS Measurement to Bassyst File')

% --- Outputs from this function are returned to the command line.
function varargout = ita_export_newBassyst_OutputFcn(hObject, eventdata, handles) 


function outFile = getOutFileWithExtension(outFile, bsName)

if( isempty(outFile) )
    outFile = [bsName getBSFileExtension()];
    return;
end

idxFileExt = strfind(outFile, getBSFileExtension());
if (~isempty(idxFileExt))
    %File Extension is at the end of the filename?
    boolAddExt = ~( ( idxFileExt + length(getBSFileExtension()) - 1 ) == length(outFile) );
else
    boolAddExt = 1;
end

if(boolAddExt)
    outFile = [outFile getBSFileExtension()];
end

%% ----------CALLBACKS----------

%% Main Buttons
function buttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.tfFile) || isempty(handles.impFile) || isempty(handles.bsName)    
    errordlg('Specify all filenames / strings!')
    return
end

handles.outFile = getOutFileWithExtension(handles.outFile, handles.bsName);

msgWindow = msgbox('Starting Export','');

try
    [transFunc, inputImp, bsName, outFile] = guiHandlesToXMLVariables(handles);
catch ME
    close(msgWindow);
    switch ME.identifier
        case 'ITA_READ:NoInputFile'
            errordlg('At least one of the filenames is not linked to a file');
        case 'ITA_READ:UnkownFiletype'
            errordlg('At least one of the specified files is no ita-file');
        otherwise
            errordlg('Error during XML-file generation');
    end
    return
end

exportBSFile(transFunc, inputImp, bsName, outFile);

close(msgWindow);
close(handles.figure1);

function buttonExit_Callback(hObject, eventdata, handles)

close(handles.figure1);


%% Edit Name
function editBSName_Callback(hObject, eventdata, handles)

handles.bsName = get(hObject, 'String');
guidata(hObject, handles);

%% Output File
function editOutFile_Callback(hObject, eventdata, handles)

handles.outFile = get(hObject,'String');
guidata(hObject, handles);

% --- Executes on button press in buttonOpenOutFile.
function buttonOpenOutFile_Callback(hObject, eventdata, handles)

[filename, path] = uiputfile(['*' getBSFileExtension()],'Specify filename of bassyst export file');
if ~ischar(path) || ~ischar(filename)
    return
end
fullFilename = [path filename];
handles.outFile = fullFilename;
guidata(hObject, handles);

set(handles.editOutFile, 'String', fullFilename);


%% Transferfunction File
function editTFFile_Callback(hObject, eventdata, handles)

handles.tfFile = get(hObject,'String');
guidata(hObject, handles);

% --- Executes on button press in buttonOpenTFFile.
function buttonOpenTFFile_Callback(hObject, eventdata, handles)

[filename, path] = uigetfile('*.ita','Select file with TF measurement');
if ~ischar(path) || ~ischar(filename)
    return
end
fullFilename = [path filename];
handles.tfFile = fullFilename;
guidata(hObject, handles);

set(handles.editTFFile, 'String', fullFilename);

%% Impedance File
function editImpFile_Callback(hObject, eventdata, handles)

handles.impFile = get(hObject,'String');
guidata(hObject, handles);

% --- Executes on button press in buttonOpenImpFile.
function buttonOpenImpFile_Callback(hObject, eventdata, handles)

[filename, path] = uigetfile('*.ita','Select file with Impedance measurement');
if ~ischar(path) || ~ischar(filename)
    return
end
fullFilename = [path filename];
handles.impFile = fullFilename;
guidata(hObject, handles);

set(handles.editImpFile, 'String', fullFilename);


%% ------CREATE FUNCTIONS---------
% --- Executes during object creation, after setting all properties.
function editBSName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBSName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editTFFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTFFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editImpFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editImpFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editOutFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOutFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
