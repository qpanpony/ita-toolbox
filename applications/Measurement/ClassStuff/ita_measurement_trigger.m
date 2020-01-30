function varargout = ita_measurement_trigger(varargin)
%ITA_MEASUREMENT_TRIGGER - Triggered measurement
%  This function performs a triggered measurement useful for e.g. impact hammer measurements.
%
%  Syntax:
%   [mean,runs] = ita_measurement_trigger() - get GUI
%   [mean,runs] = ita_measurement_trigger(MeasurementSetup, ...)
%
%    options:
%       CancelButton    Display a button where the playback/record can be cancelled
%       Duration        time in seconds for the final data
%       Threshold       value in dBFS for the trigger
%       PreTime         take ale this seconds from before the trigger event
%       TriggerChannel  use this channel as trigger
%       Averages        measure multiple times and calculate the average
%
%  Example:
%
%     [mean,runs] = ita_measurement_trigger(MS,'duration',1,'threshold',-20,'triggerchannels',1,'pretime',0.2);
%
%   See also: ita_mean, ita_measurement_run, ita_measurement_setup, ita_time_window, ita_time_shift.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_measurement_trigger">doc ita_measurement_trigger</a>
%
% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  01-Jul-2009

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(0,23);

%% GUI
if nargin == 0
    pList = [];
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Input Channels';
    pList{ele}.helptext    = 'Channels to record data' ;
    pList{ele}.datatype    = 'int_result_button';
    pList{ele}.default     =  1;
    pList{ele}.callback    = 'ita_channelselect_gui([$$],[],''onlyinput'')';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Sampling Rate';
    pList{ele}.helptext    = 'SamplingRate of your soundcard' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     =  44100;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Duration [s]';
    pList{ele}.helptext    = 'length of your impulse signal in seconds' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     =  1;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Threshold [dBFS]';
    pList{ele}.helptext    = 'threshold for the trigger. if the signal exceeds this value in dBFS the recording will start.' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     =  -30;
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Advanced Settings';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'PreTime [s]';
    pList{ele}.helptext    = 'Take also this part before the trigger event in seconds.' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     =  0.1;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Maximum Waiting Time [s]';
    pList{ele}.helptext    = 'Only wait this time for an event, otherwise return all data unprocessed.' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     =  10;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Trigger Channels';
    pList{ele}.helptext    = 'Channels used to trigger.' ;
    pList{ele}.datatype    = 'int_result_button';
    pList{ele}.default     =  1;
    pList{ele}.callback    = 'ita_channelselect_gui([$$],[],''onlyinput'')';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Averages';
    pList{ele}.helptext    = 'Amount of impacts to be recorded.';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     =  1;
    
    pList = ita_parametric_GUI(pList,'Perform triggered impact trigger measurements');
    MS = itaMSRecord('useMeasurementChain',0,'inputChannels',pList{1},'samplingRate',pList{2},'fftDegree',log2(round(pList{6}*pList{2})),'averages',pList{8});
    varargin = {MS,'threshold',pList{4},'pretime',pList{5},'Triggerchannels',pList{7},'Duration',pList{3}};
end

%% init
record = true;
hPlayRec    = ita_playrec;

% Init Settings
sArgs.pos1_data = 'itaMSRecord';
sArgs.block             = true; %Block soundcard
sArgs.cancelbutton      = 0;
sArgs.pretime           = 0; % in seconds
sArgs.threshold         = -30; % in dB
sArgs.duration          = 0.1;
sArgs.triggerchannels   = 1;

[MS, sArgs] = ita_parse_arguments(sArgs,varargin);
recsamples = MS.nSamples;
in_channel_vec   = MS.inputChannels;

if max(sArgs.triggerchannels) > max(in_channel_vec)
    error('triggerchannels is not correctly choosen')
end

% Find devices
recDeviceID = ita_preferences('recDeviceID');
[recDeviceName, recDeviceInfo] = ita_portaudio_deviceID2string(recDeviceID); %#ok<ASGLU>
if recDeviceID == -1 || isempty(recDeviceInfo)
    error('ITA_MEASUREMENT_TRIGGER: No rec device set, please call ita_preferences');
end
if isempty(in_channel_vec)
    in_channel_vec = 1:recDeviceInfo.inputChans;
else
    if max(in_channel_vec) > recDeviceInfo.inputChans
        error(['ITA_MEASUREMENT_TRIGGER: The AudioDevices does not have ' int2str(max(in_channel_vec)) ' input channels!']);
    end
end

%% main function
result = itaAudio([MS.averages 1]);

for iAverage = 1:MS.averages  % loop through amount of measurements    
    % Initialise PlayRec   % is there no other way?
    if hPlayRec('isInitialised') % is necessary to run script more than once anyway
        hPlayRec('reset');
    end
    if hPlayRec('isInitialised') && ((hPlayRec('getSampleRate') ~= MS.samplingRate) || (hPlayRec('getRecDevice') ~= recDeviceID))
        if hPlayRec('isInitialised')
            hPlayRec('reset');
        end
    end
    if(~hPlayRec('isInitialised'))
        hPlayRec('init', MS.samplingRate, -1, recDeviceID);
    end
    %try second time
    if(~hPlayRec('isInitialised'))
        hPlayRec('init', MS.samplingRate, -1, recDeviceID);
    end
    if(~hPlayRec('isInitialised'))
        error ('ita_portaudio:Unable to initialise playrec correctly');
    end
    
    recordData = [];
    
    %% Display cancel button
    if sArgs.cancelbutton
        CancelButton = stoploop({'Stop playback / record'});
    end
    
    %% start recording
    if record
        disp('start record')
        pageno = hPlayRec('rec',recsamples,in_channel_vec);
    end
    pause(0.01)
    lastSample = 1;
    
    ita_verbose_info('ITA_MEASUREMENT_TRIGGER:waiting for results',1);
    isfinished = hPlayRec('isFinished',pageno);
    
    %  LOOP TO WAIT FOR TRIGGER EVENT
    ita_portaudio_monitor('init',[0,length(in_channel_vec)]);   % switch on monitor
    %
    while ~isfinished
        %Loop till finished
        isfinished = hPlayRec('isFinished',pageno);
        
        % Display cancel Button and check if presses
        if sArgs.cancelbutton
            if CancelButton.Stop() %Button has been pressed
                CancelButton.Clear();
                if nargout > 0
                    varargout{1} = [];
                end
                hPlayRec('reset');
                return;
            end
        end
        % get data in the middle
        z = hPlayRec('getRec',pageno);
        if isempty(z)
            pause(0.1);
            continue; %
        end
        peak_data = 20.*log10(abs(z(lastSample:end,sArgs.triggerchannels)));
        
        mon_data(:,1) = 20.*log10(max(abs(z(lastSample:end,:))));
        mon_data(:,2) = 10.*log(mean((z(lastSample:end,:)).^2));
        % draw threshold line
        line(get(gca,'xlim'),[sArgs.threshold,sArgs.threshold],'color',[1 0 1],'linewidth',2); % what is the handle of the monitor figure?
        
        ita_portaudio_monitor('update',mon_data);
        sample_idx = find(peak_data >= sArgs.threshold);
        
        %check if peak has already been found
        if ~isempty(sample_idx)
            disp(['*** peak found at ' num2str(lastSample + sample_idx(1)) ' samples. value: ' num2str(peak_data(sample_idx(1)))]);
            pause(sArgs.duration); %be on the save side and wait one cycle
            z = hPlayRec('getRec',pageno); %get last data;
            pre_offset = floor(sArgs.pretime * MS.samplingRate); %
            sample_vec = lastSample + sample_idx(1) + (1:floor(MS.samplingRate)*sArgs.duration) - pre_offset;
            
            if sample_vec(1)<1      % don't subtract pre_offset for low threshold and early data. is not practically relevant but the error is annoying.
                sample_vec = lastSample + sample_idx(1) + (1:floor(MS.samplingRate)*sArgs.duration);
                disp('The threshold is probably very low and the trigger was activated immediately');
            end
            if max(sample_vec) > size(z,1)
                disp('Trigger event was really late. Returning all data recorded');
                sample_vec = size(z,1) - sArgs.duration * MS.samplingRate;
            end
            recordData = z(sample_vec,:);
            
            break; %we are ready to leave
            
        end
        lastSample = size(z,1);
        
        pause(0.1);
    end
    
    if isempty(recordData)
        disp('No Trigger event found. Just returning the entire data')
        recordData = hPlayRec('getRec',pageno);
    end
    
    %% finished
    ita_verbose_info('ITA_MEASUREMENT_TRIGGER:playback finished',1);
    ita_portaudio_monitor('close');
    
    % Remove cancel button
    if sArgs.cancelbutton
        CancelButton.Clear();
    end
    recordData        = itaAudio(recordData,MS.samplingRate,'time');
    
    %% Check for clipping and other errors
    clipping = false;
    if any(abs(recordData.time)>=1) %Check for clipping
        fprintf(2,'! ITA_MEASUREMENT_TRIGGER:: Carefull, Clipping !');
        clipping = true;
    end
    if any(any(isnan(recordData.time))) || any(any(isinf(recordData.time))) %Check for singularities
        disp('ITA_MEASUREMENT_TRIGGER:: There are singularities in the audio signal! You''d better check your settings!');
        clipping = true;
    end
    if any(all(recordData.time == 0)) && record
        disp('ITA_MEASUREMENT_TRIGGER:: There are empty channels in the audio signal! You''d better check your settings!');
    end
    [channelvolumes, index] = max(max(abs(recordData.time),[],1));
    disp(['Maximum digital level: ' int2str(20*log10(channelvolumes)) ' dB on channel: ' int2str(in_channel_vec(index))]);
    
    %% Check if soundcard-settings are right
    [recDeviceName, recDeviceInfo] = ita_portaudio_deviceID2string(hPlayRec('getRecDevice'));
    if recDeviceInfo.defaultSampleRate ~= MS.samplingRate
        if MS.samplingRate == hPlayRec('getSampleRate')
            ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',1);
            ita_verbose_info('!ITA_PORTAUDIO:Careful, not the device''s default SamplingRate!',1);
            ita_verbose_info(['! Standard Rec Device Fs: ' num2str(recDeviceInfo.defaultSampleRate) 'Hz'],1);
            ita_verbose_info(['!  Current Rec Device Fs: ' num2str(hPlayRec('getSampleRate')) 'Hz'],1);
            ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',1);
        else
            clipping = true;
            ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',0);
            ita_verbose_info('!ITA_PORTAUDIO:Careful, SamplingRate may not be set correctly!',0);
            ita_verbose_info(['! Rec Device seems to have: ' num2str(recDeviceInfo.defaultSampleRate) 'Hz'],0);
            ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',0);
        end
    end
    
    %% Add history line
    infosforhistory = struct('RecDevice',recDeviceName,'Rec_Channels',in_channel_vec,'Sampling_Rate',MS.samplingRate,'Rec_Samples',recsamples);
    if sArgs.block %We record the one from last run when not blocking, so there is no use of sub-history
        recordData = ita_metainfo_add_historyline(recordData,'ita_measurement_trigger',[{MS}; ita_struct2arguments(infosforhistory)],'withsubs');
    else
        recordData = ita_metainfo_add_historyline(recordData,'ita_measurement_trigger',[{MS}; ita_struct2arguments(infosforhistory)]);
    end
    
    if clipping
        recordData = ita_metainfo_add_historyline(recordData,'!!! ITA_MEASUREMENT_TRIGGER:: Carefull, Clipping !!!');
    end
    
    result(iAverage) = recordData';
    
    %% apply channelsettings
    if ~isempty(MS.inputMeasurementChain)
        result(iAverage) = MS.inputMeasurementChain.hw_ch(in_channel_vec)*result(iAverage);
    else
        disp([thisFuncStr,'This is no absolute data, the sensitivities were not given.']);
    end
end

hPlayRec('reset');

%% calculate mean
if length(result)>1  % for more than 1 average
    meanrun = mean(result);
    runs    = result;
else                 % for single run
    runs = merge(result);
    meanrun = runs; %pdi: bugfix: was [] before
end


%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    ita_plot_spkphase(runs);
    ita_plot_dat(runs);
elseif nargout == 1
    varargout(1) = {meanrun};
elseif nargout == 2
    varargout(1) = {meanrun};
    varargout(2) = {runs};
end

%end function
end

