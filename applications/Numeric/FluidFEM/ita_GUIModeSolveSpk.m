function varargout = ita_GUIModeSolveSpk(varargin)
% this is the function for the visualization of spectrums from
% ita_GUIModeSolve
% Begin initialization code - DO NOT EDIT

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_GUIModeSolveSpk_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_GUIModeSolveSpk_OutputFcn, ...
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

% --- Executes just before ita_GUIModeSolveSpk is made visible.
function ita_GUIModeSolveSpk_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_GUIModeSolveSpk (see VARARGIN)

% Choose default command line output for ita_GUIModeSolveSpk
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% initialize_gui(hObject, handles, false);
% --> kann auch mit eienr funktion erfolgen
% UIWAIT makes ita_GUIModeSolveSpk wait for user response (see UIRESUME)
% uiwait(handles.figure1);
if nargin ==4
    % aus GUIModeSolve
    handles.output = hObject;
    results = varargin{1};
    set(handles.nodeList,'UserData',results);
    
    % set groups
    groupNames = cell(0,0);
    for i=1:length(results.groupMaterial)
        groupNames{i} = results.groupMaterial{i}{1}.groupName; %#ok<*AGROW>
    end
    set(handles.groupList,'String',groupNames);
    
    % set mesh
    volElem = results.volElem;
    if length(volElem.nodes(1,:)) == 20
        edit = [1:7 1 9 13:20 13:15 10 3:5 11 17:19 12,7];
        plotElem = volElem.nodes(:,edit);
    elseif length(volElem.nodes(1,:)) == 10
        edit = [1:5 1 7 10 8 3:5 9 10];
        plotElem = volElem.nodes(:,edit);
    elseif length(volElem.nodes(1,:)) == 4
        edit = [1:3, 1,2,4, 2,3,4];
        plotElem = volElem.nodes(:,edit); 
    elseif length(volElem.nodes(1,:)) == 8
        edit = [1:4, 1,2,5,6, 2,3,6,7, 3,4,7,8, 1,4,5,8];
        plotElem = volElem.nodes(:,edit);    
    end
    axes(handles.nodePos);cla;
    xlabel('x');ylabel('y');zlabel('z');grid on;view([45  135]);
    hold on;

    p2 = patch('Faces',plotElem,'Vertices',results.coord.cart,'FaceVertexCData',[0 0 0],'FaceColor','none'); 
    set(p2,'EdgeColor',[0.75 0.75 1]);hold on;
    p1 =patch('Faces',results.surfElem.nodes,'Vertices',results.coord.cart,'FaceVertexCData',[0 0 0],'FaceColor',[0.9 0.9 0.9]) ;
    set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 0 1]); hold on;
    dcm_obj = datacursormode;
    set(dcm_obj,'UpdateFcn',@updateCursor);
    datacursormode off;
else
 %
end

function varargout = ita_GUIModeSolveSpk_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function nodeNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nodeNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nodeNum_Callback(hObject, eventdata, handles)

function plotSpectrum_Callback(hObject, eventdata, handles)
results = get(handles.nodeList,'UserData');
nodeIDs = get(handles.nodeList,'String');

if get(handles.RbGroup,'Value')
    groupNum = get(handles.groupList,'Value');
    num = results.groupMaterial{groupNum}{1}.ID;
    if strcmp(results.groupMaterial{groupNum}{1}.type,'nodes')
        posTmp=results.groupMaterial{groupNum}{1}.ID;
    else
        groupElem = results.surfElem.nodes(num,:);
        posTmp = groupElem(:);
    end
    for i1=1:length(posTmp)
        nodeIDsTmp(i1,1)= find(results.coord.ID==posTmp(i1),1);%new
        legendTmp{i1} = ['ID ' num2str(nodeIDsTmp(i1,:))];
    end
    
else
    if ~strcmp(nodeIDs,'list of nodes')%new
        for i = 1:size(nodeIDs,1)
            nodeIDsTmp(i,1) = str2double(nodeIDs(i,:));%new
            posTmp(i,1)= find(results.coord.ID==nodeIDsTmp(i,1),1);%new
            legendTmp{i} = ['ID ' num2str(nodeIDs(i,:))];
        end
    else
        posTmp =[];
    end
end

if sum(sum(real(results.p))) == 0 && sum(sum(imag(results.p)))== 0, press = abs(results.p(:,end));
elseif ~isempty(posTmp)
    press = 20*log10(abs(results.p(posTmp,:))/(2*10^-5));
else
    helpdlg('Please select a group or node IDs from the left side!','No nodes selected...');
    press =[];
end

freq = results.gui.Freq;
if length(freq)==1
    warndlg('Pressure is calculated only for one frequency!','! Warning !');
end

if ~isempty(press)
    axes(handles.plotSpk);cla;
    plot(freq,press);grid on;
    xlabel('f [Hz]');ylabel('p [dB]');
    posBackslash = findstr('\',results.gui.meshFilename);
    meshFilenameTmp = results.gui.meshFilename;
    for i2 = 1:length(posBackslash)
        meshFilenameTmp = [meshFilenameTmp(1:posBackslash(i2)+i2-1) meshFilenameTmp(posBackslash(i2)+i2-1:end)];
    end
    posMinus = findstr('_',meshFilenameTmp);
    for i2 = 1:length(posMinus)
        meshFilenameTmp = [meshFilenameTmp(1:posMinus(i2)+i2-2) '\' meshFilenameTmp(posMinus(i2)-1+i2:end)];
    end
    title(['Pressure [dB] from ' meshFilenameTmp]);
    if length(posTmp)<20,legend(legendTmp);end
end

function groupList_Callback(hObject, eventdata, handles)
set(handles.RbGroup,'Value',1);set(handles.RbNode,'Value',0);
set(handles.nodeList,'String','list of nodes');
groupNum = get(hObject,'Value');
results = get(handles.nodeList,'UserData');

volElem = results.volElem;
if length(volElem.nodes(1,:)) == 20
    edit = [1:7 1 9 13:20 13:15 10 3:5 11 17:19 12,7];
    plotElem = volElem.nodes(:,edit);
elseif length(volElem.nodes(1,:)) == 10
    edit = [1:5 1 7 10 8 3:5 9 10];
    plotElem = volElem.nodes(:,edit);
end
axes(handles.nodePos);cla;
xlabel('x');ylabel('y');zlabel('z');grid on;
hold on;

p2 = patch('Faces',plotElem,'Vertices',results.coord.cart,'FaceVertexCData',[0 0 0],'FaceColor','none');
set(p2,'EdgeColor',[0.75 0.75 1]);hold on;
p1 =patch('Faces',results.surfElem.nodes,'Vertices',results.coord.cart,'FaceVertexCData',[0 0 0],'FaceColor',[0.9 0.9 0.9]) ;
set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 0 1]); hold on;
    
num = results.groupMaterial{groupNum}{1}.ID;
if strcmp(results.groupMaterial{groupNum}{1}.type,'nodes')
    groupCoord = results.coord.cart(num,:);

    p3 = plot3(groupCoord(:,1),groupCoord(:,2),groupCoord(:,3));
    set(p3,'LineStyle','none');set(p3,'Marker','o');
    set(p3,'MarkerFaceColor','g');set(p3,'MarkerEdgeColor','k');
else
    groupElem = results.surfElem.nodes(num,:);
    groupCoord = results.coord.cart(groupElem,:);

    p3 = plot3(groupCoord(:,1),groupCoord(:,2),groupCoord(:,3));
    set(p3,'LineStyle','none');set(p3,'Marker','o');
    set(p3,'MarkerFaceColor','g');set(p3,'MarkerEdgeColor','k');
end

function nodeList_Callback(hObject, eventdata, handles)
set(handles.RbGroup,'Value',0);set(handles.RbNode,'Value',1);

guidata(hObject,handles);

function nodeClear_Callback(hObject, eventdata, handles)
set(handles.RbGroup,'Value',0);set(handles.RbNode,'Value',1);
set(handles.RbNum,'Value',0);set(handles.RbPos,'Value',1);set(handles.RbClear,'Value',1);

index_selected = get(handles.nodeList,'Value');
liste = get(handles.nodeList,'String');
if ~strcmp(liste,'list of nodes')
    for i = 1:size(liste,1)
        listTmp(i,1) = str2double(liste(i,:));
    end
else
    listTmp = [];
end

if ~isempty(listTmp)
    listTmp(index_selected)=[];
    if isempty(listTmp), listTmp = 'list of nodes'; end
    set(handles.nodeList,'String',num2str(listTmp));
    set(handles.nodeList,'Value',1);
end

function posAdd_Callback(hObject, eventdata, handles)
set(handles.RbGroup,'Value',0);set(handles.RbNode,'Value',1);
set(handles.RbNum,'Value',0);set(handles.RbPos,'Value',1);set(handles.RbClear,'Value',0);
results = get(handles.nodeList,'UserData');
axes(handles.nodePos);
l=datacursormode;
lData=get(l,'DataCursors');
pos=get(lData,'Position');
datacursormode on
if ~isempty(pos)
    pos2 = find( (results.coord.cart(:,1)==pos(1)) & (results.coord.cart(:,2)==pos(2)) & (results.coord.cart(:,3)==pos(3)), 1);
    if ~isempty(pos2)
        liste = get(handles.nodeList,'String');
        if strcmp(liste,'list of nodes')
            listTmp = [];
            listPosTmp=[];
        else
            for i = 1:size(liste,1)
                listTmp(i,1) = str2double(liste(i,:));
                listPosTmp(i,1) = find(listTmp(i,1)==results.coord.ID,1);%new
            end
        end
        if isempty(find(pos2==listPosTmp,1))%new: no double nodes
            listTmp = [listTmp;results.coord.ID(pos2)];%new
            listPosTmp = [listPosTmp;pos2];%new
            
            set(handles.nodeList,'String',num2str(listTmp));

            % plot
            volElem = results.volElem;
            if length(volElem.nodes(1,:)) == 20
                edit = [1:7 1 9 13:20 13:15 10 3:5 11 17:19 12,7];
                plotElem = volElem.nodes(:,edit);
            elseif length(volElem.nodes(1,:)) == 10
                edit = [1:5 1 7 10 8 3:5 9 10];
                plotElem = volElem.nodes(:,edit);
            end
            axes(handles.nodePos);cla;
            xlabel('x');ylabel('y');zlabel('z');grid on;
            hold on;

            p2 = patch('Faces',plotElem,'Vertices',results.coord.cart,'FaceVertexCData',[0 0 0],'FaceColor','none');
            set(p2,'EdgeColor',[0.75 0.75 1]);hold on;
            p1 =patch('Faces',results.surfElem.nodes,'Vertices',results.coord.cart,'FaceVertexCData',[0 0 0],'FaceColor',[0.9 0.9 0.9]) ;
            set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 0 1]); hold on;

            p3 = plot3(results.coord.cart(listPosTmp,1),results.coord.cart(listPosTmp,2),results.coord.cart(listPosTmp,3));%new
            set(p3,'LineStyle','none');set(p3,'Marker','o');
            set(p3,'MarkerFaceColor','g');set(p3,'MarkerEdgeColor','k');
            
        else
            helpdlg('This ID is already in your list!','Double node ID...');
        end
    end
else
    helpdlg('Use data cursor to select a node!','Point Selection');
end

function nodeAdd_Callback(hObject, eventdata, handles)
set(handles.RbGroup,'Value',0);set(handles.RbNode,'Value',1);
set(handles.RbNum,'Value',1);set(handles.RbPos,'Value',0);set(handles.RbClear,'Value',0);
nodeNumber = str2double(get(handles.nodeNum,'String'));

results = get(handles.nodeList,'UserData');
if find(results.coord.ID==nodeNumber,1,'first')
    liste = get(handles.nodeList,'String');
    if strcmp(liste,'list of nodes') || isempty(liste)
        listTmp = [];listPosTmp=[];
    else
        for i = 1:size(liste,1)
            listTmp(i,1) = str2double(liste(i,:));
            listPosTmp(i,1) = find(listTmp(i,1)==results.coord.ID,1);%new
        end
    end
    
    if isempty(find(nodeNumber==listTmp,1));
        listTmp = [listTmp;nodeNumber];
        listPosTmp = [listPosTmp;find(nodeNumber==results.coord.ID,1)];%new
        set(handles.nodeList,'String',num2str(listTmp));

        % plot
        volElem = results.volElem;
        if length(volElem.nodes(1,:)) == 20
            edit = [1:7 1 9 13:20 13:15 10 3:5 11 17:19 12,7];
            plotElem = volElem.nodes(:,edit);
        elseif length(volElem.nodes(1,:)) == 10
            edit = [1:5 1 7 10 8 3:5 9 10];
            plotElem = volElem.nodes(:,edit);
        end
        axes(handles.nodePos);cla;
        xlabel('x');ylabel('y');zlabel('z');grid on;
        hold on;

        p2 = patch('Faces',plotElem,'Vertices',results.coord.cart,'FaceVertexCData',[0 0 0],'FaceColor','none');
        set(p2,'EdgeColor',[0.75 0.75 1]);hold on;
        p1 =patch('Faces',results.surfElem.nodes,'Vertices',results.coord.cart,'FaceVertexCData',[0 0 0],'FaceColor',[0.9 0.9 0.9]) ;
        set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 0 1]); hold on;

        groupCoord = results.coord.cart(listPosTmp,:);%new

        p3 = plot3(groupCoord(:,1),groupCoord(:,2),groupCoord(:,3));
        set(p3,'LineStyle','none');set(p3,'Marker','o');
        set(p3,'MarkerFaceColor','g');set(p3,'MarkerEdgeColor','k');
    else
        helpdlg('This ID is already in your list!','Double node ID...');
    end

else
    warndlg('This is no node ID from the selected mesh!','Node ID not found...');
    set(handles.nodeNum,'String',results.coord.ID(1))
end

function itaSave_ClickedCallback(hObject, eventdata, handles)
itaSaveTmp = itaResult;
results = get(handles.nodeList,'UserData');
nL  = get(handles.nodeList);

if get(handles.RbGroup,'Value')
    groupNum = get(handles.groupList,'Value');
    num = results.groupMaterial{groupNum}{1}.ID;
    if strcmp(results.groupMaterial{groupNum}{1}.type,'nodes')
        posTmp=1;
    else
        groupElem = results.surfElem.nodes(num,:);
        posTmp = groupElem(:);
    end
    for i1=1:length(posTmp)
        nodeIDsTmp(i1,1)= find(results.coord.ID==posTmp(i1),1);
    end
    
else
    if ~strcmp(nL.String,'list of nodes')
        nodeIDs = str2num(nL.String); %#ok<ST2NM>
        for i1 = 1:length(nodeIDs)
            posTmp(i1,1)= find(results.coord.ID==nodeIDs(i1),1);
        end
    else
        posTmp =[];
    end
end
%old
    
itaSaveTmp.freqVector = results.gui.Freq.';
itaSaveTmp.freqData = results.p(posTmp,:).';
itaSaveTmp.resultType = 'simulation';
groupPropTmp=['meshFilename' results.gui.meshFilename '|'];
if ~isempty(results.groupMaterial{1}{2})
    for i1 = 1:length(results.groupMaterial)
        groupPropTmp = [groupPropTmp ', (' results.groupMaterial{i1}{2}.Name ') ' results.groupMaterial{i1}{2}.Type,...
            ' ' num2str(results.groupMaterial{i1}{2}.Value) ' ' results.groupMaterial{i1}{2}.Unit];
    end
else
    for i1 = 1:length(results.groupMaterial)
        groupPropTmp = [groupPropTmp ', (' results.groupMaterial{i1}{1}.groupName ') '];
    end
end
itaSaveTmp.comment =groupPropTmp;
for i1 =1:length(posTmp)
    itaSaveTmp.channelUnits(i1) ={'pa'};
    itaSaveTmp.channelNames(i1) = {[ 'node ID: ' num2str(results.coord.ID(posTmp(i1)))]};
end

[resultItaFilename,resultItaFilepath] = uiputfile('*.ita','Save result as *.ita');
resultItaFilename=[resultItaFilepath resultItaFilename];

if ~isempty(resultItaFilename)
    ita_write(itaSaveTmp,resultItaFilename);
end

set(handles.itaSave,'State','off');

%% Create --- Executes during object creation, after setting all properties.

function groupList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nodeList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% New





% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
