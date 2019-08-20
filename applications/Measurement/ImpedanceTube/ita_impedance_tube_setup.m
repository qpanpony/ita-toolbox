function outputTubeSetup = ita_impedance_tube_setup(varargin)
%ITA_IMPEDANCE_TUBE_SETUP - get parameters for standard tube configurations
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_impedance_tube_setup(audioObjIn, options)
%
%    micPositions:      microphone positions with respect to reference plane
%    dampingDimension   used to compesate the air damping acc to ISO 10534
%
%  Example:
%   audioObjOut = ita_impedance_tube_setup(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_impedance_tube_setup">doc ita_impedance_tube_setup</a>

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  22-Nov-2014


%% function calls:
% par = ita_impedance_tube_setup('Small Kundt''s Tube at ITA Mics123')
% par = ita_impedance_tube_setup('GUI')
% par = ita_impedance_tube_setup('GUI', currentPar)
% allPar = ita_impedance_tube_setup

% timeShift
% window time!

%%

if nargin == 0
    outputTubeSetup = getDefaultTubeSetupData();
    
elseif strcmpi(varargin{1}, 'GUI')
    
    defaultTubeSetup = getDefaultTubeSetupData;
    
    if nargin >= 2
        currentTube = varargin{2};
        
        if strcmpi(currentTube.name, 'CUSTOM')
            defaultTubeSetup(end) = currentTube;
            defaultTubeSelection = numel(defaultTubeSetup);
        else
            defaultTubeSelection = find(strcmpi({defaultTubeSetup.name}, currentTube.name));
            if isempty(defaultTubeSelection)
                
            end
        end
        outputTubeSetup = openGUI(defaultTubeSetup, defaultTubeSelection);
    else
        outputTubeSetup = openGUI(defaultTubeSetup);
    end
    
elseif ischar(varargin{1})
    
    defaultTubeSetup = getDefaultTubeSetupData;
    
    idxTube = find(strcmpi({defaultTubeSetup.name}, varargin{1}));
    
    if isempty(idxTube)
        error(['Unknown input. Possible input strings:' sprintf('\n - ''%s'' ', 'GUI', defaultTubeSetup(1:end-1).name)])
    end
    outputTubeSetup = defaultTubeSetup(idxTube);
    
end

%end function
end


function guioutput = openGUI(tubeSetupData,defaultTubeSelection)
%%

if nargin == 1
    defaultTubeSelection = 1;
end

currentConfig = tubeSetupData(defaultTubeSelection);
h.fgh = figure('position', [100 100 600 800],'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'tag', mfilename, 'nextPlot', 'new', 'menubar', 'none');
lineHeight = 0.05;
defaultOptions= {'parent', h.fgh, 'units', 'normalized', 'fontsize' 11};

offset = 0.1;

currentHeight = 0.75+offset;
h.tx_tilte = uicontrol('style', 'text', defaultOptions{:}, 'position', [0.1 currentHeight 0.8 0.15], 'string', 'Tube Setup', 'fontsize', 40);


currentHeight = 0.7+offset;
h.tx_tubeName = uicontrol('style', 'text', defaultOptions{:}, 'position', [0.1 currentHeight 0.4 lineHeight], 'string', 'Name of tube:');
h.pu_tubeName = uicontrol('style', 'popup', 'parent', h.fgh, 'units', 'normalized', 'position', [0.5 currentHeight 0.4 lineHeight], 'string', {tubeSetupData.name}, 'value', defaultTubeSelection,'Callback', @updateFields);

currentHeight = 0.6+offset;
h.tx_micPositions = uicontrol('style', 'text', defaultOptions{:}, 'position', [0.1 currentHeight 0.4 lineHeight], 'string', 'Microphone position (in mm)');
h.ed_micPositions = uicontrol('style', 'edit', defaultOptions{:}, 'position', [0.5 currentHeight 0.4 lineHeight], 'string', num2str(currentConfig.micPositions*1000));

currentHeight = 0.5+offset;
h.tx_dampingDimension = uicontrol('style', 'text', defaultOptions{:}, 'position', [0.1 currentHeight 0.4 lineHeight], 'string', 'Damping dimension to compensate air absorption (in m)');
h.ed_dampingDimension = uicontrol('style', 'edit', defaultOptions{:}, 'position', [0.5 currentHeight 0.4 lineHeight], 'string', num2str(currentConfig.dampingDimension));


currentHeight = 0.4+offset;
h.tx_freqRange = uicontrol('style', 'text', defaultOptions{:}, 'position', [0.1 currentHeight 0.4 lineHeight], 'string', 'Frequency range (in Hz)');
h.ed_freqRange = uicontrol('style', 'edit', defaultOptions{:}, 'position', [0.5 currentHeight 0.4 lineHeight], 'string', num2str(currentConfig.freqRange));

currentHeight = 0.3+offset;
h.tx_crossingFreq = uicontrol('style', 'text', defaultOptions{:}, 'position', [0.1 currentHeight 0.4 lineHeight], 'string', 'Crossing frequencies (in Hz)');
h.ed_crossingFreq = uicontrol('style', 'edit', defaultOptions{:}, 'position', [0.5 currentHeight 0.4 lineHeight], 'string', num2str(currentConfig.crossingFreq));


currentHeight = 0.2+offset;
h.tx_windowTime = uicontrol('style', 'text', defaultOptions{:}, 'position', [0.1 currentHeight-lineHeight/2 0.4 lineHeight], 'string', 'Window time (in s)');
h.ed_windowTime = uicontrol('style', 'edit', defaultOptions{:}, 'position', [0.5 currentHeight 0.4 lineHeight], 'string', num2str(currentConfig.windowTime));
h.cb_window_sym = uicontrol('style', 'checkbox', defaultOptions{:}, 'position', [0.5 currentHeight-lineHeight*1.1 0.4 lineHeight], 'value', currentConfig.windowSymmetric, 'string', 'Symmetric window');

currentHeight = 0.05+offset;
h.tx_time_shift = uicontrol('style', 'text', defaultOptions{:}, 'position', [0.1 currentHeight 0.4 lineHeight], 'string', 'Shift impulse response to beginning:');
h.cb_time_shift = uicontrol('style', 'checkbox', defaultOptions{:}, 'position', [0.5 currentHeight 0.4 lineHeight], 'value', currentConfig.windowSymmetric, 'string', 'Apply time shift');

currentHeight = 0.05;
h.pb_okay = uicontrol('style', 'pushbutton', defaultOptions{:}, 'position', [0.2 currentHeight 0.2 lineHeight], 'string', 'Okay', 'Callback', @okayCallback);
h.pb_cancel = uicontrol('style', 'pushbutton', defaultOptions{:}, 'position', [0.6 currentHeight 0.2 lineHeight], 'string', 'Cancel', 'callback', @cancelCallback);


gData.h = h;
gData.tubeSetupData = tubeSetupData;

guidata(h.fgh, gData)
updateFields(gData.h.pu_tubeName)
uiwait(h.fgh)
if ishandle(h.fgh)
    gData = guidata(h.fgh);
    close(h.fgh)
    guioutput = gData.output;
else
    guioutput = [];
end

end


function updateFields(popup, ~)
gData = guidata(popup);

tubeNameCell = get(gData.h.pu_tubeName, 'string');

if strcmpi(tubeNameCell{get(popup, 'value')}, 'CUSTOM')
    
    set([gData.h.ed_crossingFreq gData.h.ed_freqRange gData.h.ed_dampingDimension gData.h.ed_micPositions], 'Enable', 'on');
else
    
    set([gData.h.ed_crossingFreq gData.h.ed_freqRange gData.h.ed_dampingDimension gData.h.ed_micPositions], 'Enable', 'off')
    currentConfig = gData.tubeSetupData(get(popup, 'Value'));
    set(gData.h.ed_micPositions,  'string', num2str(currentConfig.micPositions*1000));
    set(gData.h.ed_dampingDimension , 'string', num2str(currentConfig.dampingDimension));
    set(gData.h.ed_freqRange, 'string', num2str(currentConfig.freqRange));
    set(gData.h.ed_crossingFreq ,'string', num2str(currentConfig.crossingFreq));
    
end

end


function tubeSetupData = getDefaultTubeSetupData

tubeSetupData(1).name             = 'Small Kundt''s Tube at ITA Mics123';
tubeSetupData(1).micPositions     = [ 100 117 210] / 1000;
tubeSetupData(1).dampingDimension = 0.0508 ;
tubeSetupData(1).freqRange        = [20 10000];
tubeSetupData(1).crossingFreq     = 1200;
tubeSetupData(1).nMicrophones     = 3;
tubeSetupData(1).windowTime       = [0.18 0.25];
tubeSetupData(1).windowSymmetric  = true;
tubeSetupData(1).timeShift        = true;

tubeSetupData(2).name             = 'Small Kundt''s Tube at ITA Mics1234';
tubeSetupData(2).micPositions     = [100 117 210 500] / 1000;
tubeSetupData(2).dampingDimension = 0.0508 ;
tubeSetupData(2).freqRange        = [20 10000];
tubeSetupData(2).crossingFreq     = [1200 300];
tubeSetupData(2).nMicrophones     = 4;
tubeSetupData(2).windowTime       = [0.18 0.25];
tubeSetupData(2).windowSymmetric  = true;
tubeSetupData(2).timeShift        = true;

tubeSetupData(3).name             = 'Small Kundt''s Tube at ITA Mics1236';
tubeSetupData(3).micPositions     = [100 117 210.55 614.05]/ 1000;
tubeSetupData(3).dampingDimension = 0.0508 ;
tubeSetupData(3).freqRange        = [20 10000];
tubeSetupData(3).crossingFreq     = [1200 190];
tubeSetupData(3).nMicrophones     = 4;
tubeSetupData(3).windowTime       = [0.18 0.25];
tubeSetupData(3).windowSymmetric  = true;
tubeSetupData(3).timeShift        = true;

tubeSetupData(4).name             = 'Big Kundt''s Tube at ITA';
tubeSetupData(4).micPositions     = [ 205 285 335 ] / 1000;
tubeSetupData(4).dampingDimension = 0.15 ;
tubeSetupData(4).freqRange        = [20 2000];
tubeSetupData(4).crossingFreq     = 600;
tubeSetupData(4).nMicrophones     = 3;
tubeSetupData(4).windowTime       = [0.18 0.25];
tubeSetupData(4).windowSymmetric  = true;
tubeSetupData(4).timeShift        = true;

% data taken from paper "vorlaender - acoustic load on the ear caused by
% headphones
tubeSetupData(5).name=  'Rohr mit Ohr';
tubeSetupData(5).micPositions =  [ 25 32 65 ] / 1000;
tubeSetupData(5).freqRange = [100 18000];
tubeSetupData(5).nMicrophones     = 3;
tubeSetupData(5).windowTime       = [0.18 0.25];
tubeSetupData(5).windowSymmetric  = true;
tubeSetupData(5).timeShift        = true;
% for round tubes this is just the diameter in m
tubeSetupData(5).dampingDimension = 10e-3;
tubeSetupData(5).crossingFreq     = 1500;
tubeSetupData(5).doSineMerge = 1; % in the small tube R is merged and critical frequencies are dampend with a sine

tubeSetupData(6)                  = tubeSetupData(4);
tubeSetupData(6).name             = 'CUSTOM';



end


function okayCallback(obj,~)
gData = guidata(obj);


tubeNameCell = get(gData.h.pu_tubeName, 'string');

tubeSetupData.name             = tubeNameCell{get(gData.h.pu_tubeName, 'value')};
tubeSetupData.micPositions     = ita_str2num(get(gData.h.ed_micPositions, 'string')) / 1000;
tubeSetupData.dampingDimension = ita_str2num(get(gData.h.ed_dampingDimension, 'string')) ;
tubeSetupData.freqRange        = ita_str2num(get(gData.h.ed_freqRange, 'string'));
tubeSetupData.crossingFreq     = ita_str2num(get(gData.h.ed_crossingFreq, 'string'));
tubeSetupData.nMicrophones     = numel(tubeSetupData.micPositions);
tubeSetupData.windowTime       = ita_str2num(get(gData.h.ed_windowTime, 'string'));
tubeSetupData.windowSymmetric  = get(gData.h.cb_window_sym, 'value');
tubeSetupData.timeShift        =  get(gData.h.cb_time_shift, 'value');

if strcmp(tubeSetupData.name,'Rohr mit Ohr')
   tubeSetupData.doSineMerge = 1; 
else
   tubeSetupData.doSineMerge = 0;  
end

gData.output = tubeSetupData;

guidata(gData.h.fgh, gData)
uiresume(gData.h.fgh)
end


function cancelCallback(obj,~)
gData = guidata(obj);

gData.output = [];

guidata(gData.h.fgh, gData)
uiresume(gData.h.fgh)
end
