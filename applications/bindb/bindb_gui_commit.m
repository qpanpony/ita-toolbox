function varargout = bindb_gui_commit(varargin)
% BINDB_GUI_COMMIT MATLAB code for bindb_gui_commit.fig
%      BINDB_GUI_COMMIT, by itself, creates a new BINDB_GUI_COMMIT or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = BINDB_GUI_COMMIT returns the handle to a new BINDB_GUI_COMMIT or the handle to
%      the existing singleton*.
%
%      BINDB_GUI_COMMIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDB_GUI_COMMIT.M with the given input arguments.
%
%      BINDB_GUI_COMMIT('Property','Value',...) creates a new BINDB_GUI_COMMIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bindb_gui_commit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bindb_gui_commit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bindb_gui_commit

% Last Modified by GUIDE v2.5 26-May-2012 13:35:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bindb_gui_commit_OpeningFcn, ...
                   'gui_OutputFcn',  @bindb_gui_commit_OutputFcn, ...
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


% --- Executes just before bindb_gui_commit is made visible.
function bindb_gui_commit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bindb_gui_commit (see VARARGIN)

% Choose default command line output for bindb_gui_commit
handles.output = hObject;

handles.remove_item = 0;
handles.commit_item = 0;

handles = updateContent(handles);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bindb_gui_commit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in actions_commit.
function actions_commit_Callback(hObject, eventdata, handles)
% hObject    handle to actions_commit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
% Cancel remove 
handles.remove_item = 0;
set(handles.actions_remove, 'String', 'Remove item');

if handles.commit_item == 1
    % Change button text
    set(handles.actions_commit, 'String', 'Commit item');
    
    % Cancel commit 
    handles.commit_item = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Change button text
    set(handles.actions_commit, 'String', 'Cancel commit');
    
    % Start commit 
    handles.commit_item = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in actions_remove.
function actions_remove_Callback(hObject, eventdata, handles)
% hObject    handle to actions_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Cancel commit
handles.commit_item = 0;
set(handles.actions_commit, 'String', 'Commit item');

% Remove selection

if handles.remove_item == 1
    % Change button text
    set(handles.actions_remove, 'String', 'Remove item');
    
    % Cancel commit 
    handles.remove_item = 0;
    set(handles.figure1, 'Pointer', 'arrow');
else
    % Change button text
    set(handles.actions_remove, 'String', 'Cancel remove');
    
    % Start commit 
    handles.remove_item = 1;
    set(handles.figure1, 'Pointer', 'crosshair');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in items_table.
function items_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to items_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Register globals
global bindb_data;

if ~isempty(eventdata.Indices)
    index = eventdata.Indices(1);
    type = handles.Outbox{index, 4}; % Types: 1=room, 2=measurement, 3=rir
    
    % Show description
    set(handles.items_description, 'String', handles.Outbox{index, 6});

    % Commit
    if handles.commit_item == 1       
        % Get data     
        data = get(handles.items_table, 'Data');
        
        if strcmp(data{index, 3} , 'pending')
            if type == 1
                % Commit room
                room = bindb_data.Rooms_Outbox(handles.Outbox{index, 5});
                [success, id] = bindb_room_commit(room.Name, room.Description, room.Layout, false);                 
                
                if success
                    % Update status
                    newid = id;
                    oldid = room.ID;
                    data{index, 2} = newid;
                    data{index, 3} = 'ok';  

                    % Update outbox measurements using this room
                    mmtupdated = false;
                    for immt = 1:size(handles.Outbox, 1)
                        if handles.Outbox{immt, 4} == 2
                            mmt = bindb_data.Measurements_Outbox{handles.Outbox{immt, 5}};                            
                            if mmt.Room.ID == oldid
                                 mmt.Room.ID = newid;
                                 bindb_data.Measurements_Outbox{handles.Outbox{immt, 5}} = mmt;
                                 handles.Outbox{immt, 6} = ['From ' mmt.Author ', ' datestr(mmt.Timestamp, 'yyyy-mm-dd') ' in ' mmt.Room.Name ' (Room ID:' num2str(mmt.Room.ID) ')'];
                                 mmtupdated = true;
                            end
                        end
                    end    
                    
                    % Save measurement outbox
                    if mmtupdated
                        bindb_measurement_store(); 
                    end
                    
                    % Remove from outbox
                    bindb_data.Rooms_Outbox(handles.Outbox{index, 5}) = [];
                    bindb_room_store();  
                    
                    % Update content
                    handles = updateContent(handles);
                else
                    % Update status
                    data{index, 3} = 'error';
                end
            elseif type == 2
                if bindb_data.Measurements_Outbox{handles.Outbox{index, 5}}.Room.ID < 1
                    bindb_addlog('Commit', 'Commit the local room of this measurement first.', 1);
                    return;
                end
                
                % Commit measurement
                [success, id] = bindb_measurement_commit(bindb_data.Measurements_Outbox{handles.Outbox{index, 5}}, false);
                
                if success
                    data{index, 2} = id;                
                    data{index, 3} = 'ok';
                    
                    % Remove from outbox
                    bindb_data.Measurements_Outbox(handles.Outbox{index, 5}) = [];
                    bindb_measurement_store();
                    
                    % Update content
                    handles = updateContent(handles);
                else
                    % Update status
                    data{index, 3} = 'error';
                end
            elseif type == 3
                try
                    movefile(bindb_filepath('outbox', handles.Outbox{index, 5}), bindb_filepath('rir', handles.Outbox{index, 5}));                   
                    % Update status
                    data{index, 3} = 'ok';    
                    
                     % Update content
                    handles = updateContent(handles);
                catch
                    % Update status
                    data{index, 3} = 'error';
                end                    
            end                        
        end        
        % Update table
        set(handles.items_table, 'Data', data);        
    elseif handles.remove_item == 1
        % Get data     
        data = get(handles.items_table, 'Data');
        
        if strcmp(data{index, 3} , 'pending')            
            % Change button text
            set(handles.actions_remove, 'String', 'Remove item');
    
            % Finish remove 
            handles.remove_item = 0;
            set(handles.figure1, 'Pointer', 'arrow');
            
            if type == 1
                % Remove from outbox
                bindb_data.Rooms_Outbox(handles.Outbox{index, 5}) = [];
                bindb_room_store(); 
            elseif type == 2
                % Remove from outbox
                bindb_data.Measurements_Outbox(handles.Outbox{index, 5}) = [];
                bindb_measurement_store();
            else
                delete(bindb_filepath('outbox', handles.Outbox{index, 5}));
            end            
            
            % Update content
            handles = updateContent(handles);
        end                    
    end                
end
    
% Update handles structure
guidata(hObject, handles);  

function handles = updateContent(handles)

% Register globals
global bindb_data;

% Init outbox list
handles.Outbox = cell(0, 6);

% Get rooms
if ~isempty(bindb_data.Rooms_Outbox)    
    for index = 1:length(bindb_data.Rooms_Outbox)
        handles.Outbox(end+1,:) = { 'Room', bindb_data.Rooms_Outbox(index).ID, 'pending', 1, index, bindb_data.Rooms_Outbox(index).Name};
    end
end

% Get measurements
if ~isempty(bindb_data.Measurements_Outbox)    
    for index = 1:length(bindb_data.Measurements_Outbox)
        mmt = bindb_data.Measurements_Outbox{index};
        handles.Outbox(end+1,:) = { 'Measurement', mmt.ID, 'pending', 2, index, ['From ' mmt.Author ', ' datestr(mmt.Timestamp, 'yyyy-mm-dd') ' in ' mmt.Room.Name ' (Room ID:' num2str(mmt.Room.ID) ')'] };        
    end
end

% Get rirs
rirs = dir(bindb_filepath('outbox', '*.mat'));
rirs = {rirs.name};
if ~isempty(rirs)    
    for index = 1:length(rirs)
        handles.Outbox(end+1,:) = { 'Impulse Response', 0, 'pending', 3, rirs{index}, ['Filename is ' rirs{index}] };        
    end
end

if ~isempty(handles.Outbox)
    set(handles.items_table, 'Data', handles.Outbox(:, 1:3));
else
    set(handles.items_table, 'Data', {});
end
