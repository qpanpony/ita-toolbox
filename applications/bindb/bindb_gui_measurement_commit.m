function varargout = bindb_gui_measurement_commit(varargin)
% BINDB_GUI_MEASUREMENT_COMMIT MATLAB code for bindb_gui_measurement_commit.fig
%      BINDB_GUI_MEASUREMENT_COMMIT, by itself, creates a new BINDB_GUI_MEASUREMENT_COMMIT or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_MEASUREMENT_COMMIT returns the handle to a new BINDB_GUI_MEASUREMENT_COMMIT or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_MEASUREMENT_COMMIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_MEASUREMENT_COMMIT.M with the given input arguments.
%
%      BINDB_GUI_MEASUREMENT_COMMIT('Property','Value',...) creates a new BINDB_GUI_MEASUREMENT_COMMIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_measurement_commit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_measurement_commit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_measurement_commit

% Last Modified by GUIDE v2.5 26-May-2012 14:34:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_measurement_commit_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_measurement_commit_OutputFcn, ...
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


% --- Executes just before bindb_gui_measurement_commit is made visible.
function bindb_gui_measurement_commit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_measurement_commit (see VARARGIN)

% Choose default command line output for bindb_gui_measurement_commit
handles.output = hObject;

% Update fixed comment line
handles.FixedLine =  sprintf('EDIT: %s (%s)', ita_preferences('AuthorStr'), datestr(now, 'dd.mm. HH:MM'));
set(handles.comment_line, 'String', ['+ ' handles.FixedLine]);

if isempty(varargin)
    % Get all measurements in workspace
    vars = evalin('base', 'whos');
    mmts = cell(0, 1);
    for index = 1:length(vars)
        if strcmp(vars(index).class, 'bindb_measurement')
            mmts{end+1} = vars(index).name;
        end
    end

    % Disable if no variables
    if isempty(mmts)
        set(handles.measurement_popup, 'String', 'no variables');
        set(handles.measurement_popup, 'Enable', 'off');
        set(handles.actions_ok, 'Enable', 'off');
        
        % Update handles structure
        guidata(hObject, handles);
    else            
        handles.Measurements = mmts;

        % Update popup
        set(handles.measurement_popup, 'String', mmts);
        set(handles.measurement_popup, 'Value', 1);
        measurement_popup_Callback(handles.measurement_popup, {}, handles);
    end
else
    % List parameter
    set(handles.measurement_popup, 'String', 'parameter');
    set(handles.measurement_popup, 'Enable', 'off');
    handles.Measurement = varargin{1};
    
    % Update comment
    set(handles.comment_field, 'String', sprintf(handles.Measurement.Comment));
    
    % Update handles structure
    guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_measurement_commit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in measurement_popup.
function measurement_popup_Callback(hObject, eventdata, handles)
% hObject    handle to measurement_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Measurement = evalin('base', handles.Measurements{get(hObject,'Value')});

% Update comment
set(handles.comment_field, 'String', sprintf(handles.Measurement.Comment));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in actions_ok.
function actions_ok_Callback(hObject, eventdata, handles)
% hObject    handle to actions_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get measurement
mmt = handles.Measurement;

% Increase Version
mmt.Version = mmt.Version + 1;

% Change comment
mmt.Comment = [bindb_tostring(get(handles.comment_field, 'String')) '\n' handles.FixedLine];

% Fields
fields = '';
for index = 1:size(mmt.Data, 1)-3    
    if isnumeric(mmt.Data{index+3, 2})
        if isnan(mmt.Data{index+3, 2})
            fields = [fields ', `' mmt.Data{index+3, 1} '`=NULL'];
        else
            fields = [fields ', `' mmt.Data{index+3, 1} '`=' num2str(mmt.Data{index+3, 2})];
        end
    else
        fields = [fields ', `' mmt.Data{index+3, 1} '`=''' mmt.Data{index+3, 2} ''''];
    end    
end

try
    % Update fields and measurement info
    bindb_exec(sprintf('UPDATE `Measurements` SET `Date`=''%s'', `Version`=%d, `Author`=''%s'', `Comment`=''%s'', `Humidity`=%d, `Volume`=%d, `Temperature`=%d%s WHERE `M_ID`=%d', mmt.Timestamp, mmt.Version, mmt.Author, mmt.Comment, mmt.Data{1,2}, mmt.Data{2,2}, mmt.Data{3,2}, fields, mmt.ID));
    
    % Update responses
    for hwindex = 1:length(mmt.Microphones)
        bindb_exec(sprintf('UPDATE `Responses` SET `X`=%d, `Y`=%d, `Height`=%d, `Description`=''%s'', `Hardware`=''%s'' WHERE R_ID=%d', mmt.Microphones(hwindex).Location.X, mmt.Microphones(hwindex).Location.Y, mmt.Microphones(hwindex).Location.Height, mmt.Microphones(hwindex).Location.Description, mmt.Microphones(hwindex).Hardware, mmt.Microphones(hwindex).ID));
        
        % Save rir to network folder or outbox
        RIR = mmt.Microphones(hwindex).ImpulseResponse;             
        try
            save(bindb_fileidpath('rir', mmt.Microphones(hwindex).ID), 'RIR');                   
        catch
            save(bindb_fileidpath('outbox', mmt.Microphones(hwindex).ID), 'RIR');
                
            % Add log
            bindb_addlog('System', 'failed to store impulse response in filestorage', 1);
        end
    end
    
    % Update sources
    for hwindex = 1:length(mmt.Sources)
        bindb_exec(sprintf('UPDATE `Sources` SET `X`=%d, `Y`=%d, `Height`=%d, `Description`=''%s'', `Hardware`=''%s'' WHERE S_ID=%d', mmt.Sources(hwindex).Location.X, mmt.Sources(hwindex).Location.Y, mmt.Sources(hwindex).Location.Height, mmt.Sources(hwindex).Location.Description, mmt.Sources(hwindex).Hardware, mmt.Sources(hwindex).ID));
    end
    
    
    bindb_addlog('Update measurement', 'measurement updated', 0);
    
    % Close gui
    delete(handles.figure1); 
catch err
    bindb_addlog('Update measurement', err.message, 1);
end

% Update measurement
bindb_measurement_save(mmt);
bindb_measurement_get();
