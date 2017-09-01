function varargout = ita_GUIModeSolve(varargin)
% this is the gui for the fe solver ita_ModeSolve
%ITA_GUIMODESOLVE M-file for ita_GUIModeSolve.fig
%      ITA_GUIMODESOLVE, by itself, creates a new ITA_GUIMODESOLVE or raises the existing
%      singleton*.
%

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%      H = ITA_GUIMODESOLVE returns the handle to a new ITA_GUIMODESOLVE or the handle to
%      the existing singleton*.
%
%      ITA_GUIMODESOLVE('Property','Value',...) creates a new ITA_GUIMODESOLVE using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ita_GUIModeSolve_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ITA_GUIMODESOLVE('CALLBACK') and ITA_GUIMODESOLVE('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ITA_GUIMODESOLVE.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_GUIModeSolve

% Last Modified by GUIDE v2.5 19-May-2016 11:31:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ita_GUIModeSolve_OpeningFcn, ...
    'gui_OutputFcn',  @ita_GUIModeSolve_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before ita_GUIModeSolve is made visible.
function ita_GUIModeSolve_OpeningFcn(hObject, eventdata, handles, varargin)
% defaultBackground = get(0,'defaultUicontrolBackgroundColor');
% set(hObject,'Color',defaultBackground);

set(handles.Status,'String','Do something!');
dcm_obj = datacursormode;
set(dcm_obj,'UpdateFcn',@updateCursor);
set(handles.spkToogle,'State','off');
datacursormode off;
if nargin ==4
    % gets a struct from ModeSolve for the visualisation of pressure
    handles.output = hObject;
    guidata(hObject, handles);
    set(handles.Status,'String','Calculation is finished!');
    typeString={'Admittance Y','Impedance Z','Reflection R', 'Absorption alpha',...
        'Displacement u','Velocity v','Acceleration a','Pressure p','Point Source Q'};
    set(handles.type,'String',typeString)
    solveModeString = {'particular solution','modal analysis complex','modal analysis real','eigenmodes real','eigenmodes complex'};
    set(handles.solveMode,'String', solveModeString);
    
    UD = get(handles.freqSlide,'UserData');
    ModeSolveData = varargin{1};
    UD.p = ModeSolveData.p;
    UD.gui = ModeSolveData.gui ;
    UD.farField = ModeSolveData.farField;
    set(handles.freqSlide,'Value',real(UD.gui.Freq(1))/real(UD.gui.Freq(end)));
    set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(1))*10)/10,4));
    set(handles.freqSlide,'UserData',UD);
    
    lFreq = length(UD.gui.Freq);
    set(handles.freqSlide,'SliderStep',[1/(lFreq),0.1]);
    if sum(sum(real(UD.p))) == 0 && sum(sum(imag(UD.p)))== 0
        press = zeros(length(UD.p),lFreq);
        set(handles.axes4,'Clim',[-1 1]);colorbar;
    else
        press = 20*log10(abs(UD.p(:,end))/(2*10^-5));
        cMin = min(min(press));cMax = max(max(press));
        if ~isnan(cMin) || ~isnan(cMax),set(handles.axes4,'Clim',[ cMin cMax]);colorbar; end
    end
    patch('Faces',UD.surfElem.nodes,'Vertices',UD.coord.cart,'FaceVertexCData',full(press(:,1)),'FaceColor','interp') ;
    set(handles.freqSlide,'Value',1/(lFreq));
    set(handles.SliderStart,'String',num2str(round(real(UD.gui.Freq(1))*10)/10,4));
    set(handles.SliderStop,'String',num2str(round(real(UD.gui.Freq(end))*10)/10,4));
    set(handles.lbAddedPS,'String','No added point sources');
    
else
    % initialization of gui
    handles.output = hObject;
    guidata(hObject, handles);
    typeString={'Admittance Y','Impedance Z','Reflection R', 'Absorption alpha',...
        'Displacement u','Velocity v','Acceleration a','Pressure p','Point Source Q'};
    set(handles.type,'String',typeString);
    solveModeString = {'particular solution','modal analysis complex','modal analysis real','eigenmodes real','eigenmodes complex'};
    set(handles.solveMode,'String', solveModeString);
end

% UIWAIT makes ita_GUIModeSolve wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_GUIModeSolve_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%% Start Calculation

function start_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
disp('I am starting Sound Solve now :-D');
% sets all parameter for ModeSolve from gui and starts ModeSolve
set(handles.Status,'String','I am starting Sound Solve now :-D');

startFreq        = str2double(get(handles.startFreq(end),'String'));
stopFreq         = str2double(get(handles.stopFreq(end),'String'));
stepFreq         = str2double(get(handles.stepFreq(end),'String'));
singleFreq       = str2double(get(handles.singleFreq,'String'));
multipleFreqButton = get(handles.multipleFreqButton,'Value');
singleFreqButton   = get(handles.singleFreqButton,'Value');
solveMode          =  get(handles.solveMode,'Value');

% sets frequency
ModeSolveData= get(handles.freqSlide,'UserData');

if singleFreqButton ==1 && singleFreq>0
    ModeSolveData.Freq = singleFreq;
elseif  multipleFreqButton ==1 && startFreq>0 && stepFreq>0 && stopFreq>0
    if startFreq<=stopFreq
        ModeSolveData.Freq = startFreq: stepFreq: stopFreq;
    else
        ModeSolveData.Freq = startFreq: stepFreq: startFreq+ stepFreq;
        set(handles.stopFreq,'String',num2str(startFreq+stepFreq));
    end
else
    ModeSolveData.Freq  =singleFreq;
end


% sets solver modulo
switch solveMode
    case 1, ModeSolveData.solveMode ='particular';
    case 2, ModeSolveData.solveMode ='complex';
    case 3, ModeSolveData.solveMode ='real';
    case 4
        ModeSolveData.solveMode ='eigs real';
        ModeSolveData.Thresh = [];
        ModeSolveData.NumInt = [];
    case 5 % frequency dependend boundary conditions need further informations
        ModeSolveData.solveMode ='eigs complex';
        ModeSolveData.Thresh = [];
        ModeSolveData.NumInt = [];
        for i1 = 1:length(ModeSolveData.groupMaterial)
            if ~strcmp(ModeSolveData.groupMaterial{i1}{2}.FreqInputFilename,'none') ...
                    && ~isempty(ModeSolveData.groupMaterial{i1}{2}.FreqInputFilename)
                prompt = {'max number of intervals:','threshold:'};
                dlg_title = 'Approximation';
                num_lines = 1;
                def = {'8','0.1'};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                if isempty(answer)
                    numInt =  8;
                    ModeSolveData.Thresh = 0.1;
                else
                    numInt =  str2double(answer{1});
                    ModeSolveData.Thresh = str2double(answer{2});
                end
                ModeSolveData.NumInt = ceil(log2(numInt));
                break;
            end
        end
end

% starts calculation
if ModeSolveData.Freq>0
    if get(handles.mesh,'UserData')==1
        cla;set(handles.Status,'String','I am calculating...leave me alone');
        ita_ModeSolve(ModeSolveData);
    else
        set(handles.Status,'String','There are no groups in your mesh file. Groups will be needed to calculate the pressure!');
    end
end

function startFreq_Callback(hObject, eventdata, handles)
% sets start frequency
value =str2double(get(hObject,'String'));
if ~isnan(value) && imag(value)==0 && value >= 0
    handles.startFreq = value;
else
    handles.startFreq = 20; %default
    set(hObject,'String','20');
    set(handles.Status,'String','Start frequency must be a real positive number!');
end

set(handles.singleFreqButton,'Value',0);
set(handles.multipleFreqButton,'Value',1);

function stepFreq_Callback(hObject, eventdata, handles)
% sets step frequency
value =str2double(get(hObject,'String'));
if ~isnan(value) && imag(value)==0 && value >= 0
    handles.stepFreq = value;
else
    handles.stepFreq = 1; %default
    set(hObject,'String','1');
    set(handles.Status,'String','Step frequency must be a real positive number!');
end
set(handles.singleFreqButton,'Value',0);
set(handles.multipleFreqButton,'Value',1);

function stopFreq_Callback(hObject, eventdata, handles)
% sets stop frequency
value =str2double(get(hObject,'String'));
startFreq = str2double(get(handles.startFreq(end),'String'));
if ~isnan(value) && imag(value)==0 && value >= 0
    if value > startFreq
        handles.stopFreq = value;
    else
        set(handles.Status,'String','Stop frequency must be greater than start frequency!');
        set(hObject,'String',num2str(startFreq+1));
        handles.stopFreq = startFreq+1; %default
    end
else
    handles.stopFreq = 1; %default
    set(hObject,'String','1');
    set(handles.Status,'String','Stop frequency must be a real positive number!');
end
set(handles.singleFreqButton,'Value',0);
set(handles.multipleFreqButton,'Value',1);
set(handles.singleFreqButton,'Value',0);
set(handles.multipleFreqButton,'Value',1);

function singleFreq_Callback(hObject, eventdata, handles)
% sets single frequency
value =str2double(get(hObject,'String'));
if ~isnan(value) && imag(value)==0 && value >= 0
    handles.singleFreq = value;
else
    handles.startFreq = 20; %default
    set(hObject,'String','20');
    set(handles.Status,'String','Start frequency must be a real positive number!');
end
set(handles.singleFreqButton,'Value',1);
set(handles.multipleFreqButton,'Value',0);

function mesh_Callback(hObject, eventdata, handles)
% sets meshfilename
set(handles.freqSlide,'UserData',[]);
[meshFilename,meshFilepath] =uigetfile('*.unv; *.dae; *.mat','Select Mesh');
cla(handles.axes4,'reset');
set(handles.axes4,'View',[-30 50]);
meshFilename=[meshFilepath meshFilename];
findUnv = strfind(meshFilename,'.unv');
findDae = strfind(meshFilename,'.dae');
findMat = strfind(meshFilename, '.mat');

if  isempty(findUnv) && isempty(findDae) && isempty(findMat)
    meshFilename=[];
    set(handles.Status,'String','The mesh file must be a *.unv file!');
end
set(handles.meshFilename,'String',meshFilename);


% read unv-mesh for plotting and setting groups
if ~isempty(meshFilename)
    warning off all;
    if ~isempty(findUnv)
        classes =ita_read_unv(meshFilename);
        generateGroups = 1;
        
        if isa(classes,'itaMesh')
            coord = classes.nodes;
            if length(classes)<3 % keine surf, keine gruppen
                volElem = classes.volumeElements;
                volElem  = renumberingElements(volElem,coord);
                % helpdlg('I create you some surface elements! This will take some minutes...','Surface elements...');
                surfElem = makeShellElements(volElem);
                generateGroups = 1;
            else % To Do!!!
                if isa(classes{3},'itaMeshElements') % surf elemente
                    if classes{2}.nElements<10
                        volElem = classes{2};
                        surfElem = classes{3};
                    else
                        volElem = classes{3};
                        surfElem = classes{2};
                    end
                    volElem  = renumberingElements(volElem,coord);
                    surfElem = renumberingElements(surfElem,coord);
                    if length(classes)>3 %gruppen
                        groups ={classes{4:end}};
                        generateGroups = 0;
                    end
                else % keine surf
                    volElem = classes{2};
                    volElem  = renumberingElements(volElem,coord);
                    surfElem = makeShellElements(volElem);
                    groups ={classes{3:end}};
                    generateGroups = 0;
                end
            end
        end
        
    elseif ~isempty(findDae)
        str = 'Please insert the max. length of each element.';
        wL = inputdlg(str,'Length of elements...');
        [coord, volElem] = meshingDaeTest(meshFilename,str2double(wL));
        surfElem = makeShellElements(volElem);
        generateGroups = 1;
        
    else %.mat-file
        classes = load(meshFilename);
        fnames = fieldnames(classes);
        %supported file?
        if isa(classes.(fnames{1}),'itaMesh')
            mesh = classes.(fnames{1});
            coord = mesh.nodes;
            volElem = mesh.volumeElements;
            surfElem = mesh.shellElements;
            generateGroups = 1;
        elseif length(fnames) == 2 && isa(classes.(fnames{1}),...
                'itaMeshNodes') && isa(classes.(fnames{2}), 'itaMeshElements')
            coord = classes.coord;
            volElem = classes.elem;
            surfElem = makeShellElements(volElem);
            generateGroups = 1;
        else
            error('This .mat file is not supported! File must contain [itaMeshNodes,itaMeshElements]')
        end
        
    end
    % plots mesh
    xlabel('x');ylabel('y');zlabel('z');grid on;
    plotElem = volElem.nodes;
    if length(volElem.nodes(1,:)) == 20
        edit = [1:7 1 9 13:20 13:15 10 3:5 11 17:19 12,7];
        plotElem = plotElem(:,edit);
    elseif length(volElem.nodes(1,:)) == 10
        edit = [1:5 1 7 10 8 3:5 9 10];
        plotElem = plotElem(:,edit);
    elseif length(volElem.nodes(1,:)) == 4
        edit = [1:3, 1,2,4, 2,3,4];
        plotElem = plotElem(:,edit);
    elseif length(volElem.nodes(1,:)) == 8
        edit = [1:4, 1,2,5,6, 2,3,6,7, 3,4,7,8, 1,4,5,8];
        plotElem = plotElem(:,edit);
    end
    
    hold on;
    p = patch('Faces',plotElem,'Vertices',coord.cart,'FaceVertexCData',[0 0 0],'FaceColor','none');
    set(p,'EdgeColor',[0.75 0.75 1]);
    hold on;
    p1 =patch('Faces',surfElem.nodes,'Vertices',coord.cart,'FaceVertexCData',[0 0 0],'FaceColor',[0.9 0.9 0.9]) ;
    set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 0 1]); hold off;
    
    set(handles.Status,'String','Your Mesh is on the right side! Now you can select frequency and boundary conditions');
    set(handles.mesh,'UserData',1);
    
    % Activate nodes for cursor
    dcm_obj = datacursormode;
    set(dcm_obj,'UpdateFcn',@updateCursor);
    datacursormode off;
    
    % sets maximal frequency
    [~, fMean] = preprocessingMode(coord, volElem);
    set(handles.singleFreq,'String',num2str(ceil(fMean)));
    
    
    if generateGroups==1
        groups = ita_createSurfGroups(coord,surfElem,6);
    end
    
    % elemente, gruppen... bearbeiten
    groupName = cell(length(groups),1);
    groupInfo = cell(5*length(groups),1);
    
    for i1=1:length(groups)
        groupMaterial{i1}= ita_niceGroupMaterial(coord, volElem, surfElem, groups{i1},i1); %#ok<*AGROW>
        groupName{i1} =  groups{i1}.groupName;
        groupInfo{i1*5-4} = groups{i1}.groupName;  % name
        groupInfo{i1*5-3} = 'Admittance';% type
        groupInfo{i1*5-2} = '0';% value
        groupInfo{i1*5-1} = 'none'; % File
        groupInfo{i1*5} = []; % space
    end
    
    set(handles.groupName,'String',groupName);
    set(handles.infoBC,'String',groupInfo);
    
    % data
    ModeSolveData.coord=coord;
    ModeSolveData.volElem = volElem;
    ModeSolveData.surfElem = surfElem;
    ModeSolveData.groups = groups;
    ModeSolveData.groupMaterial=groupMaterial;
    set(handles.freqSlide,'UserData',ModeSolveData);
else
    set(handles.Status,'String','I cannot read your mesh file!');
end
set(handles.lbAddedPS,'String','No added point sources');

function singleFreqButton_Callback(hObject, eventdata, handles)
% sets single frequency button
if (get(hObject,'Value') == get(hObject,'Max'))
    set(handles.multipleFreqButton,'Value',0);
end

function multipleFreqButton_Callback(hObject, eventdata, handles)
% sets multiple frequencies button
if (get(hObject,'Value') == get(hObject,'Max'))
    set(handles.singleFreqButton,'Value',0);
end

function type_Callback(hObject, eventdata, handles)
% sets boundary condition in figure
typeValue = get(hObject,'Value');
switch typeValue
    case 1; typeName = 'Admittance';
    case 2; typeName = 'Impedance';
    case 3; typeName = 'Reflection';
    case 4; typeName = 'Absorption';
    case 5; typeName = 'Displacement';
    case 6; typeName = 'Velocity';
    case 7; typeName = 'Acceleration';
    case 8; typeName = 'Pressure';
    case 9; typeName = 'Point Source';
end
groupNameValue = get(handles.groupName,'Value');
infoBC=get(handles.infoBC,'String');
infoBC{groupNameValue*5-3} =typeName;
set(handles.infoBC,'String',infoBC);

% new object
UD = get(handles.freqSlide,'UserData');
properties.ID    = UD.groupMaterial{groupNameValue}{2}.groupID;
properties.GroupName = infoBC{groupNameValue*5-4};
properties.Type = typeName;
properties.Value = UD.groupMaterial{groupNameValue}{2}.Value;
properties.freq = [];
properties.GroupFilename = 'none';
UD.groupMaterial{groupNameValue}{2}=itaMeshBoundaryC(properties);
UD.groupMaterial{groupNameValue}{2}.groupID=groupNameValue;
UD.groupMaterial{groupNameValue}{2}.ID=groupNameValue;
set(handles.freqSlide,'UserData',UD);

function FilenameBC_Callback(hObject, eventdata, handles)
% gets filename of boundary coundition file
[FilenameBC,FilepathBC] = uigetfile({'*.txt;*.ita;','BC files - Amittance (*.txt,*.ita)';
    '*.txt',  'Text files - Admittance (*.txt)'; ...
    '*.ita', 'ita files - Admittance (*.ita)';
    '*.*',  'All Files (*.*)'},'Select frequency dependent File');
FilenameBC=[FilepathBC FilenameBC];
if isempty(strfind(FilenameBC,'.ita')) && isempty(strfind(FilenameBC,'.txt')) ...
        && isempty(strfind(FilenameBC,'.ITA')) && isempty(strfind(FilenameBC,'.TXT'))
    FilenameBC = 'none';
end

set(handles.manualBC_radio,'Value',0);
set(handles.FilenameBC_radio,'Value',1);

set(handles.ValueBC,'String','0');
set(handles.FilenameBC_text,'String',FilenameBC);
groupNameValue = get(handles.groupName,'Value');
infoBC=get(handles.infoBC,'String');

infoBC{groupNameValue*5-2} ='0';
infoBC{groupNameValue*5-1} =FilenameBC;

if ~strcmp(FilenameBC,'none')
    [Data, comment] = get_freq_property(FilenameBC);
    groupNameValue = get(handles.groupName,'Value');
    UD = get(handles.freqSlide,'UserData');
    properties.ID = UD.groupMaterial{groupNameValue}{2}.groupID;
    properties.GroupName = infoBC{groupNameValue*5-4};
    properties.Type = Data.Type;
    infoBC{groupNameValue*5-3} =Data.Type;
    properties.Value = Data.Value;
    properties.freq = Data.freq;
    properties.GroupFilename = FilenameBC;
    UD.groupMaterial{groupNameValue}{2}=itaMeshBoundaryC(properties);
    UD.groupMaterial{groupNameValue}{2}.groupID=groupNameValue;
    UD.groupMaterial{groupNameValue}{2}.ID=groupNameValue;
    set(handles.freqSlide,'UserData',UD);
end
set(handles.infoBC,'String',infoBC);

function ValueBC_Callback(hObject, eventdata, handles)
% sets boundary condition value for a selected boundary condition
value = str2double(get(hObject,'String'));
groupNameValue = get(handles.groupName,'Value');
infoBC=get(handles.infoBC,'String');
infoBC{groupNameValue*5-2} =get(hObject,'String');
infoBC{groupNameValue*5-1} ='none';

if ~isnan(value)
    handles.ValueBC =value;
    infoBC{groupNameValue*5-2} =get(hObject,'String');
    UD = get(handles.freqSlide,'UserData');
    UD.groupMaterial{groupNameValue}{2}.Value = value;
    set(handles.freqSlide,'UserData',UD);
else
    handles.ValueBC =0;
    infoBC{groupNameValue*5-2} ='0';
    set(hObject,'String','0');
    set(handles.Status,'String',['Value of boundary condition ' infoBC{groupNameValue*5-4} ' must be a number!']);
end

set(handles.infoBC,'String',infoBC);
set(handles.FilenameBC_text,'String',[]);
set(handles.manualBC_radio,'Value',1);
set(handles.FilenameBC_radio,'Value',0);

function groupName_Callback(hObject, eventdata, handles)
selected =get(hObject,'Value');
result = get(handles.freqSlide,'UserData');
coord = result.coord; surfElem = result.surfElem;
groupMaterial = result.groupMaterial;

if ~isempty(surfElem)
    hold on;cla;
    p1 =patch('Faces',surfElem.nodes,'Vertices',coord.cart,'FaceVertexCData',[0 0 0],'FaceColor',[0.9 0.9 0.9]) ;
    set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 0 1]); hold off;hold on;
    
    num = groupMaterial{selected}{1}.ID;
    if strcmp(groupMaterial{selected}{1}.type,'nodes')
        groupCoord = coord.cart(num,:);
        
        p3 = plot3(groupCoord(:,1),groupCoord(:,2),groupCoord(:,3));
        set(p3,'LineStyle','none');set(p3,'Marker','o');
        set(p3,'MarkerFaceColor','g');set(p3,'MarkerEdgeColor','k');
    else
        groupElem = surfElem.nodes(num,:);
        groupCoord = coord.cart(groupElem,:);
        
        p3 = plot3(groupCoord(:,1),groupCoord(:,2),groupCoord(:,3));
        set(p3,'LineStyle','none');set(p3,'Marker','o');
        set(p3,'MarkerFaceColor','g');set(p3,'MarkerEdgeColor','k');
    end
end

function infoBC_Callback(hObject, eventdata, handles)

function solveMode_Callback(hObject, eventdata, handles)
% sets solver modulo
typeSM = get(hObject,'Value');
switch typeSM
    case 1; typeName = 'particular solution';
    case 2; typeName = 'modal analysis (complex)';
    case 3; typeName = 'modal analysis (real)';
    case 4; typeName = 'eigenmodes real';
    case 5; typeName = 'eigenmodes complex';
end

function freqSlide_Callback(hObject, eventdata, handles)
% plotting routine: sets frequency slider
freqPos = get(hObject,'Value');

UD =  get(handles.freqSlide,'UserData');
if ~isempty(UD)
    lFreq = length(UD.gui.Freq);
    posFreq = round(freqPos*lFreq);
    if posFreq == 0
        posFreq =1;
    end
    stat= get(handles.playFreqPB,'Value');
    set(handles.playFreqPB,'Value', ~stat);
    set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(posFreq)*10))/10,4));
    set(handles.freqSlide,'SliderStep',[1/(lFreq),0.1]);
    
    if sum(sum(real(UD.p))) == 0 && sum(sum(imag(UD.p)))== 0, press = zeros(length(UD.p),lFreq);
        set(handles.axes4,'Clim',[-1 1]);colorbar;
    else
        press = 20*log10(abs(UD.p)/(2*10^-5));
        cMin = min(min(press));cMax = max(max(press));
        if ~isinf(cMin) && ~isinf(cMax)
            set(handles.axes4,'Clim',[ cMin cMax]);
            colorbar;
        end
    end
    cla;
    patch('Faces',UD.surfElem.nodes,'Vertices',UD.coord.cart,'FaceVertexCData', full(press(:,posFreq)),'FaceColor','interp') ;
    if max(UD.farField(end)) ~=0
        set(handles.farField,'String',num2str(round(100*max(UD.farField(posFreq)))/100));
    else
        set(handles.farField,'String','');
    end
    
end

function playFreqPB_Callback(hObject, eventdata, handles)
% plotting routine: sets play button
buttonPos = get(handles.playFreqPB,'Position');
UD =  get(handles.freqSlide,'UserData');
if ~isempty(UD)
    lFreq = length(UD.gui.Freq);
    
    set(handles.freqSlide,'SliderStep',[1/(lFreq),0.1]);
    if sum(sum(real(UD.p))) == 0 && sum(sum(imag(UD.p)))== 0, press = zeros(length(UD.p),lFreq);
        set(handles.axes4,'Clim',[-1 1]);colorbar;
    else
        press = 20*log10(abs(UD.p)/(2*10^-5));
        cMin = min(min(press));cMax = max(max(press));
        if ~isinf(cMin) && ~isinf(cMax),set(handles.axes4,'Clim',[ cMin cMax]);
            colorbar;
        end
    end
    
    slidePos = get(handles.freqSlide,'Value');
    if slidePos ==0, i1 = 1;
    elseif slidePos == 1, i1 =1;
    else i1 = ceil(slidePos*lFreq);
    end
    
    % unnecessary picture
    [dataPic, map]=imread('pig.gif','gif','frame','all');
    lPic = size(dataPic,4);i2 = 1;
    
    set(handles.playFreqPB,'String','');
    
    set(handles.playFreqPB,'Position',[buttonPos(1) buttonPos(2)+buttonPos(4)/2-0.327 buttonPos(3) 0.654]);
    
    while i1<=lFreq  && get(handles.playFreqPB,'Value')
        cla;
        set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(i1))*10)/10,4));
        set(handles.freqSlide,'Value',i1/(lFreq));
        patch('Faces',UD.surfElem.nodes,'Vertices',UD.coord.cart,'FaceVertexCData',full(press(:,i1)),'FaceColor','interp') ;
        if UD.farField(i1) ~=0
            set(handles.farField,'String',num2str(round(100*max(UD.farField(i1)))/100,4));
        else
            set(handles.farField,'String','');
        end
        i1 = i1+1;
        
        % unnecessary picture
        if i2 > lPic, i2 = 1;end
        pic=ind2rgb(dataPic(:,:,1,i2),map);
        set(hObject,'CData',pic); i2 = i2+1;
        pause(0.25);
        if i2 == lPic, pause(0.25);end
        if i2 > lPic, i2 = 1;end
        pic=ind2rgb(dataPic(:,:,1,i2),map);
        set(hObject,'CData',pic); i2 = i2+1;
        pause(0.25);
        if i2 == lPic, pause(0.25);end
    end
    set(handles.playFreqPB,'String','Play');
    set(hObject,'CData',[]);
    
end
set(handles.playFreqPB,'Position',buttonPos);

function pausePB_Callback(hObject, eventdata, handles)
% plotting routine: sets wait button
stat= get(handles.playFreqPB,'Value');
set(handles.playFreqPB,'Value', ~stat);
if get(handles.ffPB,'Value')==1
    set(handles.ffPB,'Value', 0);
end

if get(handles.rwPB,'Value')==1
    set(handles.rwPB,'Value', 0);
end

function stopPB_Callback(hObject, eventdata, handles)
% plotting routine: sets stop button
stat= get(handles.playFreqPB,'Value');
set(handles.playFreqPB,'Value', ~stat);
if get(handles.ffPB,'Value')==1
    set(handles.ffPB,'Value', 0);
end

if get(handles.rwPB,'Value')==1
    set(handles.rwPB,'Value', 0);
end

UD =  get(handles.freqSlide,'UserData');
if ~isempty(UD)
    lFreq = length(UD.gui.Freq);
    set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(1)*10)/10),4));
    set(handles.freqSlide,'Value',1/(lFreq));
end

function rwPB_Callback(hObject, eventdata, handles)
% plotting routine: sets rewind button
if get(handles.playFreqPB,'Value')==1
    set(handles.playFreqPB,'Value', 0);
end
if get(handles.ffPB,'Value')==1
    set(handles.ffPB,'Value', 0);
end

UD =  get(handles.freqSlide,'UserData');
if ~isempty(UD)
    lFreq = length(UD.gui.Freq);
    set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(1))*10)/10,4));
    
    if sum(sum(real(UD.p))) == 0 && sum(sum(imag(UD.p)))== 0, press = zeros(length(UD.p),lFreq);
        set(handles.axes4,'Clim',[-1 1]);colorbar;
    else
        press = 20*log10(abs(UD.p)/(2*10^-5));
        cMin = min(min(press));cMax = max(max(press));
        if ~isinf(cMin) && ~isinf(cMax),set(handles.axes4,'Clim',[ cMin cMax]);colorbar;end
    end
    
    slidePos = get(handles.freqSlide,'Value');
    if slidePos ==0, i1 = 1;
    elseif slidePos == 1, i1 =1;
    else i1 = round(slidePos*lFreq);
    end
    
    while i1>0  && get(handles.rwPB,'Value')
        cla;
        set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(i1)*10)/10),4));
        set(handles.freqSlide,'Value',i1/(lFreq));
        patch('Faces',UD.surfElem.nodes,'Vertices',UD.coord.cart,'FaceVertexCData',press(:,i1),'FaceColor','interp') ;
        if UD.farField(i1) ~=0
            set(handles.farField,'String',num2str(round(100*max(UD.farField(i1)))/100,4));
        else
            set(handles.farField,'String','');
        end
        i1 = i1-1;
        pause(0.15);
    end
end

function ffPB_Callback(hObject, eventdata, handles)
% plotting routine: sets fast forward button
if get(handles.playFreqPB,'Value')==1
    set(handles.playFreqPB,'Value', 0);
end
if get(handles.rwPB,'Value')==1
    set(handles.rwPB,'Value', 0);
end

UD =  get(handles.freqSlide,'UserData');
if ~isempty(UD)
    lFreq = length(UD.gui.Freq);
    set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(1))*10)/10,4));
    
    if sum(sum(real(UD.p))) == 0 && sum(sum(imag(UD.p)))== 0, press = zeros(length(UD.p),lFreq);
        set(handles.axes4,'Clim',[-1 1]); colorbar;
    else
        press = 20*log10(abs(UD.p)/(2*10^-5));
        cMin = min(min(press));cMax = max(max(press));
        if ~isinf(cMin) && ~isinf(cMax),set(handles.axes4,'Clim',[ cMin cMax]); colorbar;end
    end
    
    slidePos = get(handles.freqSlide,'Value');
    if slidePos ==0, i1 = 1;
    elseif slidePos == 1, i1 =1;
    else i1 = round(slidePos*lFreq);
    end
    
    while i1<=lFreq  && get(handles.ffPB,'Value')
        cla;
        set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(i1))*10)/10,4));
        set(handles.freqSlide,'Value',i1/(lFreq));
        patch('Faces',UD.surfElem.nodes,'Vertices',UD.coord.cart,'FaceVertexCData',press(:,i1),'FaceColor','interp') ;
        if UD.farField(i1) ~=0
            set(handles.farField,'String',num2str(round(100*max(UD.farField(i1)))/100,4));
        else
            set(handles.farField,'String','');
        end
        i1 = i1+1;
        pause(0.15);
    end
end

function plotFreq_Callback(hObject, eventdata, handles)
% plotting routine: sets frequency for pressure which should be plotted
plotFreq  = str2double(get(handles.plotFreq,'String'));
UD =  get(handles.freqSlide,'UserData');

if isnan(plotFreq) || plotFreq<0 || imag(plotFreq)~=0
    plotFreq = UD.gui.Freq(1);
    set(hObject,'String', num2str(plotFreq));
    set(handles.Status,'String','Frequency must be a real positive number!');
end

if ~isempty(UD)
    [diff, posFreq] =  min(abs(UD.gui.Freq-plotFreq));
    lFreq = length(UD.gui.Freq);
    
    set(handles.freqSlide,'SliderStep',[1/lFreq,0.1]);
    if sum(sum(real(UD.p))) == 0 && sum(sum(imag(UD.p)))== 0, press = zeros(length(UD.p),1);
        set(handles.axes4,'Clim',[-1 1]);colorbar;
    else
        press = 20*log10(abs(UD.p(:,posFreq))/(2*10^-5));
        cMin = min(min(press));cMax = max(max(press));
        if ~isinf(cMin) && ~isinf(cMax),set(handles.axes4,'Clim',[ cMin cMax]);colorbar; end
    end
    
    cla;
    set(handles.currentFreq,'String',num2str(round(real(UD.gui.Freq(posFreq))*10)/10,4));
    set(handles.freqSlide,'Value',posFreq/lFreq);
    patch('Faces',UD.surfElem.nodes,'Vertices',UD.coord.cart,'FaceVertexCData',press,'FaceColor','interp') ;
end

function spkToogle_ClickedCallback(hObject, eventdata, handles)
UD = get(handles.freqSlide,'UserData');
if ~isempty(UD)
    UD=get(handles.freqSlide,'UserData');
    UD.gui.meshFilename = get(handles.meshFilename,'String');
    ita_GUIModeSolveSpk(UD);
else
    set(handles.Status,'String','No calculations are done, so you have to chose a mesh and later result data from unv files!');
    
    % set meshfilename
    mesh_Callback(hObject, eventdata, handles)
    meshFilename = get(handles.meshFilename,'String');
    % set resultfilename
    [resultFilename,resultFilepath] =uigetfile({'*.unv';'*.ita';'*.*'},'Select result file...');
    resultFilename=[resultFilepath resultFilename];
    findUnv = findstr(resultFilename,'.unv');
    findIta = findstr(resultFilename,'.ita');
    
    if isempty(findUnv) && isempty(findIta)
        resultFilename=[];
        set(handles.Status,'String','The result file must be an *.unv or *ita file!');
    end
    
    if ~isempty(meshFilename) && ~isempty(resultFilename)
        try
            if strcmp(resultFilename(end-3:end),'.unv')
                results = ita_readunv2414(resultFilename);
                results = results{1};
            elseif strcmp(resultFilename(end-3:end),'.ita')
                results = ita_read(resultFilename);
            else
                set(handles.Status,'String','Your results has to be a *.ita or *.unv file!');
            end
            % summary of data
            if length(coord.x)==size(results.data,2)
                OutGUI.p = results.data.';
                OutGUI.surfElem = UD.surfElem;
                OutGUI.volElem = UD.volElem;
                OutGUI.coord = UD.coord;
                OutGUI.groups = UD.groupMaterial;
                OutGUI.gui.Freq =results.freqVector;
                OutGUI.gui.meshFilename = meshFilename;
                OutGUI.gui.resultFilename = resultFilename;
                ita_GUIModeSolveSpk(OutGUI);
            else
                set(handles.Status,'String','Your mesh does not belong to your results!');
            end
            
        catch
            set(handles.Status,'String','This is no unv file 2414!');
        end
    else
        set(handles.Status,'String','If you want to import data: First select the mesh and afterwards select the data!');
    end
end
set(handles.spkToogle,'State','off');

function itaSave_ClickedCallback(hObject, eventdata, handles)
% prepare data for saving

button = questdlg('What do you want to save?','Save results...','unv-File','ita-File','Workspace','ita-File');
switch button
    case 'ita-File'
        itaSaveTmp = itaResult;
        results = get(handles.freqSlide,'UserData');
        itaSaveTmp.freqVector = results.gui.Freq.';
        itaSaveTmp.freqData = results.p.';
        itaSaveTmp.resultType = 'simulation';
        groupPropTmp=['meshFilename' get(handles.meshFilename,'String') '|'];
        
        for i1 = 1:length(results.groupMaterial)
            if ~isempty(results.groupMaterial{i1}{2})
                if length(results.groupMaterial{i1}{2}.Value)>1
                    stringBC = results.groupMaterial{i1}{2}.FreqInputFilename;
                else
                    stringBC = num2str(results.groupMaterial{i1}{2}.Value);
                end
                groupPropTmp = [groupPropTmp ', (' results.groupMaterial{i1}{2}.Name ') ' results.groupMaterial{i1}{2}.Type,...
                    ' ' stringBC ' ' results.groupMaterial{i1}{2}.Unit];
            end
        end
        
        itaSaveTmp.comment =groupPropTmp;
        itaSaveTmp.channelUnits(1:length(results.coord.ID)) ={'pa'};
        for i1 =1:length(results.coord.ID)
            itaSaveTmp.channelNames(i1) = {num2str(results.coord.ID(i1))};
        end
        itaSaveTmp.channelCoordinates = results.coord;
        
        % get result filename
        [resultItaFilename,resultItaFilepath] = uiputfile('*.ita','Save result as *.ita');
        resultItaFilename=[resultItaFilepath resultItaFilename];
        
        % save data
        findIta = findstr(resultItaFilename,'.ita');
        
        if isempty(findIta)
            resultItaFilename=[];
            set(handles.Status,'String','The ita file must be a *.ita file!');
        end
        
        if ~isempty(resultItaFilename)
            ita_write(itaSaveTmp,resultItaFilename);
            set(handles.Status,'String',['Your result is written in file' resultItaFilename '!']);
        end
    case 'Workspace'
        itaSaveTmp = itaResult;
        results = get(handles.freqSlide,'UserData');
        itaSaveTmp.freqVector = results.gui.Freq.';
        itaSaveTmp.freqData = results.p.';
        itaSaveTmp.resultType = 'simulation';
        groupPropTmp=['meshFilename' get(handles.meshFilename,'String') '|'];
        
        for i1 = 1:length(results.groupMaterial)
            if ~isempty(results.groupMaterial{i1}{2})
                if length(results.groupMaterial{i1}{2}.Value)>1
                    stringBC = results.groupMaterial{i1}{2}.FreqInputFilename;
                else
                    stringBC = num2str(results.groupMaterial{i1}{2}.Value);
                end
                groupPropTmp = [groupPropTmp ', (' results.groupMaterial{i1}{2}.Name ') ' results.groupMaterial{i1}{2}.Type,...
                    ' ' stringBC ' ' results.groupMaterial{i1}{2}.Unit];
            end
        end
        
        itaSaveTmp.comment =groupPropTmp;
        itaSaveTmp.channelUnits(1:length(results.coord.ID)) ={'pa'};
        for i1 =1:length(results.coord.ID)
            itaSaveTmp.channelNames(i1) = {num2str(results.coord.ID(i1))};
        end
        itaSaveTmp.channelCoordinates = results.coord;
        
        % get result filename
        ita_setinbase('simuRes',itaSaveTmp);
    case 'log-File'
        
        % sets name and dir of logfile
        [logFilename,logFilepath] = uiputfile('*.txt','Save logfile as');
        logFilename=[logFilepath logFilename];
        findTxt = findstr(logFilename,'.txt');
        if isempty(findTxt)
            logFilename=[];
            set(handles.Status,'String','The logfile must be a *.txt file!');
        end
        
        UD =  get(handles.freqSlide,'UserData');
        if ~isempty(UD) && ~isempty(logFilename)
            meshFilename = get(handles.meshFilename,'String');
            writeLogFile(logFilename,meshFilename,UD.gui,UD.coord,{UD.volElem, UD.surfElem },UD.groupMaterial);
            set(handles.Status,'String',['Logfile is saved in ' logFilename '!']);
        end
        
    case 'unv-File'
        % sets name and dir of resultfile
        UD =  get(handles.freqSlide,'UserData');
        
        [resultFilename,resultFilepath] = uiputfile('*.unv','Save resultfile as');
        resultFilename=[resultFilepath resultFilename];
        
        findUnv = findstr(resultFilename,'.unv');
        
        if isempty(findUnv)
            resultFilename=[];
            set(handles.Status,'String','The result file must be a *.unv file!');
        end
        
        if ~isempty(UD) && ~isempty(resultFilename)
            for i1=1:length(UD.gui.Freq)
                Data.p_real = real(UD.p(:,i1));
                Data.p_imag = imag(UD.p(:,i1));
                Data.freq = UD.gui.Freq(i1);
                Data.nodes  = UD.coord.ID;
                Data.Type   = 'pressure';
                Data.eigenValues = [];
                writeuff2414(resultFilename,Data);
            end
            set(handles.Status,'String',['Results are saved in ' resultFilename '!']);
        end
end
set(handles.itaSave,'State','off');

function loadData_ClickedCallback(hObject, eventdata, handles)

set(handles.Status,'String','Results are loaded from files!');

[resultFilename,resultFilepath] =uigetfile({'*.unv';'*.ita';'*.*'},'Select result file...');
resultFilename=[resultFilepath resultFilename];

mesh_Callback(hObject, eventdata, handles);
meshFilename = get(handles.meshFilename,'String');

% set resultfilename
findUnv = strfind(meshFilename,'.unv');
findIta = strfind(resultFilename,'.ita');

if (isempty(findUnv)&&isempty(findIta))
    resultFilename=[];
    set(handles.Status,'String','The result file must be a *.unv file!');
end

%import data in gui
if ~isempty(meshFilename) && ~isempty(resultFilename)
    try
        if strcmp(resultFilename(end-3:end),'.unv')
            results = ita_readunv2414(resultFilename);
            results = results{1};
        elseif strcmp(resultFilename(end-3:end),'.ita')
            results = ita_read(resultFilename);
        else
            set(handles.Status,'String','Your results has to be a *.ita or *.unv file!');
        end
        
        % summary of data
        UD = get(handles.freqSlide,'UserData');
        if length(UD.coord.ID)==size(results.freqData,2)
            UD.p = results.freqData.';
            UD.gui.Freq = results.freqVector.';
            UD.farField = zeros(1,length(results.freqVector));
            set(handles.freqSlide,'Value',real(results.freqVector(1))/real(results.freqVector(end)));
            set(handles.currentFreq,'String',num2str(round(real(results.freqVector(1))*10)/10,4));
            set(handles.freqSlide,'UserData',UD);
            
            % plot first frequency
            lFreq = length(UD.gui.Freq);
            set(handles.freqSlide,'SliderStep',[1/(lFreq),0.1]);
            if sum(sum(real(UD.p))) == 0 && sum(sum(imag(UD.p)))== 0
                press = zeros(length(UD.p),lFreq);
                set(handles.axes4,'Clim',[-1 1]);colorbar;
            else
                press = 20*log10(abs(UD.p(:,end))/(2*10^-5));
                cMin = min(min(press));cMax = max(max(press));
                if ~isnan(cMin) || ~isnan(cMax),set(handles.axes4,'Clim',[ cMin cMax]);colorbar; end
            end
            cla;
            patch('Faces',UD.surfElem.nodes,'Vertices',UD.coord.cart,'FaceVertexCData',press(:,1),'FaceColor','interp') ;
            set(handles.freqSlide,'Value',1/(lFreq));
            set(handles.SliderStart,'String',num2str(round(real(UD.gui.Freq(1))*10)/10,4));
            set(handles.SliderStop,'String',num2str(round(real(UD.gui.Freq(end))*10)/10,4));
            
            % set filenames
            set(handles.meshFilename,'String',meshFilename);
        else
            set(handles.Status,'String','Your mesh does not belong to your results!');
        end
        
    catch
        set(handles.Status,'String','This is no unv file 2414 or valid *.ita file!');
    end
else
    set(handles.Status,'String','If you want to import data: First select the mesh and afterwards select the data!');
end
set(handles.loadData,'State','off');

function pbDeletePS_Callback(hObject, eventdata, handles)
pos =get(handles.lbAddedPS,'Value');
currentPS =get(handles.lbAddedPS,'UserData');
currentPS2 =get(handles.lbAddedPS,'String');
infoBC=get(handles.infoBC,'String');
groupName=get(handles.groupName,'String');
UD = get(handles.freqSlide,'UserData');
if ~ischar(currentPS2) && length(currentPS2)>1
    PSNameTmp = currentPS2{pos};
    currentPS = {currentPS{1:pos-1}; currentPS{pos+1:end}};
    currentPS2 = {currentPS2{1:pos-1}; currentPS2{pos+1:end}};
    
    l_infoBC = length(infoBC);
    
    for i1=1:5:l_infoBC
        if strcmp(infoBC{i1} ,PSNameTmp)~=0
            infoBC = {infoBC{1:i1-1,1} infoBC{i1+5:end,1}}';
            groupName = {groupName{1:((i1+4)/5)-1,1} groupName{((i1+4)/5)+1:end,1}};
            UD.groupMaterial = {UD.groupMaterial{1:((i1+4)/5)-1} UD.groupMaterial{((i1+4)/5):end}};
            set(handles.groupName,'String',groupName);
            set(handles.infoBC,'String',infoBC);
            break;
        end
    end
    set(handles.lbAddedPS,'UserData',currentPS);
    set(handles.lbAddedPS,'String',currentPS2);
elseif ~ischar(currentPS2) && length(currentPS2)==1
    infoBC=get(handles.infoBC,'String');
    l_infoBC = length(infoBC);
    PSNameTmp = currentPS2{pos};
    for i1=1:5:l_infoBC
        if strcmp(infoBC{i1} ,PSNameTmp)~=0
            infoBC = {infoBC{1:i1-1,1} infoBC{i1+5:end,1}}';
            groupName = {groupName{1:((i1+4)/5)-1,1}}';
            UD.groupMaterial = UD.groupMaterial{1:((i1+4)/5)-1};
            set(handles.freqSlide,'UserData',UD);
            set(handles.groupName,'String',groupName);
            set(handles.infoBC,'String',infoBC);
            break;
        end
    end
    set(handles.lbAddedPS,'UserData',[]);
    set(handles.lbAddedPS,'String','No added point sources');
end

set(handles.lbAddedPS,'Value',1);

function lbAddedPS_Callback(hObject, eventdata, handles)

function PointSourceName_Callback(hObject, eventdata, handles)
lbPS = get(handles.lbAddedPS,'UserData');
namePS = get(hObject,'String');
UD = get(handles.freqSlide,'UserData');
if isempty(namePS)
    set(hObject,'String','Name of point source');
else
    exist=0;
    for i1 = 1:length(lbPS)
        if strcmp(namePS,lbPS{i1})
            helpdlg(['The name of the point source ' namePS ' already exits!'],'Name of oint source...');
            set(hObject,'String','Name of point source');
            exist=1;
            break;
        end
    end
    if exist == 0
        if ~strcmp(namePS,'Name of point source') && ( ~isempty(get(handles.txtCursorID,'String')) || ~strcmp(get(handles.PointSourceID,'String'),'ID edit'))
            lbPS = get(handles.lbAddedPS,'String');
            if strcmp(lbPS,'No added point sources')
                set(handles.lbAddedPS,'String',{namePS});
                set(handles.lbAddedPS,'UserData',{namePS});
            else
                lbPS{end+1} = namePS;
                set(handles.lbAddedPS,'String',lbPS);
                set(handles.lbAddedPS,'UserData',lbPS);
            end
            set(handles.PointSourceName,'String','Name of point source');
            set(handles.txtCursorID,'String','');
            set(handles.PointSourceID,'String','ID edit');
            
            % neu
            groupInfo = get(handles.infoBC,'String');
            groupName = get(handles.groupName,'String');
            lGroup = length(UD.groupMaterial);
            groupTmp = itaMeshGroup(1,namePS ,1,'nodes');
            if get(handles.rbEditID,'Value')
                groupTmp.ID = str2double(get(handles.PointSourceID,'String'));
            else
                groupTmp.ID = str2double(get(handles.PointSourceCursorID,'String'));
            end
            
            prop.ID = lGroup+1; prop.name =namePS; prop.type = 'Point Source';
            prop.Value =1; prop.zFreqA = []; prop.zFreqBName = 'none';
            groupMaterialTmp = itaMeshBoundaryC(prop);
            groupMaterialTmp.groupID = lGroup+1;
            UD.groupMaterial{end+1} = {groupTmp, groupMaterialTmp};
            
            groupInfo{(lGroup+1)*5-4} = namePS;  % name
            groupName{lGroup+1} = namePS;
            groupInfo{(lGroup+1)*5-3} = 'Point Source';% type
            groupInfo{(lGroup+1)*5-2} = '1';% value
            groupInfo{(lGroup+1)*5-1} = 'none'; % File
            groupInfo{(lGroup+1)*5} = []; % space
            
            set(handles.groupName,'String',groupName);
            set(handles.infoBC,'String',groupInfo);
            set(handles.freqSlide,'UserData',UD);
            %alt
        end
    end
end

%% function PointSourceCursorID_Callback(hObject, eventdata, handles)
% UD =  get(handles.freqSlide,'UserData');
% set(handles.rbEditID,'Value',0);
% set(handles.rbCursorID,'Value',1);
% l=datacursormode;
% lData=get(l,'DataCursors');
% pos=get(lData,'Position');
% datacursormode on
% if ~isempty(pos)
%     pos2 = find( (UD.coord.cart(:,1)==pos(1)) & (UD.coord.cart(:,2)==pos(2)) & (UD.coord.cart(:,3)==pos(3)), 1);
%     %id = UD.coord.ID(pos2);
%     id = pos2;
%     set(handles.PointSourceID,'String','ID edit');
%     set(handles.txtCursorID,'String',id);
%     namePS = get(handles.PointSourceName,'String');
%     if ~strcmp(namePS,'Name of point source')
%         lbPS = get(handles.lbAddedPS,'String');
%         if strcmp(lbPS,'No added point sources')
%             set(handles.lbAddedPS,'String',{namePS});
%             set(handles.lbAddedPS,'UserData',{namePS});
%         else
%             lbPS{end+1} = namePS;
%             set(handles.lbAddedPS,'String',lbPS);
%             set(handles.lbAddedPS,'UserData',lbPS);
%         end
%         set(handles.PointSourceName,'String','Name of point source');
%         %neu
%         set(handles.txtCursorID,'String','');
%         groupInfo = get(handles.infoBC,'String');
%         groupName = get(handles.groupName,'String');
%         lGroup = length(groupInfo)/5;
% %         if strcmp(groupInfo,'Select mesh')
% %             lGroup = 0;
% %         end
%
%         groupTmp = itaMeshGroup(1,namePS ,1,'nodes');
%         groupTmp.ID = id;
%
%         prop.ID = lGroup+1; prop.name =namePS; prop.type = 'Point Source';
%         prop.Value =1; prop.zFreqA = []; prop.zFreqBName = 'none';
%         groupMaterialTmp = itaMeshBoundaryC(prop);
%         groupMaterialTmp.groupID = lGroup+1;
%         if length(UD.groupMaterial)==2 && isa(UD.groupMaterial{1},'itaMeshGroup')
%             UD.groupMaterial = {UD.groupMaterial {groupTmp, groupMaterialTmp}};
%         else
%             UD.groupMaterial{end+1} = {groupTmp, groupMaterialTmp};
%         end
%
%         groupInfo{(lGroup+1)*5-4} = namePS;  % name
%         groupName{lGroup+1} = namePS;
%         groupInfo{(lGroup+1)*5-3} = 'Point Source';% type
%         groupInfo{(lGroup+1)*5-2} = '1';% value
%         groupInfo{(lGroup+1)*5-1} = 'none'; % File
%         groupInfo{(lGroup+1)*5} = []; % space
%
%         set(handles.groupName,'String',groupName);
%         set(handles.infoBC,'String',groupInfo);
%         set(handles.freqSlide,'UserData',UD);
%         %alt
%     else
%         set(handles.Status,'String','Please select a name for your point source!');
%     end
% end

function PointSourceID_Callback(hObject, eventdata, handles)
sourceID = str2double(get(hObject,'String'));
UD =  get(handles.freqSlide,'UserData');
set(handles.rbEditID,'Value',1);
set(handles.rbCursorID,'Value',0);
set(handles.txtCursorID,'String','');
if isnan(sourceID) || imag(sourceID)~=0 || sourceID <= 0
    set(hObject,'String','ID edit');
    set(handles.Status,'String','ID of the node you like to add must be a real positiv number!');
elseif isempty(find(sourceID==UD.coord.ID,1))
    set(hObject,'String','ID edit');
    set(handles.Status,'String','This ID is no ID from your seleced mesh!');
else
    namePS = get(handles.PointSourceName,'String');
    if ~strcmp(namePS,'Name of point source')
        lbPS = get(handles.lbAddedPS,'String');
        if strcmp(lbPS,'No added point sources')
            set(handles.lbAddedPS,'String',{namePS});
            set(handles.lbAddedPS,'UserData',{namePS});
        else
            lbPS{end+1} = namePS;
            set(handles.lbAddedPS,'String',lbPS);
            set(handles.lbAddedPS,'UserData',lbPS);
        end
        set(handles.PointSourceName,'String','Name of point source');
        set(hObject,'String','ID edit');
        groupInfo = get(handles.infoBC,'String');
        groupName = get(handles.groupName,'String');
        lGroup = length(groupInfo)/5;
        
        groupTmp = itaMeshGroup(1,namePS ,1,'nodes');
        groupTmp.ID = sourceID;
        
        prop.ID = lGroup+1; prop.name =namePS; prop.type = 'Point Source';
        prop.Value =1; prop.zFreqA = []; prop.zFreqBName = 'none';
        groupMaterialTmp = itaMeshBoundaryC(prop);
        groupMaterialTmp.groupID = lGroup+1;
        if length(UD.groupMaterial)==2 && isa(UD.groupMaterial{1},'itaMeshGroup')
            UD.groupMaterial = {UD.groupMaterial {groupTmp, groupMaterialTmp}};
        else
            UD.groupMaterial{end+1} = {groupTmp, groupMaterialTmp};
        end
        groupInfo{(lGroup+1)*5-4} = namePS;  % name
        groupName{lGroup+1} = namePS;
        groupInfo{(lGroup+1)*5-3} = 'Point Source';% type
        groupInfo{(lGroup+1)*5-2} = '1';% value
        groupInfo{(lGroup+1)*5-1} = 'none'; % File
        groupInfo{(lGroup+1)*5} = []; % space
        
        set(handles.groupName,'String',groupName);
        set(handles.infoBC,'String',groupInfo);
        set(handles.freqSlide,'UserData',UD);
        %alt
    else
        set(handles.Status,'String','Please select a name for your point source!');
    end
end
%% Create Functions
%==========================================================================

function singleFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stopFreq_CreateFcn(hObject, eventdata, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stepFreq_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function startFreq_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function logfile_CreateFcn(hObject, eventdata, handles)

function type_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ValueBC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function groupName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function solveMode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function infoBC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function freqSlide_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function plotFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uiFiles_CreateFcn(hObject, eventdata, handles)

function PointSourceID_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PointSourceName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lbAddedPS_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Neue Funktionen
%==========================================================================
%==========================================================================


% --------------------------------------------------------------------
function spkToogle_OnCallback(hObject, eventdata, handles)
% hObject    handle to spkToogle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function createMeshTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to createMeshTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[coord, volElem] = GUICreateMesh;

if ~isa(coord, 'itaMeshNodes') || ~isa(volElem,'itaMeshElements')
    disp('Something went wrong, try again!')
    return
end

cla(handles.axes4,'reset');
set(handles.axes4,'View',[-30 50]);

surfElem = makeShellElements(volElem);

% plots mesh
xlabel('x');ylabel('y');zlabel('z');grid on;
plotElem = volElem.nodes;
if length(volElem.nodes(1,:)) == 20
    edit = [1:7 1 9 13:20 13:15 10 3:5 11 17:19 12,7];
    plotElem = plotElem(:,edit);
elseif length(volElem.nodes(1,:)) == 10
    edit = [1:5 1 7 10 8 3:5 9 10];
    plotElem = plotElem(:,edit);
elseif length(volElem.nodes(1,:)) == 4
    edit = [1:3, 1,2,4, 2,3,4];
    plotElem = plotElem(:,edit);
elseif length(volElem.nodes(1,:)) == 8
    edit = [1:4, 1,2,5,6, 2,3,6,7, 3,4,7,8, 1,4,5,8];
    plotElem = plotElem(:,edit);
end

hold on;
p = patch('Faces',plotElem,'Vertices',coord.cart,'FaceVertexCData',[0 0 0],'FaceColor','none');
set(p,'EdgeColor',[0.75 0.75 1]);
hold on;
p1 =patch('Faces',surfElem.nodes,'Vertices',coord.cart,'FaceVertexCData',[0 0 0],'FaceColor',[0.9 0.9 0.9]) ;
set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 0 1]); hold off;

set(handles.Status,'String','Your Mesh is on the right side! Now you can select frequency and boundary conditions');
set(handles.mesh,'UserData',1);

% Activate nodes for cursor
dcm_obj = datacursormode;
set(dcm_obj,'UpdateFcn',@updateCursor);
datacursormode off;

% sets maximal frequency
[~, fMean] = preprocessingMode(coord, volElem);
set(handles.singleFreq,'String',num2str(ceil(fMean)));

groups = ita_createSurfGroups(coord,surfElem,6);

% elemente, gruppen... bearbeiten
groupName = cell(length(groups),1);
groupInfo = cell(5*length(groups),1);

for i1=1:length(groups)
    groupMaterial{i1}= ita_niceGroupMaterial(coord, volElem, surfElem, groups{i1},i1); %#ok<*AGROW>
    groupName{i1} =  groups{i1}.groupName;
    groupInfo{i1*5-4} = groups{i1}.groupName;  % name
    groupInfo{i1*5-3} = 'Admittance';% type
    groupInfo{i1*5-2} = '0';% value
    groupInfo{i1*5-1} = 'none'; % File
    groupInfo{i1*5} = []; % space
end

set(handles.groupName,'String',groupName);
set(handles.infoBC,'String',groupInfo);

% data
ModeSolveData.coord=coord;
ModeSolveData.volElem = volElem;
ModeSolveData.surfElem = surfElem;
ModeSolveData.groups = groups;
ModeSolveData.groupMaterial=groupMaterial;
set(handles.freqSlide,'UserData',ModeSolveData);


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu11.
function popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu11


% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function xPos_Callback(hObject, eventdata, handles)
UD =  get(handles.freqSlide,'UserData');
set(handles.rbEditID,'Value',0);
set(handles.rbCursorID,'Value',1);

if sum(isstrprop(get(handles.xPos,'string'),'xdigit'))>= 1 &&...
        sum(isstrprop(get(handles.yPos,'string'),'xdigit'))>= 1 &&...
        sum(isstrprop(get(handles.zPos,'string'),'xdigit'))>= 1
    pos = zeros(1,3);
    pos(1) = str2double(get(handles.xPos,'string'));
    pos(2) = str2double(get(handles.yPos,'string'));
    pos(3) = str2double(get(handles.zPos,'string'));
    
    posC = itaCoordinates;
    posC.cart = pos;
    
    
    pos2 = UD.coord.findnearest(posC);
    %pos2 = find( (UD.coord.cart(:,1)==pos(1)) & (UD.coord.cart(:,2)==pos(2)) & (UD.coord.cart(:,3)==pos(3)), 1);
    %id = UD.coord.ID(pos2);
    id = pos2;
    set(handles.PointSourceID,'String','ID edit');
    set(handles.txtCursorID,'String',id);
    namePS = get(handles.PointSourceName,'String');
    if ~strcmp(namePS,'Name of point source')
        lbPS = get(handles.lbAddedPS,'String');
        if strcmp(lbPS,'No added point sources')
            set(handles.lbAddedPS,'String',{namePS});
            set(handles.lbAddedPS,'UserData',{namePS});
        else
            lbPS{end+1} = namePS;
            set(handles.lbAddedPS,'String',lbPS);
            set(handles.lbAddedPS,'UserData',lbPS);
        end
        set(handles.PointSourceName,'String','Name of point source');
        %neu
        set(handles.txtCursorID,'String','');
        groupInfo = get(handles.infoBC,'String');
        groupName = get(handles.groupName,'String');
        lGroup = length(groupInfo)/5;
        %         if strcmp(groupInfo,'Select mesh')
        %             lGroup = 0;
        %         end
        
        groupTmp = itaMeshGroup(1,namePS ,1,'nodes');
        groupTmp.ID = id;
        
        prop.ID = lGroup+1; prop.name =namePS; prop.type = 'Point Source';
        prop.Value =1; prop.zFreqA = []; prop.zFreqBName = 'none';
        groupMaterialTmp = itaMeshBoundaryC(prop);
        groupMaterialTmp.groupID = lGroup+1;
        if length(UD.groupMaterial)==2 && isa(UD.groupMaterial{1},'itaMeshGroup')
            UD.groupMaterial = {UD.groupMaterial {groupTmp, groupMaterialTmp}};
        else
            UD.groupMaterial{end+1} = {groupTmp, groupMaterialTmp};
        end
        
        groupInfo{(lGroup+1)*5-4} = namePS;  % name
        groupName{lGroup+1} = namePS;
        groupInfo{(lGroup+1)*5-3} = 'Point Source';% type
        groupInfo{(lGroup+1)*5-2} = '1';% value
        groupInfo{(lGroup+1)*5-1} = 'none'; % File
        groupInfo{(lGroup+1)*5} = []; % space
        
        set(handles.groupName,'String',groupName);
        set(handles.infoBC,'String',groupInfo);
        set(handles.freqSlide,'UserData',UD);
        %alt
    else
        set(handles.Status,'String','Please select a name for your point source!');
    end
    set(handles.xPos,'string','x')
    set(handles.yPos,'string','y')
    set(handles.zPos,'string','z')
end

function zPos_Callback(hObject, eventdata, handles)
xPos_Callback(hObject, eventdata, handles)


function yPos_Callback(hObject, eventdata, handles)
xPos_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function xPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function zPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lbAddedPS.
function listbox8_Callback(hObject, eventdata, handles)
% hObject    handle to lbAddedPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbAddedPS contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbAddedPS


% % --- Executes during object creation, after setting all properties.
% function listbox8_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to lbAddedPS (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
%
% % Hint: listbox controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes during object creation, after setting all properties.
function yPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
