function varargout = ita_vibro_lasergui(varargin)
%ITA_VIBRO_LASERGUI - GUI to control the Polytec laser-vibrometer
%  This GUI gives control over all the function of the polytec
%  laser-vibrometer and reads out signal level and overrange state. If
%  called with one serial object as the input argument, the GUI can only be
%  used to either address the controller unit (the "big box" with the
%  buttons) or to move the laser through the interface.
%  If called with two serial objects, the first serial object is the one
%  that commmunicates with the controller, the second is for the
%  interface and moves the laser.
%
%  default serial port settings: ('BaudRate',9600,'DataBits',8,'StopBits',1)
%
%  Call: ita_vibro_lasergui()
%
%   See also ita_measurement_polar, ita_vibro_sendCommand.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_vibro_lasergui">doc ita_vibro_lasergui</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 25-Nov-2008 

% Last Modified by GUIDE v2.5 23-Jul-2013 18:26:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_vibro_lasergui_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_vibro_lasergui_OutputFcn, ...
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


% --- Executes just before ita_vibro_lasergui is made visible.
function ita_vibro_lasergui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_vibro_lasergui (see VARARGIN)

% nargin refers to this function, so hObject, eventdata and handles are the
% first three arguments
global controller_serial;
global interface_serial;

if isempty(controller_serial) || isempty(interface_serial)
    ita_vibro_init;
end

if ~isempty(varargin) && ischar(varargin{1})
    handles.mode = varargin{1};
    switch handles.mode
        case 'C'
            handles.modes = {'  Use Controller only'};
            handles.modesShort = {'C'};
            handles.so = controller_serial;
            set(handles.so,'Timeout',3);
%             handles.interfaceSo = interface_serial;
%             set(handles.interfaceSo,'Timeout',3);
        case 'I'
            handles.modes = {'  Use Interface only'};
            handles.modesShort = {'I'};
            handles.so = interface_serial;
            set(handles.so,'Timeout',3);
%             handles.interfaceSo = interface_serial;
%             set(handles.interfaceSo,'Timeout',3);
        case 'CI'
            handles.modes = {'  Use Controller only','  Use Interface only','  Use Controller and Interface'};
            handles.modesShort = {'C','I','CI'};
            handles.so = controller_serial;
            set(handles.so,'Timeout',3);
            handles.interfaceSo = interface_serial;
            set(handles.interfaceSo,'Timeout',3);
        otherwise
            error('ITA_VIBRO_LASERGUI:incorrect input argument');
    end
else
    handles.mode = 'CI';
    handles.modes = {'  Use Controller only','  Use Interface only','  Use Controller and Interface'};
    handles.modesShort = {'C','I','CI'};
    handles.so = controller_serial;
    set(handles.so,'Timeout',3);
    handles.interfaceSo = interface_serial;
    set(handles.interfaceSo,'Timeout',3);
end
handles = initialize(handles);
% Choose default command line output for ita_vibro_lasergui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes ita_vibro_lasergui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ita_vibro_lasergui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startMonitoring(handles);
% Get default command line output from handles structure
varargout{1} = handles.output;


function handles = initialize(handles)
%
if ~strcmp(handles.so.Status,'open')
    fopen(handles.so);
end
condition = strcmp(handles.so.Status,'open');
if strcmp(handles.mode,'CI')
    if ~strcmp(handles.interfaceSo.Status,'open')
        fopen(handles.interfaceSo);
    end
    condition = condition && strcmp(handles.interfaceSo.Status,'open');
end

if condition
    set(handles.modeSelect,'String',handles.modes);
    switch(handles.mode)
        case 'C'
            set(handles.modeSelect,'Value',1);
        case 'I'
            set(handles.modeSelect,'Value',2);
        case 'CI'
            set(handles.modeSelect,'Value',3);
        otherwise
            set(handles.modeSelect,'Value',1);
    end
    handles = setEchoon(0,handles);
    handles = getAllValues(handles);
    veloOverrangeFunction(handles);

    handles.signalbar = bar(0,handles.signalLevel,'g');
    axis([-1 1 0 40]);
    set(get(handles.signalbar,'Parent'),'XTickLabel','Signal','FontWeight','bold');

    switch(handles.velo)
        case 1
            handles.lastVeloButton = handles.velobutton4;
        case 6
            handles.lastVeloButton = handles.velobutton3;
        case 7
            handles.lastVeloButton = handles.velobutton2;
        case 8
            handles.lastVeloButton = handles.velobutton1;
        otherwise
            handles.lastVeloButton = handles.velobutton1;
    end

    switch(handles.track)
        case 1
            handles.lastTrackButton = handles.trackbutton1;
        case 3
            handles.lastTrackButton = handles.trackbutton3;
        case 4
            handles.lastTrackButton = handles.trackbutton2;
        otherwise
            handles.lastTrackButton = handles.trackbutton2;
    end

    switch(handles.rem)
        case 0
            handles.lastModeButton = handles.modebutton1;
        case 1
            handles.lastModeButton = handles.modebutton2;
        case 2
            handles.lastModeButton = handles.modebutton3;
        otherwise
            handles.lastModeButton = handles.modebutton1;
    end
    updateGUI(handles);
else
    error('ITA_VIBRO_LASERGUI::no connection for the specified serial object');
end


function updateGUI(handles)
%
updateSignalbar(handles.signalLevel,handles.signalbar)

switch(handles.velo)
    case 1
        velobutton = handles.velobutton4;
    case 6
        velobutton = handles.velobutton3;
    case 7
        velobutton = handles.velobutton2;
    case 8
        velobutton = handles.velobutton1;
    otherwise
        velobutton = handles.velobutton1;
end
handles = veloButtonFunction(velobutton,handles);

switch(handles.track)
    case 1
        trackbutton = handles.trackbutton1;
    case 3
        trackbutton = handles.trackbutton3;
    case 4
        trackbutton = handles.trackbutton2;
    otherwise
        trackbutton = handles.trackbutton2;
end
handles = trackButtonFunction(trackbutton,handles);

switch(handles.rem)
    case 0
        modebutton = handles.modebutton1;
    case 1
        modebutton = handles.modebutton2;
    case 2
        modebutton = handles.modebutton3;
    otherwise
        modebutton = handles.modebutton1;
end
handles = modeButtonFunction(modebutton,handles);
guidata(handles.figure1,handles);


function startMonitoring(handles)
condition = strcmp(handles.so.Status,'open') && ~strcmp(handles.mode,'I');
while(condition)
    handles.over = str2double(getOverrange(handles));
    veloOverrangeFunction(handles);
    updateSignalbar(str2double(getSignalLevel(handles)),handles.signalbar);
    pause(0.25);
    condition = strcmp(handles.so.Status,'open') && ~strcmp(handles.mode,'I');
end


function handles = getAllValues(handles)
%
handles.velo = str2double(getVeloRange(handles));
handles.track = str2double(getTracking(handles));
handles.over = str2double(getOverrange(handles));
handles.signalLevel = str2double(getSignalLevel(handles));
handles.rem = str2double(getRemoteMode(handles));


function velo = getVeloRange(handles)
sent = ita_vibro_sendCommand('VELO?',handles,'controller');
if sent
    resp = fgetl(handles.so);
    if handles.echoon
        %         resp = 'VELO8';
        velo = resp(5);
    else
        %         resp = '8';
        velo = resp;
    end
else
    velo = '8';
end


function errmsg = setVeloRange(handles)
errmsg = '';
sent = ita_vibro_sendCommand(['VELO' num2str(handles.velo)],handles,'controller');
if sent
    new_velo = str2double(getVeloRange(handles));
    if new_velo ~= handles.velo
        errmsg = '>velo unchanged';
    end
end


function veloOverrangeFunction(handles)
%
if handles.over
    set(handles.overrange,'BackgroundColor','r');
else
    set(handles.overrange,'BackgroundColor','w');
end


function track = getTracking(handles)
sent = ita_vibro_sendCommand('TRACK?',handles,'controller');
if sent
    resp = fgetl(handles.so);
    if handles.echoon
        %         resp = 'TRACK1';
        track = resp(6);
    else
        %         resp = '1';
        track = resp;
    end
else
    track = '1';
end


function errmsg = setTracking(handles)
errmsg = '';
sent = ita_vibro_sendCommand(['TRACK' num2str(handles.track)],handles,'controller');
if sent
    new_track = str2double(getTracking(handles));
    if new_track ~= handles.track
        errmsg = '>track unchanged';
    end
end


function over = getOverrange(handles)
sent = ita_vibro_sendCommand('OVR',handles,'controller');
if sent
    resp = fgetl(handles.so);
    if handles.echoon
        %     resp = 'OVR0';
        over = resp(4);
    else
        %     resp = '0';
        over = resp;
    end
else
    over = '0';
end


function lev = getSignalLevel(handles)
sent = ita_vibro_sendCommand('LEV',handles,'controller');
if sent
    resp = fgetl(handles.so);
    if handles.echoon
        %     resp = ['LEV' lStr];
        lev = resp(4:5);
    else
        %     resp = lStr;
        lev = resp;
    end
else
    lev = '0';
end


function rem = getRemoteMode(handles)
sent = ita_vibro_sendCommand('REM',handles,'controller');
if sent
    resp = fgetl(handles.so);
    if handles.echoon
        %         resp = 'REM0';
        rem = resp(4);
    else
        %         resp = '0';
        rem = resp;
    end
else
    rem = '0';
end


function errmsg = setRemoteMode(handles)
errmsg = '';
switch(handles.rem)
    case 0
        com = 'GTL';
    case 1
        com = 'REN';
    case 2
        com = 'LLO';
    otherwise
        com = 'GTL';
end
sent = ita_vibro_sendCommand(com,handles,'controller');
if sent
    new_rem = str2double(getRemoteMode(handles));
    if new_rem ~= handles.rem
        errmsg = '>rem unchanged';
    end
end


function handles = setEchoon(on,handles)
%
handles.echoon = on;
if handles.echoon
    ita_vibro_sendCommand('ECHOON',handles,'controller');
else
    ita_vibro_sendCommand('ECHOOFF',handles,'controller');
end


function handles = veloButtonFunction(hObject,handles)
%
set(handles.lastVeloButton,'BackgroundColor','w');
set(hObject,'BackgroundColor','y');
handles.lastVeloButton = hObject;
handles.velo = get(hObject,'UserData');
guidata(hObject,handles);
err = setVeloRange(handles);
if ~isempty(err)
    displayText(err,handles);
end


function handles = trackButtonFunction(hObject,handles)
%
set(handles.lastTrackButton,'BackgroundColor','w');
set(hObject,'BackgroundColor','y');
handles.lastTrackButton = hObject;
handles.track = get(hObject,'UserData');
guidata(hObject,handles);
err = setTracking(handles);
if ~isempty(err)
    displayText(err,handles);
end


function updateSignalbar(level,signalbar)
% evaluate LEV
set(signalbar,'YData',level);


function handles = modeButtonFunction(hObject,handles)
%
set(handles.lastModeButton,'BackgroundColor','w');
set(hObject,'BackgroundColor','y');
handles.lastModeButton = hObject;
handles.rem = get(hObject,'UserData');
guidata(hObject,handles);
err = setRemoteMode(handles);
if ~isempty(err)
    displayText(err,handles);
end


function echoButtonFunction(hObject,handles)
%
set(hObject,'Value',1);
if hObject == handles.echobutton1
    handles = setEchoon(1,handles);
    set(handles.echobutton2,'Value',0);
elseif hObject == handles.echobutton2
    handles = setEchoon(0,handles);
    set(handles.echobutton1,'Value',0);
end
guidata(hObject,handles);


function displayText(text,handles)
%
temp = get(handles.textbox,'String');
if size(temp,1) < 12
    set(handles.textbox,'String',strvcat(temp,sprintf(text)));
else
    set(handles.textbox,'String',sprintf(text));
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ita_vibro_sendCommand('IFC',handles,'controller');
fclose(handles.so);
if strcmp(handles.mode,'CI')
    fclose(handles.interfaceSo);
end
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in velobutton1.
function velobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to velobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
veloButtonFunction(hObject,handles);


% --- Executes on button press in velobutton2.
function velobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to velobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
veloButtonFunction(hObject,handles);


% --- Executes on button press in velobutton3.
function velobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to velobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
veloButtonFunction(hObject,handles);


% --- Executes on button press in velobutton4.
function velobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to velobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
veloButtonFunction(hObject,handles);    


% --- Executes on button press in trackbutton1.
function trackbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to trackbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trackButtonFunction(hObject,handles);


% --- Executes on button press in trackbutton2.
function trackbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to trackbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trackButtonFunction(hObject,handles);


% --- Executes on button press in trackbutton3.
function trackbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to trackbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trackButtonFunction(hObject,handles);


% --- Executes during object creation, after setting all properties.
function signalbar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to signalbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in modebutton1.
function modebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to modebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modeButtonFunction(hObject,handles);


% --- Executes on button press in modebutton2.
function modebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to modebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modeButtonFunction(hObject,handles);


% --- Executes on button press in modebutton3.
function modebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to modebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modeButtonFunction(hObject,handles);


% --- Executes on button press in echobutton1.
function echobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to echobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
echoButtonFunction(hObject,handles);


% --- Executes on button press in echobutton2.
function echobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to echobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
echoButtonFunction(hObject,handles);


function textbox_Callback(hObject, eventdata, handles)
% hObject    handle to textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of textbox as text
%        str2double(get(hObject,'String')) returns contents of textbox as a double


% --- Executes during object creation, after setting all properties.
function textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ita_vibro_sendCommand('DCL',handles,'controller');
handles = getAllValues(handles);
updateGUI(handles);


% --- Executes on button press in focusbutton1.
function focusbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to focusbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ita_vibro_sendCommand('R',handles,'controller');


% --- Executes on button press in focusbutton2.
function focusbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to focusbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ita_vibro_sendCommand('r',handles,'controller');


% --- Executes on button press in focusbutton3.
function focusbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to focusbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ita_vibro_sendCommand('N',handles,'controller');


% --- Executes on button press in focusbutton4.
function focusbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to focusbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ita_vibro_sendCommand('l',handles,'controller');


% --- Executes on button press in focusbutton5.
function focusbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to focusbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ita_vibro_sendCommand('L',handles,'controller');


% --- Executes on button press in steerZB.
function steerZB_Callback(hObject, eventdata, handles)
% hObject    handle to steerZB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('ZB',handles,'interface'),handles);


% --- Executes on button press in steerIX1.
function steerIX1_Callback(hObject, eventdata, handles)
% hObject    handle to steerIX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('IX0.01',handles,'interface'),handles);


% --- Executes on button press in steerDX1.
function steerDX1_Callback(hObject, eventdata, handles)
% hObject    handle to steerDX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('DX0.01',handles,'interface'),handles);

% --- Executes on button press in steerIY1.
function steerIY1_Callback(hObject, eventdata, handles)
% hObject    handle to steerIY1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('IY0.01',handles,'interface'),handles);


% --- Executes on button press in steerDY1.
function steerDY1_Callback(hObject, eventdata, handles)
% hObject    handle to steerDY1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('DY0.01',handles,'interface'),handles);


% --- Executes on button press in steerIY2.
function steerIY2_Callback(hObject, eventdata, handles)
% hObject    handle to steerIY2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('IY0.2',handles,'interface'),handles);


% --- Executes on button press in steerDY2.
function steerDY2_Callback(hObject, eventdata, handles)
% hObject    handle to steerDY2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('DY0.2',handles,'interface'),handles);


% --- Executes on button press in steerIX2.
function steerIX2_Callback(hObject, eventdata, handles)
% hObject    handle to steerIX2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('IX0.2',handles,'interface'),handles);


% --- Executes on button press in steerDX2.
function steerDX2_Callback(hObject, eventdata, handles)
% hObject    handle to steerDX2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('DX0.2',handles,'interface'),handles);


% --- Executes on button press in steerDX3.
function steerDX3_Callback(hObject, eventdata, handles)
% hObject    handle to steerDX3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('DX2.0',handles,'interface'),handles);


% --- Executes on button press in steerIX3.
function steerIX3_Callback(hObject, eventdata, handles)
% hObject    handle to steerIX3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('IX2.0',handles,'interface'),handles);


% --- Executes on button press in steerIY3.
function steerIY3_Callback(hObject, eventdata, handles)
% hObject    handle to steerIY3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('IY2.0',handles,'interface'),handles);


% --- Executes on button press in steerDY3.
function steerDY3_Callback(hObject, eventdata, handles)
% hObject    handle to steerDY3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(ita_vibro_sendCommand('DY2.0',handles,'interface'),handles);


% --- Executes on button press in getposition.
function getposition_Callback(hObject, eventdata, handles)
% hObject    handle to getposition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayText(mat2str(ita_vibro_getPosition()),handles);


% --- Executes on selection change in modeSelect.
function modeSelect_Callback(hObject, eventdata, handles)
% hObject    handle to modeSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(hObject,'Value');
handles.mode = handles.modesShort{index};
if index == 1
    handles = initialize(handles);
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function modeSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modeSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');

