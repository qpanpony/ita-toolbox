function ita_audiometer()
% GUI for norsonic audiometer

% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%
% TODOs:
% - am anfanga axes schön machen
% -


%% init hardware: sondcard and COM port
[gData.serialObj, gData.soundcard.playDeviceID, gData.soundcard.samplingRate, gData.soundcard.outputChannels] = ita_audiometer_initHardware();

% init norsonic
parStruct = struct('daVolume', -127, 'bekesy', 'stop', 'mute',0, 'pulsingActive', 0 );
struct2norsonic(gData.serialObj, parStruct)

%% set default parameter
gData.parameter.frequencies = [125 250 500 750 1000 1500 2000 3000 4000 6000 8000];
gData.parameter.testMethod  = 'bracketing'; % methdod ascending / bracketing

gData.parameter.norsonic = struct('pulsingFadeSpeed', 300 , 'pulsingPeriod', 200, 'pulsingAttenuation',-40, 'pulsingActive', 1, ...
    'bracketingFadeSpeed', 10);

% bracketing parameter
gData.parameter.minLevelBetweenResponses        = 3; % dB
gData.parameter.ignoreFirstResponses            = 1;
gData.parameter.maxDifferenceBetweenResponses   = 10; %dB
gData.parameter.responsesNeededForCalculation   = 6;


%% load calibration
calibFileName = fullfile(fileparts(which(mfilename)), 'calibData.mat');
if exist(calibFileName, 'file')   % keep old calib information
    calibData = load(calibFileName);
    calibData = calibData.calibDataStruct;
else
    error('no calib file found')
end

gData.parameter.calib.allCalibData = calibData;
gData.parameter.calib.idxCurrCalib = numel(calibData);
gData.parameter.calib.currCalib = gData.parameter.calib.allCalibData(gData.parameter.calib.idxCurrCalib);

%% let user adjust parameter
gData.parameter = ita_audiometer_preferences(gData.parameter);

if isempty(gData.parameter)
    fclose(gData.serialObj );
    fprintf('\n serial port: closed\n')
    delete(gData.serialObj )
    return
end


%% create GUI

try
    investigatorName = ita_preferences('authorStr');
catch  %#ok<CTCH>
    fprintf('ITA-Toolbox not found. Investigator name unknown.')
    investigatorName = '';
end


% TODO:
% -relative to scrren size
h.f = figure('position', [100 100 1200 800], 'name', mfilename, 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'nextPlot', 'new');% , 'CloseRequestFcn', @closeRegFcn);

% axes
h.ax_currLevel    = axes('Parent', h.f, 'outerposition', [0 0.5 0.8 0.45]);
h.ax_audiogram    = axes('Parent', h.f, 'outerposition', [0 0   0.8 0.5]);


h.tx_currFreq = uicontrol('style', 'text', 'parent', h.f, 'units', 'normalized', 'position', [0.3 0.93  0.2 0.04], 'string', '', 'fontsize', 15 );
%panel Personal Data
h.pa_personalData = uipanel( h.f, 'units', 'normalized', 'position', [0.8 0.57 0.19 0.4], 'title', 'Personal Data');

h.tx_name           = uicontrol('style', 'text', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.02 0.8  0.2   0.07], 'string', 'Name', 'FontSize', 10, 'horizontalAlignment', 'left');
h.ed_name           = uicontrol('style', 'edit', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.4  0.8  0.56  0.07]);

h.tx_birthday       = uicontrol('style', 'text', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.02 0.65 0.35  0.07], 'string', 'Date of Birth', 'FontSize', 10, 'horizontalAlignment', 'left');
h.ed_birthday       = uicontrol('style', 'edit', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.4  0.65 0.56  0.07]);
h.tx_investigator   = uicontrol('style', 'text', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.02 0.5  0.3   0.07], 'string',  'Investigator', 'FontSize', 10, 'horizontalAlignment', 'left');
h.ed_investigator   = uicontrol('style', 'edit', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.4  0.5  0.56  0.07], 'string', investigatorName);
h.tx_date           = uicontrol('style', 'text', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.02 0.35 0.2   0.07], 'string', 'Date', 'FontSize', 10, 'horizontalAlignment', 'left');
h.ed_date           = uicontrol('style', 'edit', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.4  0.35 0.56  0.07], 'string', datestr(now, 'dd.mm.yyyy'));
h.tx_comment        = uicontrol('style', 'text', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.02 0.2  0.25  0.07], 'string', 'Comment', 'FontSize', 10, 'horizontalAlignment', 'left');
h.ed_comment        = uicontrol('style', 'edit', 'parent', h.pa_personalData, 'units', 'normalized', 'position', [0.4  0.2  0.56  0.07]);

% buttons
h.pb_start       = uicontrol('style', 'pushbutton',   'parent', h.f, 'units', 'normalized', 'position', [0.89 0.45  1/10 1/15], 'string', 'Start',      'callback',@startFullAudiometry);
h.pb_stop        = uicontrol('style', 'pushbutton',   'parent', h.f, 'units', 'normalized', 'position', [0.89 0.37  1/10 1/15], 'string', 'Stop',   	'callback',@stop, 'enable', 'off');
h.pb_reDoFreq    = uicontrol('style', 'pushbutton',   'parent', h.f, 'units', 'normalized', 'position', [0.89 0.29  1/10 1/15], 'string', 'Redo/add Freq',    'callback',@redoCallback, 'enable', 'off');
h.tb_pause       = uicontrol('style', 'togglebutton', 'parent', h.f, 'units', 'normalized', 'position', [0.89 0.21  1/10 1/15], 'string', 'Pause', 'enable', 'off');
h.pb_preferences = uicontrol('style', 'pushbutton',   'parent', h.f, 'units', 'normalized', 'position', [0.77 0.29  1/10 1/15], 'string', 'preferences','callback',@changePreferences);
h.pb_save        = uicontrol('style', 'pushbutton',   'parent', h.f, 'units', 'normalized', 'position', [0.77 0.45  1/10 1/15], 'string', 'Save',      'callback',@saveResults, 'enable', 'off');
h.pb_nextSubject = uicontrol('style', 'pushbutton',   'parent', h.f, 'units', 'normalized', 'position', [0.77 0.37  1/10 1/15], 'string', 'Next subject',      'callback',@newSubjects, 'enable', 'off');

h.lb_info = uicontrol('style', 'listbox', 'parent', h.f, 'units', 'normalized', 'position', [0.77 0.05  0.22 0.12], 'string', {''});

%% init and save guiData

h.measurementData = [];
gData.h = h;
gData.onlinePar.isRunning = false;
gData.onlinePar.cancelByUser    = false;
guidata(gData.h.f,gData)

if isempty(gData.parameter) % if user closed first preferences window
    close(gData.h.f)
end

end

function newSubjects(s, ~)

gData = guidata(s);

if ~gData.userData.dataSaved
    answer = questdlg('Old data will be lost. Sure you want to start with new subject?', 'Next subject', 'No');
    if any(strcmpi({'No', 'Cancel'}, answer))
        return
    end
end


% adjust pushbuttons
set([gData.h.pb_start gData.h.pb_preferences, gData.h.pb_nextSubject] , 'enable', 'on')
set([gData.h.pb_stop gData.h.pb_reDoFreq gData.h.pb_save  gData.h.tb_pause] , 'enable', 'off')


% reset user info
set([gData.h.ed_name gData.h.ed_birthday gData.h.ed_comment] , 'string', '');

gData.userData.freqVector = gData.parameter.frequencies;
gData.userData.auditoryThreshold = nan(length(gData.userData.freqVector),2);
gData.userData.dataSaved = false;


% plot audiogram
semilogx(gData.h.ax_audiogram, gData.userData.freqVector, gData.userData.auditoryThreshold, '-o', 'linewidth', 2);
set(gData.h.ax_audiogram,  'yDir','reverse', 'xLim', gData.userData.freqVector([1 end]) .* [0.9 1.1], 'ylim', [-25 60], 'YGrid', 'on',  'xscale', 'log', 'XTick', gData.userData.freqVector, 'XTickLabel', num2str(gData.userData.freqVector'), 'XGrid', 'on' )
xlabel(gData.h.ax_audiogram, 'frequency in Hz')
ylabel(gData.h.ax_audiogram, 'level in dB HL')


plot(gData.h.ax_currLevel, 0, 0, 'linewidth', 3, 'color', 'k');
axis(gData.h.ax_currLevel, [0 10 -15 15])
xlabel(gData.h.ax_currLevel, 'time in s')
ylabel(gData.h.ax_currLevel, 'level in dB HL')

set(gData.h.lb_info, 'string', {'New subject'})

drawnow

end



function startFullAudiometry(s,~)
gData = guidata(s);

startTime = now;

% add info
set(gData.h.lb_info , 'string', {'Starting...'})

% set frequency order: first 1k, then increasing, flowed by remaining freqs decreasing, last 1k again
idxFreqOrder = [ find(gData.parameter.frequencies>= 1000) fliplr( find(gData.parameter.frequencies < 1000)) find(gData.parameter.frequencies== 1000)];

hearingThreshold = doAudiometry(gData, gData.parameter.frequencies, idxFreqOrder);
gData.userData.freqVector = gData.parameter.frequencies;
gData.userData.auditoryThreshold = hearingThreshold;
gData.userData.dataSaved = false;
guidata(s, gData);

% add info
minutesNeeded = (now-startTime)* 24*60;
messages = [{sprintf('finished (%02i:%02i)',  floor(minutesNeeded), round(rem(minutesNeeded,1)*60))}; get(gData.h.lb_info , 'String')];
set(gData.h.lb_info , 'string', messages)


set(gData.h.pb_start , 'enable', 'off')

end

function auditoryThreshold = doAudiometry(gData, freqs2check, idxFreqOrder, auditoryThreshold)

if ~exist('auditoryThreshold', 'var') % full audimetry => init with nans, else use old values
    auditoryThreshold  = nan(numel(freqs2check), 2);
end

% plot audiogram
semilogx(gData.h.ax_audiogram, freqs2check, auditoryThreshold, '-o', 'linewidth', 2);
set(gData.h.ax_audiogram,  'yDir','reverse', 'xLim', freqs2check([1 end]) .* [0.9 1.1], 'ylim', [-25 60], 'YGrid', 'on',  'xscale', 'log', 'XTick', freqs2check, 'XTickLabel', num2str(freqs2check'), 'XGrid', 'on' )
xlabel(gData.h.ax_audiogram, 'frequency in Hz')
ylabel(gData.h.ax_audiogram, 'level in dB HL')
drawnow


% adjust pushbuttons
set([gData.h.pb_start gData.h.pb_preferences, gData.h.pb_reDoFreq gData.h.pb_save gData.h.pb_nextSubject] , 'enable', 'off')
set([gData.h.pb_stop gData.h.tb_pause], 'enable', 'on')


channelNames = {'left' 'right'};

% init norsonix with parameter from preferences
struct2norsonic(gData.serialObj, gData.parameter.norsonic)

for iEar = 1:2 % 1:left 2:right
    freqIdxToDo = idxFreqOrder;
    
    while ~isempty(freqIdxToDo)
        pause(0.3) % debug
        currFreq = freqs2check(freqIdxToDo(1));
        set(gData.h.tx_currFreq , 'string', sprintf('%s ear: %i Hz', channelNames{iEar}, currFreq))
        status = checkOneFrequency(gData, currFreq, gData.soundcard.outputChannels(iEar)); % TODO: save detailed result data?
        set(gData.h.tx_currFreq , 'string',  ' ')
        
        switch lower(status)
            case'cancelbyuser'
                fprintf(' cancel freq loop\n')
                break
            case 'restartfreq' % restart current frequency
                continue
        end
        
        if ischar(status) % somethin went wrong: repeat freq
            % add as second last
            fprintf('invalid result for %s channel at freq %i Hz (%s)\n', channelNames{iEar},currFreq, status);
            if numel(freqIdxToDo) > 1
                freqIdxToDo = freqIdxToDo([2:end-1 1 end]);
            end % else just repeat last freq
        else
            % check if repeated 1 kHz measurment gives similar results
            if numel(freqIdxToDo) == 1 && currFreq == 1000
                if  abs(auditoryThreshold(freqIdxToDo(1), iEar) - status) > 10
                    idxWhatToDO = ita_questiondlg(sprintf('First and last measurment of 1 kHz differ (%2.0f dB): according ISO measurement is invalid.', abs(auditoryThreshold(freqIdxToDo(1), iEar) - status)), 'Invalid Measurement', {'Repeat complete ear', 'Take measurements'});
                    
                    if idxWhatToDO == 1 % repeat
                        freqIdxToDo = idxFreqOrder;
                        auditoryThreshold(:, iEar) = nan;
                        continue
                    end
                else
                    fprintf('repeated 1kHz measurement for %s ear is okay (%2.2f and %2.2f )\n', channelNames{iEar}, auditoryThreshold(freqIdxToDo(1), iEar), status )
                end
            end
            
            
            auditoryThreshold(freqIdxToDo(1), iEar) = status;
            freqIdxToDo(1) = [];
            
            % add info
            messages = [{sprintf('%s ear @ %2.1f Hz: %2.1f dB HL', channelNames{iEar},  currFreq, status)}; get(gData.h.lb_info , 'String')];
            set(gData.h.lb_info , 'string', messages)
        end
        % plot audiogram
        semilogx(gData.h.ax_audiogram, freqs2check, auditoryThreshold, '-o', 'linewidth', 2);
        set(gData.h.ax_audiogram,  'yDir','reverse', 'xLim', freqs2check([1 end]) .* [0.9 1.1], 'ylim', [-25 60], 'YGrid', 'on',  'xscale', 'log', 'XTick', freqs2check, 'XTickLabel', num2str(freqs2check'), 'XGrid', 'on' )
        xlabel(gData.h.ax_audiogram, 'frequency in Hz')
        ylabel(gData.h.ax_audiogram, 'level in dB HL')
        drawnow
        
        % pause, for user...
        pause(2)
    end
    if strcmpi(status, 'cancelByUser')
        fprintf(' cancel ear loop\n')
        break
    end
    
end

% adjust pushbuttons
set([gData.h.pb_start gData.h.pb_preferences, gData.h.pb_reDoFreq gData.h.pb_nextSubject] , 'enable', 'on')
set([gData.h.pb_stop gData.h.tb_pause], 'enable', 'off')
if isnumeric(status)
    set(gData.h.pb_save , 'enable', 'on')
    set(gData.h.pb_preferences, 'enable', 'off')
end



end


function redoCallback(s,~)
gData = guidata(s);

[redoFreq addFreq] = ita_audiometer_redoFreq(gData.userData.freqVector);


if isempty([redoFreq addFreq])
    return
end



% add info
messages = [{'Redo/add frequencies...'}; get(gData.h.lb_info , 'String')];
set(gData.h.lb_info , 'string', messages)


% add new frequencies
newThreshold = [gData.userData.auditoryThreshold; nan(numel(addFreq),2)];
newFreq      = [gData.userData.freqVector, addFreq];
[newFreq, freqSortIdx]  = sort(newFreq);
newThreshold            = newThreshold(freqSortIdx,:);

[~, idxFreqOrder ,~] = intersect(newFreq,  [redoFreq addFreq]);

% start...
hearingThreshold = doAudiometry(gData, newFreq, idxFreqOrder, newThreshold);
gData.userData.freqVector = newFreq;
gData.userData.auditoryThreshold = hearingThreshold;
gData.userData.dataSaved = false;
guidata(s, gData);

% add info
messages = [{'Done...'}; get(gData.h.lb_info , 'String')];
set(gData.h.lb_info , 'string', messages)
end

function stop(s,~)
fprintf('\n\nstop callback\n\n')
% stop
gData = guidata(s);
gData.onlinePar.cancelByUser = true;
guidata(gData.h.f, gData);
ita_norsonic838(gData.serialObj, 'bekesy', 'stop')
ita_norsonic838(gData.serialObj, 'daVolume', -127)


% adjust pushbuttons
set([gData.h.pb_start gData.h.pb_preferences] , 'enable', 'on')
set([gData.h.pb_stop gData.h.tb_pause], 'enable', 'off')
end


function saveResults(s,~)
gData = guidata(s);

% save personal data in struct

personalInfo = readUserDataFromGUI(gData);
if isempty(personalInfo)
    return
end

saveStruct = struct('personalInfo', personalInfo, 'AudiometerParameter', gData.parameter, 'result', gData.userData);


%% get filename form user

fileName             = [saveStruct.personalInfo.name '__' saveStruct.personalInfo.date];

pathName             = 'C:\Dokumente und Einstellungen\guski\Eigene Dateien\AudiometerData\';
sonderzeichenCell = {'ä' 'ae' 'ö' 'oe' 'ü' 'ue' 'Ä' 'Ae' 'Ö' 'Oe' 'Ü' 'Ue' 'ß' 'ss' ' ', '_' '.' ''};
for iSonderzeichen = 1:2:numel(sonderzeichenCell)
    fileName = strrep(fileName, sonderzeichenCell{iSonderzeichen}, sonderzeichenCell{iSonderzeichen+1});
end

[fileName, pathName] = uiputfile('*.txt', 'Save', fullfile(pathName, [fileName '.txt']));

if fileName == 0
    return
end

%% save as text file
fid = fopen(fullfile(pathName, fileName), 'w+');
fopen(fid);

fprintf(fid, 'Name: \t\t\t %s\r\n', saveStruct.personalInfo.name);
fprintf(fid, 'Date of investigation: \t %s\r\n', saveStruct.personalInfo.date);
fprintf(fid, 'Birthday: \t\t %s\r\n', saveStruct.personalInfo.birthday);
fprintf(fid, 'Investigator: \t\t %s\r\n', saveStruct.personalInfo.investigator);
fprintf(fid, 'Comment: \t\t %s\r\n', saveStruct.personalInfo.comment);

fprintf(fid, '\r\n\r\n');
fprintf(fid, 'Hearing threshold in dB HL:\r\n\r\n');
fprintf(fid, ' Freq (Hz) \t Links \t Rechts \r\n');
fprintf(fid, ' %i \t  \t %3.1f  \t  %3.1f \r\n', [saveStruct.result.freqVector ; round(saveStruct.result.auditoryThreshold.'*10)/10]);

fclose(fid);

%% save as struct

save(fullfile(pathName,[ fileName(1:end-4) '.mat']), 'saveStruct')

%% plot and save figure

fgh2 = figure('position', [200 200 1500 800]);
%
freqVec = [100 125 250 500 750 1000 1500 2000 3000 4000 6000 8000 10000];
freqCell = {'100' '125' '250' '500' '750' '1k' '1.5k' '2k' '3k' '4k' '6k' '8k' '10k'};

% freqVec = [ 125 160 200 250 315 400 500 630 750 800 1000 1250 1500 1600 2000 2500 3000 3150 4000 5000 6000 6300 8000]
% freqCell = {'125' '160' '200' '250' '315' '400' '500' '630' xxxx '750' '1k' '1.5k' '2k' '3k' '4k' '6k' '8k' '10k'};
plot(saveStruct.result.freqVector, saveStruct.result.auditoryThreshold(:,1), 'x-', 'linewidth', 2.5, 'color', [0 0 1], 'markersize', 10)
hold all
plot(saveStruct.result.freqVector, saveStruct.result.auditoryThreshold(:,2), 'o-', 'linewidth', 2.5, 'color', [1 0 0],  'markersize', 7);
% plot(freqVec([1 end]), 15*[1  1], '--', 'linewidth', 1.5, 'color', [1 0.84 0]);
% plot(freqVec([1 end]), 20*[1  1], '--', 'linewidth', 1.5, 'color', [1 0 0]);
hold off
xlim(freqVec([1 end])); ylim([-25 60])
set(gca,'yDir','reverse', 'xscale', 'log', 'xTick', freqVec, 'xTickLabel', freqCell);
legend({'left ear', 'right ear'}, 'location', 'south')
grid on

title(sprintf('%s (%s)', saveStruct.personalInfo.name, saveStruct.personalInfo.date))
xlabel('Frequency in Hz')
ylabel('Hearing level acc. ISO in dB HL')

if exist('ita_savethisplot', 'file')
    ita_savethisplot(fgh2, fullfile(pathName, [ fileName(1:end-4) '.png']))
    %     close(fgh)
    helpdlg('Results saved (as *.txt, *.mat and *.png).','Results saved...');
else
    helpdlg('Results saved (as *.txt and *.mat ). *.png not saved because ITA-Toolbox is missing.','Results saved...');
end


gData.userData.dataSaved = true;
guidata(gData.h.f, gData)


end


%%
function status = checkOneFrequency(gData, currFreq, outputChannel)

fprintf('\t checking freq %i Hz, ch: %i \n', currFreq, outputChannel)
% get start dBFS level
startBelowThreshold = 20;  % dB
dBFS_for_RETSPL = gData.parameter.calib.currCalib.dBFS_for_RETSPL(gData.parameter.calib.currCalib.freqVector == currFreq);
startDBFSlevel = round(min(max( dBFS_for_RETSPL - startBelowThreshold, -127),0));

% play parameter
pageBufferCount = 3;
blockSize    = gData.soundcard.samplingRate/5 * 1; % for blockSize of 8820 (and multiples) all frequencies have full periods (samplingrate / 5 Hz)
pauseForNoNewData = 0.2;

% generate sine
audioData = sin(2*pi* (1:blockSize)' / gData.soundcard.samplingRate * currFreq);

% init variables
allResponses = [];
remainingData = [];
pageBuffer = zeros(pageBufferCount,1);

% init sound card if necessary
if ~playrec('isInitialised')
    playrec('init', gData.soundcard.samplingRate, gData.soundcard.playDeviceID, -1);
    fprintf('\t playrec... waiting 0.5 second \n');
    pause(0.5);
end


gData.onlinePar.isRunning    = true;
gData.onlinePar.cancelByUser = false;
guidata(gData.h.f, gData);

% start DSP
flushinput(gData.serialObj);
flushoutput(gData.serialObj)
parStruct = struct('mute', 0, 'daVolume', startDBFSlevel, 'minfadelevel', startDBFSlevel, 'maxfadelevel', 0, 'bekesy', 'start');
struct2norsonic(gData.serialObj, parStruct)

% play sound
pageBuffer = [pageBuffer(2:end); playrec('play',single(audioData),outputChannel )];

while gData.onlinePar.isRunning && ~gData.onlinePar.cancelByUser && ~get(gData.h.tb_pause, 'value')
    
    %     fprintf('\nplay: ')
    pageBuffer = [pageBuffer(2:end); playrec('play',single(audioData),outputChannel )];
    isFinished = false;
    
    while ~isFinished && pageBuffer(1) && ~gData.onlinePar.cancelByUser  && ~get(gData.h.tb_pause, 'value') % not finished and is valid page no
        
        if gData.serialObj.BytesAvailable
            currRawData = fread(gData.serialObj, gData.serialObj.BytesAvailable);
            
            [newSwitchTimeData, remainingData] = ita_audiometer_decodeBekesy([remainingData; currRawData]);
            
            newSwitchTimeData(:,1) = newSwitchTimeData(:,1) - dBFS_for_RETSPL;  % convert dBFS of norsonix to dB HL (mean hearing level...)
            
            [allResponses , status ] = evalUserResponses(allResponses, newSwitchTimeData, gData);
            
            if ~strcmpi(status, 'running')
                gData.onlinePar.isRunning = false;
                guidata(gData.h.f,gData);
                
                % add info
                if ~isnumeric(status)  % if error => show info
                    messages = [{sprintf('%s (%2.1f Hz, Ch: %i)', status, currFreq, outputChannel)}; get(gData.h.lb_info , 'String')];
                    set(gData.h.lb_info , 'string', messages)
                end
                
                fprintf('\t eval result: end of run\n')
                break
            end
        else
            fprintf('.')
            pause(pauseForNoNewData)
        end
        
        isFinished = playrec('isFinished',pageBuffer(1));
        
    end
    gData = guidata(gData.h.f);
end
playrec('delPage',pageBuffer);
parStruct = struct( 'daVolume', -127, 'bekesy', 'stop');
struct2norsonic(gData.serialObj, parStruct)

if gData.onlinePar.cancelByUser
    status = 'cancelByUser';
elseif   get(gData.h.tb_pause, 'value')      % pause button loop
    
    status = 'restartFreq';
    set(gData.h.pb_stop, 'enable', 'off')
    
    while get(gData.h.tb_pause, 'value') % wait for end of pause...
        set(gData.h.tb_pause, 'backgroundcolor', [1 (sin(now*24*3600*4)+1)/2 *[1 1]])
        pause(0.2)
    end
    set(gData.h.tb_pause, 'backgroundcolor',get(gData.h.pb_start, 'backgroundcolor'))
    set(gData.h.pb_stop , 'enable', 'on')
    
end

end



function [allResponses status] = evalUserResponses(allResponses, newSwitchTimeData, gData)

status = 'running';
if isempty(newSwitchTimeData)
    return;
end

switch lower(gData.parameter.testMethod)
    case 'bracketing'

        for iNewData = 1:size(newSwitchTimeData,1)
            isValid = true;
            
            if newSwitchTimeData(iNewData,2) == 0  % start point
                isValid = false;
                fprintf('\t\t ignore start point\n')
            elseif size(allResponses,1)  <=  gData.parameter.ignoreFirstResponses
                isValid = false;
                fprintf('\t\t ignore %i. response\n', size(allResponses,1))
            elseif abs(newSwitchTimeData(iNewData,1) - allResponses(end,1)) < gData.parameter.minLevelBetweenResponses
                isValid = false;
                fprintf('\t\t less than %i dB between response  (%i dB)\n',abs(newSwitchTimeData(iNewData,1) - allResponses(end,1)))
            end
            allResponses = [allResponses; [newSwitchTimeData(iNewData,:) isValid]];
            
        end
        
        
        plot(gData.h.ax_currLevel, allResponses(:,2), allResponses(:,1))
        
        
        hold(gData.h.ax_currLevel,'all')
        idxInvalid = allResponses(:,4) == 0;
        scatter(gData.h.ax_currLevel, allResponses(idxInvalid,2),allResponses(idxInvalid,1),50, [1 0 0], 'filled')
        
        idxValid = allResponses(:,4) == 1;
        scatter(gData.h.ax_currLevel, allResponses(idxValid,2),allResponses(idxValid,1),50, [0 1 0], 'filled')
        
        for iSwitchState = 0:1
            idxSwitchingPoints = find(allResponses(:,4) == 1 & allResponses(:,3) == iSwitchState);
            if abs(max(allResponses(idxSwitchingPoints,1)) - min(allResponses(idxSwitchingPoints,1))) > gData.parameter.maxDifferenceBetweenResponses
                %     fprintf('')
                [~, idxMaxOfUpper] = max(allResponses(idxSwitchingPoints,1));
                [~, idxMinOfUpper] = min(allResponses(idxSwitchingPoints,1));
                
                idxOfExtrema = idxSwitchingPoints([idxMaxOfUpper, idxMinOfUpper]);
                scatter(gData.h.ax_currLevel, allResponses(idxOfExtrema,2) ,allResponses(idxOfExtrema,1),150, [1 0 0], 'filled');
                status = sprintf('Difference between switching points > %i dB. Cancel frequency.', gData.parameter.maxDifferenceBetweenResponses);
            end
        end
        
        if strcmp(status, 'running') && sum(idxValid) >= gData.parameter.responsesNeededForCalculation
            % plot upper und lower mean
            meanSwitchLevels = zeros(2,1);
            for iSwitchState = 1:2
                idxSwitchingPoints = find(allResponses(:,4) == 1 & allResponses(:,3) == iSwitchState-1);
                meanSwitchLevels(iSwitchState) = mean(allResponses(idxSwitchingPoints,1));
                plot(gData.h.ax_currLevel, allResponses(idxSwitchingPoints([1 end]),2), [1 1] * meanSwitchLevels(iSwitchState), 'color', 'k', 'linewidth', 2);
            end
            
            % plot mean level (result)
            status = mean(meanSwitchLevels);
            plot(gData.h.ax_currLevel, allResponses([2 end],2), [1 1] * status, 'linewidth', 3, 'color', 'k');
        end
        
        
    case 'ascending'
  
        for iNewData = 1:size(newSwitchTimeData,1)

            if newSwitchTimeData(iNewData,2) == 0  % start point
                isValid = false;
                fprintf('\t\t ignore start point\n')
            else
                isValid = true;
            end
            allResponses = [allResponses; [newSwitchTimeData(iNewData,:) isValid]];
        end
        
        plot(gData.h.ax_currLevel, allResponses(:,2), allResponses(:,1))
        hold(gData.h.ax_currLevel,'all')
        
        idxInvalid = allResponses(:,4) == 0;
        scatter(gData.h.ax_currLevel, allResponses(idxInvalid,2),allResponses(idxInvalid,1),50, [1 0 0], 'filled')
        
        idxValid = allResponses(:,4) == 1;
        scatter(gData.h.ax_currLevel, allResponses(idxValid,2),allResponses(idxValid,1),50, [0 1 0], 'filled')
        
        if  sum(idxValid) % one valid point is enough
            idxSwitchingPoints = find(allResponses(:,4) == 1 & allResponses(:,3) == 0); %  iSwitchState = 1
            status = allResponses(idxSwitchingPoints(1),1);
            %                 plot(gData.h.ax_currLevel, [ 0.1 allResponses(idxSwitchingPoints(1),2)+1], [1 1] * status, 'color', 'k', 'linewidth', 2);
        end
        
    otherwise
        error('method not yet implemented...')
end

hold(gData.h.ax_currLevel,'off')
xlim(gData.h.ax_currLevel, [0 10*max(ceil(max(allResponses(:,2))/10),1)])
grid(gData.h.ax_currLevel, 'on')
xlabel(gData.h.ax_currLevel, 'time in s')
ylabel(gData.h.ax_currLevel, 'level in dB HL')





end %

function userData = readUserDataFromGUI(gData)
userData.name         = get(gData.h.ed_name, 'string');
userData.investigator = get(gData.h.ed_investigator, 'string');
userData.birthday     = get(gData.h.ed_birthday, 'string');
userData.date         = get(gData.h.ed_date, 'string');
userData.comment      = get(gData.h.ed_comment, 'string');

if any([isempty(userData.name) isempty(userData.investigator) isempty(userData.birthday) isempty(userData.date)])
    errordlg('Please enter all personal data!')
    userData = [];
end
end
function struct2norsonic(serialObj, parStruct)
% send multiple parameters of struct to norsonic
allPar = fieldnames(parStruct);
for iPar = 1:numel(allPar)
    ita_norsonic838(serialObj, allPar{iPar}, parStruct.(allPar{iPar}));
end

end


function changePreferences(s,~)

gData = guidata(s);
gData.parameter = ita_audiometer_preferences(gData.parameter);
if ~isempty(gData.parameter)
    guidata(gData.h.f, gData);
end
end

function closeRegFcn(s, ~)
gData = guidata(s);
% if gData.serialObj
fclose(gData.serialObj );
fprintf('\n serial port: closed\n')
delete(gData.serialObj )
delete(gData.h.f)
end
