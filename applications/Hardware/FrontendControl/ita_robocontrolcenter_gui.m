function varargout = ita_robocontrolcenter_gui(varargin)
% ITA_ROBOCONTROLCENTER_GUI - M-file for robocontrolcenter.fig
%      ROBOCONTROLCENTER, by itself, creates a new ROBOCONTROLCENTER or raises the existing
%      singleton*.
%
%      H = ROBOCONTROLCENTER returns the handle to a new ROBOCONTROLCENTER or the handle to
%      the existing singleton*.
%
%      ROBOCONTROLCENTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROBOCONTROLCENTER.M with the given input arguments.
%
%      ROBOCONTROLCENTER('Property','Value',...) creates a new ROBOCONTROLCENTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before robocontrolcenter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to robocontrolcenter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Edit the above text to modify the response to help ita_robocontrolcenter_gui

% Last Modified by GUIDE v2.5 07-Jan-2009 14:57:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ita_robocontrolcenter_gui_OpeningFcn, ...
    'gui_OutputFcn',  @ita_robocontrolcenter_gui_OutputFcn, ...
    'gui_LayoutFcn',  @ita_robocontrolcenter_gui_export_LayoutFcn, ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
warning off %#ok<WNOFF>
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ita_robocontrolcenter_gui is made visible.
function ita_robocontrolcenter_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_robocontrolcenter_gui (see VARARGIN)

warning off %#ok<WNOFF>

%% INIT Robo
[handles.values.InputRange, handles.values.Mode, handles.values.OutputRange] = ita_robocontrol('getSettings');
% ita_robocontrol('0dB','LineRef','0dB');
% handles.values.InputRange=0;
% handles.values.Mode='norm';
% handles.values.OutputRange=0;


% Choose default command line output for ita_robocontrolcenter_gui
handles.output = hObject;

%send settings via Midi SysEx
ita_robocontrol(handles.values.InputRange,handles.values.Mode, handles.values.OutputRange);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ita_robocontrolcenter_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in InputRange.
function InputRange_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in InputRange
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'togglebutton_p40dB'
        %execute this code when fontsize08_radiobutton is selected
        handles.values.InputRange = '+40dB';
    case 'togglebutton_p20dB'
        %execute this code when fontsize12_radiobutton is selected
        handles.values.InputRange = '+20dB';
    case 'togglebutton_0dB'
        %execute this code when fontsize16_radiobutton is selected
        handles.values.InputRange = '0dB';
    case 'togglebutton_m20dB'
        %execute this code when fontsize16_radiobutton is selected
        handles.values.InputRange = '-20dB';
    case 'togglebutton_m40dB'
        %execute this code when fontsize16_radiobutton is selected
        handles.values.InputRange = '-40dB';
    otherwise
        % Code for when there is no match.
        disp('shit what happened?')
end

%send settings via Midi SysEx
ita_robocontrol(handles.values.InputRange,handles.values.Mode, handles.values.OutputRange);

%updates the handles structure
guidata(hObject, handles);


% --- Executes when selected object is changed in Mode.
function Mode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Mode
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'togglebuttonNorm'
        %execute this code when fontsize08_radiobutton is selected
        handles.values.Mode = 'Norm';
    case 'togglebuttonImp'
        %execute this code when fontsize12_radiobutton is selected
        handles.values.Mode = 'Imp';
    case 'togglebutton10OhmCal'
        %execute this code when fontsize16_radiobutton is selected
        handles.values.Mode = '10Ohm';
    case 'togglebuttonLineRef'
        %execute this code when fontsize16_radiobutton is selected
        handles.values.Mode = 'LineRef';
    case 'togglebuttonAmpRef'
        %execute this code when fontsize16_radiobutton is selected
        handles.values.Mode = 'AmpRef';
    otherwise
        % Code for when there is no match.
        disp('shit what happened?')
end

%send settings via Midi SysEx
ita_robocontrol(handles.values.InputRange,handles.values.Mode, handles.values.OutputRange);

%updates the handles structure
guidata(hObject, handles);


% --- Executes when selected object is changed in OutputRange.
function OutputRange_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in OutputRange
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'togglebutton_p20dBu'
        %execute this code when fontsize08_radiobutton is selected
        handles.values.OutputRange = '+20dBu';
    case 'togglebutton_0dBu'
        %execute this code when fontsize12_radiobutton is selected
        handles.values.OutputRange = '0dBu';
    otherwise
        % Code for when there is no match.
        disp('shit what happened?')
end

%send settings via Midi SysEx
ita_robocontrol(handles.values.InputRange,handles.values.Mode, handles.values.OutputRange);

%updates the handles structure
guidata(hObject, handles);


% --- Creates and returns a handle to the GUI figure.
function h1 = ita_robocontrolcenter_gui_export_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton) %#ok<AND2>
    h1 = hsingleton;
    return;
end

%% callbacks for button change events
modeCallback = @(hObject,eventdata)ita_robocontrolcenter_gui('Mode_SelectionChangeFcn',get(hObject,'SelectedObject'),eventdata,guidata(get(hObject,'SelectedObject')));
outputCallback = @(hObject,eventdata)ita_robocontrolcenter_gui('OutputRange_SelectionChangeFcn',get(hObject,'SelectedObject'),eventdata,guidata(get(hObject,'SelectedObject')));
inputCallback = @(hObject,eventdata)ita_robocontrolcenter_gui('InputRange_SelectionChangeFcn',get(hObject,'SelectedObject'),eventdata,guidata(get(hObject,'SelectedObject')));

%% INIT Robo
[handles.values.InputRange, handles.values.Mode, handles.values.OutputRange] = ita_robocontrol('getSettings');
% % ita_robocontrol('0dB','LineRef','0dB');
% handles.values.InputRange=-20;
% handles.values.Mode='imp';
% handles.values.OutputRange=0;
click01=0;
click02=0;
click03=0;
click04=0;
click05=0;
click06=0;
click07=0;
click08=0;
click09=0;
click10=0;
click11=0;
click12=0;

% Startbutton for Mode
if (strcmp(handles.values.Mode,'norm'))
    click01=1;
elseif (strcmp(handles.values.Mode,'imp'))
    click02=1;
elseif (strcmp(handles.values.Mode,'10ohm'))
    click03=1;
elseif (strcmp(handles.values.Mode,'lineref'))
    click04=1;
elseif (strcmp(handles.values.Mode,'ampref'))
    click05=1;
else
    click01=1;
end

if (handles.values.OutputRange==20)
    click06=1;
elseif (handles.values.OutputRange==0)
    click07=1;
else
    click06=1;
end

if (handles.values.InputRange == 40)
    click08=1;
elseif (handles.values.InputRange == 20)
    click09=1;
elseif (handles.values.InputRange == 0)
    click10=1;
elseif (handles.values.InputRange == -20)
    click11=1;
elseif (handles.values.InputRange == -40)
    click12=1;
else
    click08=1;
end

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'radiobutton', 11, ...
    'uipanel', 8, ...
    'togglebutton', 28), ...
    'override', 0, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0);
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
    'Units','characters',...
    'PaperUnits',get(0,'defaultfigurePaperUnits'),...
    'Color',[0.7 0.7 0.7],...
    'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
    'IntegerHandle','off',...
    'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
    'MenuBar','none',...
    'Name','ita_robocontroconter_gui',...
    'NumberTitle','off',...
    'PaperPosition',get(0,'defaultfigurePaperPosition'),...
    'PaperSize',[20.98404194812 29.67743169791],...
    'PaperType',get(0,'defaultfigurePaperType'),...
    'Position',[103.833333333333 29.1666666666667 112 32.3333333333333],...
    'Resize','off',...
    'HandleVisibility','callback',...
    'Tag','figure1',...
    'UserData',[],...
    'Visible','on',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Mode';

h2 = uibuttongroup(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',10,...
    'Title','Mode',...
    'Tag','Mode',...
    'Clipping','on',...
    'Position',[39.8 12.7692307692308 25.2 13.5384615384615],...
    'SelectedObject',[],...
    'SelectionChangeFcn',modeCallback,...
    'OldSelectedObject',[],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebuttonNorm';

h3 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[3 9.76923076923077 18.2 1.76923076923077],...
    'String','Norm.',...
    'Style','togglebutton',...
    'Value',click01,...
    'Tag','togglebuttonNorm',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebuttonImp';

h4 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[3 7.6923076923077 18.2 1.76923076923077],...
    'String','Imp.',...
    'Style','togglebutton',...
    'Value',click02,...
    'Tag','togglebuttonImp',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton10OhmCal';

h5 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[3 5.61538461538462 18.2 1.76923076923077],...
    'String','10 Ohm Cal.',...
    'Style','togglebutton',...
    'Value',click03,...
    'Tag','togglebutton10OhmCal',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebuttonLineRef';

h6 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[3 3.53846153846154 18.2 1.76923076923077],...
    'String','Line Ref.',...
    'Style','togglebutton',...
    'Value',click04,...
    'Tag','togglebuttonLineRef',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebuttonAmpRef';

h7 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[3 1.23076923076924 18.2 1.76923076923077],...
    'String','Amp Ref.',...
    'Style','togglebutton',...
    'Value',click05,...
    'Tag','togglebuttonAmpRef',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'OutputRange';

h8 = uibuttongroup(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',10,...
    'Title','Output Range',...
    'Tag','OutputRange',...
    'Clipping','on',...
    'Position',[69.8 19.2307692307692 23 7.07692307692308],...
    'SelectedObject',[],...
    'SelectionChangeFcn',outputCallback,...
    'OldSelectedObject',[],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton_p20dBu';

h9 = uicontrol(...
    'Parent',h8,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[3.4 3.30769230769231 15.2 1.69230769230769],...
    'String','+20dB',...
    'Style','togglebutton',...
    'Value',click06,...
    'Tag','togglebutton_p20dBu',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton_0dBu';

h10 = uicontrol(...
    'Parent',h8,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[3.4 1.38461538461539 15.2 1.69230769230769],...
    'String','0dB',...
    'Style','togglebutton',...
    'Value',click07,...
    'Tag','togglebutton_0dBu',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'InputRange';

h11 = uibuttongroup(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',10,...
    'Title','Input Range',...
    'Tag','InputRange',...
    'Clipping','on',...
    'Position',[8 12.9230769230769 22 13.4615384615385],...
    'SelectedObject',[],...
    'SelectionChangeFcn',inputCallback,...
    'OldSelectedObject',[],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton_p40dB';

h12 = uicontrol(...
    'Parent',h11,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[1.6 9.53846153846154 15.2 1.69230769230769],...
    'String','+40dB',...
    'Style','togglebutton',...
    'Value',click08,...
    'Tag','togglebutton_p40dB',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton_p20dB';

h13 = uicontrol(...
    'Parent',h11,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[1.6 7.53846153846154 15.2 1.69230769230769],...
    'String','+20dB',...
    'Style','togglebutton',...
    'Value',click09,...
    'Tag','togglebutton_p20dB',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton_0dB';

h14 = uicontrol(...
    'Parent',h11,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[1.6 5.53846153846154 15.2 1.69230769230769],...
    'String','0dB',...
    'Style','togglebutton',...
    'Value',click10,...
    'Tag','togglebutton_0dB',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton_m20dB';

h15 = uicontrol(...
    'Parent',h11,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[1.6 3.53846153846154 15.2 1.69230769230769],...
    'String','-20dB',...
    'Style','togglebutton',...
    'Value',click11,...
    'Tag','togglebutton_m20dB',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton_m40dB';

h16 = uicontrol(...
    'Parent',h11,...
    'Units','characters',...
    'Callback','',...
    'FontSize',10,...
    'Position',[1.6 1.30769230769231 15.2 1.69230769230769],...
    'String','-40dB',...
    'Style','togglebutton',...
    'Value',click12,...
    'Tag','togglebutton_m40dB',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

hsingleton = h1;


% --- Set application data first then calling the CreateFcn.
function local_CreateFcn(hObject, eventdata, createfcn, appdata)
%% ITA toolbox logo with grey background
a_im = importdata(which('ita_toolbox_logo.png'));
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [20 10 350 65]*0.6); %TODO: later set correctly the position
% %

if ~isempty(appdata)
    names = fieldnames(appdata);
    for i=1:length(names)
        name = char(names(i));
        setappdata(hObject, name, appdata.(name));
    end
end

if ~isempty(createfcn)
    eval(createfcn);
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)


gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error('MATLAB:gui_mainfcn:FieldNotFound', 'Could not find field %s in the gui_State struct in GUI M-file %s', gui_StateFields{i}, gui_Mfile);
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end



numargin = length(varargin);

if numargin == 0
    % ITA_ROBOCONTROLCENTER_GUI_EXPORT
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % ITA_ROBOCONTROLCENTER_GUI_EXPORT(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallbak(gui_State, varargin{:})
    % ITA_ROBOCONTROLCENTER_GUI_EXPORT('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % ITA_ROBOCONTROLCENTER_GUI_EXPORT(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~strcmpi(get(fig,'Type'),'figure')  %~isa(handle(fig),'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
    
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end
    
    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end
        
        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.
    
    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);
        
        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')
        
        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end
    
    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);
    
    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;
    
    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', [0.8 0.8 0.8]);
        end
        
        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end
    
    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end
        
        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end
    
    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end
    
    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});
    
    if isscalar(gui_hFigure) && ishandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure);
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
        
        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end
        
        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end
        
        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end
    
    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end
    
    if isscalar(gui_hFigure) && ishandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
        && isequal(varargin{1},gcbo);
catch %#ok<CTCH>
    result = false;
end

function result = local_isInvokeHGCallbak(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
        (ischar(varargin{1}) ...
        && isequal(ishandle(varargin{2}), 1) ...
        && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
        ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch %#ok<CTCH>
    result = false;
end


