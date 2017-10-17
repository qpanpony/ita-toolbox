function varargout = v2gui(varargin)
% V2 Laboratory
% Sound Insulation measurement of different plates.
%-------------------------------------------------------------------------
% External dependencies:
%   - Ghostscript installed on system           
%

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Files that need to be present in the same folder:
%   - findjobj.m    
%   - export_fig.m
%   - using_hg2.m   (from export_fig package)
%   - print2array.m (from export_fig package)
%   - offlineMode_workspace.mat (for offline Mode)
%-------------------------------------------------------------------------
% Offline Mode:
%   Setting variable handles.offlineMode in v2gui_OpeningFcn to 1 will make
%   the program
%       - skip the measurement    
%       - load data from a SINGLE measurement from offlineMode_workspace.mat 
%       - crash if used with more than one source position.
%   Could be useful if you want to work on this from a computer that does 
%   not have the proper hardware connected to it. 
%-------------------------------------------------------------------------
% v1.2, 29.10.2014
% Florian Theviï¿½en, Florian.Thevissen@rwth-aachen.de
% Institute of Technical Acoustics (ITA), RWTH Aachen Universita4iopü+% 
%-------------------------------------------------------------------------

% Edit the above text to modify the response to help gui
% Last Modified by GUIDE v2.5 06-Oct-2014 13:07:41

% Warnings OFF!
warning('off','all');

% Begin GUIDE initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @v2gui_OpeningFcn, ...
                   'gui_OutputFcn',  @v2gui_OutputFcn, ...
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
% End GUIDE initialization code - DO NOT EDIT



% --- Executes just before gui is made visible.
function v2gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% offline mode: loads pre-measure results from mat-file 
% 'offlineMode_workspace.mat' instead of measuring. Use this to test the
% GUI from computers without the necessary hardware. (do not use more than
% one source position with it though. There be dragons.)
handles.offlineMode = 0;
%handles.offlineMode = 1;
guidata(hObject, handles);
global handlesg;
handlesg = handles;

image1=imread('ita_toolbox_logo.png');
axes(handles.logoAxes);
imshow(image1);
handles.currentAxes(1) = axes('tag', 'ax1');
set(handles.currentAxes(1), 'position', [0.252 0.294 0.735 0.638]);

% initialization
import v2;
handles.v2 = 'not instantiated yet';
handles.status = 'preMeasurement';                  % el {'preMeasurement' , 'postMeasurement'}
checkMaterialPropVisibility(handles);               % Material entry area
%configureAx(handles);                               % Axes element

% default values of text fields
% fpa: save all results to folder on desktop
defaultPath = fullfile(winqueryreg('HKEY_CURRENT_USER', 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'Desktop'),...
    sprintf('Laboratory_V2_%s', datestr(now, 'yyyy-mm-dd')));
set(handles.directoryTextEdit, 'String', defaultPath);      

% Update handles structure
handles.okButtonClicked = false;
handles.statusText = {};
%handles = appendToStatus(handles,'V2 starting up...');
set(handles.eventLog,'String',handles.statusText);
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
uiwait(handles.gui);


% --- Executes when user attempts to close gui.
function gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
uiresume(handles.gui);

% --- Outputs from this function are returned to the command line.
function varargout = v2gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.gui);

% make text editor fields visible / enable them depending on selected
% material
function checkMaterialPropVisibility(handles)
material = get( handles.MaterialPopupMenu, 'Value');
switch material
    case 1  % MDF
        set( handles.ThicknessLabel1, 'Visible', 'on');
        set( handles.ThicknessTextEdit1, 'Visible', 'on');
        set( handles.ThicknessUnitLabel1, 'Visible', 'on');
        set( handles.ThicknessLabel2, 'Visible', 'off');
        set( handles.ThicknessTextEdit2, 'Visible', 'off');
        set( handles.ThicknessUnitLabel2, 'Visible', 'off');
        set( handles.ThicknessLabel3, 'Visible', 'off');
        set( handles.ThicknessTextEdit3, 'Visible', 'off');
        set( handles.ThicknessUnitLabel3, 'Visible', 'off');
        set( handles.OpeningAreaLabel, 'Visible', 'off');       
        set( handles.OpeningAreaTextEdit, 'Visible', 'off');
        set( handles.OpeningAreaUnitLabel, 'Visible', 'off');
    case 2  % MDF double plate
        set( handles.ThicknessLabel1, 'Visible', 'on');
        set( handles.ThicknessTextEdit1, 'Visible', 'on');
        set( handles.ThicknessUnitLabel1, 'Visible', 'on');
        set( handles.ThicknessLabel2, 'Visible', 'on');
        set( handles.ThicknessTextEdit2, 'Visible', 'on');
        set( handles.ThicknessUnitLabel2, 'Visible', 'on');
        set( handles.ThicknessLabel3, 'Visible', 'on');
        set( handles.ThicknessTextEdit3, 'Visible', 'on');
        set( handles.ThicknessUnitLabel3, 'Visible', 'on');
        set( handles.OpeningAreaLabel, 'Visible', 'off');    
        set( handles.OpeningAreaTextEdit, 'Visible', 'off');
        set( handles.OpeningAreaUnitLabel, 'Visible', 'off');    
    case 3  % Aluminium
        set( handles.ThicknessLabel1, 'Visible', 'on');
        set( handles.ThicknessTextEdit1, 'Visible', 'on');
        set( handles.ThicknessUnitLabel1, 'Visible', 'on');
        set( handles.ThicknessLabel2, 'Visible', 'off');
        set( handles.ThicknessTextEdit2, 'Visible', 'off');
        set( handles.ThicknessUnitLabel2, 'Visible', 'off');
        set( handles.ThicknessLabel3, 'Visible', 'off');
        set( handles.ThicknessTextEdit3, 'Visible', 'off');
        set( handles.ThicknessUnitLabel3, 'Visible', 'off');
        set( handles.OpeningAreaLabel, 'Visible', 'off');
        set( handles.OpeningAreaTextEdit, 'Visible', 'off');
        set( handles.OpeningAreaUnitLabel, 'Visible', 'off');         
    case 4  % Brass
        set( handles.ThicknessLabel1, 'Visible', 'on');
        set( handles.ThicknessTextEdit1, 'Visible', 'on');
        set( handles.ThicknessUnitLabel1, 'Visible', 'on');
        set( handles.ThicknessLabel2, 'Visible', 'off');
        set( handles.ThicknessTextEdit2, 'Visible', 'off');
        set( handles.ThicknessUnitLabel2, 'Visible', 'off');
        set( handles.ThicknessLabel3, 'Visible', 'off');
        set( handles.ThicknessTextEdit3, 'Visible', 'off');
        set( handles.ThicknessUnitLabel3, 'Visible', 'off');
        set( handles.OpeningAreaLabel, 'Visible', 'off');
        set( handles.OpeningAreaTextEdit, 'Visible', 'off');
        set( handles.OpeningAreaUnitLabel, 'Visible', 'off');
    case 5  % Plate with opening area
        set( handles.ThicknessLabel1, 'Visible', 'on');
        set( handles.ThicknessTextEdit1, 'Visible', 'on');
        set( handles.ThicknessUnitLabel1, 'Visible', 'on');
        set( handles.ThicknessLabel2, 'Visible', 'off');
        set( handles.ThicknessTextEdit2, 'Visible', 'off');
        set( handles.ThicknessUnitLabel2, 'Visible', 'off');
        set( handles.ThicknessLabel3, 'Visible', 'off');
        set( handles.ThicknessTextEdit3, 'Visible', 'off');
        set( handles.ThicknessUnitLabel3, 'Visible', 'off');
        set( handles.OpeningAreaLabel, 'Visible', 'on');
        set( handles.OpeningAreaTextEdit, 'Visible', 'on');
        set( handles.OpeningAreaUnitLabel, 'Visible', 'on');
    otherwise
        
end

function clearEventLog(handles)
handles.statusText = {};
guidata(handles.gui, handles);
set(handles.eventLog,'String',handles.statusText);

function handles = appendToEventLog(handles,str)
%set(handles.statusText, 'String', str);
handles.statusText = [handles.statusText, str];
guidata(handles.gui, handles);
set(handles.eventLog,'String',handles.statusText);
jhEdit = findjobj(handles.eventLog);    % TODO: improve by hacking EDT
jEdit = jhEdit.getComponent(0).getComponent(0);
jEdit.setCaretPosition(jEdit.getDocument.getLength);

% --- Check current inputs in material and measurement setup text edits
function success = checkInputs(handles)
success = true;
[materialProperties, measurementProperties, outputDirectory] = collectInputs(handles);

t = materialProperties.thickness1;
if( isempty(t) || ~isnumeric(t))
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Error: invalid entry in thickness1 textbox.');
end
t = materialProperties.thickness2;
if( isempty(t) || ~isnumeric(t))
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Error: invalid entry in thickness2 textbox.');
end
t = materialProperties.thicknessAir;
if( isempty(t) || ~isnumeric(t))
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Error: invalid entry in thickness3 textbox.');
end
t = materialProperties.openingArea;
if( isempty(t) || ~isnumeric(t))
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Error: invalid entry in openingArea textbox.');
end
t = materialProperties.density;
if( isempty(t) || ~isnumeric(t))
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Error: invalid entry in density textbox.');
end
t = materialProperties.youngsModulus;
if( isempty(t) || ~isnumeric(t))
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Error: invalid entry in openingArea textbox.');
end
t = measurementProperties.sourcePositions;
if( isempty(t) || ~isnumeric(t))
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Error: invalid entry in sourcePositions textbox.');
end
t = measurementProperties.sourcePositions;
if( isempty(t) || ~isnumeric(t) || t > 32)
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Error: invalid entry in samples textbox.');
end
if ( isequal(outputDirectory, '0') || isempty(outputDirectory))
    success = false;
    handles = guidata(handles.gui);
    appendToEventLog(handles, 'Error: invalid output directory');
end
% check if directory is creatable if it does not exist
if ( ~isdir(outputDirectory) )
    [status,message] = mkdir(outputDirectory);
    if( status == 0)
        handles = guidata(handles.gui);
        appendToEventLog(handles, 'Error: output directory could not be created. Reason: ', message); 
        success = false;
    else
        % directory successfully created, remove it again
        success = true;
        rmdir(outputDirectory);
    end
end

% --- Collect text input from text edits, sort them into structs and return
function [materialProperties, measurementProperties, outputDirectory] = collectInputs(handles)
val = get( handles.MaterialPopupMenu,'Value');
string_list = get( handles.MaterialPopupMenu,'String');
materialProperties.material = string_list{val};
materialProperties.thickness1 = str2double( get( handles.ThicknessTextEdit1, 'String')) / 1000;    % now in m
materialProperties.thickness2 = str2double( get( handles.ThicknessTextEdit2, 'String')) / 1000;
materialProperties.thicknessAir = str2double( get( handles.ThicknessTextEdit3, 'String')) / 1000;
materialProperties.openingArea = str2double( get( handles.OpeningAreaTextEdit, 'String')) / 1e6;   % now in m^6
materialProperties.density = str2double( get( handles.DensityTextEdit, 'String'));
materialProperties.youngsModulus = str2double( get( handles.YoungsTextEdit, 'String'));
measurementProperties.sourcePositions = str2double(get( handles.MeasurementsTextEdit, 'String'));
measurementProperties.samples = str2double(get( handles.SamplesTextEdit, 'String'));
outputDirectory = get( handles.directoryTextEdit, 'String');

%--------------------------------------------------------------------------
% Callback functions

% --- Executes on button press in startMeasurementButton.
function startMeasurementButton_Callback(hObject, eventdata, handles)
% hObject    handle to startMeasurementButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clearEventLog(handles);
handles = guidata(handles.gui);
% reset axes
if numel(handles.currentAxes)>1
    delete(handles.currentAxes(2));
    legend off
    % not nice but working
    title('');
    xlabel('')
    ylabel('')
    hid = findall(gca, 'type', 'line');
    delete(hid);
    
    set(handles.currentAxes(1), 'position', [0.252 0.294 0.735 0.638]);
end

appendToEventLog(handles,'Starting measurement...');
if ( checkInputs(handles) == false)
    handles = guidata(handles.gui);
    appendToEventLog(handles,'Measurement aborted.');
    return;
end
handles = guidata(handles.gui);
[materialProperties, measurementProperties, outputDirectory] = collectInputs(handles);
% recording room properties, hard-coded here
recordingRoom.height = 750e-3;
recordingRoom.width = 1000e-3;
recordingRoom.depth = 1130e-3;
% calibration file for measurement chain
calibrationFile = 'V2_calib.mat';

% instantiate v2 object
handles.v2 = v2(recordingRoom,materialProperties,measurementProperties,outputDirectory, calibrationFile);
if(handles.offlineMode == 0)
    % ... and let it do it's thing  
    guidata(handles.gui, handles);
    handles.v2 = handles.v2.exec();    
else
    % ... or not due to offlineMode: load variables from a previous
    % measurement and put them into v2 instance:
    load('offlineMode_workspace.mat');
    handles.v2.SNR = SNR;
    handles.v2.R = R;
    handles.v2.soundInsulationIndex = soundInsulationIndex;
    handles.v2.soundInsulationCurve = soundInsulationCurve;
end

if(handles.v2.measurementProperties.sourcePositions == 1)
    % show SNR plot of measurement
    filename = handles.v2.genFilenameString();
    ita_plot_freq(handles.v2.SNR(1), 'figure_handle', handles.gui, 'axes_handle', handles.currentAxes(1), 'FontSize', 9);
    title(handles.currentAxes(1), ['Signal-to-Noise Ratio in 1/3 octave bands, ' handles.v2.genMaterialString(),...
        ', fftdegree = ',num2str(measurementProperties.samples)], 'FontSize', 9);
    hline = findobj(gcf, 'type', 'line');
    % set(hline,'LineStyle','--', 'LineWidth', 1);
    set(hline([3:4]),'LineWidth',2,'LineStyle','-');
    ylim([0 80]);
    hlegend = findobj(gcf,'Type','axes','Tag','legend');
    set(hlegend, 'Location', 'best');
    set(handles.gui, 'Name', 'V2 Laboratory: Airborne Sound Insulation');
    
    % ask user if he wants to continue (yes, no)
    choice = questdlg('Continue?', 'SNR sufficiently high?', 'Yes','No, abort', 'No, abort');
    switch choice
        case 'No, abort'
            % abort
            % temporarily save plot
            export_fig(handles.currentAxes(1),  fullfile(pwd, 'temp.jpg'), '-painters')
            handles.snrPlotTempFileJpg = strcat(pwd,'/temp.jpg');
            guidata(handles.gui, handles);
            
            % ...  and move temporary SNR plot from current directory to outputDirectory
            snrPlotPathJpg = strcat(outputDirectory,'/SNR_fftdegree',num2str(measurementProperties.samples),'_', filename,'.jpg');
            movefile(handles.snrPlotTempFileJpg,snrPlotPathJpg);
            
            appendToEventLog(handles,'Measurement aborted.');
            return;
    end  
    
    % temporarily save plot
    export_fig(handles.currentAxes(1),  fullfile(pwd, 'temp.jpg'), '-painters')
    handles.snrPlotTempFileJpg = strcat(pwd,'/temp.jpg');
    guidata(handles.gui, handles);
     
elseif(handles.v2.measurementProperties.sourcePositions > 1)
    filename = handles.v2.genFilenameString();
    % show SNR plots
    set(handles.currentAxes(1), 'position', [0.252 0.66 0.735 0.300]);
    handles.currentAxes(2) = axes('tag', 'ax2');
    set(handles.currentAxes(2), 'position', [0.252 0.31 0.735 0.300]);
    
    % SNR plot of first measurement
    set(handles.gui, 'CurrentAxes', handles.currentAxes(1));
    hh = ita_plot_freq(handles.v2.SNR(1), 'figure_handle', handles.gui, 'axes_handle', handles.currentAxes(1), 'FontSize', 9);
    title(handles.currentAxes(1), ['Signal-to-Noise Ratio of first measurement in 1/3 octave bands, ' ...
        handles.v2.genMaterialString(),', fftdegree',num2str(measurementProperties.samples)], 'FontSize', 9);
    hline = findobj(handles.currentAxes(1), 'type', 'line');
    set(hline,'LineStyle','--', 'LineWidth', 1);
    set(hline([1:2]),'LineWidth',2,'LineStyle','-')
    ylim(handles.currentAxes(1), [0 80]);
    
    % hide x-label of top plot 
    hxlabel = get(handles.currentAxes(1), 'XLabel');
    set(hxlabel, 'visible', 'off');
  
    % SNR plot of mean
    set(handles.gui, 'CurrentAxes', handles.currentAxes(2));
    hh = ita_plot_freq(handles.v2.SNR_m, 'figure_handle', handles.gui, 'axes_handle', handles.currentAxes(2), 'FontSize', 9);
    title(handles.currentAxes(2), ['Mean Signal-to-Noise Ratio over ' num2str(handles.v2.measurementProperties.sourcePositions)...
        ' positions in 1/3 octave bands, ' handles.v2.genMaterialString(),', fftdegree = ',num2str(measurementProperties.samples)],...
        'FontSize', 9);
    hline = findobj(handles.currentAxes(2), 'type', 'line');
    set(hline,'LineStyle','--', 'LineWidth', 1);
    set(hline([1:2]),'LineWidth',2,'LineStyle','-');
    ylim(handles.currentAxes(2), [0 80]);
      
    % move legends out of the way
    hl = findobj(handles.gui, 'Tag', 'legend');
    set(hl(2), 'Position', [0.28 0.6680 0.1431 0.2638]);
    set(hl(1), 'Position', [0.28 0.322 0.1756 0.2638]);

    ax1 = handles.currentAxes(1);
    ax2 = handles.currentAxes(2);

    % move axes to a figure, s.t. it can be passed to export_fig, make it 
    % look good and temporarily save it
    fh = figure();
    set(fh, 'position', [100 100 1000 620]);    
    ha1 = copyobj(handles.currentAxes(1), fh);
    set(ha1, 'units', 'pixel');
    set(ha1, 'position', [50 350 940 250]);
    hxlbl1 = get(ha1, 'XLabel');
    set(hxlbl1, 'visible', 'off');
    hla1 = copyobj([hl(1) ax1],fh);
    set(hla1, 'position', [0.79 0.6 0.1760 0.3208])
    ha2 = copyobj(handles.currentAxes(2), fh);
    set(ha2, 'units', 'pixel');
    set(ha2, 'position', [50 50 940 250]);
    hla2 = copyobj(hl(2), fh);
    set(hla2, 'position', [0.79 0.12 0.1760 0.3208])  
    export_fig(fh,  fullfile(pwd, 'temp.jpg'), '-painters')
    %ita_savethisplot(handles.gui,fullfile(pwd,'temp.fig'),'resolution',300);
    handles.snrPlotTempFileJpg = strcat(pwd,'/temp.jpg');
    %handles.snrPlotTempFileFig = strcat(pwd,'/temp.fig');
    guidata(handles.gui, handles);    
    delete(fh);
    set(handles.gui, 'Name', 'V2 Laboratory: Airborne Sound Insulation');
    
    % ask user if he wants to continue (yes, no)
    choice = questdlg('Continue?', 'SNR sufficiently high?', 'Yes','No, abort', 'No, abort');
    switch choice
        case 'No, abort'
            % abort
            appendToEventLog(handles,'Measurement aborted.');
%             delete('temp.jpg');     % delete temporarily saved SNR plots
%             delete('temp.fig');
            
            % temporarily save plot
            export_fig(handles.currentAxes,  fullfile(pwd, 'temp.jpg'), '-painters')
            handles.snrPlotTempFileJpg = strcat(pwd,'/temp.jpg');
            guidata(handles.gui, handles);
            
            % ...  and move temporary SNR plot from current directory to outputDirectory
            snrPlotPathJpg = strcat(outputDirectory,'/SNR_fftdegree',num2str(measurementProperties.samples),'_',filename,'.jpg');
            movefile(handles.snrPlotTempFileJpg,snrPlotPathJpg);
            return;
    end  
    
    % reset axes
    delete(handles.currentAxes(2));
    set(handles.currentAxes(1), 'position', [0.252 0.294 0.735 0.638]);
    handles.currentAxes(2) = [];
end

% continue: plot R...
set(handles.currentAxes(1), 'NextPlot', 'replace');
ita_plot_freq(handles.v2.R, 'figure_handle', handles.gui, 'axes_handle', handles.currentAxes(1), 'hold', 'off', 'ylim', [0,60], 'xlim', [315,20000], 'FontSize', 9);
title(handles.currentAxes(1), ['Sound Insulation, ' 'R_W(f=500Hz) = ' num2str(handles.v2.soundInsulationIndex) 'dB, ' ...
    handles.v2.genMaterialString()], 'FontSize', 9);
ylabel(handles.currentAxes(1), 'Sound insulation [dB]', 'FontSize', 9);
xlabel(handles.currentAxes(1), 'Frequency [Hz]', 'FontSize', 9);
% ... and the reference curve
hold(handles.currentAxes(1), 'on');
ref_values = 20*log10(handles.v2.soundInsulationCurve);
ref_freqs = ~isnan(ref_values)
h = plot(handles.currentAxes(1), handles.v2.R.freqVector(ref_freqs,1), ref_values(ref_freqs), 'r', 'LineWidth', 2, 'Color', 'g');
hLegend = legend(handles.currentAxes(1),'R measured', 'R calculated (mass law)', 'Shifted reference curve', 'Location', 'South');
ylim('auto');
set(handles.gui, 'Name', 'V2 Laboratory: Airborne Sound Insulation');

str = strcat('Measurement complete. Sound Insulation Index at 500Hz = ', num2str(handles.v2.soundInsulationIndex), 'dB.');
appendToEventLog(handles,str);
handles = guidata(handles.gui);
handles.status = 'postMeasurement';
guidata(handles.gui, handles);

% setup directory
if( isempty(outputDirectory) && ~isdir(outputDirectory))
    appendToEventLog(handles,'Error: invalid output directory. Plot not saved.');
    handles = guidata(handles.gui);
    return;
end
% create it if it does not exist
[status,message,messageid] = mkdir(outputDirectory);
if( status == 0)
    appendToEventLog(handles, 'Error: output directory could not be created. Reason: ', message);
    handles = guidata(handles.gui);
end

% save R plot...
export_fig(handles.currentAxes(1),  fullfile(outputDirectory,['R_', filename, '.jpg']), '-painters');
saveas(handles.currentAxes(1),  fullfile(outputDirectory,['R_', filename]),'fig')
% ...  and move temporary SNR plot from current directory to outputDirectory
snrPlotPathJpg = strcat(outputDirectory,'/SNR_fftdegree',num2str(measurementProperties.samples),'_',filename,'.jpg');
movefile(handles.snrPlotTempFileJpg,snrPlotPathJpg);
appendToEventLog(handles,strcat('Plots saved at  ', outputDirectory));
guidata(handles.gui, handles);


function MaterialPopupMenu_Callback(hObject, eventdata, handles)
% hObject    handle to MaterialPopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaterialPopupMenu as text
%        str2double(get(hObject,'String')) returns contents of MaterialPopupMenu as a double
test = get(hObject, 'String');
checkMaterialPropVisibility(handles);


% --- Executes during object creation, after setting all properties.
function MaterialPopupMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaterialPopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function YoungsTextEdit_Callback(hObject, eventdata, handles)
% hObject    handle to YoungsTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YoungsTextEdit as text
%        str2double(get(hObject,'String')) returns contents of YoungsTextEdit as a double


% --- Executes during object creation, after setting all properties.
function YoungsTextEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YoungsTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThicknessTextEdit1_Callback(hObject, eventdata, handles)
% hObject    handle to ThicknessTextEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThicknessTextEdit1 as text
%        str2double(get(hObject,'String')) returns contents of ThicknessTextEdit1 as a double


% --- Executes during object creation, after setting all properties.
function ThicknessTextEdit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThicknessTextEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThicknessTextEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to ThicknessTextEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThicknessTextEdit2 as text
%        str2double(get(hObject,'String')) returns contents of ThicknessTextEdit2 as a double


% --- Executes during object creation, after setting all properties.
function ThicknessTextEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThicknessTextEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThicknessTextEdit3_Callback(hObject, eventdata, handles)
% hObject    handle to ThicknessTextEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThicknessTextEdit3 as text
%        str2double(get(hObject,'String')) returns contents of ThicknessTextEdit3 as a double


% --- Executes during object creation, after setting all properties.
function ThicknessTextEdit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThicknessTextEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OpeningAreaTextEdit_Callback(hObject, eventdata, handles)
% hObject    handle to OpeningAreaTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OpeningAreaTextEdit as text
%        str2double(get(hObject,'String')) returns contents of OpeningAreaTextEdit as a double


% --- Executes during object creation, after setting all properties.
function OpeningAreaTextEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OpeningAreaTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DensityTextEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DensityTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DensityTextEdit as text
%        str2double(get(hObject,'String')) returns contents of DensityTextEdit as a double


% --- Executes during object creation, after setting all properties.
function DensityTextEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DensityTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function directoryTextEdit_Callback(hObject, eventdata, handles)
% hObject    handle to directoryTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of directoryTextEdit as text
%        str2double(get(hObject,'String')) returns contents of directoryTextEdit as a double


% --- Executes during object creation, after setting all properties.
function directoryTextEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directoryTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MeasurementsTextEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MeasurementsTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MeasurementsTextEdit as text
%        str2double(get(hObject,'String')) returns contents of MeasurementsTextEdit as a double


% --- Executes during object creation, after setting all properties.
function MeasurementsTextEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MeasurementsTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SamplesTextEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SamplesTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SamplesTextEdit as text
%        str2double(get(hObject,'String')) returns contents of SamplesTextEdit as a double


% --- Executes during object creation, after setting all properties.
function SamplesTextEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SamplesTextEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set( handles.okButtonClicked, 'String', 'Hello OpeningFnc' );
handles.okButtonClicked = true;
guidata( hObject, handles );	
close(handles.gui);

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)	
close(handles.gui);

% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, handles)
% hObject    handle to browseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir('C:', 'Choose directory');
set(handles.directoryTextEdit, 'String', folder_name);  
%varargout{1} = folder_name;

function statusTextEdit_Callback(hObject, eventdata, handles)
% hObject    handle to eventLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eventLog as text
%        str2double(get(hObject,'String')) returns contents of eventLog as a double


% --- Executes during object creation, after setting all properties.
function eventLog_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closeTestbenchButton.
function closeTestbenchButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeTestbenchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.gui);
