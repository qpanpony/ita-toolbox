function  ita_impedance_tube_gui
%ITA_IMPEDANCE_TUBE_GUI - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_impedance_tube_gui(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_impedance_tube_gui(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_impedance_tube_gui">doc ita_impedance_tube_gui</a>

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  19-Nov-2014
%% todos:
% - browse button f�r pfad
% - ita_preferences button & update des sound devices
% -  auto check felder: temp+humid auf isvalue
% -  name der probe mit genvarname ersetzen
% - bei check MS auch die gefensterte version plotten
% - transmission einbauen
% set in base var names auf sonerzeichen pr�fen 'UL200.1'
%% Initialization and Input Parsing
% sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
% [input,sArgs] = ita_parse_arguments(sArgs,varargin);

%% choose kundt tube setup
gData.currentTubeSetup = ita_impedance_tube_setup('GUI');

if isempty(gData.currentTubeSetup)
    return
end

%% create GUI
gData.h.fgh = figure('position', [100 100 800 800],  'name', mfilename, 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'tag', mfilename, 'nextPlot', 'new', 'menubar', 'none', 'CloseRequestFcn', @closeReqFunction);
centerfig(gData.h.fgh)
defaultOptions = { 'parent', gData.h.fgh, 'units', 'normalized'};
gData.h.txt_headLine = uicontrol('style', 'text', 'string', 'Impedance Tube Measurement', defaultOptions{:}, 'position', [0.05 0.87 0.9 0.1], 'fontsize', 30);

% material data
gData.h.pa_materialData  = uipanel( gData.h.fgh, 'units', 'normalized', 'position', [0.05 0.5 0.9 0.35], 'title', 'Material Data');
xPos = 0.35;
gData.h.txt_materialName  = uicontrol('style', 'text', 'string', 'Name of Material:','units', 'normalized',  'position', [0.05 0.87 xPos-0.075 0.1],'parent', gData.h.pa_materialData , 'horizontalAlignment', 'right', 'fontsize', 15);
gData.h.ed_materialName   = uicontrol('style', 'edit', 'string', 'Probe_01_Sample1', 'units', 'normalized', 'position',  [xPos 0.87 0.95-xPos 0.1],'parent', gData.h.pa_materialData  , 'fontsize', 12);

gData.h.txt_temperature   = uicontrol('style', 'text', 'string', 'Temperature in C:', 'units', 'normalized', 'position', [0.05 0.75 xPos-0.075 0.1],'parent', gData.h.pa_materialData ,  'horizontalAlignment', 'right', 'fontsize', 15 );
gData.h.ed_temperature    = uicontrol('style', 'edit', 'string', '20.1','units', 'normalized',  'position',  [xPos 0.75 0.95-xPos 0.1],'parent', gData.h.pa_materialData  , 'fontsize', 12);

gData.h.txt_humidity      = uicontrol('style', 'text', 'string', 'Relative Humidity in %','units', 'normalized',  'position', [0.05 0.63 xPos-0.075 0.1],'parent', gData.h.pa_materialData , 'horizontalAlignment', 'right', 'fontsize', 15 );
gData.h.ed_humidity       = uicontrol('style', 'edit', 'string', '50.2' , 'units', 'normalized' , 'position',  [xPos 0.63 0.95-xPos 0.1],'parent', gData.h.pa_materialData, 'fontsize', 12);

gData.h.txt_path          = uicontrol('style', 'text', 'string', 'Save folder','units', 'normalized',  'position', [0.05 0.51 xPos-0.075 0.1],'parent', gData.h.pa_materialData , 'horizontalAlignment', 'right', 'fontsize', 15 );
gData.h.ed_path           = uicontrol('style', 'edit', 'string',  pwd   ,      'units', 'normalized' , 'position',  [xPos 0.51 0.84-xPos 0.1],'parent', gData.h.pa_materialData, 'fontsize', 12);
gData.h.pb_path           = uicontrol('style', 'pushbutton', 'string',  'Select' , 'units', 'normalized' , 'position',  [0.85 0.51 0.1 0.1],'parent', gData.h.pa_materialData, 'fontsize', 12, 'callback', @selectPath);



% measuremant buttons
gData.h.pa_measurement  = uipanel( gData.h.fgh, 'units', 'normalized', 'position', [0.05 0.2 0.9 0.27], 'title', 'Measurment');
gData.h.txt_measurementButtons = zeros(4,1);
gData.h.pb_measurementButtons = zeros(4,1);
gData.h.txt_measurementInfo = zeros(4,1);

for iMicPos = 1:4
    height = ((5-iMicPos)*3-2) / 13;
    gData.h.txt_measurementButtons(iMicPos) = uicontrol('style', 'text', 'parent', gData.h.pa_measurement, 'units', 'normalized', 'position', [0.1 height 0.2 2/13], 'string', 'Run measurement', 'fontsize', 12, 'horizontalAlignment', 'right');
    gData.h.pb_measurementButtons(iMicPos) = uicontrol('style', 'pushbutton', 'parent', gData.h.pa_measurement, 'units', 'normalized', 'position', [1/3 height 0.3 2/13], 'string', sprintf('Mic Position %i', iMicPos), 'callback', @runMeasurement);
    gData.h.txt_measurementInfo(iMicPos) = uicontrol('style', 'text', 'parent', gData.h.pa_measurement, 'units', 'normalized', 'position', [2/3 height 0.3 2/13], 'string', '(no measurment available)', 'fontsize', 10);
end

gData = updateGUI(gData);

% function calls
gData.h.pb_calculate     = uicontrol('style', 'pushbutton', 'parent', gData.h.fgh, 'units', 'normalized', 'position', [0.7 0.1 0.2 0.05], 'string', 'Calculate', 'callback', @calc);
gData.h.pb_exportGUIdata = uicontrol('style', 'pushbutton', 'parent', gData.h.fgh, 'units', 'normalized', 'position', [0.7 0.06 0.2 0.03], 'string', 'Export GUI data', 'callback', @exportGUIdataToWorkspace);

gData.h.pb_editMS = uicontrol('style', 'pushbutton', 'parent', gData.h.fgh, 'units', 'normalized', 'position', [0.45 0.1 0.2 0.05], 'string', 'Measurement Setup', 'callback', @editMeasurmentSetup);
gData.h.pb_checkMS = uicontrol('style', 'pushbutton', 'parent', gData.h.fgh, 'units', 'normalized', 'position', [0.45 0.06 0.2 0.03], 'string', 'Check MS', 'callback', @checkMeasurementSetup);

gData.h.pb_editKundtSetup = uicontrol('style', 'pushbutton', 'parent', gData.h.fgh, 'units', 'normalized', 'position', [0.20 0.1 0.2 0.05], 'string', 'Tube Setup', 'callback', @editTubeSetup);

gData.h.pb_automatic = uicontrol('style', 'pushbutton', 'parent', gData.h.fgh, 'units', 'normalized', 'position', [0.20 0.06 0.15 0.03], 'string', 'Automatic', 'callback', @automaticMode);
gData.h.ed_automatic = uicontrol('style', 'edit',       'parent', gData.h.fgh, 'units', 'normalized', 'position', [0.36 0.06 0.04 0.03], 'string', '5');

%% Default Measurement Setup

fftDegree   = 17;
freqRange   = round(gData.currentTubeSetup.freqRange .* [1/1.2 1.2]);
type  = 'exp';
stopMargin  = 0.1;

inputCh      = 1;
outputCh     = 3;

outputamplification = -20;
commentStr = ['Kundt''s tube measurement (' datestr(now)  ')'];

pauseTime           = 0.1;
averages            = 2;


%% create MFTF object

gData.MeasurementSetup = itaMSTF('freqRange', freqRange, 'fftDegree', fftDegree, 'stopMargin', stopMargin, 'useMeasurementChain', false,'inputChannels', inputCh, 'outputChannels', outputCh, 'averages', averages, 'pause' , pauseTime, 'comment', commentStr, 'type', type, 'outputamplification', outputamplification );
% gData.MeasurementSetup.edit

%%


guidata(gData.h.fgh, gData)

%end function
end


function runMeasurement(buttonPressed, ~)
gData = guidata(buttonPressed);
oldColor = get(buttonPressed, 'backgroundcolor');
set(buttonPressed, 'backgroundcolor', [1 0.7 0.7]);
iMic = find(gData.h.pb_measurementButtons == buttonPressed);
[gData.rawMeasurements(iMic), maxRecValue]  = gData.MeasurementSetup.run;
set(buttonPressed, 'backgroundcolor', oldColor);
set(gData.h.txt_measurementInfo(iMic) , 'String', sprintf(' %s (%2.1f dBFS)', datestr(now, 'HH:MM:SS'), 20*log10(maxRecValue)))
guidata(gData.h.fgh, gData)

if iMic < gData.currentTubeSetup.nMicrophones % => next mic
    uicontrol(gData.h.pb_measurementButtons(iMic+1))
else % calc button
     uicontrol(gData.h.pb_calculate)
end

end



function calc(obj,~)

gData = guidata(obj);

temperature = ita_str2num(get(gData.h.ed_temperature, 'string'));
humidity = ita_str2num(get(gData.h.ed_humidity, 'string'));
nameOfProbe = get(gData.h.ed_materialName, 'string');
savePath = get(gData.h.ed_path, 'string');


rho0    = double(ita_constants('rho_0', 'T', temperature, 'phi', humidity/100));
c0      = double(ita_constants('c',     'T', temperature, 'phi', humidity/100));

rawMeasurements =   gData.rawMeasurements.merge;
% rawMeasurements = ita_read('D:\[Archiv]\Messungen\[Kundtsches Rohr]\2014-11-18 - RUAG Fix\schallhart_dist_raw.ita');
options.doSineMerge = gData.currentTubeSetup.doSineMerge;
% calculation
[Z, R] = ita_impedance_tube_calculation(rawMeasurements, c0, rho0, gData.currentTubeSetup.micPositions,  gData.currentTubeSetup.freqRange, gData.currentTubeSetup.dampingDimension, gData.currentTubeSetup.crossingFreq, gData.currentTubeSetup.windowTime, gData.currentTubeSetup.timeShift,options);

% calc alpha
alpha = 1 - abs(R)^2;
alpha.allowDBPlot = 0;
alpha.plotAxesProperties = {'ylim', [-0.1 1.1], 'xlim', gData.currentTubeSetup.freqRange};
alpha.channelNames{1} = [strrep(nameOfProbe, '_', ' ') ' : absorption'];

% add meta information
userData = struct('tubeSetup', gData.currentTubeSetup, 'temperature', temperature, 'humidity', humidity, 'rho0', rho0, 'c0', c0, 'windowTime', gData.currentTubeSetup.windowTime);
[R.userData, Z.userData, alpha.userData, rawMeasurements.userData ] = deal(userData);
[R.comment, Z.comment, alpha.comment, rawMeasurements.comment] = deal(nameOfProbe);

uicontrol(gData.h.ed_materialName)
% plot
alpha.plot_freq
R.allowDBPlot = false;
% R.plot_cmplx

% save

ita_write(rawMeasurements,    fullfile(savePath, [nameOfProbe '_rawMeasurement.ita' ]))
ita_write(alpha,    fullfile(savePath, [nameOfProbe '_alpha.ita' ]))
ita_write(R,    fullfile(savePath, [nameOfProbe '_R.ita' ]))

ita_setinbase(nameOfProbe, Z)
ita_setinbase([nameOfProbe '_alpha'], alpha)


end


function editMeasurmentSetup(obj, ~)
gData = guidata(obj);
gData.MeasurementSetup.edit
gData = updateGUI(gData); % reset measurments
guidata(obj,gData);
end

function checkMeasurementSetup(obj, ~)
gData = guidata(obj);
mb_handle = msgbox('SNR measurement in progress...');
[~, rawSingnal, rawNoise] = gData.MeasurementSetup.run_snr;
impulseResponse = rawSingnal*gData.MeasurementSetup.compensation;
if ishandle(mb_handle)
    close(mb_handle)
end

plotVar = merge(rawSingnal, rawNoise);
plotVar.channelNames = {'Signal' 'Noise'};

if gData.currentTubeSetup.timeShift
    impulseResponse = ita_time_shift(impulseResponse);
end
if ~isempty(gData.currentTubeSetup.windowTime)
     impulseResponse = merge(impulseResponse, ita_time_window(impulseResponse, gData.currentTubeSetup.windowTime, 'time', 'symmetric', gData.currentTubeSetup.windowSymmetric));
     impulseResponse.channelNames = {'Impulse response' 'Windowed Impulse Response'};
     signalWin = impulseResponse.ch(2)*gData.MeasurementSetup.raw_excitation;
     plotVar = merge(plotVar, signalWin);
     plotVar.channelNames{3} = 'Signal after windowing';
end   


fgh = ita_plottools_figure;
ita_plot_freq(plotVar, 'figure_handle', fgh, 'axes_handle', subplot(211));
title('Signal to noise ratio')

ita_plot_time_dB(impulseResponse, 'figure_handle', fgh, 'axes_handle', subplot(212));
title('Impulse response')


end


function editTubeSetup(button, ~)
gData = guidata(button);

userSecletion = ita_impedance_tube_setup('GUI', gData.currentTubeSetup);
if ~isempty(userSecletion )
    gData.currentTubeSetup = userSecletion;
    gData = updateGUI(gData);
    guidata(gData.h.fgh, gData)
    
end
end

function gData = updateGUI(gData)

switch gData.currentTubeSetup.name
    
    case 'Small Kundt''s Tube at ITA Mics1236'
        buttonStrings = ita_sprintf('Mic Position %i', [1:3 6]);
    otherwise
        buttonStrings = ita_sprintf('Mic Position %i', 1:4);
end

% ste new button names
for iButton = 1:4
    set(gData.h.pb_measurementButtons(iButton), 'string', buttonStrings(iButton))
end

% hide 4th button for 3 mic measurement
if gData.currentTubeSetup.nMicrophones == 3
    set([gData.h.txt_measurementInfo(4) gData.h.pb_measurementButtons(4) gData.h.txt_measurementButtons(4)], 'visible', 'off')
end


 set(  gData.h.txt_measurementInfo, 'string',  '(no measurment available)')
gData.rawMeasurements = itaAudio(gData.currentTubeSetup.nMicrophones,1);
ita_verbose_info('Setup changes. Resetting measurements ',1)
end



function closeReqFunction(fgh,~)
gData = guidata(fgh);
if strcmpi(questdlg('Do you really want to end measurements?', 'Close DLG'), 'yes')
    
    ita_setinbase('dataFromImpedanceTubeGUI', gData)
    delete(gData.h.fgh)
end
end

function exportGUIdataToWorkspace(button, ~)

gData = guidata(button);
ita_setinbase('dataFromImpedanceTubeGUI', gData)

fprintf('GUI Data has been exported to workspace: dataFromImpedanceTubeGUI\n')
end

function selectPath(button, ~)
gData = guidata(button);
savePath = get(gData.h.ed_path, 'string');
newPath = uigetdir(savePath, 'select Path to save files');

if newPath
    set(gData.h.ed_path, 'string', newPath)
end

end

function automaticMode(button, ~)
gData = guidata(button);



nSecPause = str2num(get(gData.h.ed_automatic, 'string'));
if ~isnumeric(nSecPause) 
    errordlg('number of seconds is not numeric')
    error('number of seconds is not numeric')
end

fgh = figure('position', [100 100 400 250],  'name', 'Automatic Mode', 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'tag', mfilename, 'nextPlot', 'new', 'menubar', 'none');
centerfig(fgh);
txt_handle =  uicontrol('style', 'text', 'string', '', 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8],'parent', fgh ,  'horizontalAlignment', 'center', 'fontsize', 20 );
bgColor = get(txt_handle, 'backgroundcolor');
printCell = cell(5,1);

printCell{1} = ['Material: ', get(gData.h.ed_materialName, 'string')];


for iMic = 1:gData.currentTubeSetup.nMicrophones
    printCell{3} = sprintf('Next Mic Position: %i', iMic);
    
    if(iMic>1)
        for iSec = nSecPause:-1:0
            printCell{5} = sprintf('Next Measurement in %i s',iSec);
            set(txt_handle, 'string', printCell)
            pause(1)
        end
    end
    
    printCell{5} = sprintf('Measurement running...');
    set(txt_handle, 'string', printCell)
    set(txt_handle, 'backgroundcolor', [1 0.7 0.7]);
    
    runMeasurement( gData.h.pb_measurementButtons(iMic), [])
    uicontrol(txt_handle)
    printCell{5} = sprintf('Measurement done.');
    set(txt_handle, 'string', printCell)
    set(txt_handle, 'backgroundcolor', bgColor);
    
    
    
end

close(fgh)
calc(gData.h.pb_measurementButtons(iMic))


end
