function outStruct = ita_audiometer_preferences(inStruct)



% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% define presets



h.data.presets.parStructs(1)   = struct('norsonic', struct('pulsingFadeSpeed', 300 , 'pulsingPeriod', 20, 'pulsingAttenuation',-40, 'pulsingActive', 1, 'bracketingFadeSpeed', 10), ...
                                'frequencies', -1, 'testMethod',  'bracketing',  'minLevelBetweenResponses', 3, 'ignoreFirstResponses', 1, 'maxDifferenceBetweenResponses', 10, 'responsesNeededForCalculation', 6, 'calib', inStruct.calib);
h.data.presets.parStructs(2)   = struct('norsonic', struct('pulsingFadeSpeed', 300 , 'pulsingPeriod', 20, 'pulsingAttenuation',-40, 'pulsingActive', 0, 'bracketingFadeSpeed', 10), ...
                                'frequencies', -1, 'testMethod',  'ascending',  'minLevelBetweenResponses', 3, 'ignoreFirstResponses', 0, 'maxDifferenceBetweenResponses', 10, 'responsesNeededForCalculation', 5, 'calib', inStruct.calib);

                            
h.data.presets.names        = {'ISO 8253-1: Bracketing' 'ISO 8253-1: Ascending', 'Custom'};


%%

norsonicParameter = inStruct.norsonic;
h.possibleFreq = [ 125 160 200 250 315 400 500 630 750 800 1000 1250 1500 1600 2000 2500 3000 3150 4000 5000 6000 6300 8000];


                   
%%

screenSize = get(0, 'ScreenSize');
% figSize = screenSize(3:4)*0.5;
figSize = [750 600];

% TODO: , 'WindowStyle ', 'modal'
h.f = figure('outerposition',  [(screenSize(3:4)-figSize)/2 figSize ], 'name', 'ita_audiometer_preferences', 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'nextPlot', 'new');%, 'CloseRequestFcn', @CloseRequestFcn);

% presets
h.pa_parameter    = uipanel( h.f, 'units', 'normalized', 'position', [1/30 0.18  0.6 0.81], 'title', 'Parameters');
h.lb_parameter    = uicontrol('style', 'popupmenu', 'parent', h.pa_parameter,'units', 'normalized', 'position', [1/12 0.8 0.6 0.15], 'string',{'ISO 8253-1 Bracketing' 'ISO 8253-1 Ascending' 'custom'}, 'callback', @listBoxCallback);
h.tx_presets      = uicontrol('style', 'text', 'parent', h.pa_parameter, 'units', 'normalized', 'position', [1/12 0.97 0.6  0.025], 'string', 'Presets', 'HorizontalAlignment', 'left');

% alogritm par
algorithmParCell = {'responsesNeededForCalculation' 'maxDifferenceBetweenResponses' 'minLevelBetweenResponses' 'ignoreFirstResponses'};
textCell = {'Responses need for calculation:' 'Max. difference between responses' 'Min. difference between responses' 'Ignore first'};
unitCell = {'responses' 'dB', 'dB' 'samples'};
h.pa_alorithm = uipanel( h.pa_parameter, 'units', 'normalized', 'position', [1/12 0.5  0.763 0.36], 'title', 'Algorithm');
lineHeight = 0.15;
for iPar = 1: numel(algorithmParCell)
    linePos = 1.1 - (iPar )/numel(algorithmParCell );
    h.(['tx_' algorithmParCell{iPar}])         = uicontrol('style', 'text', 'parent', h.pa_alorithm, 'units', 'normalized', 'position', [0.01 linePos 0.62  lineHeight], 'string', textCell{iPar}, 'horizontalAlignment', 'left');
    h.(['ed_' algorithmParCell{iPar}])         = uicontrol('style', 'edit', 'parent', h.pa_alorithm, 'units', 'normalized', 'position', [0.63 linePos 0.15  lineHeight], 'string', '', 'callback', @switch2customPreset);
    h.(['tx_' algorithmParCell{iPar} '_unit']) = uicontrol('style', 'text', 'parent', h.pa_alorithm, 'units', 'normalized', 'position', [0.8 linePos 0.19  lineHeight], 'string', unitCell{iPar}, 'horizontalAlignment', 'left');
end

% DSP Parameter
h.pa_parDSP  = uipanel(h.pa_parameter, 'units', 'normalized', 'position', [2/30+0.28+0.05  0.025  0.45 0.45],'title', 'DSP Parameter');
lineHeight = 0.1;
linePos = 0.8;
h.tx_bracketingFadeSpeed      = uicontrol('style', 'text', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.01       linePos 3/6  lineHeight], 'string', 'Change Rate ', 'HorizontalAlignment', 'right');
h.ed_bracketingFadeSpeed      = uicontrol('style', 'edit', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.03+3/6  linePos 3/12  lineHeight], 'string', norsonicParameter.bracketingFadeSpeed, 'callback', @switch2customPreset);
h.tx_bracketingFadeSpeed_unit = uicontrol('style', 'text', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.05+9/12 linePos 0.15  lineHeight], 'string', 'dB / s');


linePos = 0.6;
h.cb_pulsingActive      = uicontrol('style', 'checkbox', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.03+3/6  linePos 0.4  lineHeight], 'string', 'Use pulsing', 'value', norsonicParameter.pulsingActive,  'callback', @pulsingCallBack);

linePos = 0.4;
h.tx_pulsingAttenuation      = uicontrol('style', 'text', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.01 linePos 3/6  lineHeight], 'string', 'Attenuation ', 'HorizontalAlignment', 'right');
h.ed_pulsingAttenuation      = uicontrol('style', 'edit', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.03+3/6  linePos 3/12  lineHeight], 'string', norsonicParameter.pulsingAttenuation,  'callback', @switch2customPreset);
h.tx_pulsingAttenuation_unit = uicontrol('style', 'text', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.05+9/12 linePos 0.15  lineHeight], 'string', 'dB');

linePos = 0.25;
h.tx_pulsingPeriod      = uicontrol('style', 'text', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.01 linePos 3/6  lineHeight], 'string', 'Period ', 'HorizontalAlignment', 'right');
h.ed_pulsingPeriod      = uicontrol('style', 'edit', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.03+3/6  linePos 3/12  lineHeight], 'string', norsonicParameter.pulsingPeriod, 'callback', @switch2customPreset);
h.tx_pulsingPeriod_unit = uicontrol('style', 'text', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.05+9/12 linePos 0.15  lineHeight], 'string', 'ms');

linePos = 0.1;
h.tx_pulsingFadeSpeed      = uicontrol('style', 'text', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.01 linePos 3/6  lineHeight], 'string', 'Fade speed ', 'HorizontalAlignment', 'right');
h.ed_pulsingFadeSpeed      = uicontrol('style', 'edit', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.03+3/6  linePos 3/12  lineHeight], 'string', norsonicParameter.pulsingFadeSpeed, 'callback', @switch2customPreset);
h.tx_pulsingFadeSpeed_unit = uicontrol('style', 'text', 'parent', h.pa_parDSP, 'units', 'normalized', 'position', [0.05+9/12 linePos 0.15  lineHeight], 'string', 'dB /s');

% frequency
h.pa_freq  = uipanel( h.f, 'units', 'normalized', 'position', [3/30+0.28*2  0.09  0.28 0.9],'title', 'Frequencies');
[freq2take, h.cb_freq] = deal(zeros(size(h.possibleFreq)));
[~, idxFreq2take, ~] = intersect(h.possibleFreq, inStruct.frequencies);
freq2take(idxFreq2take) = 1;
for iFreq = 1:numel(h.possibleFreq)
    linePos = 0.95 * (1 - (iFreq/numel(h.possibleFreq))) + 0.025;
    h.cb_freq(iFreq) =  uicontrol('style', 'checkbox', 'parent', h.pa_freq, 'units', 'normalized', 'position', [0.1  linePos 0.8  0.05], 'string', sprintf('%i Hz', h.possibleFreq(iFreq)), 'value', freq2take(iFreq));
end

% method
h.pa_method = uibuttongroup( h.pa_parameter, 'units', 'normalized', 'position', [1/30+0.05 0.275  0.28 0.2], 'title', 'Method', 'SelectionChangeFcn', @switch2customPreset);
h.rb_method_bracketing = uicontrol('style', 'radiobutton', 'parent', h.pa_method,'units', 'normalized', 'position', [ 2 6 8 2]/10, 'string', 'Bracketing');
h.rb_method_ascending = uicontrol('style', 'radiobutton', 'parent', h.pa_method,'units', 'normalized', 'position', [ 2 3 8 2]/10, 'string', 'Ascending');


% BUTTONS 
h.pb_abbrechen = uicontrol('style', 'pushbutton', 'parent', h.f, 'string', 'Cancel', 'units', 'normalized', 'position', [0.84 0.01 0.1 0.07], 'callback', @cancelCallback);
h.pb_chooseCalib = uicontrol('style', 'pushbutton', 'parent', h.f, 'string', 'Choose Calibration', 'units', 'normalized', 'position', [1/30 0.09 0.15 0.07], 'callback', @chooseCalibCallback);
h.pb_okay = uicontrol('style', 'pushbutton', 'parent', h.f, 'string', 'Okay', 'units', 'normalized', 'position', [0.72 0.01 0.1 0.07], 'callback', @okayCallback);

h.pb_save = uicontrol('style', 'pushbutton', 'parent', h.f,'units', 'normalized', 'position', [0.413 0.01 0.1 0.07], 'string','Save', 'callback', @saveParameter);
h.pb_load = uicontrol('style', 'pushbutton', 'parent', h.f,'units', 'normalized', 'position', [0.533 0.01 0.1 0.07], 'string','Load', 'callback', @loadParameter);

h.data.norsonicParameter = norsonicParameter;
h.data.calib = inStruct.calib;
h.data.output = [];



%%
guidata(h.f, h)
updateGUIfromStruct(h, inStruct)


uiwait()
% todo abbrechenabfuangen

if ishandle(h.f)
    h = guidata(h.f);
    outStruct = h.data.output;
    delete(h.f)
else
    outStruct = [];
end


end

function chooseCalibCallback(self, ~)
h = guidata(self);
[h.data.calib.allCalibData h.data.calib.idxCurrCalib ] = ita_audiometer_chooseCalibration_GUI(h.data.calib.allCalibData,h.data.calib.idxCurrCalib);
%bugfix jri: set the currCalib data after the calibration is selected
h.data.calib.currCalib = h.data.calib.allCalibData(h.data.calib.idxCurrCalib);
guidata(h.f, h)
end


function pulsingCallBack(self, ~)
h = guidata(self);
allPulsingHandles = [h.tx_pulsingAttenuation h.tx_pulsingAttenuation_unit h.ed_pulsingAttenuation h.tx_pulsingPeriod  h.tx_pulsingPeriod_unit h.ed_pulsingAttenuation h.ed_pulsingPeriod   h.tx_pulsingFadeSpeed  h.tx_pulsingFadeSpeed_unit h.ed_pulsingFadeSpeed ];
if get(self, 'value')
    set(allPulsingHandles, 'Enable', 'on')
else
    set(allPulsingHandles, 'Enable', 'off')
end
switch2customPreset(self, [])
    
end


function switch2customPreset(self,~)
h = guidata(self);
set(h.lb_parameter, 'value', numel(get(h.lb_parameter, 'string')));

if get(h.rb_method_ascending, 'value') % ascending
   set(allchild(h.pa_alorithm), 'enable', 'off')
else
    set(allchild(h.pa_alorithm), 'enable', 'on')
end



end

function listBoxCallback(self,~)
h = guidata(self);

idxPreset = get(h.lb_parameter, 'value');

if idxPreset ~= numel(get(h.lb_parameter, 'string')) % else: custom => do nothing
    updateGUIfromStruct(h, h.data.presets.parStructs(idxPreset))
end


fprintf('TODO: was ist mit calib und ISO preset???\n')

end

% function CloseRequestFcn(~,~)
% uiresume()
% end


function okayCallback(hObj, ~)

h = guidata(hObj);
outStruct = readGUIandCreateStruct(h);

h.data.output = outStruct;
guidata(h.f, h);
uiresume
end

function cancelCallback(hObj, ~)

h = guidata(hObj);
outStruct = readGUIandCreateStruct(h);

h.data.output = [];
guidata(h.f, h);
uiresume
end



% read data from gui and save in struct
function outStruct = readGUIandCreateStruct(h)
% DSP parameter
allFieldNames = fieldnames(h.data.norsonicParameter);
for iField = 1:numel(allFieldNames)
    if strcmp(allFieldNames{iField}, 'pulsingActive')
        outStruct.norsonic.(allFieldNames{iField}) = get(h.(['cb_' allFieldNames{iField}]), 'value');
    else % edit field
        outStruct.norsonic.(allFieldNames{iField}) = ita_str2num(get(h.(['ed_' allFieldNames{iField}]), 'string'));
    end
end

% get frequencies
outStruct.frequencies =  h.possibleFreq(logical(cell2mat(get(h.cb_freq, 'value'))));

% methdod
methodnameCell = {'bracketing' 'ascending'};
idxMethod = cell2mat(get([h.rb_method_bracketing h.rb_method_ascending], 'value'));
outStruct.testMethod = methodnameCell{idxMethod == 1};

% Alogrithm parameter
algorithmParCell = { 'minLevelBetweenResponses' 'ignoreFirstResponses'  'maxDifferenceBetweenResponses' 'responsesNeededForCalculation' };
for iPar = 1: numel(algorithmParCell)
    outStruct.(algorithmParCell{iPar}) = str2double(get(h.(['ed_' algorithmParCell{iPar}]) , 'string'));
end

% calib data ( not really form GUI, but needs to be saved)
outStruct.calib = h.data.calib;

end

% read data from struct and update gui
function updateGUIfromStruct(h, parStruct)

% DSP Parameter
allFieldNames = fieldnames(h.data.norsonicParameter);
for iField = 1:numel(allFieldNames)
    if strcmp(allFieldNames{iField}, 'pulsingActive')
        set(h.(['cb_' allFieldNames{iField}]), 'value', parStruct.norsonic.(allFieldNames{iField}));
        
        
        allPulsingHandles = [h.tx_pulsingAttenuation h.tx_pulsingAttenuation_unit h.ed_pulsingAttenuation h.tx_pulsingPeriod  h.tx_pulsingPeriod_unit h.ed_pulsingAttenuation h.ed_pulsingPeriod   h.tx_pulsingFadeSpeed  h.tx_pulsingFadeSpeed_unit h.ed_pulsingFadeSpeed ];
        if parStruct.norsonic.(allFieldNames{iField})
            set(allPulsingHandles, 'Enable', 'on')
        else
            set(allPulsingHandles, 'Enable', 'off')
        end
    else % edit field
        set(h.(['ed_' allFieldNames{iField}]), 'string', num2str(parStruct.norsonic.(allFieldNames{iField})));
    end
end

% get frequencies
if parStruct.frequencies ~= -1    % else  => keep old values
    set(h.cb_freq, 'value', 0);
    [~, ~, idxFreqActive] = intersect(parStruct.frequencies , h.possibleFreq);
    set(h.cb_freq(idxFreqActive), 'value', 1);
end

switch lower(parStruct.testMethod)
    case 'bracketing' 
        set(h.rb_method_bracketing , 'value', 1)
    case 'ascending'
        set(h.rb_method_ascending , 'value', 1)
    otherwise
        error('unknown method')
end

% update alorithm par
algorithmParCell = {'responsesNeededForCalculation' 'maxDifferenceBetweenResponses' 'minLevelBetweenResponses' 'ignoreFirstResponses'};
for iPar = 1: numel(algorithmParCell)
    set(h.(['ed_' algorithmParCell{iPar}]) , 'string', parStruct.(algorithmParCell{iPar}));
end

% calib data ( not really in GUI, but needs to be restore)
h.data.calib = parStruct.calib ;

guidata(h.f, h)
end

function saveParameter(self, ~)
h = guidata(self);
audiometerParameterStruct = readGUIandCreateStruct(h); %#ok<*NASGU>

[fileName, pathName] = uiputfile('*.audiometerPar', 'Save Audiometer Parameter', 'AudiometerParameter.audiometerPar');
if fileName
    save(fullfile(pathName, fileName), 'audiometerParameterStruct')
end

end

function loadParameter(self, ~)
h = guidata(self);

% load parameter struct
[fileName, pathName] = uigetfile('*.audiometerPar', 'Save Audiometer Parameter');
if fileName == 0
    return
end

parData = load(fullfile(pathName, fileName), '-mat');

% add as preset
% oldPresetNames = get(h.lb_parameter, 'string');
% h.data.presets.names = [oldPresetNames{1:end-1} {fileName}, oldPresetNames{end}];
% h.data.presets.parStructs(end+1) = parData.audiometerParameterStruct;
% set(h.lb_parameter, 'string',h.data.presets.names  , 'value', numel(oldPresetNames ));
updateGUIfromStruct(h, parData.audiometerParameterStruct)

guidata(h.f, h)
end

