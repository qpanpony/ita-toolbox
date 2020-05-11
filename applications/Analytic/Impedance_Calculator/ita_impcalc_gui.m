% Version von 27.01.2010

% <ITA-Toolbox>
% This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%%% VERSION LOG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 27.01.2010: Marc Aretz: Vollstaendiger Rewrite des Programmes


%% INITIALIZATION FUNCTIONS (DO NOT EDIT)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ita_impcalc_gui(varargin)
% ITA_IMPCALC_GUI M-file for ita_impcalc_gui.fig
%      ITA_IMPCALC_GUI, by itself, creates a new ITA_IMPCALC_GUI or raises the existing
%      singleton*.
%
%      H = ITA_IMPCALC_GUI returns the handle to a new ITA_IMPCALC_GUI or the handle to
%      the existing singleton*.
%
%      ITA_IMPCALC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITA_IMPCALC_GUI.M with the given input arguments.
%
%      ITA_IMPCALC_GUI('Property','Value',...) creates a new ITA_IMPCALC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ita_impcalc_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ita_impcalc_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ita_impcalc_gui

% Last Modified by GUIDE v2.5 23-Dec-2010 10:10:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ita_impcalc_gui_OpeningFcn, ...
    'gui_OutputFcn',  @ita_impcalc_gui_OutputFcn, ...
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
end %function

function ita_impcalc_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ita_impcalc_gui (see VARARGIN)

% Choose default command line output for ita_impcalc_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
end %function

function varargout = ita_impcalc_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end %function



%% CREATE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Funktion die beim starten des GUIs ausgefuehrt wird,
% Hier koennen Variablen initialisiert werden
function figure1_CreateFcn(hObject, eventdata, handles)

handles.matData = {};
handles.matDataPath = [];

guidata(hObject, handles);
end %function

% Alle folgenden Create Funktionen tun eigentlich nichts
function popup_schi_empmat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function popupmenu5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function popup_schi_klassmat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function popup_matlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function belagtype_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function lb_rf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function lb_erg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function lb_winkel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_txtname_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_sea_step_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_sea_winkel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_sea_von_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_sea_bis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_gewicht_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_res_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_res_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_qkz_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_verlust_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_dicke_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_dichte_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_emod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_vol_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_dicke_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_resistanz_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_raumgew_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_kap2_c_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_kap1_c_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_kap1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_kap2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_volpo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_b22_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_b11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_kappa_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_chi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_b21_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_b12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_schi_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_pla_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_fb_step_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_fb_unten_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_fb_oben_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_debug2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_debug_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_pla_abstand_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_pla_dicke_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_pla_breite_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_SampleRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_fftDegree_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_dia_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function

function ed_bel_perfratio_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %function



%% CALLBACK FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PUSHBUTTONS

% neuen Belag erzeugen
function pb_bel_neu_Callback(hObject, eventdata, handles)

newName = sprintf('Belag');
show_panel('belag', handles);

%LISTBOX UPDATEN
matListNames = get(handles.lb_rf, 'String');
nMats = length(matListNames);
matListNames{nMats+1} = newName;
set(handles.lb_rf, 'String', matListNames);
set(handles.lb_rf, 'Value', nMats+1);
curLBValue = nMats+1;

% neuen Belag in interner Materialdatenverwaltung mit Default-Werten anlegen
neuerBelag = belag(newName);
handles.matData{curLBValue} = neuerBelag;

updateValuesInBelagPanel(neuerBelag, handles.pb_bel_neu, handles);
handles = guidata(hObject);

guidata(hObject, handles);
end %function

% neue Schicht erzeugen
function pb_schi_neu_Callback(hObject, eventdata, handles)

newName = sprintf('Schicht');
show_panel('schicht', handles);

%LISTBOX UPDATEN
matListNames = get(handles.lb_rf, 'String');
nMats = length(matListNames);
matListNames{nMats+1} = newName;
set(handles.lb_rf, 'String', matListNames);
set(handles.lb_rf, 'Value', nMats+1);
curLBValue = nMats+1;

% neue Schicht in interner Materialdatenverwaltung anlegen
neueSchicht = schicht(newName);
handles.matData{curLBValue} = neueSchicht;

updateValuesInSchichtPanel(neueSchicht, handles.pb_schi_neu, handles);
handles = guidata(hObject);

guidata(hObject, handles);
end %function

% neue Lochplatte erzeugen
function pb_pla_neu_Callback(hObject, eventdata, handles)

newName = sprintf('Lochplatte');
show_panel('lochplatte',handles);   % richtiges panel aktivieren

%LISTBOX UPDATEN
matListNames = get(handles.lb_rf, 'String');
nMats = length(matListNames);
matListNames{nMats+1} = newName;
set(handles.lb_rf, 'String', matListNames);
set(handles.lb_rf, 'Value', nMats+1);
curLBValue = nMats+1;

% neue Schicht in interner Materialdatenverwaltung anlegen
neueLP = lochplatte(newName);
handles.matData{curLBValue} = neueLP;

updateValuesInLochplattePanel(neueLP, handles.pb_pla_neu, handles);
handles = guidata(hObject);

guidata(hObject, handles);
end %function

% Komponente nach unten
function pb_rf_down_Callback(hObject, eventdata, handles)

%LISTBOX und MaterialDatenListe holen
matListNames = get(handles.lb_rf, 'String');
matData = handles.matData;

if isempty(matListNames) || (length(matListNames)==1)
    % falls Liste leer oder nur ein Eintrag
    return;
end

% ausgewaehltes Material holen
curLBValue  = get(handles.lb_rf, 'Value');

if curLBValue == length(matListNames)
    % ausgewaehltes Material ist schon letztes in der Liste
    return;
end

% umsortieren in Listbox und in interner Datenverwaltung
matListNames = swapInCellArray(matListNames, curLBValue, curLBValue+1);
matData      = swapInCellArray(matData, curLBValue, curLBValue+1);

% update GUI and handles.matData
handles.matData = matData;
set(handles.lb_rf, 'String', matListNames);
set(handles.lb_rf, 'Value', curLBValue+1);
handles.matData = matData;

guidata(hObject,handles)
end %function

% Komponente nach oben
function pb_rf_up_Callback(hObject, eventdata, handles)

%LISTBOX und MaterialDatenListe holen
matListNames = get(handles.lb_rf, 'String');
matData = handles.matData;

if isempty(matListNames) || (length(matListNames)==1)
    % falls Liste leer oder nur ein Eintrag
    return;
end

% ausgewaehltes Material holen
curLBValue  = get(handles.lb_rf, 'Value');

if curLBValue == 1
    % ausgewaehltes Material ist schon das erste in der Liste
    return;
end

% umsortieren in Listbox und in interner Datenverwaltung
matListNames = swapInCellArray(matListNames, curLBValue-1, curLBValue);
matData      = swapInCellArray(matData, curLBValue-1, curLBValue);

% update GUI and handles.matData
set(handles.lb_rf, 'String', matListNames);
set(handles.lb_rf, 'Value', curLBValue-1);
handles.matData = matData;

guidata(hObject,handles)
end %function

% Komponente loeschen
function pb_rf_del_Callback(hObject, eventdata, handles)

%LISTBOX und MaterialDatenListe holen
matListNames = get(handles.lb_rf, 'String');
matData = handles.matData;

if isempty(matListNames)
    % falls Liste schon leer, nichts tun
    return;
end

% ausgewaehltes Material holen
curLBValue  = get(handles.lb_rf, 'Value');

matData = remove(matData, curLBValue);
matListNames(curLBValue) = [];

% update listbox and matData
set(handles.lb_rf, 'String', matListNames);
handles.matData = matData;

% move the highlighted item to an appropiate value
if curLBValue > 1
    set(handles.lb_rf,'Value',(curLBValue-1));
else
    set(handles.lb_rf,'Value',1);
end

% update appearance of materialdata panels according to current selection
% in listbox
lb_rf_Callback(handles.lb_rf, eventdata, handles);

guidata(hObject, handles);
end %function

% Laden einer Komponentenanordnung
function pb_load_Callback(hObject, eventdata, handles)

if isempty(handles.matDataPath)
    % Speicherziel festlegen
    [fileName,pathName,filterIndex] = uigetfile('*.mat','�ffnen...');
else
    [fileName,pathName,filterIndex] = uigetfile('*.mat','�ffnen...', handles.matDataPath);
end

if fileName == 0  %% falls abgebrochen wurde
    return
end
handles.matDataPath = pathName;

% Datei laden
load(fullfile(pathName, fileName));

% Datenstruktur wiederherstellen
handles.matData = saveIt.matData;

%  Reihenfolge ListBox wiederherstellen
set(handles.lb_rf, 'String', saveIt.rf_name_cell);
set(handles.lb_rf, 'Value',saveIt.rf_value);

% Schalleinfall und Frequenzen wiederherstellen
set(handles.ed_sea_winkel ,'String', saveIt.sea.winkel);
set(handles.ed_sea_bis    ,'String', saveIt.sea.bis);
set(handles.ed_sea_step   ,'String', saveIt.sea.step);
set(handles.ed_fb_unten   ,'String', saveIt.fb.unten);
set(handles.ed_fb_oben    ,'String', saveIt.fb.oben );
set(handles.ed_fb_step    ,'String', saveIt.fb.step);

if saveIt.sea.senk
    set(handles.rb_sea_senk,'Value',1);
else
    set(handles.rb_sea_diff,'Value',1);
end

if saveIt.fb.lin
    set(handles.rb_fb_lin,'Value',1);
else
    set(handles.rb_fb_log,'Value',1);
end

% abschlussArt wiederherstellen
set(handles.rb_ab_hart,   'Value', saveIt.abschluss_hart);
set(handles.rb_ab_frei,   'Value', saveIt.abschluss_frei);
set(handles.rb_ab_vakuum, 'Value', saveIt.abschluss_vakuum);

uipanel_schalleinfall_SelectionChangeFcn(handles.uipanel_schalleinfall, eventdata, handles);
uipanel_freq_bereich_SelectionChangeFcn(handles.uipanel_freq_bereich, eventdata, handles);

% update appearance of materialdata panels according to current selection
% in listbox
lb_rf_Callback(handles.lb_rf, eventdata, handles);

guidata(hObject, handles);
end %function

% Speichern einer Komponentenanordnung
function pb_save_Callback(hObject, eventdata, handles)

if isempty(handles.matDataPath)
    % Speicherziel festlegen
    [fileName,pathName,filterIndex] = uiputfile('*.mat','Speichern...');
else
    [fileName,pathName,filterIndex] = uiputfile('*.mat','Speichern...', handles.matDataPath);
end

if fileName == 0  %% falls abgebrochen wurde
    return
end
handles.matDataPath = pathName;

% Reihenfolde ListBox speichern
saveIt.rf_name_cell = get(handles.lb_rf, 'String');
saveIt.rf_value = get(handles.lb_rf, 'Value');

% Restlichen Parameter speichern
saveIt.sea.winkel = getValue(handles.ed_sea_winkel);
saveIt.sea.bis = getValue(handles.ed_sea_bis);
saveIt.sea.step = getValue(handles.ed_sea_step);
saveIt.sea.senk = get(handles.rb_sea_senk,'Value');

saveIt.fb.unten = getValue(handles.ed_fb_unten);
saveIt.fb.oben = getValue(handles.ed_fb_oben);
saveIt.fb.step = getValue(handles.ed_fb_step);
saveIt.fb.lin = get(handles.rb_fb_lin,'Value');
saveIt.abschluss_hart = get(handles.rb_ab_hart, 'Value');
saveIt.abschluss_frei = get(handles.rb_ab_frei, 'Value');
saveIt.abschluss_vakuum = get(handles.rb_ab_vakuum, 'Value');

saveIt.matData = handles.matData;
saveas = fullfile(pathName,fileName);
save(saveas, 'saveIt');
guidata(hObject, handles);
end %function

% Plausibilitaetstests und Berechnung starten
function pb_run_Callback(hObject, eventdata, handles)

%LISTBOX und MaterialDatenListe holen
matListNames = get(handles.lb_rf, 'String');
matData = handles.matData;
nMats = length(matData);

% Pruefen ob wenigstens eine Komponente definiert ist, sonst error
if isempty(matListNames)
    errordlg('Bitte erst die Komponenten definieren!','Fehler');
    return;
end

% Abschluss & Modus speichern
abschlussArt = [ get(handles.rb_ab_hart, 'Value'), get(handles.rb_ab_frei, 'Value'), get(handles.rb_ab_vakuum, 'Value')] * [0;1;2];
diffusEinfall = (get(handles.rb_sea_diff, 'Value'));
matrixModus = get(handles.rb_ber_mat, 'Value');
vorAbschluss = matData{end};

% Matrixmodus und gleichzeitig diffuser Schall abfangen
if (matrixModus && diffusEinfall)
    errordlg('Im Matrixmodus bitte einen bestimmten Winkel w�hlen!','Fehler');
    return;
end

% PLAUSIBILITAETSCHECKS FUER MATERIALIENREIHENFOLGE UND ABSCHLUSS

% CHECK I
% Restriktionen fuer unterschiedliche Abschluss-Bedingungen
if ~matrixModus   % falls nicht Matrix modus gewaehlt wurde
    if abschlussArt == 0 % schallharter Abschluss
        if isa(vorAbschluss,'lochplatte') %Lochplatte
            errordlg('Es muss mindestens eine Schicht zwischen Lochplatte und schallhartem Abschluss definiert sein.','Fehler');
            return
        elseif isa(vorAbschluss,'belag') %Belag
            errordlg('Belag am Ende der Anordnung vor schallhartem Abschluss ist irrelevant. (Berechnung wird fortgesetzt)','Warnung');
        end
    elseif abschlussArt == 2 % Vakuum
        if isa(vorAbschluss,'schicht') % Schicht
            errordlg('Poroese Schicht vor Vakuum nicht moeglich. Abschlussbedingung Vakuum nur fuer luftundurchlaessigen Belag am Ende des geschichteten Absorbers zulaessig.','Fehler');
            return
        elseif isa(vorAbschluss,'lochplatte') %Lochplatte
            errordlg('Lochplatte vor Vakuum nicht moeglich. Abschlussbedingung Vakuum nur fuer luftundurchlaessigen Belag am Ende des geschichteten Absorbers zulaessig.','Fehler');
            return
        end
    end
end

% CHECK II
% Es ist nicht moeglich, dass zwei Lochplatten ohne eine (existierende)
% dazwischenliegende Schicht (d.h. Schicht_Dicke > 0) aufeinanderfolgen
if nMats > 1
    %Suche Lochplatten
    isLP = false(1,nMats);
    for k=1:nMats
        if isa(matData{k},'lochplatte')
            isLP(k) = true;
        end
    end
    
    % nachsehen, ob zwei Lochplatten direkt hintereinander
    for k = 1:nMats-1
        if isLP(k) && isLP(k+1)
            errordlg('Es ist nicht moeglich, dass zwei Lochplatten ohne eine (existierende) dazwischenliegende Schicht aufeinanderfolgen.','Fehler');
            return
        end
    end
end

% CHECK III
% Ist ein Belag vor oder hinter einer Lochplatte definiert, so muss
% dieser eine definierte Stroemungsresistanz haben
if nMats > 1
    %Suche Lochplatten
    isLP = false(1,nMats);
    isB  = false(1,nMats);
    for k=1:nMats
        if isa(matData{k},'lochplatte')
            isLP(k) = true;
        elseif isa(matData{k},'belag')
            isB(k) = true;
        end
    end
    
    % nachsehen, ob Lochplatten und Belag direkt hintereinander
    for k = 1:nMats-1
        if (isLP(k) && isB(k+1)) && (matData{k+1}.belagsTyp~=2)
            errordlg('Ist ein Belag vor oder hinter einer Lochplatte definiert, so muss dieser eine definierte Stroemungsresistanz haben','Fehler');
            return;
        elseif (isLP(k+1) && isB(k)) && (matData{k}.belagsTyp~=2)
            errordlg('Ist ein Belag vor oder hinter einer Lochplatte definiert, so muss dieser eine definierte Stroemungsresistanz haben','Fehler');
            return;
        end
    end
end

% CHECK IV
% Ist eine Lochplatte beidseitig von Belaegen umgeben, so muessen beide
% Belaege eine definierte Stroemungsresistanz haben
if nMats > 2
    %Suche Lochplatten
    isLP = false(1,nMats);
    isB  = false(1,nMats);
    for k=1:nMats
        if isa(matData{k},'lochplatte')
            isLP(k) = true;
        elseif isa(matData{k},'belag')
            isB(k) = true;
        end
    end
    
    % nachsehen, ob Lochplatte mit Belag davor UND dahinter
    for k = 2:nMats-1
        if (isB(k-1) && isLP(k) && isB(k+1)) && ( (matData{k-1}.belagsTyp~=2) || (matData{k+1}.belagsTyp~=2) )
            errordlg('Ist eine Lochplatte beidseitig von Belaegen umgeben, so muessen beide Belaege eine definierte Stroemungsresistanz haben.','Fehler');
            return;
        end
    end
end

% EINZELNE MATERIALIEN AUF VOLLSTAENDIGKEIT PR�FEN:

for k = 1:nMats
    check = [];
    switch class(matData{k})
        case 'belag'
            switch matData{k}.belagsTyp
                case 1 % Massenbelag (luftundurchlaessig)
                    check(1) = isnumeric([matData{k}.dicke, matData{k}.dichte, matData{k}.verlustFaktor]);
                    check(2) = all([matData{k}.dicke, matData{k}.dichte]  > 0);
                    check(3) = matData{k}.verlustFaktor >= 0;
                case 2 % Massenbelag (luftdurchlaessig)
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.dichte ...
                        matData{k}.stroemungsResistanz ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.dichte, ...
                        matData{k}.stroemungsResistanz ]  > 0);
                case 3 % Platte
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.dichte ...
                        matData{k}.eModul, ...
                        matData{k}.querKontraktionsZahl, ...
                        matData{k}.verlustFaktor ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.dichte, ...
                        matData{k}.eModul, ...
                        matData{k}.querKontraktionsZahl ]  > 0);
                    check(3) = matData{k}.verlustFaktor >= 0;
                    check(4) = matData{k}.querKontraktionsZahl < 1;
                case 4 % MPP (mit Plattenparametern)
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.dichte ...
                        matData{k}.eModul, ...
                        matData{k}.querKontraktionsZahl, ...
                        matData{k}.verlustFaktor, ...
                        matData{k}.lochDurchmesser, ...
                        matData{k}.perforationsRatio ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.dichte, ...
                        matData{k}.eModul, ...
                        matData{k}.verlustFaktor, ...
                        matData{k}.querKontraktionsZahl, ...
                        matData{k}.lochDurchmesser, ...
                        matData{k}.perforationsRatio ]  > 0);
                    check(3) = matData{k}.perforationsRatio < 1;
                case 5 % MPP (ohne Plattenparameter)
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.dichte ...
                        matData{k}.lochDurchmesser, ...
                        matData{k}.perforationsRatio ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.dichte, ...
                        matData{k}.lochDurchmesser, ...
                        matData{k}.perforationsRatio ]  > 0);
                    check(3) = matData{k}.perforationsRatio < 1;
            end
            if ~all(check)
                errordlg(['Fuer den Belag "' matData{k}.name ...
                    '" sind nicht alle notwendigen Eingangsparameter gueltig definiert. ' ...
                    'Bitte ueberpruefen Sie Ihre Eingaben.!'], 'Fehler');
                return;
            end
        case 'schicht'
            switch matData{k}.schichtModell
                case 1 % Luftschicht
                    check(1) = isnumeric(matData{k}.dicke);
                    check(2) = all([matData{k}.dicke] > 0);
                case 2 % Por. Abs. nach klassischer Theorie
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz, ...
                        matData{k}.raumGewicht, ...
                        matData{k}.porositaet, ...
                        matData{k}.strukturFaktor, ...
                        matData{k}.adiabatenKoeff ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz, ...
                        matData{k}.raumGewicht, ...
                        matData{k}.porositaet, ...
                        matData{k}.strukturFaktor, ...
                        matData{k}.adiabatenKoeff ] > 0);
                    check(3) = (matData{k}.porositaet >= 0.95) && (matData{k}.porositaet <= 1);
                    check(4) = (matData{k}.adiabatenKoeff >= 1) && (matData{k}.adiabatenKoeff <= 1.4);
                case 3 % Por. Abs. nach empirischer Kennwertrelation
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz ] > 0);
                case 4 % Por. Abs. nach Komatsu Modell
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz ] > 0);
            end
            if ~all(check)
                errordlg(['Fuer die Schicht "' matData{k}.name ...
                    '" sind nicht alle notwendigen Eingangsparameter g�ltig definiert. ' ...
                    'Bitte ueberpruefen Sie Ihre Eingaben.!'], 'Fehler');
                return;
            end
        case 'lochplatte'
            % Bedingungen, die fuer alle Schichten erf�llt sein muessen
            check(1) = isnumeric( [matData{k}.dicke, ...
                matData{k}.lochSchlitzAbmessung, ...
                matData{k}.lochSchlitzAbstand] );
            check(2) = all([ matData{k}.dicke, ...
                matData{k}.lochSchlitzAbmessung, ...
                matData{k}.lochSchlitzAbstand ] > 0);
            if ~all(check)
                errordlg(['Fuer die Lochplatte "' matData{k}.name ...
                    '" sind nicht alle notwendigen Eingangsparameter gueltig definiert. ' ...
                    'Bitte ueberpruefen Sie Ihre Eingaben.!'], 'Fehler');
                return;
            end
    end
end

% ERZEUGE JEWEILS EINEN DUMMY FUER BELAG, SCHICHT UND LOCHPLATTE

dummy_belag      = belag('dummy belag');
dummy_lochplatte = lochplatte('dummy lochplatte');
dummy_schicht    = schicht('dummy schicht');


% LAGEN FESTLEGEN UND PSEUDO SCHICHTEN, BEL�GE UND LOCHPLATTEN EINFUEGEN
% jede Lage besteht aus einem Belag(B), einer Lochplatte(L) und einer Schicht(S).
%
% Typenliste erstellen
for k=1:nMats
    switch class(matData{k})
        case 'belag'
            typListe(k) = 'B';
        case 'lochplatte'
            typListe(k) = 'L';
        case 'schicht'
            typListe(k) = 'S';
    end
end

% Speicher fuer Lagen struct allozieren
Lagen = cell(nMats,3); % die Anzahl der Lagen ist apriori nicht bekannt, aber maximal gleich nMats

curLage = 1;
k = 1;
% Immer Dreierpakete holen, und Lagen erstellen
while k <= nMats
    
    if k==nMats % nur noch ein Mat uebrig
        
        % das letzte verbliebene Material muss in eine eigene Lage
        switch typListe(k) % letztes Mat holen
            case 'B'
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = dummy_schicht;
                k=k+1;
            case 'L'
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = dummy_schicht;
                k=k+1;
            case 'S'
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k};
                k=k+1;
        end
        
    elseif (k+1)==nMats % nur noch zwei Mats uebrig
        
        switch typListe(k:k+1) % letzten 2 Mats holen
            case {'SB','SL','SS'} % die Schicht wird in eine Lage gepackt, das 2te (und letzte) Mat wird erst in der naechsten Lage eingefuegt
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k};
                k=k+1;
            case 'BB' % der Belag wird in eine Lage gepackt, der 2te (und letzte) Belag wird erst in der naechsten Lage eingefuegt
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = dummy_schicht;
                k=k+1;
            case 'BL' % Belag und Lochplatte werden in die letzte Lage gepackt
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = matData{k+1};
                Lagen{curLage,3} = dummy_schicht;
                k=k+2;
            case 'BS' % Belag und Schicht werden in die letzte Lage gepackt
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k+1};
                k=k+2;
            case 'LB' % Lochplatte und Belag werden in die letzte Lage gepackt
                matData{k}.side = 1; % B ist hinter L
                Lagen{curLage,1} = matData{k+1};
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = dummy_schicht;
                k=k+2;
            case 'LL' % 2 Lochplatten hintereinander nicht moeglich => error
                errordlg('2 Lochplatten direkt hintereinander sind nicht moeglich!','Fehler');
                return;
            case 'LS' % Lochplatte und Schicht werden in die letzte Lage gepackt
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = matData{k+1};
                k=k+2;
        end
        
    elseif (k+1)<nMats % ganzes Dreierpaket holen
        
        switch typListe(k:k+2) % volles Dreierpaket holen
            case {'SSS','SSB','SSL','SBS','SBB','SBL','SLS','SLB'} % vordere Schicht in Lage, die anderen 2 Mats sp�ter behandeln
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k};
                k=k+1;
            case {'SLL','BLL','LLS','LLB','LLL'} % 2 Lochplatten hintereinander nicht moeglich => error
                errordlg('2 Lochplatten direkt hintereinander sind nicht moeglich!','Fehler');
                return;
            case {'BSS','BSB','BSL'} % Belag und Schicht in Lage, drittes Mat spaeter
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k+1};
                k=k+2;
            case {'BBS','BBB','BBL'} % Belag in Lage, die anderen beiden Mats spaeter
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = dummy_schicht;
                k=k+1;
            case {'LSS','LSB','LSL'} % Lochplatte und Schicht in Lage, das dritte Mat spaeter
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = matData{k+1};
                k=k+2;
            case {'LBB','LBL'} % Lochplatte und Belag in Lage, drittes Mat spaeter
                matData{k}.side = 1; % B ist hinter L
                Lagen{curLage,1} = matData{k+1};
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = dummy_schicht;
                k=k+2;
            case 'BLS' % alle drei Mats in Lage
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = matData{k+1};
                Lagen{curLage,3} = matData{k+2};
                k=k+3;
            case 'BLB' % Belag und Lochplatte in Lage, drittes Mat spaeter
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = matData{k+1};
                Lagen{curLage,3} = dummy_schicht;
                k=k+2;
            case 'LBS' % alle drei Mats in Lage
                matData{k}.side = 1; % B ist hinter L
                Lagen{curLage,1} = matData{k+1};
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = matData{k+2};
                k=k+3;
        end
        
    end
    curLage = curLage+1;
end
anzahlLagen = curLage-1;

% Anzahl Lagen nun bekannt -> umspeichern
Lagen = Lagen(1:anzahlLagen,:);

% Alle Daten der Absorberkonfiguration in struct speichern
saveIt.rf_name_cell = get(handles.lb_rf, 'String');
saveIt.rf_value = get(handles.lb_rf, 'Value');

% Restlichen Parameter speichern
saveIt.sea.winkel = getValue(handles.ed_sea_winkel);
saveIt.sea.bis = getValue(handles.ed_sea_bis);
saveIt.sea.step = getValue(handles.ed_sea_step);
saveIt.sea.senk = get(handles.rb_sea_senk,'Value');

saveIt.fb.unten = getValue(handles.ed_fb_unten);
saveIt.fb.oben = getValue(handles.ed_fb_oben);
saveIt.fb.step = getValue(handles.ed_fb_step);
saveIt.fb.lin = get(handles.rb_fb_lin,'Value');
saveIt.abschluss_hart = get(handles.rb_ab_hart, 'Value');
saveIt.abschluss_frei = get(handles.rb_ab_frei, 'Value');
saveIt.abschluss_vakuum = get(handles.rb_ab_vakuum, 'Value');

saveIt.matData = handles.matData;

% Funktion Impedanz aufrufen
erg=Impedanz(saveIt, matrixModus, Lagen, anzahlLagen, abschlussArt);
%Umbennenen der Ergebnisse
handles.erg=erg;

% Eingabepanel ausblenden
set(handles.uipanel_freq_bereich, 'Visible', 'Off');
set(handles.uipanel_schalleinfall, 'Visible', 'Off');
set(handles.uipanel_berechnung, 'Visible', 'Off');
set(handles.uipanel_rf, 'Visible', 'Off');
show_panel('none',handles);

% Ergebnispanel einblenden, aber Achsen ausblenden
set(handles.ui_cont, 'Visible', 'Off');
cla(handles.ax_erg_real, 'reset');
set(handles.ax_erg_real, 'Visible', 'Off');
cla(handles.ax_erg_cmplx_1, 'reset');
set(handles.ax_erg_cmplx_1, 'Visible', 'Off');
cla(handles.ax_erg_cmplx_2, 'reset');
set(handles.ax_erg_cmplx_2, 'Visible', 'Off');

% Auswahlmoeglichkeiten fuer Ergebnisse festlegen
if matrixModus    % Matrix Modus
    str = {'a11';'a12';'a21';'a22'; 'y11'; 'y12'; 'y21'; 'y22'; 'z11'; 'z12'; 'z21'; 'z22'; };
else                    % Impedanzmodus
    str= {'Z';'Y';'R';'alpha'; 'tau'};
end
set(handles.lb_erg, 'String', str);

% Save Panel anpassen
if matrixModus
    set(handles.uip_ergchannels_matrixmodus, 'Visible', 'On');
    set(handles.uip_ergchannels_impmodus, 'Visible', 'Off');
else
    set(handles.uip_ergchannels_matrixmodus, 'Visible', 'Off');
    set(handles.uip_ergchannels_impmodus, 'Visible', 'On');
end

set(handles.panel_ergebnisse, 'Visible', 'On');
set(handles.uipanel_saveerg, 'Visible', 'On'); % Speicher-Panel anzeigen

guidata(hObject, handles);
end %function

% Figure mit Plot erzeugen
function pb_plot_Callback(hObject, eventdata, handles)
showPlot(handles, 'EXTERN');
guidata(hObject, handles);

end %function

% Zurueck zur Eingabe
function pb_back_Callback(hObject, eventdata, handles)
% eingabepanel ausblenden; ergebnis panel einblenden
set(handles.uipanel_freq_bereich, 'Visible', 'On');
set(handles.uipanel_schalleinfall, 'Visible', 'On');
set(handles.uipanel_berechnung, 'Visible', 'On');
set(handles.uipanel_rf, 'Visible', 'On');
set(handles.panel_ergebnisse, 'Visible', 'Off');
set(handles.uipanel_saveerg, 'Visible', 'Off');

set(handles.lb_erg, 'Value',1);
guidata(hObject, handles);
end %function

%  als .ita speichern
function pb_ita_save_Callback(hObject, eventdata, handles)
itaSave(hObject, handles, 'ita');
guidata(hObject, handles);
end %function

%  in den Workspace schreiben
function pb_ws_save_Callback(hObject, eventdata, handles)
itaSave(hObject, handles, 'ws');
guidata(hObject, handles);
end %function

%% TXT EDITS

% Schalleinfallswinkel
function ed_sea_winkel_Callback(hObject, eventdata, handles)
winkel_check(handles)
end %function

function ed_sea_von_Callback(hObject, eventdata, handles)
winkel_check(handles)
end %function

function ed_sea_bis_Callback(hObject, eventdata, handles)
winkel_check(handles)
end %function

function ed_sea_step_Callback(hObject, eventdata, handles)
end %function

% Frequenzbereich
function ed_fb_unten_Callback(hObject, eventdata, handles)
end %function

function ed_fb_oben_Callback(hObject, eventdata, handles)
end %function

function ed_fb_step_Callback(hObject, eventdata, handles)
end %function

% Belaege
function ed_bel_name_Callback(hObject, eventdata, handles)
newName = get(hObject, 'String');

%LISTBOX UPDATEN
matListNames = get(handles.lb_rf, 'String');
curLBValue  = get(handles.lb_rf, 'Value');

matListNames{curLBValue} = newName;
set(handles.lb_rf, 'String', matListNames);

% Namen in interner Materialdatenverwaltung aktualisieren
handles.matData{curLBValue}.name = newName;
guidata(hObject, handles)
end %function

function ed_bel_dicke_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.dicke = (getValue(hObject))/1000; % mm -> m
guidata(hObject, handles);
end %function

function ed_bel_res_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.stroemungsResistanz = (getValue(hObject))*1000; % kPas/m^2 -> Pas/m^2
guidata(hObject, handles);
end %function

function ed_bel_verlust_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.verlustFaktor = getValue(hObject);
guidata(hObject, handles);
end %function

function ed_bel_qkz_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.querKontraktionsZahl = getValue(hObject);
guidata(hObject, handles);
end %function

function ed_bel_dichte_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.dichte = getValue(hObject);
guidata(hObject, handles);
end %function

function ed_bel_emod_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.eModul = (getValue(hObject))*1e6;  % N/mm^2 -> N/m^2
guidata(hObject, handles);
end %function

function ed_bel_dia_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.lochDurchmesser = (getValue(hObject))/1000; % mm -> m
guidata(hObject, handles);
end %function

function ed_bel_perfratio_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.perforationsRatio = getValue(hObject);
guidata(hObject, handles);
end %function

% Schichten
function ed_schi_name_Callback(hObject, eventdata, handles)
newName = get(hObject, 'String');

%LISTBOX UPDATEN
matListNames = get(handles.lb_rf, 'String');
curLBValue  = get(handles.lb_rf, 'Value');

matListNames{curLBValue} = newName;
set(handles.lb_rf, 'String', matListNames);

% Namen in interner Materialdatenverwaltung aktualisieren
handles.matData{curLBValue}.name = newName;
guidata(hObject, handles)
end %function

function ed_schi_dicke_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.dicke = (getValue(hObject))/1000; % mm -> m
guidata(hObject, handles);
end %function

function ed_schi_res_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.stroemungsResistanz = (getValue(hObject))*1000; % kPas/m^2 -> Pas/m^2

% Falls es sich um einen por. Abs. nach klassischer Theorie handelt muss
% gegebenenfalls das Raumgewicht aus der Stroemungsresistanz berechnet
% werden.
if handles.matData{curPos}.schichtModell == 2
    auswahlMat = handles.matData{curPos}.klassMat;
    if ( auswahlMat ~= 1 ) % falls nicht selbstdef. Material
        handles.matData{curPos} = handles.matData{curPos}.calcDensityFromResistivity();
        % update edit box
        set(handles.ed_schi_gewicht,'String', handles.matData{curPos}.raumGewicht);
    end
end
guidata(hObject, handles);
end %function

function ed_schi_gewicht_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.raumGewicht = getValue(hObject);

% Falls es sich um einen por. Abs. nach klassischer Theorie handelt muss
% gegebenenfalls das Raumgewicht aus der Stroemungsresistanz berechnet
% werden.
if handles.matData{curPos}.schichtModell == 2
    auswahlMat = handles.matData{curPos}.klassMat;
    if ( auswahlMat ~= 1 ) % falls nicht selbstdef. Material
        handles.matData{curPos} = handles.matData{curPos}.calcResistivityFromDensity();
        % update edit box
        set(handles.ed_schi_res,'String', handles.matData{curPos}.stroemungsResistanz/1000);
    end
end
guidata(hObject, handles);
end %function

function ed_schi_volpo_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

value = getValue(hObject);
if value <= 1 && value >= 0.95
    % Wert in interner Materialdatenverwaltung uebernehmen
    handles.matData{curPos}.porositaet = value;
elseif value <= 1 && value >= 0 && get(handles.popup_matlist,'Value')== 7
    handles.matData{curPos}.porositaet = value;
else
    set(hObject, 'String', '0.97');
    handles.matData{curPos}.porositaet = 0.97;
    errordlg('Bitte eine Volumenporoesitaet zwischen 0.95 und 1 angeben','Fehler');
end
guidata(hObject, handles);
end %function

function ed_schi_chi_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.strukturFaktor = getValue(hObject);
guidata(hObject, handles);
end %function

function ed_schi_kappa_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

value = getValue(hObject);
if value <= 1.4 && value >= 1
    % Wert in interner Materialdatenverwaltung uebernehmen
    handles.matData{curPos}.adiabatenKoeff = value;
else
    set(hObject, 'String', '1');
    handles.matData{curPos}.adiabatenKoeff = 1;
    errordlg('Bitte einen effektiven Adiabatenkoeffizient zwischen 1 und 1.4 angeben','Fehler');
end
guidata(hObject, handles);
end %function

function ed_schi_b11_Callback(hObject, eventdata, handles)
% Felder sind nur zur Anzeige, nicht manipulierbar
end %function

function ed_schi_b12_Callback(hObject, eventdata, handles)
% Felder sind nur zur Anzeige, nicht manipulierbar
end %function

function ed_schi_b21_Callback(hObject, eventdata, handles)
% Felder sind nur zur Anzeige, nicht manipulierbar
end %function

function ed_schi_b22_Callback(hObject, eventdata, handles)
% Felder sind nur zur Anzeige, nicht manipulierbar
end %function

function ed_schi_kap1_Callback(hObject, eventdata, handles)
% Felder sind nur zur Anzeige, nicht manipulierbar
end %function

function ed_schi_kap2_Callback(hObject, eventdata, handles)
% Felder sind nur zur Anzeige, nicht manipulierbar
end %function

function ed_schi_kap1_c_Callback(hObject, eventdata, handles)
% Felder sind nur zur Anzeige, nicht manipulierbar
end %function

function ed_schi_kap2_c_Callback(hObject, eventdata, handles)
% Felder sind nur zur Anzeige, nicht manipulierbar
end %function

% Platten
function ed_pla_name_Callback(hObject, eventdata, handles)
newName = get(hObject, 'String');

%LISTBOX UPDATEN
matListNames = get(handles.lb_rf, 'String');
curLBValue  = get(handles.lb_rf, 'Value');

matListNames{curLBValue} = newName;
set(handles.lb_rf, 'String', matListNames);

% Namen in interner Materialdatenverwaltung aktualisieren
handles.matData{curLBValue}.name = newName;
guidata(hObject, handles)
end %function

function ed_pla_dicke_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.dicke = (getValue(hObject))/1000; % mm -> m
guidata(hObject, handles);
end %function

function ed_pla_breite_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.lochSchlitzAbmessung = (getValue(hObject))/1000; % mm -> m;
guidata(hObject, handles);
end %function

function ed_pla_abstand_Callback(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
handles.matData{curPos}.lochSchlitzAbstand = (getValue(hObject))/1000; % mm -> m
guidata(hObject, handles);
end %function

% Edit ITA_Header_Info
function ed_SampleRate_Callback(hObject, eventdata, handles)

sR = str2double(get(hObject, 'String'));
if ~(isnumeric(sR) && isfinite(sR) && sR>0)
    set(hObject, 'String', '');
else
    set(hObject, 'String', num2str(round(sR)));
end

guidata(hObject, handles);

end %function

function ed_fftDegree_Callback(hObject, eventdata, handles)

fftDegree = str2double(get(hObject, 'String'));
if ~(isnumeric(fftDegree) && isfinite(fftDegree) && fftDegree>0)
    set(hObject, 'String', '');
else
    set(hObject, 'String', num2str(round(fftDegree)));
end

guidata(hObject, handles);

end %function

%% UIPANEL SELECTION CHANGE FUNCTIONS

% FREQUENZBEREICH LIN / LOG GEAENDERT
function uipanel_freq_bereich_SelectionChangeFcn(hObject, eventdata, handles)
if get(handles.rb_fb_lin,'Value')
    set(handles.text68, 'String','Hz     ');
else
    set(handles.text68, 'String','Oktave');
end
guidata(hObject, handles);
end %function

% SCHALLEINFALL (passt das GUI abhaengig von Einfallart an)
function uipanel_schalleinfall_SelectionChangeFcn(hObject, eventdata, handles)
grey = ones(1,3)*0.5;

if(get(handles.rb_sea_senk, 'Value'))           % falls  Einfall unter bestimmten Winkel
    set(handles.ed_sea_winkel, 'Enable','On');
    set(handles.text37, 'ForegroundColor', 'black');
    
    set(handles.ed_sea_von, 'Enable','Off');
    set(handles.ed_sea_bis, 'Enable','Off');
    set(handles.ed_sea_step, 'Enable','Off');
    
    set(handles.t_sea_1, 'ForegroundColor', grey)
    set(handles.t_sea_2, 'ForegroundColor', grey)
    set(handles.t_sea_3, 'ForegroundColor', grey)
    set(handles.t_sea_4, 'ForegroundColor', grey)
    set(handles.t_sea_5, 'ForegroundColor', grey)
    set(handles.t_sea_6, 'ForegroundColor', grey)
    
    ed_sea_winkel_Callback(handles.ed_sea_winkel, eventdata, handles);
    
    
else                                            %  diffuser Schalleinfall
    set(handles.ed_sea_von, 'Enable','Off');
    set(handles.ed_sea_bis, 'Enable','On');
    set(handles.ed_sea_step, 'Enable','On');
    set(handles.t_sea_1, 'ForegroundColor', 'black')
    set(handles.t_sea_2, 'ForegroundColor', 'black')
    set(handles.t_sea_3, 'ForegroundColor', 'black')
    set(handles.t_sea_4, 'ForegroundColor', 'black')
    set(handles.t_sea_5, 'ForegroundColor', 'black')
    set(handles.t_sea_6, 'ForegroundColor', 'black')
    
    set(handles.ed_sea_winkel, 'Enable','Off');
    set(handles.text37, 'ForegroundColor', grey);
    ed_sea_von_Callback(handles.ed_sea_von, eventdata, handles);
    ed_sea_bis_Callback(handles.ed_sea_bis, eventdata, handles);
end
guidata(hObject, handles);
end %function

% Falls "lateral / lokal" geaendert wurde
function uipanel_lokal_lateral_SelectionChangeFcn(hObject, eventdata, handles)
% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

% Wert in interner Materialdatenverwaltung uebernehmen
if get(handles.rb_schi_lat,'Value')
    handles.matData{curPos}.ausbreitungsArt = 1; % lateral
else
    handles.matData{curPos}.ausbreitungsArt = 0; % lokal
end
guidata(hObject, handles);
end %function

% Umschalten zwischen LOCH / SCHLITZ Platten
function uipanel_platten_SelectionChangeFcn(hObject, eventdata, handles)

% akutelle Position holen
curPos  = get(handles.lb_rf, 'Value');

handles.matData{curPos}.lochTyp = get(handles.rb_pla_loch,'Value');

% txt Felder anpassen (Loch bzw. Schlitz)
updateValuesInLochplattePanel(handles.matData{curPos}, handles.rb_pla_loch, handles)
handles = guidata(hObject);

guidata(hObject, handles);
end %function

% Art des Plots auswaehlen
function ui_cont_SelectionChangeFcn(hObject, eventdata, handles)
if get(handles.rb_cont_norm, 'Value')                   % NORM
    set(handles.lb_winkel, 'Enable', 'On');
    set(handles.lb_winkel, 'Value', 1);
    plot(0,0);
elseif get(handles.rb_cont_cont, 'Value')               % CONT PLOT
    set(handles.lb_winkel, 'Enable', 'Off');
elseif get(handles.rb_cont_diff, 'Value')               % DIFF
    set(handles.lb_winkel, 'Enable', 'Off');
end
showPlot(handles, 'VORSCHAU');
guidata(hObject, handles);
end %function

function uip_result_format_SelectionChangeFcn(hObject, eventdata, handles)
end %function

%% CHECKBOXES

% Checkboxen fuer Ergebnis plot
function cb_kettenmatrix_Callback(hObject, eventdata, handles)

end %function

function cb_admittanzmatrix_Callback(hObject, eventdata, handles)

end %function

function cb_impedanzmatrix_Callback(hObject, eventdata, handles)

end %function

function cb_impedanz_Callback(hObject, eventdata, handles)

end %function

function cb_admittanz_Callback(hObject, eventdata, handles)

end %function

function cb_reflexionsfaktor_Callback(hObject, eventdata, handles)

end %function

function cb_absorption_Callback(hObject, eventdata, handles)

end %function

%% POPUP MENUS

% �ndert Felder auf  UI Panel jenachdem ob Massen-Belag oder MPP Absorber
function belagtype_popup_Callback(hObject, eventdata, handles)

curLBValue = get(handles.lb_rf,'Value');
handles.matData{curLBValue}.belagsTyp = get(hObject, 'Value');

% reset Belag parameters that are not used depending on type:
switch get(hObject, 'Value')
    case 1 % Belag (luftdicht)
        handles.matData{curLBValue}.stroemungsResistanz = 0;
        handles.matData{curLBValue}.eModul = 0;
        handles.matData{curLBValue}.querKontraktionsZahl = 0;
        handles.matData{curLBValue}.lochDurchmesser = 0;
        handles.matData{curLBValue}.perforationsRatio = 0;
    case 2 % Belag (luftdurchlaessig)
        handles.matData{curLBValue}.eModul = 0;
        handles.matData{curLBValue}.querKontraktionsZahl = 0;
        handles.matData{curLBValue}.verlustFaktor = 0;
        handles.matData{curLBValue}.lochDurchmesser = 0;
        handles.matData{curLBValue}.perforationsRatio = 0;
    case 3 % Platte
        handles.matData{curLBValue}.stroemungsResistanz = 0;
        handles.matData{curLBValue}.lochDurchmesser = 0;
        handles.matData{curLBValue}.perforationsRatio = 0;
    case 4 % MPP (mit Plattenparametern)
        handles.matData{curLBValue}.stroemungsResistanz = 0;
    case 5 % MPP (ohne Plattenparameter)
        handles.matData{curLBValue}.stroemungsResistanz = 0;
        handles.matData{curLBValue}.eModul = 0;
        handles.matData{curLBValue}.querKontraktionsZahl = 0;
        handles.matData{curLBValue}.verlustFaktor = 0;
end

updateValuesInBelagPanel(handles.matData{curLBValue}, handles.belagtype_popup, handles);

guidata(hObject,handles);
end %function

% Reaktion auf Auswahl der ART DER SCHICHT ( Luft | Klassisch | Empirisch | Komatsu | DelanyBazley | Miki )
function popup_matlist_Callback(hObject, eventdata, handles)

% update internal data
curLBValue = get(handles.lb_rf,'Value');
handles.matData{curLBValue}.schichtModell = get(hObject, 'Value');

% Werte in interner Datenverwaltung auf default zuruecksetzen
handles.matData{curLBValue}.klassMat            = 1;
handles.matData{curLBValue}.empiricalMat        = 1;
handles.matData{curLBValue}.stroemungsResistanz = 0;
handles.matData{curLBValue}.raumGewicht         = 0;
handles.matData{curLBValue}.porositaet          = 0;
handles.matData{curLBValue}.strukturFaktor      = 1;
handles.matData{curLBValue}.adiabatenKoeff      = 1;

% GUI anpassen
updateValuesInSchichtPanel(handles.matData{curLBValue}, hObject, handles);

guidata(hObject,handles);
end %function

% Funktion wird aufgerufen bei Auswahl des Materials bei KLASSISCHER Theorie
function popup_schi_klassmat_Callback(hObject, eventdata, handles)
% update internal data
curLBValue = get(handles.lb_rf,'Value');
handles.matData{curLBValue}.klassMat = get(hObject, 'Value');

% reset Raumgewicht before setting it again
handles.matData{curLBValue}.raumGewicht = 0;
set(handles.ed_schi_gewicht     ,'String', '');

% set new Raumgewicht according to selected Material
ed_schi_res_Callback(handles.ed_schi_res, eventdata, handles);
handles = guidata(hObject);

guidata(hObject, handles);
end %function

% Funktion wird aufgerufen bei Auswahl des Materials bei EMPIRISCHER Theorie
function popup_schi_empmat_Callback(hObject, eventdata, handles)

% update internal data
auswahl = get(hObject,'Value');
curLBValue = get(handles.lb_rf,'Value');
handles.matData{curLBValue}.empiricalMat = auswahl;

updateValuesInSchichtPanel(handles.matData{curLBValue}, handles.popup_schi_empmat, handles)

guidata(hObject, handles);
end %function

%% LISTBOXES

% Komponente auswaehlen
function lb_rf_Callback(hObject, eventdata, handles)

matListNames = get(hObject, 'String');
if isempty(matListNames)
    % falls Liste leer, alle Panel ausblenden
    show_panel('none', handles);
    return;
end

% get internal data for displaying
curMat = handles.matData{get(hObject,'Value')};

if isa(curMat, 'belag')            % BELAG
    show_panel('belag', handles);
    updateValuesInBelagPanel(curMat, handles.lb_rf, handles);
elseif isa(curMat, 'schicht')      % SCHICHT
    show_panel('schicht', handles);
    updateValuesInSchichtPanel(curMat, handles.lb_rf, handles);
    
elseif isa(curMat, 'lochplatte')   % PLATTE
    show_panel('lochplatte', handles);
    updateValuesInLochplattePanel(curMat, handles.lb_rf, handles);
else
    error('All materials have to belong to the classes belag, schicht or lochplatte!');
end

guidata(hObject, handles);

end %function

% Winkel auswaehlen
function lb_winkel_Callback(hObject, eventdata, handles)
showPlot(handles, 'VORSCHAU');
guidata(hObject, handles);
end %function

% Ergebnisvariable auswaehlen
function lb_erg_Callback(hObject, eventdata, handles)
auswahl = get(hObject, 'Value');

if handles.erg.modus == 0                   % IMPEDANZ-MODUS
    if length(handles.erg.theta) == 1       % nur ein winkel
        set(handles.rb_cont_norm, 'Value', 1);
        set(handles.rb_cont_diff, 'Value', 0);
        set(handles.rb_cont_cont, 'Value', 0);
        set(handles.ui_cont, 'Visible', 'Off');
        showPlot(handles, 'VORSCHAU');
        
    else                                   % mehrere Winkel
        set(handles.ui_cont, 'Visible', 'On');
        set(handles.rb_cont_norm, 'Value', 1);
        set(handles.rb_cont_diff, 'Value', 0);
        set(handles.rb_cont_cont, 'Value', 0);
        set(handles.lb_winkel, 'String', handles.erg.theta);
        set(handles.lb_winkel, 'Enable', 'On');
        set(handles.lb_winkel, 'Value', 1);
        switch auswahl
            case 1
                set(handles.rb_cont_cont,'Enable','Off');
                set(handles.rb_cont_diff,'Enable','On');
                set(handles.rb_cont_diff, 'String', 'Z_diff');
            case 2
                set(handles.rb_cont_cont,'Enable','Off');
                set(handles.rb_cont_diff,'Enable','On');
                set(handles.rb_cont_diff, 'String', 'A_diff');
            case 3
                set(handles.rb_cont_cont,'Enable','Off');
                set(handles.rb_cont_diff,'Enable','Off');
                set(handles.rb_cont_diff, 'String', 'R_diff');
            case 4
                set(handles.rb_cont_cont,'Enable','On');
                set(handles.rb_cont_diff,'Enable','On');
                set(handles.rb_cont_diff, 'String', 'alpha_diff');
            case 5
                set(handles.rb_cont_cont,'Enable','On');
                set(handles.rb_cont_diff,'Enable','On');
                set(handles.rb_cont_diff, 'String', 'tau_diff');
            otherwise
                set(handles.rb_cont_cont,'Enable','Off');
                set(handles.rb_cont_diff, 'Enable', 'Off');
        end
    end
else                                        % MATRIX-MODUS / immer nur ein winkel
    set(handles.ui_cont, 'Visible', 'Off');
end
showPlot(handles, 'VORSCHAU');
guidata(hObject, handles);
end %function



%% AUXILIARY FUNCTIONS

% SHOW PANEL (Blendet ein Panel ein (Schicht, Belag oder Lochplatte))
function show_panel(name, handles)
switch name
    case 'belag'
        set(handles.uipanel_schicht, 'Visible','Off');
        set(handles.uipanel_platten, 'Visible','Off');
        set(handles.uipanel_belag, 'Visible','On');
    case 'schicht'
        set(handles.uipanel_belag, 'Visible','Off');
        set(handles.uipanel_platten, 'Visible','Off');
        set(handles.uipanel_schicht, 'Visible','On');
    case 'lochplatte'
        set(handles.uipanel_schicht, 'Visible','Off');
        set(handles.uipanel_belag, 'Visible','Off');
        set(handles.uipanel_platten, 'Visible','On');
    case 'none'
        set(handles.uipanel_schicht, 'Visible','Off');
        set(handles.uipanel_platten, 'Visible','Off');
        set(handles.uipanel_belag,   'Visible','Off');
end
end %function

% Hauptplotfunktion
function showPlot(handles, AxesToPlot)
% AxesToPlot = 'EXTERN' || 'VORSCHAU'
auswahl = get(handles.lb_erg, 'Value');

% WOHING GEPLOTTET WERDEN SOLL
if isequal(AxesToPlot,'EXTERN') % in ein eigenes Fenster plotten
    scrsz = get(0,'ScreenSize');
    h_fig = figure('Position',[1 1 scrsz(3) scrsz(4)]);
    h_ax_cmplx_1 = axes('Position',[0.07 0.15 0.4 0.75]);
    h_ax_cmplx_2 = axes('Position',[0.57 0.15 0.4 0.75]);
    h_ax_real    = axes('Position',[0.1 0.17 0.83 0.75]);
else
    h_fig = gcf;
    h_ax_cmplx_1 = handles.ax_erg_cmplx_1;
    h_ax_cmplx_2 = handles.ax_erg_cmplx_2;
    h_ax_real    = handles.ax_erg_real;
    
    ita_pref = ita_preferences();
    
    ita_preferences('itamenu',0);
    ita_preferences('plotcursors',0);
    ita_preferences('legend',0);
    ita_preferences('fontsize',10);
    ita_preferences('linewidth',1);
    ita_preferences('toolboxlogo',0);
end

resetAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2)

if length(handles.erg.theta) == 1
    auswahlWinkelNummer = 1;
else
    auswahlWinkelNummer = get(handles.lb_winkel, 'Value');
end

freqs = handles.erg.f;

if handles.erg.modus == 0                          % IMPEDANZMODUS
    
    if get(handles.rb_cont_norm, 'Value')           % normaler plot
        switch auswahl
            case 1                         % Z
                data = handles.erg.Z(:,auswahlWinkelNummer);
                data2Plot = itaResult(data, freqs, 'freq')/414;
                ita_plot_cmplx(data2Plot,'figure_handle',h_fig,'axes_handle',[h_ax_cmplx_1, h_ax_cmplx_2],'nodb')
                ylabel(h_ax_cmplx_1, 'Z/Z_0 - real part');
                ylabel(h_ax_cmplx_2, 'Z/Z_0 - imaginary part');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'cmplx');
            case 2                         % Y
                data = handles.erg.Y(:,auswahlWinkelNummer);
                data2Plot = itaResult(data, freqs, 'freq')*414;
                ita_plot_cmplx(data2Plot,'figure_handle',h_fig,'axes_handle',[h_ax_cmplx_1, h_ax_cmplx_2],'nodb')
                ylabel(h_ax_cmplx_1, 'Y/Y_0 - real part');
                ylabel(h_ax_cmplx_2, 'Y/Y_0 - imaginary part');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'cmplx');
            case 3                     % R
                data = handles.erg.R(:,auswahlWinkelNummer);
                data2Plot   = itaResult(data, freqs, 'freq');
                ita_plot_freq_phase( data2Plot, 'figure_handle', h_fig, 'axes_handle', [h_ax_cmplx_1, h_ax_cmplx_2], 'nodB', 'ylim', [0 1]  );
                title(h_ax_cmplx_2, '');
                ylabel(h_ax_cmplx_1, 'Reflection Factor - magnitude');
                ylabel(h_ax_cmplx_2, 'Reflection Factor - phase');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'cmplx');
            case 4                     % ALPHA
                data = handles.erg.alpha(:,auswahlWinkelNummer);
                data2Plot = itaResult(data, freqs, 'freq');
                ita_plot_freq( data2Plot, 'figure_handle', h_fig, 'axes_handle', h_ax_real, 'nodB', 'ylim', [0 1] );
                ylabel(h_ax_real, 'Absorption');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'real');
            case 5                     % TAU
                data = handles.erg.tau(:,auswahlWinkelNummer);
                data2Plot = itaResult(data, freqs, 'freq');
                ita_plot_freq( data2Plot, 'figure_handle', h_fig, 'axes_handle', h_ax_real, 'nodB', 'ylim', [0 1] );
                ylabel(h_ax_real, 'Transmission Coefficient');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'real');
        end
        
    elseif get(handles.rb_cont_diff, 'Value')       %diff plotten
        switch auswahl
            case 1                         % Z
                data = handles.erg.Z_diff;
                data2Plot = itaResult(data, freqs, 'freq')/414;
                ita_plot_cmplx(data2Plot,'figure_handle',h_fig,'axes_handle',[h_ax_cmplx_1, h_ax_cmplx_2],'nodb')
                ylabel(h_ax_cmplx_1, 'Z/Z_0 - diffuse incidence - real part');
                ylabel(h_ax_cmplx_2, 'Z/Z_0 - diffuse incidence - imaginary part');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'cmplx');
            case 2                         % Y
                data = handles.erg.Y_diff;
                data2Plot = itaResult(data, freqs, 'freq')*414;
                ita_plot_cmplx(data2Plot,'figure_handle',h_fig,'axes_handle',[h_ax_cmplx_1, h_ax_cmplx_2],'nodb')
                ylabel(h_ax_cmplx_1, 'Y/Y_0 - diffuse incidence - real part');
                ylabel(h_ax_cmplx_2, 'Y/Y_0 - diffuse incidence - imaginary part');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'cmplx');
            case 3                     % R
                data = handles.erg.R_diff;
                data2Plot   = itaResult(data, freqs, 'freq');
                ita_plot_freq_phase( data2Plot, 'figure_handle', h_fig, 'axes_handle', [h_ax_cmplx_1, h_ax_cmplx_2], 'nodB', 'ylim', [0 1]  );
                ylabel(h_ax_cmplx_1, 'Reflection Factor - diffuse incidence - magnitude');
                ylabel(h_ax_cmplx_2, 'Reflection Factor - diffuse incidence - phase');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'cmplx');
            case 4                     % ALPHA
                data = handles.erg.alpha_diff;
                data2Plot = itaResult(data, freqs, 'freq');
                ita_plot_freq( data2Plot, 'figure_handle', h_fig, 'axes_handle', h_ax_real, 'nodB', 'ylim', [0 1]   );
                ylabel(h_ax_real, 'Absorption - diffuse incidence');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'real');
            case 5                     % TAU
                data = handles.erg.tau_diff;
                data2Plot = itaResult(data, freqs, 'freq');
                ita_plot_freq( data2Plot, 'figure_handle', h_fig, 'axes_handle', h_ax_real, 'nodB', 'ylim', [0 1]   );
                ylabel(h_ax_real, 'Transmission Coefficient - diffuse incidence');
                setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'real');
        end
        
    elseif get(handles.rb_cont_cont, 'Value')           % CONTOUR plot
        [f_grid, theta_grid] = meshgrid(handles.erg.f, handles.erg.theta);
        conlist = [0.2 0.4 0.6 0.7 0.8 0.85 0.9 0.95 0.98];
        [xtick,xtickLabels] = ita_plottools_ticks('log');
        switch auswahl
            case 4
                plotData = handles.erg.alpha;
            case 5
                plotData = handles.erg.tau;
        end
        [C,h] = contourf(h_ax_real, f_grid.', theta_grid.', plotData, conlist);
        clabel(C,h, conlist);
        set(h_ax_real,...
            'XTick',xtick,...
            'XTickLabel',xtickLabels,...
            'XGrid','on',...
            'XScale','log',...
            'YTickLabel',{'0','16','32','48','64','80','88'},...
            'YTick',[0 16 32 48 64 80 88],...
            'YGrid','on');
        setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'real');
        
    end
    
else  % KETTENPARAMETER MODUS
    switch auswahl
        case 1                      % A 11
            data = handles.erg.a11;
            yLab = 'Kettenmatrix-Parameter a_{11}';
        case  2                     % A 12
            data = handles.erg.a12;
            yLab = 'Kettenmatrix-Parameter a_{12}';
        case 3                     % A 21
            data = handles.erg.a21;
            yLab = 'Kettenmatrix-Parameter a_{21}';
        case 4                     % A 22
            data = handles.erg.a22;
            yLab = 'Kettenmatrix-Parameter a_{22}';
        case 5
            data = handles.erg.y11;
            yLab = 'Admittanzmatrix-Parameter y_{11}';
        case 6
            data = handles.erg.y12;
            yLab = 'Admittanzmatrix-Parameter y_{12}';
        case 7
            data = handles.erg.y21;
            yLab = 'Admittanzmatrix-Parameter y_{21}';
        case 8
            data = handles.erg.y22;
            yLab = 'Admittanzmatrix-Parameter y_{22}';
        case 9
            data = handles.erg.z11;
            yLab = 'Impedanzmatrix-Parameter z_{11}';
        case 10
            data = handles.erg.z12;
            yLab = 'Impedanzmatrix-Parameter z_{12}';
        case 11
            data = handles.erg.z21;
            yLab = 'Impedanzmatrix-Parameter z_{21}';
        case 12
            data = handles.erg.z22;
            yLab = 'Impedanzmatrix-Parameter z_{22}';
    end
    data2Plot   = itaResult(data, freqs, 'freq');
    ita_plot_freq( data2Plot, 'figure_handle', h_fig, 'axes_handle', h_ax_cmplx_1 );
    ita_plot_phase( data2Plot, 'figure_handle', h_fig, 'axes_handle', h_ax_cmplx_2 );
    ylabel(h_ax_cmplx_1, [yLab, ' - magnitude']);
    ylabel(h_ax_cmplx_2, [yLab, ' - phase']);
    setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, 'cmplx');
end

if isequal(AxesToPlot,'VORSCHAU')
    set(gcf, 'Name', 'ita_impcalc_gui');
    ita_preferences('itamenu',ita_pref.itamenu);
    ita_preferences('plotcursors',ita_pref.plotcursors);
    ita_preferences('legend',ita_pref.legend);
    ita_preferences('fontsize',ita_pref.fontsize);
    ita_preferences('linewidth',ita_pref.linewidth);
    ita_preferences('toolboxlogo',ita_pref.toolboxlogo);
end


end %function

function [] = setAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2, type)

switch type
    case 'cmplx'
        set(h_ax_real, 'Visible', 'Off');
        set(h_ax_cmplx_1, 'Visible', 'On');
        set(h_ax_cmplx_2, 'Visible', 'On');
    case 'real'
        set(h_ax_real, 'Visible', 'On');
        set(h_ax_cmplx_1, 'Visible', 'Off');
        set(h_ax_cmplx_2, 'Visible', 'Off');
end

end %function

function [] = resetAxesDisplay(h_ax_real, h_ax_cmplx_1, h_ax_cmplx_2)

cla(h_ax_real, 'reset');
set(h_ax_real, 'Visible', 'Off');
cla(h_ax_cmplx_1, 'reset');
set(h_ax_cmplx_1, 'Visible', 'Off');
cla(h_ax_cmplx_2, 'reset');
set(h_ax_cmplx_2, 'Visible', 'Off');

end %function

% Prueft ob Winkel gueltig und zeigt ggf. Warnung an
function winkel_check(handles)
winkel = str2double(get(handles.ed_sea_winkel, 'String'));
von = str2double(get(handles.ed_sea_von, 'String'));
bis = str2double(get(handles.ed_sea_bis, 'String'));

if get(handles.rb_sea_diff,'Value')   % diffuser schalleinfall
    if (von > 90 || von < 0)
        set(handles.err_winkelbereich, 'Visible', 'On');
    elseif (bis > 90 || bis < 0)
        set(handles.err_winkelbereich, 'Visible', 'On');
    else
        set(handles.err_winkelbereich, 'Visible', 'Off');
    end
else
    if (winkel > 90 || winkel < 0)
        set(handles.err_winkelbereich, 'Visible', 'On');
    else
        set(handles.err_winkelbereich, 'Visible', 'Off');
    end
end
end %function

% Zum Auswerten der Eingaben der Edit Felder
function value = getValue(hObject)
%Funktion um auch das Eingeben von Zahlen mit Komma oder Bruchstrich zu ermoeglichen
str = get(hObject,'String');

if strcmp(str,'')
    value = 0;
else
    str = strrep(str, ',', '.');
    str = strrep(str, '/', ' / ');
    
    auswertung = sscanf(str, '%f %s %d', [1, inf]);
    
    if size(auswertung) == [1,1]
        value = auswertung;
        return
    elseif size(auswertung) == [1,3]
        if auswertung(2) == '/'
            value = auswertung(1) / auswertung(3);
        end
    else
        errordlg('Wert kann nicht eingelesen werden','Fehler');
    end
end
end %function

% Compose comment for txt-file and header in ITA data-struct
function comment = composeheadercomment(handles)

matListNames = get(handles.lb_rf, 'String');
nMats = length(matListNames);

cl = clock;
comment = '';
comment = [ comment, sprintf( 'Datum: %02i.%02i.%04i %02i:%02i Uhr. Anzahl der Komponenten: %i  \n\n', cl(3), cl(2), cl(1), cl(4), cl(5), nMats) ];
% winkel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if get(handles.rb_sea_senk, 'Value')
    comment = [ comment, sprintf( 'Schalleinfall unter einem Winkel von %i°.\n',getValue(handles.ed_sea_winkel)) ];
else
    comment = [ comment, sprintf( 'Diffuser Schalleinfall gemittelt von 0° bis %i° in Schritten von %i°.\n', getValue(handles.ed_sea_bis), getValue(handles.ed_sea_step) ) ];
end
% frequenz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if get(handles.rb_fb_log, 'Value')
    comment = [ comment, sprintf( 'Frequenzbereich von %i Hz bis %i Hz - logarithmisch unterteilt mit einer Schrittweite von %f Oktaven.\n',getValue(handles.ed_fb_unten), getValue(handles.ed_fb_oben), getValue(handles.ed_fb_step)) ];
else
    comment = [ comment, sprintf( 'Frequenzbereich von %i Hz bis %i Hz - linear unterteilt mit einer Schrittweite von %i Hz. \n',getValue(handles.ed_fb_unten), getValue(handles.ed_fb_oben), getValue(handles.ed_fb_step)) ];
end
% abschluss %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
abschluss = find( [get(handles.rb_ab_hart,'Value'), get(handles.rb_ab_vakuum,'Value'), get(handles.rb_ab_frei,'Value')] == 1);
abschltxt = {'Der Abschluss ist SCHALLHART.\n\n', 'Der Abschluss ist VAKUUM.\n\n', 'Der Abschluss ist FREIFELD.\n\n'};
comment = [ comment, sprintf(abschltxt{abschluss}) ];
% komponenten %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
comment = [ comment, sprintf('KOMPONENTEN:\n') ];
for i=1:nMats
    comment = [ comment, sprintf('\n%02i.) ',i) ];
    comment = [ comment, sprintf('Name: %s\n', handles.matData{i}.name) ];
    comment = [ comment, sprintf('Materialparameter: ') ];
    switch class(handles.matData{i})
        case 'belag'           % BELAG
            switch handles.matData{i}.belagsTyp
                case 1 % Massenbelag (luftdicht)
                    comment = [comment, sprintf('Massenbelag (luftdicht): Dicke: %8.4f mm    Dichte: %8.4e kg/m^3 \n', ...
                        handles.matData{i}.dicke*1000, handles.matData{i}.dichte ) ];
                case 2 % Massenbelag (luftdurchl�ssig)
                    comment = [comment, sprintf('Massenbelag (luftdurchlaessig): Dicke: %8.4f mm    Dichte: %8.4e kg/m^3    Str�mungsres.: %8.4e kPa s/m^2\n', ...
                        handles.matData{i}.dicke*1000, handles.matData{i}.dichte, handles.matData{i}.stroemungsResistanz/1000 ) ];
                case 3 % Platte
                    comment = [comment, sprintf('Platte: Dicke: %8.4f mm    Dichte: %8.4e kg/m^3    EModul: %8.4e N/mm^2    Querkontraktionszahl: %8.4e    Verlustfaktor: %1.4f \n', ...
                        handles.matData{i}.dicke*1000, handles.matData{i}.dichte, handles.matData{i}.eModul/1e6, handles.matData{i}.querKontraktionsZahl, handles.matData{i}.verlustFaktor ) ];
                case 4 % MPP mit Plattenparameter
                    comment = [comment, sprintf('MPP (mit Plattenparametern): Dicke: %8.4f mm    Dichte: %8.4e kg/m^3    EModul: %8.4e N/mm^2    Querkontraktion: %8.4e    Verlustfaktor: %1.4f    Lochdurchmesser: 8.4f mm    Perforationsratio: 8.4f\n', ...
                        handles.matData{i}.dicke*1000, handles.matData{i}.dichte, handles.matData{i}.eModul/1e6, handles.matData{i}.querKontraktionsZahl, handles.matData{i}.verlustFaktor, handles.matData{i}.lochDurchmesser*1000, handles.matData{i}.perforationsRatio ) ];
                case 5 % MPP ohne Plattenparametern
                    comment = [comment, sprintf('MPP (ohne Plattenparametern): Dicke: %8.4f mm Dichte: %8.4e kg/m^3 Lochdurchmesser: 8.4f mm Perforationsratio: 8.4f\n', ...
                        handles.matData{i}.dicke*1000, handles.matData{i}.dichte, handles.matData{i}.lochDurchmesser*1000, handles.matData{i}.perforationsRatio) ];
            end
        case 'schicht'           % SCHICHT
            if handles.matData{i}.ausbreitungsArt == 1 % laterale Schicht
                textcell1 = 'lateral';
            else
                textcell1 = 'lokal';
            end
            textcell2 = get(handles.popup_schi_klassmat, 'String');
            textcell3 = get(handles.popup_schi_empmat, 'String');
            switch handles.matData{i}.schichtModell
                case 1       % LUFT
                    comment = [ comment, sprintf('Luftschicht (%s reagierend):    Dicke: %8.4f mm \n', textcell1, handles.matData{i}.dicke*1000 ) ];
                case 2       % Klassisch
                    comment = [ comment, sprintf( 'Por. Abs. nach klassischer Theorie (%s reagierend):    Material: %s    Dicke: %8.4f mm    Str�mungsres.:  %8.4e kPa s/m^2    Por�sit�t: %1.4f    Raumgewicht: %8.4e kg/m^3    Strukturfaktor: %8.4e    Adiabatenkoeffizient: %8.4e\n', ...
                        textcell1, textcell2{handles.matData{i}.klassMat}, handles.matData{i}.dicke*1000, handles.matData{i}.stroemungsResistanz/1000, handles.matData{i}.porositaet, ...
                        handles.matData{i}.raumGewicht, handles.matData{i}.strukturFaktor, handles.matData{i}.adiabatenKoeff ) ];
                case 3       % empirisch
                    comment = [ comment, sprintf( 'Por. Abs. nach empirischer Kennwertrelation (%s reagierend):    Material: %s    Dicke: %8.4f mm    Str�mungsres.:  %8.4e kPa s/m^2    Poroesitaet: %1.4f\n', ...
                        textcell1, textcell3{handles.matData{i}.empiricalMat}, handles.matData{i}.dicke*1000, handles.matData{i}.stroemungsResistanz/1000, handles.matData{i}.porositaet ) ];
                case 4       % Komatsu
                    comment = [ comment, sprintf('Por. Abs. nach Komatsu-Modell (%s reagierend):    Dicke: %8.4f mm    Stroemungsres.:  %8.4e kPa s/m^2\n', ...
                        textcell1, handles.matData{i}.dicke*1000, handles.matData{i}.stroemungsResistanz/1000) ];
            end
        case 'lochplatte'           % LOCHPLATTE
            if handles.matData{i}.lochTyp == 1 % Lochplatte
                textcell1 = 'Kreis-Lochplatte';
            else
                textcell1 = 'Schlitz-Lochplatte';
            end
            comment = [ comment, sprintf( 'Typ: %s    Dicke: %8.4f mm    Loch/Schlitz-Abmessung: %8.4f mm    Loch/Schlitz-Abstand: %8.4f mm\n', ...
                textcell1, handles.matData{i}.dicke*1000, handles.matData{i}.lochSchlitzAbmessung*1000, handles.matData{i}.lochSchlitzAbstand*1000 ) ];
    end
end

end %function

% interpolate modelling data and set data to zero outside of modeling range
function [interpData] = interp_zeroextrap(freq, data, newFreq, modus)

if (size(data,1)==1) || (size(data,2)==1)
    % Make sure all vectors are row vectors
    freqHelp(1,:)    = freq;
    dataHelp(1,:)    = data;
    newFreqHelp(1,:) = newFreq;
    freq             = freqHelp;
    data             = dataHelp;
    newFreq          = newFreqHelp;
    
    lenF             = length(freq);
    lenNF            = length(newFreq);
    idxS             = 1;
    idxE             = lenNF;
    interpData       = zeros(1, lenNF);
    
    % Append zeros where impedance data is not available
    while newFreq(idxS) < min(freq)
        idxS = idxS+1;
    end
    while newFreq(idxE) > max(freq)
        idxE = idxE-1;
    end
    interpData(idxS:idxE) = interp1(freq, data, newFreq(idxS:idxE), modus);
else
    error('FUNCTION:INTERP_ZEROEXTRAP: Invalid first input argument.');
end
end %function

% Eintr�ge in Cell Array vertauschen
function newCellList = swapInCellArray(cellList, idx1, idx2)

newCellList = cellList;
newCellList{idx1} = cellList{idx2};
newCellList{idx2} = cellList{idx1};

end %function

function newMatData = remove(matData, idx)

newMatData = matData;
newMatData(idx) = [];

end %function

function updateValuesInBelagPanel(aktBel, hObject, handles)

set(handles.ed_bel_name, 'String', aktBel.name);
set(handles.belagtype_popup, 'Value', aktBel.belagsTyp);
if aktBel.belagsTyp == 1 % Massenbelag (luftdicht)
    set(handles.textEMod,           'ForegroundColor', [.5 .5 .5]);
    set(handles.textEModUnit,       'ForegroundColor', [.5 .5 .5]);
    set(handles.textQKZ,            'ForegroundColor', [.5 .5 .5]);
    set(handles.textVerlust,        'ForegroundColor', 'black');
    set(handles.textLochDiaB,        'ForegroundColor', [.5 .5 .5]);
    set(handles.textPerfRatio,      'ForegroundColor', [.5 .5 .5]);
    set(handles.textLochDiaUnit,    'ForegroundColor', [.5 .5 .5]);
    set(handles.textStrResBel,      'ForegroundColor', [0.5 0.5 0.5]);
    set(handles.textStrResBelUnit,  'ForegroundColor', [0.5 0.5 0.5]);
    set(handles.ed_bel_dia,         'Enable', 'Off');
    set(handles.ed_bel_perfratio,   'Enable', 'Off');
    set(handles.ed_bel_emod,        'Enable', 'Off');
    set(handles.ed_bel_qkz,         'Enable', 'Off');
    set(handles.ed_bel_verlust,     'Enable', 'On');
    set(handles.ed_bel_res,         'Enable', 'Off');
    set(handles.ed_bel_dia,         'String', '');
    set(handles.ed_bel_perfratio,   'String', '');
    set(handles.ed_bel_emod,        'String', '');
    set(handles.ed_bel_qkz,         'String', '');
    set(handles.ed_bel_verlust,     'String', '');
    set(handles.ed_bel_res,         'String', '');
    
    if aktBel.dicke > 0
        set(handles.ed_bel_dicke,       'String', aktBel.dicke*1000);
        set(handles.ed_bel_dichte,      'String', aktBel.dichte);
        set(handles.ed_bel_verlust,     'String', aktBel.verlustFaktor);
    else
        set(handles.ed_bel_dicke,       'String', '');
        set(handles.ed_bel_dichte,      'String', '');
        set(handles.ed_bel_verlust,     'String', '');
    end
    
elseif aktBel.belagsTyp == 2 % Massenbelag (luftdurchl�ssig)
    set(handles.textEMod,           'ForegroundColor', [.5 .5 .5]);
    set(handles.textEModUnit,       'ForegroundColor', [.5 .5 .5]);
    set(handles.textQKZ,            'ForegroundColor', [.5 .5 .5]);
    set(handles.textVerlust,        'ForegroundColor', [.5 .5 .5]);
    set(handles.textLochDiaB,        'ForegroundColor', [.5 .5 .5]);
    set(handles.textPerfRatio,      'ForegroundColor', [.5 .5 .5]);
    set(handles.textLochDiaUnit,    'ForegroundColor', [.5 .5 .5]);
    set(handles.textStrResBel,      'ForegroundColor', 'black');
    set(handles.textStrResBelUnit,  'ForegroundColor', 'black');
    set(handles.ed_bel_emod,        'Enable', 'Off');
    set(handles.ed_bel_qkz,         'Enable', 'Off');
    set(handles.ed_bel_verlust,     'Enable', 'Off');
    set(handles.ed_bel_dia,         'Enable', 'Off');
    set(handles.ed_bel_perfratio,   'Enable', 'Off');
    set(handles.ed_bel_res,         'Enable', 'On');
    set(handles.ed_bel_emod,        'String', '');
    set(handles.ed_bel_qkz,         'String', '');
    set(handles.ed_bel_verlust,     'String', '');
    set(handles.ed_bel_dia,         'String', '');
    set(handles.ed_bel_perfratio,   'String', '');
    
    if aktBel.dicke > 0
        set(handles.ed_bel_dicke,   'String', aktBel.dicke*1000);
        set(handles.ed_bel_dichte,  'String', aktBel.dichte);
        if (aktBel.stroemungsResistanz>0)
            set(handles.ed_bel_res,     'String', aktBel.stroemungsResistanz/1000);
        else
            set(handles.ed_bel_res,     'String', '');
        end
    else
        set(handles.ed_bel_dicke,   'String', '');
        set(handles.ed_bel_dichte,  'String', '');
        set(handles.ed_bel_res,     'String', '');
    end
    
elseif aktBel.belagsTyp == 3 % Platte
    set(handles.textEMod,           'ForegroundColor', 'black');
    set(handles.textEModUnit,       'ForegroundColor', 'black');
    set(handles.textQKZ,            'ForegroundColor', 'black');
    set(handles.textVerlust,        'ForegroundColor', 'black');
    set(handles.textLochDiaB,       'ForegroundColor', [.5 .5 .5]);
    set(handles.textPerfRatio,      'ForegroundColor', [.5 .5 .5]);
    set(handles.textLochDiaUnit,    'ForegroundColor', [.5 .5 .5]);
    set(handles.textStrResBel,      'ForegroundColor', [.5 .5 .5]);
    set(handles.textStrResBelUnit,  'ForegroundColor', [.5 .5 .5]);
    set(handles.ed_bel_emod,        'Enable', 'On');
    set(handles.ed_bel_qkz,         'Enable', 'On');
    set(handles.ed_bel_verlust,     'Enable', 'On');
    set(handles.ed_bel_dia,         'Enable', 'Off');
    set(handles.ed_bel_perfratio,   'Enable', 'Off');
    set(handles.ed_bel_res,         'Enable', 'Off');
    set(handles.ed_bel_dia,         'String', '');
    set(handles.ed_bel_perfratio,   'String', '');
    set(handles.ed_bel_res,         'String', '');
    
    if aktBel.dicke > 0
        set(handles.ed_bel_dicke,   'String', aktBel.dicke*1000);
        set(handles.ed_bel_dichte,  'String', aktBel.dichte);
        set(handles.ed_bel_emod,    'String', aktBel.eModul/1e6);
        set(handles.ed_bel_qkz,     'String', aktBel.querKontraktionsZahl);
        set(handles.ed_bel_verlust, 'String', aktBel.verlustFaktor);
    else
        set(handles.ed_bel_dicke,   'String', '');
        set(handles.ed_bel_dichte,  'String', '');
        set(handles.ed_bel_res,     'String', '');
        set(handles.ed_bel_emod,    'String', '');
        set(handles.ed_bel_qkz,     'String', '');
        set(handles.ed_bel_verlust, 'String', '');
    end
    
elseif aktBel.belagsTyp == 4 % MPP (mit Plattenparametern)
    set(handles.textEMod,           'ForegroundColor', 'black');
    set(handles.textEModUnit,       'ForegroundColor', 'black');
    set(handles.textQKZ,            'ForegroundColor', 'black');
    set(handles.textVerlust,        'ForegroundColor', 'black');
    set(handles.textLochDiaB,       'ForegroundColor', 'black');
    set(handles.textPerfRatio,      'ForegroundColor', 'black');
    set(handles.textLochDiaUnit,    'ForegroundColor', 'black');
    set(handles.textStrResBel,      'ForegroundColor', [.5 .5 .5]);
    set(handles.textStrResBelUnit,  'ForegroundColor', [.5 .5 .5]);
    set(handles.ed_bel_emod,        'Enable', 'On');
    set(handles.ed_bel_qkz,         'Enable', 'On');
    set(handles.ed_bel_verlust,     'Enable', 'On');
    set(handles.ed_bel_dia,         'Enable', 'On');
    set(handles.ed_bel_perfratio,   'Enable', 'On');
    set(handles.ed_bel_res,         'Enable', 'Off');
    set(handles.ed_bel_res,         'String', '');
    
    if aktBel.dicke > 0
        set(handles.ed_bel_dicke,   'String', aktBel.dicke*1000);
        set(handles.ed_bel_dichte,  'String', aktBel.dichte);
        set(handles.ed_bel_emod,    'String', aktBel.eModul/1e6);
        set(handles.ed_bel_qkz,     'String', aktBel.querKontraktionsZahl);
        set(handles.ed_bel_verlust, 'String', aktBel.verlustFaktor);
        set(handles.ed_bel_dia,      'String', aktBel.lochDurchmesser*1000);
        set(handles.ed_bel_perfratio,'String', aktBel.perforationsRatio);
    else
        set(handles.ed_bel_dicke,   'String', '');
        set(handles.ed_bel_dichte,  'String', '');
        set(handles.ed_bel_emod,    'String', '');
        set(handles.ed_bel_qkz,     'String', '');
        set(handles.ed_bel_verlust, 'String', '');
        set(handles.ed_bel_dia,      'String', '');
        set(handles.ed_bel_perfratio,'String', '');
    end
    
elseif aktBel.belagsTyp == 5 % MPP (ohne Plattenparameter)
    set(handles.textEMod,           'ForegroundColor', 'black');
    set(handles.textEModUnit,       'ForegroundColor', 'black');
    set(handles.textQKZ,            'ForegroundColor', 'black');
    set(handles.textVerlust,        'ForegroundColor', 'black');
    set(handles.textLochDiaB,       'ForegroundColor', 'black');
    set(handles.textPerfRatio,      'ForegroundColor', 'black');
    set(handles.textLochDiaUnit,    'ForegroundColor', 'black');
    set(handles.textStrResBel,      'ForegroundColor', [.5 .5 .5]);
    set(handles.textStrResBelUnit,  'ForegroundColor', [.5 .5 .5]);
    set(handles.ed_bel_emod,        'Enable', 'Off');
    set(handles.ed_bel_qkz,         'Enable', 'Off');
    set(handles.ed_bel_verlust,     'Enable', 'Off');
    set(handles.ed_bel_dia,         'Enable', 'On');
    set(handles.ed_bel_perfratio,   'Enable', 'On');
    set(handles.ed_bel_res,         'Enable', 'Off');
    set(handles.ed_bel_res,         'String', '');
    set(handles.ed_bel_emod,        'String', '');
    set(handles.ed_bel_qkz,         'String', '');
    set(handles.ed_bel_verlust,     'String', '');
    
    if aktBel.dicke > 0
        set(handles.ed_bel_dicke,   'String', aktBel.dicke*1000);
        set(handles.ed_bel_dichte,  'String', aktBel.dichte);
        set(handles.ed_bel_dia,      'String', aktBel.lochDurchmesser*1000);
        set(handles.ed_bel_perfratio,'String', aktBel.perforationsRatio);
    else
        set(handles.ed_bel_dicke,   'String', '');
        set(handles.ed_bel_dichte,  'String', '');
        set(handles.ed_bel_dia,      'String', '');
        set(handles.ed_bel_perfratio,'String', '');
    end
end

guidata(hObject,handles);

end %function

function updateValuesInSchichtPanel(aktSchi, hObject, handles)

% Namen setzen
set(handles.ed_schi_name,       'String',  aktSchi.name);

% lokal/lateral setzen
if aktSchi.ausbreitungsArt==0
    set(handles.rb_schi_lok,'Value', 1);
elseif aktSchi.ausbreitungsArt==1
    set(handles.rb_schi_lat,'Value', 1);
end

%popup Menu fuer schichtmodell setzen
set(handles.popup_matlist, 'Value', aktSchi.schichtModell);

switch aktSchi.schichtModell
    case 1 % Luftschicht
        
        % alle edit und txt felder ausser Dicke im Panel ausblenden
        set(handles.textMat ,'Visible', 'Off');
        set(handles.textStrRes ,'Visible', 'Off');
        set(handles.textStrResUnit ,'Visible', 'Off');
        set(handles.textRG ,'Visible', 'Off');
        set(handles.textRGUnit ,'Visible', 'Off');
        set(handles.textPor ,'Visible', 'Off');
        set(handles.textStrFak ,'Visible', 'Off');
        set(handles.textKappa ,'Visible', 'Off');
        set(handles.textKappa1re ,'Visible', 'Off');
        set(handles.textKappa2re ,'Visible', 'Off');
        set(handles.textKappa1im ,'Visible', 'Off');
        set(handles.textKappa2im ,'Visible', 'Off');
        set(handles.textb11 ,'Visible', 'Off');
        set(handles.textb12 ,'Visible', 'Off');
        set(handles.textb21 ,'Visible', 'Off');
        set(handles.textb22 ,'Visible', 'Off');
        
        set(handles.ed_schi_res         ,'Visible', 'Off');
        set(handles.ed_schi_gewicht     ,'Visible', 'Off');
        set(handles.ed_schi_volpo       ,'Visible', 'Off');
        set(handles.ed_schi_chi         ,'Visible', 'Off');
        set(handles.ed_schi_kappa       ,'Visible', 'Off');
        set(handles.ed_schi_b11         ,'Visible', 'Off');
        set(handles.ed_schi_b12         ,'Visible', 'Off');
        set(handles.ed_schi_b21         ,'Visible', 'Off');
        set(handles.ed_schi_b22         ,'Visible', 'Off');
        set(handles.ed_schi_kap1        ,'Visible', 'Off');
        set(handles.ed_schi_kap2        ,'Visible', 'Off');
        set(handles.ed_schi_kap1_c      ,'Visible', 'Off');
        set(handles.ed_schi_kap2_c      ,'Visible', 'Off');
        
        set(handles.popup_schi_empmat   ,'Visible', 'Off');
        set(handles.popup_schi_klassmat ,'Visible', 'Off');
        
        if aktSchi.dicke > 0
            set(handles.ed_schi_dicke ,     'String', aktSchi.dicke*1000);
        else
            set(handles.ed_schi_dicke ,     'String', '');
        end
        
    case 2 % por. Absorber nach klassischer Theorie
        
        % alle edit und txt felder entsprechend Schichtmodel ein- bzw. ausblenden
        set(handles.textMat ,'Visible', 'On');
        set(handles.textStrRes ,'Visible', 'On');
        set(handles.textStrResUnit ,'Visible', 'On');
        set(handles.textRG ,'Visible', 'On');
        set(handles.textRGUnit ,'Visible', 'On');
        set(handles.textPor ,'Visible', 'On');
        set(handles.textStrFak ,'Visible', 'On');set(handles.textStrFak ,'String', 'Strukturfaktor');
        set(handles.textStrFak ,'String', 'Strukturfaktor');
        set(handles.textKappa ,'Visible', 'On');
        set(handles.textKappa1re ,'Visible', 'Off');
        set(handles.textKappa2re ,'Visible', 'Off');
        set(handles.textKappa1im ,'Visible', 'Off');
        set(handles.textKappa2im ,'Visible', 'Off');
        set(handles.textb11 ,'Visible', 'Off');
        set(handles.textb12 ,'Visible', 'Off');
        set(handles.textb21 ,'Visible', 'Off');
        set(handles.textb22 ,'Visible', 'Off');
        
        set(handles.ed_schi_res         ,'Visible', 'On');
        set(handles.ed_schi_gewicht     ,'Visible', 'On');
        set(handles.ed_schi_volpo       ,'Visible', 'On');
        set(handles.ed_schi_chi         ,'Visible', 'On');
        set(handles.ed_schi_kappa       ,'Visible', 'On');
        set(handles.ed_schi_b11         ,'Visible', 'Off');
        set(handles.ed_schi_b12         ,'Visible', 'Off');
        set(handles.ed_schi_b21         ,'Visible', 'Off');
        set(handles.ed_schi_b22         ,'Visible', 'Off');
        set(handles.ed_schi_kap1        ,'Visible', 'Off');
        set(handles.ed_schi_kap2        ,'Visible', 'Off');
        set(handles.ed_schi_kap1_c      ,'Visible', 'Off');
        set(handles.ed_schi_kap2_c      ,'Visible', 'Off');
        
        set(handles.popup_schi_empmat   ,'Visible', 'Off');
        set(handles.popup_schi_klassmat ,'Visible', 'On');
        
        set(handles.popup_schi_klassmat, 'Value',  aktSchi.klassMat);
        if aktSchi.dicke > 0
            set(handles.ed_schi_dicke ,      'String', aktSchi.dicke*1000);
            set(handles.ed_schi_res ,       'String',  aktSchi.stroemungsResistanz/1000);
            set(handles.ed_schi_gewicht ,   'String',  aktSchi.raumGewicht);
            set(handles.ed_schi_volpo ,     'String',  aktSchi.porositaet);
            set(handles.ed_schi_chi ,       'String',  aktSchi.strukturFaktor);
            set(handles.ed_schi_kappa ,     'String',  aktSchi.adiabatenKoeff);
        else
            set(handles.ed_schi_dicke ,     'String', '');
            set(handles.ed_schi_res ,       'String', '');
            set(handles.ed_schi_gewicht ,   'String', '');
            set(handles.ed_schi_volpo ,     'String', '');
            set(handles.ed_schi_chi ,       'String', '1'); % default Strukturfaktor
            set(handles.ed_schi_kappa ,     'String', '1'); % default eff. Adiabatenkoeff.
        end
        
    case 3 % por. Absorber nach empirischer Kennwertrelation
        
        % alle edit und txt felder entsprechend Schichtmodel ein- bzw. ausblenden
        set(handles.textMat ,'Visible', 'On');
        set(handles.textStrRes ,'Visible', 'On');
        set(handles.textStrResUnit ,'Visible', 'On');
        set(handles.textRG ,'Visible', 'Off');
        set(handles.textRGUnit ,'Visible', 'Off');
        set(handles.textPor ,'Visible', 'Off');
        set(handles.textStrFak ,'Visible', 'Off');
        set(handles.textKappa ,'Visible', 'Off');
        set(handles.textKappa1re ,'Visible', 'On');
        set(handles.textKappa2re ,'Visible', 'On');
        set(handles.textKappa1im ,'Visible', 'On');
        set(handles.textKappa2im ,'Visible', 'On');
        set(handles.textb11 ,'Visible', 'On');
        set(handles.textb12 ,'Visible', 'On');
        set(handles.textb21 ,'Visible', 'On');
        set(handles.textb22 ,'Visible', 'On');
        
        set(handles.ed_schi_res         ,'Visible', 'On');
        set(handles.ed_schi_gewicht     ,'Visible', 'Off');
        set(handles.ed_schi_volpo       ,'Visible', 'Off');
        set(handles.ed_schi_chi         ,'Visible', 'Off');
        set(handles.ed_schi_kappa       ,'Visible', 'Off');
        set(handles.ed_schi_b11         ,'Visible', 'On');
        set(handles.ed_schi_b12         ,'Visible', 'On');
        set(handles.ed_schi_b21         ,'Visible', 'On');
        set(handles.ed_schi_b22         ,'Visible', 'On');
        set(handles.ed_schi_kap1        ,'Visible', 'On');
        set(handles.ed_schi_kap2        ,'Visible', 'On');
        set(handles.ed_schi_kap1_c      ,'Visible', 'On');
        set(handles.ed_schi_kap2_c      ,'Visible', 'On');
        
        set(handles.popup_schi_empmat   ,'Visible', 'On');
        set(handles.popup_schi_klassmat ,'Visible', 'Off');
        
        set(handles.popup_schi_empmat ,  'Value',  aktSchi.empiricalMat);
        if aktSchi.dicke > 0
            set(handles.ed_schi_dicke ,      'String', aktSchi.dicke*1000);
            set(handles.ed_schi_res ,       'String',  aktSchi.stroemungsResistanz/1000);
            set(handles.ed_schi_volpo ,     'String',  aktSchi.porositaet);
        else
            set(handles.ed_schi_dicke ,     'String', '');
            set(handles.ed_schi_res ,       'String', '');
            set(handles.ed_schi_volpo ,     'String', '');
        end
        
        % Liste der empirischen Parameter
        set(handles.ed_schi_kap1,  'String', aktSchi.kappa1re );
        set(handles.ed_schi_kap1_c,'String', aktSchi.kappa1im );
        set(handles.ed_schi_kap2,  'String', aktSchi.kappa2re );
        set(handles.ed_schi_kap2_c,'String', aktSchi.kappa2im );
        set(handles.ed_schi_b11,   'String', aktSchi.b11 );
        set(handles.ed_schi_b12,   'String', aktSchi.b12 );
        set(handles.ed_schi_b21,   'String', aktSchi.b21 );
        set(handles.ed_schi_b22,   'String', aktSchi.b22 );
        
    case 4 % por. Absorber nach Komatsu Modell
        
        % alle edit und txt felder entsprechend Schichtmodel ein- bzw. ausblenden
        set(handles.textMat ,'Visible', 'Off');
        set(handles.textStrRes ,'Visible', 'On');
        set(handles.textStrResUnit ,'Visible', 'On');
        set(handles.textRG ,'Visible', 'Off');
        set(handles.textRGUnit ,'Visible', 'Off');
        set(handles.textPor ,'Visible', 'Off');
        set(handles.textStrFak ,'Visible', 'Off');
        set(handles.textKappa ,'Visible', 'Off');
        set(handles.textKappa1re ,'Visible', 'Off');
        set(handles.textKappa2re ,'Visible', 'Off');
        set(handles.textKappa1im ,'Visible', 'Off');
        set(handles.textKappa2im ,'Visible', 'Off');
        set(handles.textb11 ,'Visible', 'Off');
        set(handles.textb12 ,'Visible', 'Off');
        set(handles.textb21 ,'Visible', 'Off');
        set(handles.textb22 ,'Visible', 'Off');
        
        set(handles.ed_schi_res         ,'Visible', 'On');
        set(handles.ed_schi_gewicht     ,'Visible', 'Off');
        set(handles.ed_schi_volpo       ,'Visible', 'Off');
        set(handles.ed_schi_chi         ,'Visible', 'Off');
        set(handles.ed_schi_kappa       ,'Visible', 'Off');
        set(handles.ed_schi_b11         ,'Visible', 'Off');
        set(handles.ed_schi_b12         ,'Visible', 'Off');
        set(handles.ed_schi_b21         ,'Visible', 'Off');
        set(handles.ed_schi_b22         ,'Visible', 'Off');
        set(handles.ed_schi_kap1        ,'Visible', 'Off');
        set(handles.ed_schi_kap2        ,'Visible', 'Off');
        set(handles.ed_schi_kap1_c      ,'Visible', 'Off');
        set(handles.ed_schi_kap2_c      ,'Visible', 'Off');
        
        set(handles.popup_schi_empmat   ,'Visible', 'Off');
        set(handles.popup_schi_klassmat ,'Visible', 'Off');
        
        if aktSchi.dicke > 0
            set(handles.ed_schi_dicke ,      'String', aktSchi.dicke*1000);
            set(handles.ed_schi_res ,       'String',  aktSchi.stroemungsResistanz/1000);
        else
            set(handles.ed_schi_dicke ,     'String', '');
            set(handles.ed_schi_res ,       'String', '');
        end
        
    case 5 % por. Absorber nach Delany Bazley Modell
        
        % alle edit und txt felder entsprechend Schichtmodel ein- bzw. ausblenden
        set(handles.textMat ,'Visible', 'Off');
        set(handles.textStrRes ,'Visible', 'On');
        set(handles.textStrResUnit ,'Visible', 'On');
        set(handles.textRG ,'Visible', 'Off');
        set(handles.textRGUnit ,'Visible', 'Off');
        set(handles.textPor ,'Visible', 'Off');
        set(handles.textStrFak ,'Visible', 'Off');
        set(handles.textKappa ,'Visible', 'Off');
        set(handles.textKappa1re ,'Visible', 'Off');
        set(handles.textKappa2re ,'Visible', 'Off');
        set(handles.textKappa1im ,'Visible', 'Off');
        set(handles.textKappa2im ,'Visible', 'Off');
        set(handles.textb11 ,'Visible', 'Off');
        set(handles.textb12 ,'Visible', 'Off');
        set(handles.textb21 ,'Visible', 'Off');
        set(handles.textb22 ,'Visible', 'Off');
        
        set(handles.ed_schi_res         ,'Visible', 'On');
        set(handles.ed_schi_gewicht     ,'Visible', 'Off');
        set(handles.ed_schi_volpo       ,'Visible', 'Off');
        set(handles.ed_schi_chi         ,'Visible', 'Off');
        set(handles.ed_schi_kappa       ,'Visible', 'Off');
        set(handles.ed_schi_b11         ,'Visible', 'Off');
        set(handles.ed_schi_b12         ,'Visible', 'Off');
        set(handles.ed_schi_b21         ,'Visible', 'Off');
        set(handles.ed_schi_b22         ,'Visible', 'Off');
        set(handles.ed_schi_kap1        ,'Visible', 'Off');
        set(handles.ed_schi_kap2        ,'Visible', 'Off');
        set(handles.ed_schi_kap1_c      ,'Visible', 'Off');
        set(handles.ed_schi_kap2_c      ,'Visible', 'Off');
        
        set(handles.popup_schi_empmat   ,'Visible', 'Off');
        set(handles.popup_schi_klassmat ,'Visible', 'Off');
        
        if aktSchi.dicke > 0
            set(handles.ed_schi_dicke ,      'String', aktSchi.dicke*1000);
            set(handles.ed_schi_res ,       'String',  aktSchi.stroemungsResistanz/1000);
        else
            set(handles.ed_schi_dicke ,     'String', '');
            set(handles.ed_schi_res ,       'String', '');
        end
        
    case 6 % por. Absorber nach Miki Modell
        
        % alle edit und txt felder entsprechend Schichtmodel ein- bzw. ausblenden
        set(handles.textMat ,'Visible', 'Off');
        set(handles.textStrRes ,'Visible', 'On');
        set(handles.textStrResUnit ,'Visible', 'On');
        set(handles.textRG ,'Visible', 'Off');
        set(handles.textRGUnit ,'Visible', 'Off');
        set(handles.textPor ,'Visible', 'Off');
        set(handles.textStrFak ,'Visible', 'Off');
        set(handles.textKappa ,'Visible', 'Off');
        set(handles.textKappa1re ,'Visible', 'Off');
        set(handles.textKappa2re ,'Visible', 'Off');
        set(handles.textKappa1im ,'Visible', 'Off');
        set(handles.textKappa2im ,'Visible', 'Off');
        set(handles.textb11 ,'Visible', 'Off');
        set(handles.textb12 ,'Visible', 'Off');
        set(handles.textb21 ,'Visible', 'Off');
        set(handles.textb22 ,'Visible', 'Off');
        
        set(handles.ed_schi_res         ,'Visible', 'On');
        set(handles.ed_schi_gewicht     ,'Visible', 'Off');
        set(handles.ed_schi_volpo       ,'Visible', 'Off');
        set(handles.ed_schi_chi         ,'Visible', 'Off');
        set(handles.ed_schi_kappa       ,'Visible', 'Off');
        set(handles.ed_schi_b11         ,'Visible', 'Off');
        set(handles.ed_schi_b12         ,'Visible', 'Off');
        set(handles.ed_schi_b21         ,'Visible', 'Off');
        set(handles.ed_schi_b22         ,'Visible', 'Off');
        set(handles.ed_schi_kap1        ,'Visible', 'Off');
        set(handles.ed_schi_kap2        ,'Visible', 'Off');
        set(handles.ed_schi_kap1_c      ,'Visible', 'Off');
        set(handles.ed_schi_kap2_c      ,'Visible', 'Off');
        
        set(handles.popup_schi_empmat   ,'Visible', 'Off');
        set(handles.popup_schi_klassmat ,'Visible', 'Off');
        
        if aktSchi.dicke > 0
            set(handles.ed_schi_dicke ,      'String', aktSchi.dicke*1000);
            set(handles.ed_schi_res ,       'String',  aktSchi.stroemungsResistanz/1000);
        else
            set(handles.ed_schi_dicke ,     'String', '');
            set(handles.ed_schi_res ,       'String', '');
        end
    case 7 % Attenborough f�r Bitumen
        
        % alle edit und txt felder entsprechend Schichtmodel ein- bzw. ausblenden
        set(handles.textMat ,'Visible', 'On');
        set(handles.textStrRes ,'Visible', 'On');
        set(handles.textStrResUnit ,'Visible', 'On');
        set(handles.textRG ,'Visible', 'Off');
        set(handles.textRGUnit ,'Visible', 'Off');
        set(handles.textPor ,'Visible', 'On');
        set(handles.textStrFak ,'Visible', 'On');
        set(handles.textStrFak ,'String', 'Strukturfaktor');
        set(handles.textStrFak ,'String', 'Tortuosit�t');
        set(handles.textKappa ,'Visible', 'Off');
        set(handles.textKappa1re ,'Visible', 'Off');
        set(handles.textKappa2re ,'Visible', 'Off');
        set(handles.textKappa1im ,'Visible', 'Off');
        set(handles.textKappa2im ,'Visible', 'Off');
        set(handles.textb11 ,'Visible', 'Off');
        set(handles.textb12 ,'Visible', 'Off');
        set(handles.textb21 ,'Visible', 'Off');
        set(handles.textb22 ,'Visible', 'Off');
        
        set(handles.ed_schi_res         ,'Visible', 'On');
        set(handles.ed_schi_gewicht     ,'Visible', 'Off');
        set(handles.ed_schi_volpo       ,'Visible', 'On');
        set(handles.ed_schi_chi         ,'Visible', 'On');
        set(handles.ed_schi_kappa       ,'Visible', 'Off');
        set(handles.ed_schi_b11         ,'Visible', 'Off');
        set(handles.ed_schi_b12         ,'Visible', 'Off');
        set(handles.ed_schi_b21         ,'Visible', 'Off');
        set(handles.ed_schi_b22         ,'Visible', 'Off');
        set(handles.ed_schi_kap1        ,'Visible', 'Off');
        set(handles.ed_schi_kap2        ,'Visible', 'Off');
        set(handles.ed_schi_kap1_c      ,'Visible', 'Off');
        set(handles.ed_schi_kap2_c      ,'Visible', 'Off');
        
        set(handles.popup_schi_empmat   ,'Visible', 'Off');
        set(handles.popup_schi_klassmat ,'Visible', 'Off');
        
        if aktSchi.dicke > 0
            set(handles.ed_schi_dicke ,     'String',  aktSchi.dicke*1000);
            set(handles.ed_schi_res ,       'String',  aktSchi.stroemungsResistanz/1000);
            set(handles.ed_schi_volpo ,     'String',  aktSchi.porositaet);
            set(handles.ed_schi_chi ,       'String',  aktSchi.strukturFaktor);
        else
            set(handles.ed_schi_dicke ,     'String', '');
            set(handles.ed_schi_res ,       'String', '');
            set(handles.ed_schi_volpo ,     'String', '');
            set(handles.ed_schi_chi ,       'String', '1'); % default Strukturfaktor
        end
end

guidata(hObject, handles);

end %function

function updateValuesInLochplattePanel(aktLP, hObject, handles)

set(handles.ed_pla_name, 'String', aktLP.name);
set(handles.rb_pla_loch, 'Value', aktLP.lochTyp);

if  aktLP.lochTyp
    set(handles.textLochDiaLP, 'String','Kreisdurchmesser');
    set(handles.textLochAbstand, 'String','Lochabstand');
else
    set(handles.textLochDiaLP, 'String','Schlitzbreite');
    set(handles.textLochAbstand, 'String','Schlitzabstand');
end

if aktLP.dicke > 0
    set(handles.ed_pla_dicke ,      'String', aktLP.dicke*1000);
    set(handles.ed_pla_breite ,     'String', aktLP.lochSchlitzAbmessung*1000);
    set(handles.ed_pla_abstand ,    'String', aktLP.lochSchlitzAbstand*1000);
else
    set(handles.ed_pla_dicke ,      'String', '');
    set(handles.ed_pla_breite ,     'String', '');
    set(handles.ed_pla_abstand ,    'String', '');
end

guidata(hObject, handles);
end %function

function itaSave(hObject, handles, type)

if strcmpi(type, 'ita')
    if isempty(handles.matDataPath)
        % Speicherziel festlegen
        [fileName,pathName,filterIndex] = uiputfile('*.ita','Speichern...');
    else
        [fileName,pathName,filterIndex] = uiputfile('*.ita','Speichern...', handles.matDataPath);
    end
    
    if fileName == 0  %% falls abgebrochen wurde
        return
    end
    handles.matDataPath = pathName;
    
    saveAs = fullfile(pathName,fileName);
else % workspace
    % handles.matDataPath = [];
    saveAs = '';
end


%  Compose comment for header
comment = composeheadercomment(handles);

if get(handles.rb_save_as_itaResult,'Value')
    
    freq    = (handles.erg.f).';
    
    if length(handles.erg.theta) == 1
        if handles.erg.modus == 0          % BESTIMMTER WINKEL UND IMPEDANZMODUS
            chIdx = 1;
            if get(handles.cb_impedanz, 'Value')
                data(chIdx) = itaResult(handles.erg.Z, freq, 'freq');
                data(chIdx).channelNames{1} = 'Impedance';
                data(chIdx).channelUnits{1} = 'kg/(s m^2)';
                chIdx = chIdx+1;
            end
            if get(handles.cb_admittanz, 'Value')
                data(chIdx) = itaResult(handles.erg.Y, freq, 'freq');
                data(chIdx).channelNames{1} = 'Admittance';
                data(chIdx).channelUnits{1} = 's m^2/kg';
                chIdx = chIdx+1;
            end
            if get(handles.cb_reflexionsfaktor, 'Value')
                data(chIdx) = itaResult(handles.erg.R, freq, 'freq');
                data(chIdx).channelNames{1} = 'Reflection Factor';
                data(chIdx).channelUnits{1} = '';
                chIdx = chIdx+1;
            end
            if get(handles.cb_absorption, 'Value')
                data(chIdx) = itaResult(handles.erg.alpha, freq, 'freq');
                data(chIdx).channelNames{1} = 'Absorption';
                data(chIdx).channelUnits{1} = '';
                chIdx = chIdx+1;
            end
            
        else                               % BESTIMMTER WINKEL UND MATRIXMODUS
            chIdx = 1;
            if get(handles.cb_kettenmatrix, 'Value')
                data(chIdx) = itaResult(handles.erg.a11, freq, 'freq');
                data(chIdx).channelNames{1} = 'A_{11} (Kettenmatrix)';
                data(chIdx).channelUnits{1} = '';
                data(chIdx+1) = itaResult(handles.erg.a12, freq, 'freq');
                data(chIdx+1).channelNames{1} = 'A_{12} (Kettenmatrix)';
                data(chIdx+1).channelUnits{1} = 'kg/(s m^2)';
                data(chIdx+2) = itaResult(handles.erg.a21, freq, 'freq');
                data(chIdx+2).channelNames{1} = 'A_{21} (Kettenmatrix)';
                data(chIdx+2).channelUnits{1} = 'kg/(s m^2)';
                data(chIdx+3) = itaResult(handles.erg.a22, freq, 'freq');
                data(chIdx+3).channelNames{1} = 'A_{22} (Kettenmatrix)';
                data(chIdx+3).channelUnits{1} = '';
                chIdx = chIdx+4;
            end
            if get(handles.cb_admittanzmatrix, 'Value')
                data(chIdx) = itaResult(handles.erg.y11, freq, 'freq');
                data(chIdx).channelNames{1} = 'Y_{11} (Kettenmatrix)';
                data(chIdx).channelUnits{1} = 's m^2/kg';
                data(chIdx+1) = itaResult(handles.erg.y12, freq, 'freq');
                data(chIdx+1).channelNames{1} = 'Y_{12} (Kettenmatrix)';
                data(chIdx+1).channelUnits{1} = 's m^2/kg';
                data(chIdx+2) = itaResult(handles.erg.y21, freq, 'freq');
                data(chIdx+2).channelNames{1} = 'Y_{21} (Kettenmatrix)';
                data(chIdx+2).channelUnits{1} = 's m^2/kg';
                data(chIdx+3) = itaResult(handles.erg.y22, freq, 'freq');
                data(chIdx+3).channelNames{1} = 'Y_{22} (Kettenmatrix)';
                data(chIdx+3).channelUnits{1} = 's m^2/kg';
                chIdx = chIdx+4;
            end
            if get(handles.cb_impedanzmatrix, 'Value')
                data(chIdx) = itaResult(handles.erg.yz11, freq, 'freq');
                data(chIdx).channelNames{1} = 'Z_{11} (Kettenmatrix)';
                data(chIdx).channelUnits{1} = 'kg/s m^2';
                data(chIdx+1) = itaResult(handles.erg.z12, freq, 'freq');
                data(chIdx+1).channelNames{1} = 'Z_{12} (Kettenmatrix)';
                data(chIdx+1).channelUnits{1} = 'kg/s m^2';
                data(chIdx+2) = itaResult(handles.erg.z21, freq, 'freq');
                data(chIdx+2).channelNames{1} = 'Z_{21} (Kettenmatrix)';
                data(chIdx+2).channelUnits{1} = 'kg/s m^2';
                data(chIdx+3) = itaResult(handles.erg.z22, freq, 'freq');
                data(chIdx+3).channelNames{1} = 'Z_{22} (Kettenmatrix)';
                data(chIdx+3).channelUnits{1} = 'kg/s m^2';
                chIdx = chIdx+4;
            end
        end
    else                                   % DIFFUSER SCHALLEINFALL UND IMPEDANZMODUS
        
        chIdx = 1;
        if get(handles.cb_impedanz, 'Value')
            data(chIdx) = itaResult(handles.erg.Z_diff, freq, 'freq');
            data(chIdx).channelNames{1} = 'Impedance, diffuse incidence';
            data(chIdx).channelUnits{1} = 'kg/(s m^2)';
            chIdx = chIdx+1;
        end
        if get(handles.cb_admittanz, 'Value')
            data(chIdx) = itaResult(handles.erg.Y_diff, freq, 'freq');
            data(chIdx).channelNames{1} = 'Admittance, diffuse incidence';
            data(chIdx).channelUnits{1} = 's m^2/kg';
            chIdx = chIdx+1;
        end
        if get(handles.cb_reflexionsfaktor, 'Value')
            data(chIdx) = itaResult(handles.erg.R_diff, freq, 'freq');
            data(chIdx).channelNames{1} = 'Reflection Factor, diffuse incidence';
            data(chIdx).channelUnits{1} = '';
            chIdx = chIdx+1;
        end
        if get(handles.cb_absorption, 'Value')
            data(chIdx) = itaResult(handles.erg.alpha_diff, freq, 'freq');
            data(chIdx).channelNames{1} = 'Absorption, diffuse incidence';
            data(chIdx).channelUnits{1} = '';
            chIdx = chIdx+1;
        end
        
    end
    
    if ~exist('data', 'var')
        errordlg('Bitte ausw�hlen, was gespeichert werden soll!','Fehler');
        return;
    end
    
    impedanceResults = ita_merge(data);
    impedanceResults.comment = comment;
    
    if strcmpi(type, 'ita')
        ita_write(impedanceResults, saveAs, 'overwrite');
    elseif strcmpi(type, 'ws')
        assignin('base', 'impCalcResults', impedanceResults);
    end
    
else % get(handles.rb_save_as_itaAudio,'Value')
    
    fftDegree  = getValue(handles.ed_fftDegree);
    sampleRate =  getValue(handles.ed_SampleRate);
    tmp     = ita_generate('flat',0,sampleRate,fftDegree);
    newFreq = tmp.freqVector;
    freq    = (handles.erg.f).';
    
    if length(handles.erg.theta) == 1
        if handles.erg.modus == 0          % BESTIMMTER WINKEL UND IMPEDANZMODUS
            
            chIdx = 1;
            if get(handles.cb_impedanz, 'Value')
                spk(:, chIdx)  = interp_zeroextrap(freq, handles.erg.Z, newFreq, 'spline');
                channelNames{chIdx} = 'Impedance';
                channelUnits{chIdx} = 'kg/(s m^2)';
                chIdx = chIdx+1;
            end
            if get(handles.cb_admittanz, 'Value')
                spk(:, chIdx)  = interp_zeroextrap(freq, handles.erg.Y, newFreq, 'spline');
                channelNames{chIdx} = 'Admittance';
                channelUnits{chIdx} = 's m^2/kg';
                chIdx = chIdx+1;
            end
            if get(handles.cb_reflexionsfaktor, 'Value')
                spk(:, chIdx)  = interp_zeroextrap(freq, handles.erg.R, newFreq, 'spline');
                channelNames{chIdx} = 'Reflection Factor';
                channelUnits{chIdx} = '';
                chIdx = chIdx+1;
            end
            if get(handles.cb_absorption, 'Value')
                spk(:, chIdx)  = interp_zeroextrap(freq, handles.erg.alpha, newFreq, 'spline');
                channelNames{chIdx} = 'Absorption';
                channelUnits{chIdx} = '';
                chIdx = chIdx+1;
            end
            
        else                               % BESTIMMTER WINKEL UND MATRIXMODUS
            chIdx = 1;
            if get(handles.cb_kettenmatrix, 'Value')
                spk(:, chIdx)  =  interp_zeroextrap(freq, handles.erg.a11, newFreq, 'spline');
                spk(:, chIdx+1)  =  interp_zeroextrap(freq, handles.erg.a12, newFreq, 'spline');
                spk(:, chIdx+2)  =  interp_zeroextrap(freq, handles.erg.a21, newFreq, 'spline');
                spk(:, chIdx+3)  =  interp_zeroextrap(freq, handles.erg.a22, newFreq, 'spline');
                channelNames{chIdx}   = 'A_{11}';
                channelNames{chIdx+1} = 'A_{12}';
                channelNames{chIdx+2} = 'A_{21}';
                channelNames{chIdx+3} = 'A_{22}';
                channelUnits{chIdx}   = '';
                channelUnits{chIdx+1} = 'kg/s m^2';
                channelUnits{chIdx+2} = 's m^2/kg';
                channelUnits{chIdx+3} = '';
                chIdx = chIdx+4;
            end
            if get(handles.cb_admittanzmatrix, 'Value')
                spk(:, chIdx)  =  interp_zeroextrap(freq, handles.erg.y11, newFreq, 'spline');
                spk(:, chIdx+1)  =  interp_zeroextrap(freq, handles.erg.y12, newFreq, 'spline');
                spk(:, chIdx+2)  =  interp_zeroextrap(freq, handles.erg.y21, newFreq, 'spline');
                spk(:, chIdx+3)  =  interp_zeroextrap(freq, handles.erg.y22, newFreq, 'spline');
                channelNames{chIdx}   = 'Y_{11}';
                channelNames{chIdx+1} = 'Y_{12}';
                channelNames{chIdx+2} = 'Y_{21}';
                channelNames{chIdx+3} = 'Y_{22}';
                channelUnits{chIdx}   = 's m^2/kg';
                channelUnits{chIdx+1} = 's m^2/kg';
                channelUnits{chIdx+2} = 's m^2/kg';
                channelUnits{chIdx+3} = 's m^2/kg';
                chIdx = chIdx+4;
            end
            if get(handles.cb_impedanzmatrix, 'Value')
                spk(:, chIdx)   =  interp_zeroextrap(freq, handles.erg.z11, newFreq, 'spline');
                spk(:, chIdx+1) =  interp_zeroextrap(freq, handles.erg.z12, newFreq, 'spline');
                spk(:, chIdx+2) =  interp_zeroextrap(freq, handles.erg.z21, newFreq, 'spline');
                spk(:, chIdx+3) =  interp_zeroextrap(freq, handles.erg.z22, newFreq, 'spline');
                channelNames{chIdx}   = 'Z_{11}';
                channelNames{chIdx+1} = 'Z_{12}';
                channelNames{chIdx+2} = 'Z_{21}';
                channelNames{chIdx+3} = 'Z_{22}';
                channelUnits{chIdx}   = 'kg/s m^2';
                channelUnits{chIdx+1} = 'kg/s m^2';
                channelUnits{chIdx+2} = 'kg/s m^2';
                channelUnits{chIdx+3} = 'kg/s m^2';
                chIdx = chIdx+4;
            end
        end
    else                                   % DIFFUSER SCHALLEINFALL UND IMPEDANZMODUS
        
        chIdx = 1;
        if get(handles.cb_impedanz, 'Value')
            spk(:, chIdx)  = interp_zeroextrap(freq, handles.erg.Z_diff, newFreq, 'spline');
            channelNames{chIdx} = 'Impedance, diffuse incidence';
            channelUnits{chIdx} = 'kg/(s m^2)';
            chIdx = chIdx+1;
        end
        if get(handles.cb_admittanz, 'Value')
            spk(:, chIdx)  = interp_zeroextrap(freq, handles.erg.Y_diff, newFreq, 'spline');
            channelNames{chIdx} = 'Admittance, diffuse incidence';
            channelUnits{chIdx} = 's m^2/kg';
            chIdx = chIdx+1;
        end
        if get(handles.cb_reflexionsfaktor, 'Value')
            spk(:, chIdx)  = interp_zeroextrap(freq, handles.erg.R_diff, newFreq, 'spline');
            channelNames{chIdx} = 'Reflection Factor, diffuse incidence';
            channelUnits{chIdx} = '';
            chIdx = chIdx+1;
        end
        if get(handles.cb_absorption, 'Value')
            spk(:, chIdx)  = interp_zeroextrap(freq, handles.erg.alpha_diff, newFreq, 'spline');
            channelNames{chIdx} = 'Absorption, diffuse incidence';
            channelUnits{chIdx} = '';
            chIdx = chIdx+1;
        end
        
    end
    
    if ~exist('spk', 'var')
        errordlg('Bitte auswaehlen, was gespeichert werden soll!','Fehler');
        return;
    end
    
    impedanceResults = itaAudio();
    impedanceResults.freqData = spk;
    impedanceResults.channelNames = channelNames;
    impedanceResults.channelUnits = channelUnits;
    impedanceResults.comment = comment;
    impedanceResults.signalType = 'energy';
    impedanceResults.fileName = 'newfile';
    impedanceResults.history = {'ita_impcalc_gui(filename)'};
    
    if strcmpi(type, 'ita')
        ita_write(impedanceResults, saveAs, 'overwrite');
    elseif strcmpi(type, 'ws')
        assignin('base', 'impCalcResults', impedanceResults);
    end
    
end

guidata(hObject, handles);

end %function



%% NEW FUNCTIONS THAT ARE CREATED BY GUIDE
