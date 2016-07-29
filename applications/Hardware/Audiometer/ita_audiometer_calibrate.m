function ita_audiometer_calibrate()
%ITA_AUDIOMETER_CALIBRATE - calirate audiometer
%  This function calibrates the audiometer with Beyer headphones with a 
%  coupler (IEC 60303).
%
%  Syntax:
%   ita_audiometer_calibrate()
%   ita_audiometer_calibrate(serialObj)
%
%  See also:
%   ita_audiometer, ita_norsonic838
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_audiometer_calibrate">doc ita_audiometer_calibrate</a>

% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  03-Feb-2013


%% init hardware: sondcard and COM port
[gData.serialObj, gData.soundcard.playDeviceID, gData.soundcard.samplingRate] = ita_audiometer_initHardware();

%% values form ISO 389-1:1998
% recommanded reference equivalent threshold sound pressure levels (RETSPL) in a coupler complying with IEC 60303
gData.freqVec = [125 160 200 250 315 400 500 630 750 800 1000 1250 1500 1600 2000 2500 3000 3150 4000 5000 6000 6300 8000];
% gData.RETSPL_THD = [45 37.5 31.5 25.5 20 15 11.5 8.5 7.5 7 7 6.5 6.5 7 9 9.5 10 10 9.5 13 15.5 15 13];
% gData.RETSPL_Beyer = [47.5 40.5 34 28.5 23 18.5 14.5 11.5 9.5 9 8 7.5 7.5 7.5 8 7 6 6 5.5 7 8 9 14.5];
gData.RETSPL = [45 38.5 32.5 27 22 17 13.5 10.5 9 8.5 7.5 7.5 7.5 8 9 10.5 11.5 11.5 12 11 16 21 15.5];
gData.calibData.dBFS_for_RETSPL = nan(numel(gData.freqVec),2);

%% create GUI

%,  'CloseRequestFcn', @closeRegFcn
h.f = figure('position', [100 66 900 500],'name', 'Calibrate Audiometer', 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'nextPlot', 'new');

startDAvolume = -40;
daRange = [-127 0];
h.pa_output = uibuttongroup( h.f, 'units', 'normalized', 'position', [9/30 21.5/30  20/30 8/30], 'title', 'Output', 'SelectionChangeFcn', @updateLevelEditField);

h.tx_daVolume = uicontrol('style', 'text', 'parent', h.pa_output,'units', 'normalized', 'position', [1/20 10/20 18/20 2/20], 'string', sprintf('Output level: %i dBFS', startDAvolume));
h.sl_daVolume = uicontrol('style', 'slider', 'parent', h.pa_output,'units', 'normalized', 'position', [1/20 3/20 18/20 5/20], 'max', daRange(2), 'min', daRange(1), 'sliderStep', [1 10]/diff(daRange), 'callback', @sliderCallback, 'value', startDAvolume);

h.rb_left  = uicontrol('style', 'radiobutton', 'parent', h.pa_output,'units', 'normalized', 'position', [ 7 15 3 3]/20, 'string', 'left channel');
h.rb_right = uicontrol('style', 'radiobutton', 'parent', h.pa_output,'units', 'normalized', 'position', [10 15 3 3]/20, 'string', 'right channel');

h.lb_freq  = uicontrol('style', 'listbox', 'parent', h.f, 'units', 'normalized', 'position', [ 1 1 7 28]/30, 'string', '', 'callback', @updateLevelEditField );

h.pa_value       = uipanel( h.f, 'units', 'normalized', 'position', [9/30 6/30  20/30 15/30]);
h.tx_unit        = uicontrol('style', 'text', 'parent', h.pa_value, 'units', 'normalized', 'position', [0.66 0.3 0.1 0.1], 'string', 'dB SPL', 'fontsize', 13, 'HorizontalAlignment', 'left');
h.tx_level       = uicontrol('style', 'text',        'parent', h.pa_value, 'units', 'normalized', 'position', [ 3 10 10 8]/20, 'string', 'Connect Beyer DT 48 earphone (with flat cushion) to artificial ear IEC 60318 Adjust an appropriate output level. Then press "Play". Insert measured SPL. Press "Next" to calibrate next frequency. ');
h.ed_playingInfo = uicontrol('style', 'text',        'parent', h.pa_value, 'units', 'normalized', 'position', [ 2  1 12 4]/20, 'string', '', 'fontsize', 18);
h.ed_level       = uicontrol('style', 'edit',        'parent', h.pa_value, 'units', 'normalized', 'position', [ 3  6 10 3]/20, 'string', '',         'callback', @applyValue);
h.tb_playback    = uicontrol('style', 'togglebutton','parent', h.pa_value, 'units', 'normalized', 'position', [16 13  3 4]/20, 'string', 'Play','fontsize',10, 'callback', @playToggleButtonCallBack);
h.tb_next        = uicontrol('style', 'pushbutton',  'parent', h.pa_value, 'units', 'normalized', 'position', [16  6  3 3]/20, 'string', 'Next',     'callback', @nextFreq);


h.pb_saveCalib = uicontrol('style', 'pushbutton', 'parent', h.f,'units', 'normalized', 'position', [56/75 0.05 0.1 0.07], 'string', 'Save calib', 'callback', @saveCalibData);
h.pb_Abbrechen = uicontrol('style', 'pushbutton', 'parent', h.f,'units', 'normalized', 'position', [13/15 0.05 0.1 0.07], 'string', 'Cancel', 'callback',@cancelButtonCallback);


% TODO DEL

set(h.lb_freq, 'string', ita_sprintf('Freq:  %i', 1:100))

%% Init Norsonic

ita_norsonic838(gData.serialObj, 'daVolume',      -40 );
ita_norsonic838(gData.serialObj, 'bekesy',        'stop');
ita_norsonic838(gData.serialObj, 'mute',          0);
ita_norsonic838(gData.serialObj, 'pulsingActive', 0);
   
%% save guidata
gData.h = h;
updateFreqListbox(gData)
guidata(gData.h.f, gData)

%end function
end

% save calib data to hard disk
function saveCalibData(s, ~)
gData = guidata(s);

% create calib struct
try
    nameStr = ita_preferences('authorStr');
catch %#ok<CTCH>
    nameStr = 'Max Musterman';
end
inputResult = inputdlg({'User name', 'Comment:'}, 'Calibration information', 1, {nameStr, ''});
calibDataStruct = struct( 'dateOfCalibration', datestr(now), 'userName', inputResult{1}, 'comment', inputResult{2}, 'freqVector', gData.freqVec, 'dBFS_for_RETSPL', gData.calibData.dBFS_for_RETSPL, 'RETSPL', gData.RETSPL);

calibFileName = fullfile(fileparts(which(mfilename)), 'calibData.mat');

if exist(calibFileName, 'file')   % keep old calib information
    oldCalibData = load(calibFileName);
    calibDataStruct = [oldCalibData.calibDataStruct calibDataStruct]; %#ok<NASGU>
end

% write 
save(calibFileName, 'calibDataStruct')
helpdlg('Calibration saved.','Saved');

end

function cancelButtonCallback(s, ~)
gData = guidata(s);
close(gData.h.f)
end

function updateLevelEditField(self, ~)
gData = guidata(self);
currFreqIdx = get(gData.h.lb_freq, 'value');
currChannel = find(cell2mat(get([gData.h.rb_left gData.h.rb_right], 'value')));
calibValue = gData.calibData.dBFS_for_RETSPL(currFreqIdx, currChannel); %#ok<FNDSB>

if isnan(calibValue)
    set(gData.h.ed_level, 'string', '')
else
    currDAoutput = get(gData.h.sl_daVolume, 'value');
    splInCoupler = currDAoutput + gData.RETSPL(currFreqIdx)  - calibValue;
    set(gData.h.ed_level, 'string', sprintf('%2.1f', splInCoupler))
end

end


function applyValue(self, ~)
% read level from edit, save it in gData, update freqListbox
gData = guidata(self);

currFreqIdx = get(gData.h.lb_freq, 'value');
currChannel = find(cell2mat(get([gData.h.rb_left gData.h.rb_right], 'value')));

inputStr = get(gData.h.ed_level, 'string');
inputStr = strrep(inputStr, ',', '.');       % allow ,
splInCoupler = str2double(inputStr);

if ~isnumeric(splInCoupler) || isempty(splInCoupler)
    errordlg('can not read level')
%     return
    error('wrong input')
end

currDAoutput = get(gData.h.sl_daVolume, 'value');

gData.calibData.dBFS_for_RETSPL(currFreqIdx, currChannel) = currDAoutput + gData.RETSPL(currFreqIdx) - splInCoupler;  %#ok<FNDSB>

guidata(gData.h.f, gData)
updateFreqListbox(gData)

end


function updateFreqListbox(gData)
% update freq listbox

% schleife ohne toolbox
signCell = {'ok' , '    '};
freqCell = cell(numel(gData.freqVec),1);
for iFreq = 1:numel(gData.freqVec)
    freqCell{iFreq} = sprintf(' % 8i Hz \t (left:  %s | right:   %s )', gData.freqVec(iFreq), signCell{isnan(gData.calibData.dBFS_for_RETSPL(iFreq,1))+1}, signCell{isnan(gData.calibData.dBFS_for_RETSPL(iFreq,2))+1});
end
set(gData.h.lb_freq, 'string', freqCell)

end

function nextFreq(self, ~)
% save value, switch to text freq

applyValue(self); % save entered value

gData = guidata(self);

currFreqIdx = get(gData.h.lb_freq, 'value');


if currFreqIdx < numel(gData.freqVec)
    set(gData.h.lb_freq, 'value', currFreqIdx+1);
else % change channels
    set(gData.h.lb_freq, 'value', 1);
    
    channelHandle = [gData.h.rb_left gData.h.rb_right];
    idxChannelOff = find(~cell2mat(get(channelHandle, 'value')));
    set(channelHandle(idxChannelOff), 'value', 1); %#ok<FNDSB>
end


updateLevelEditField(gData.h.f)

end

function playToggleButtonCallBack(self, ~)

if get(self, 'value')
    gData = guidata(self);
    playSine(gData)
end

end

function playSine(gData)
% function play sine and updates channel and frequency automatic for GUI

% play parameter
blockSize    = gData.soundcard.samplingRate/5 * 1; % for blockSize of 8820 (and multiples) all frequencies have full periods (samplingrate / 5 Hz)
pageBufferCount = 2;

channelNamesCell = {'left channel' 'right channel'};
currFreq = gData.freqVec(get(gData.h.lb_freq, 'value'));
currChannel = find(cell2mat(get([gData.h.rb_left gData.h.rb_right], 'value')));
audioData = sin(2*pi* (1:blockSize)' / gData.soundcard.samplingRate * currFreq);

pageBuffer = zeros(pageBufferCount,1);

if ~playrec('isInitialised')
    playrec('init', gData.soundcard.samplingRate, gData.soundcard.playDeviceID, -1);
    fprintf('\t initializing... waiting 0.5 second...\n');
    pause(0.5); %pdi: was 1 before
end

% play sound
pageBuffer = [pageBuffer(2:end); playrec('play',single(audioData),currChannel )]; 

while get(gData.h.tb_playback, 'value')
    
    
    % create new signal
    currFreq = gData.freqVec(get(gData.h.lb_freq, 'value'));
    currChannel = find(cell2mat(get([gData.h.rb_left gData.h.rb_right], 'value')));
    audioData = sin(2*pi* (1:blockSize)' / gData.soundcard.samplingRate * currFreq);
    
    
    set(gData.h.ed_playingInfo, 'string', sprintf('playing %i Hz on %s', currFreq, channelNamesCell{currChannel}));
    
    pageBuffer = [pageBuffer(2:end); playrec('play',single(audioData),currChannel )];
    isFinished = false;
    
    % TODO: auf blocking mode umstellen
    while ~isFinished && pageBuffer(1) % not finished and is valid page no
        pause(0.05);
        isFinished = playrec('isFinished',pageBuffer(1));
    end;
    
end
playrec('delPage',pageBuffer);
set(gData.h.ed_playingInfo, 'string', '');

end
%
function sliderCallback(sliderHandle, ~)
gData = guidata(sliderHandle);

daVolume = round(get(sliderHandle, 'value'));
set(sliderHandle, 'value', daVolume);          % round volume values
set(gData.h.tx_daVolume ,'string', sprintf('Output level: %i dBFS', daVolume));


% set new DA volume
ita_norsonic838(gData.serialObj, 'daVolume', daVolume);
updateLevelEditField(gData.h.f)

end

function closeRegFcn(s,~)
gData = guidata(s);

if strcmpi(gData.serialObj.Status, 'open')
    fclose(gData.serialObj);
end
delete(gData.h.f)
end

