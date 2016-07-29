function varargout = bindb_gui_measurement_results(varargin)
% BINDB_GUI_MEASUREMENT_RESULTS MATLAB code for bindb_gui_measurement_results.fig
%      BINDB_GUI_MEASUREMENT_RESULTS, by itself, creates a new BINDB_GUI_MEASUREMENT_RESULTS or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_MEASUREMENT_RESULTS returns the handle to a new BINDB_GUI_MEASUREMENT_RESULTS or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_MEASUREMENT_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_MEASUREMENT_RESULTS.M with the given input arguments.
%
%      BINDB_GUI_MEASUREMENT_RESULTS('Property','Value',...) creates a new BINDB_GUI_MEASUREMENT_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_measurement_results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_measurement_results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_measurement_results

% Last Modified by GUIDE v2.5 30-May-2012 20:43:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_measurement_results_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_measurement_results_OutputFcn, ...
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


% --- Executes just before bindb_gui_measurement_results is made visible.
function bindb_gui_measurement_results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_measurement_results (see VARARGIN)

% Choose default command line output for bindb_gui_measurement_results
handles.output = hObject;

% Store results
handles.Results = varargin{1};

% Remove state
handles.remove_measurement = 0;

% Register globals
global bindb_data;

if length(handles.Results) == 1 && strcmp(handles.Results{1}, 'No Data')
    % No results
    set(handles.results_table, 'Data', cell(0, 7));
else
    % Check if measurement is local
    for index = 1:size(handles.Results, 1)
        ind = bindb_findmeasurement(handles.Results{index, 1});
        if ind > 0   
            if bindb_data.Measurements{ind}.Version < handles.Results{index, 3}
                handles.Results{index, 10} = ['Update V.' num2str(handles.Results{index, 3})]; 
                handles.Results{index, 11} = 1;
            else
                handles.Results{index, 10} = ['Local V.' num2str(handles.Results{index, 3})];
                handles.Results{index, 11} = 0;
            end
        else
            handles.Results{index, 10} = ['Version ' num2str(handles.Results{index, 3})];
            handles.Results{index, 11} = 1;
        end
    end

    % Moditfy comments
    for row = 1:size(handles.Results, 1)
        handles.Results{row, 8} = ['[' num2str(handles.Results{row, 1}) '] ' strrep(handles.Results{row, 8}, sprintf('\n'), ' ')];
    end
    
    % Update table
    set(handles.results_table, 'Data', handles.Results(:, 4:10));    
end

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_measurement_results_OutputFcn(hObject, eventdata, handles) 
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

% Move labels
set(handles.results_name, 'Position', [10 (newsize(4) - 31) 51 21]);
set(handles.results_background, 'Position', [70 0 (newsize(3) - 70) newsize(4)]);
set(handles.transfers_hint, 'Position', [(newsize(3) - 241) 10 231 31]);

% Resize table and columns
set(handles.results_table, 'Position', [80 50 (newsize(3) - 90) (newsize(4) - 60)]);
set(handles.results_table, 'ColumnWidth', {70 100 80 100 (newsize(3) - 560) 20 80});


% --- Executes when selected cell(s) is changed in results_table.
function results_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to results_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Register globals
global bindb_data;

% Click on download
if ~isempty(eventdata.Indices)
    if handles.remove_measurement == 1
        % Change button text
        set(handles.remove, 'String', 'Remove');
    
        % Finish remove 
        handles.remove_measurement = 0;
        set(handles.figure1, 'Pointer', 'arrow');
        
        % Remove measurement
        row = eventdata.Indices(1);
        success = bindb_measurement_remove(handles.Results{row, 1});
        
        % Remove row
        if success
           data = get(handles.results_table, 'Data');  
           data(row, :) = [];
           set(handles.results_table, 'Data', data);
        end
    elseif eventdata.Indices(2) == 7
        data = get(handles.results_table, 'Data');  
        row = eventdata.Indices(1);

        % Alredy downloaded?
        if handles.Results{row, 11} == 0
            return;
        else
            % Update table
            data{row, 7} = 'download...';        
            set(handles.results_table, 'Data', data);
            drawnow();
        end

        % Load measurement
        [mmt, success] = bindb_measurement_load(handles.Results{eventdata.Indices(1), 1});

        if success
            % Save measurement
            bindb_measurement_save(mmt);

            % Update row
            data{row, 7} = ['Local V.' num2str(mmt.Version)];    
            handles.Results{row, 11} = 0;
        else
            % Update row
            data{row, 7} = 'Error';
        end

        % Update table
        set(handles.results_table, 'Data', data);

        % Read measurements
        bindb_measurement_get();
    end
end


% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Register globals
global bindb_data;

if handles.remove_measurement == 1
    % Change button text
    set(handles.remove, 'String', 'Remove');
    
    % Cancel remove 
    handles.remove_measurement = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    if bindb_data.Settings.AdminMode == 1
        % Change button text
        set(handles.remove, 'String', 'Cancel remove');

        % Start remove 
        handles.remove_measurement = 1;
        set(handles.figure1, 'Pointer', 'crosshair');
    else
    bindb_addlog('system', 'admin mode required', 1);
    fprintf('This action requires admin mode.\n<a href="matlab:bindb_setadmin(1)">Enter admin mode</a> <a href="matlab:bindb_setadmin(0)">Exit admin mode</a>\n');
    end    
end

% Update handles structure
guidata(hObject, handles);
