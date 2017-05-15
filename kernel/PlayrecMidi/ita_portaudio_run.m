function varargout = ita_portaudio_run(varargin)
%ita_portaudio_run - Play audioObj and Record
%  This function plays back audioObj data, i.e. sweeps, and records
%  from the soundcard and gives it back as an audioObj as well.
%  The function can be used to play or record or play and record audioSignals
%
%  Syntax: audioObj = ita_portaudio_run(audioObj, [...])    for playback and record
%                      ita_portaudio_run(audioObj)           for playback only
%          audioObj = ita_portaudio_run(number_of_samples)     for record only
%
%  Options:
%           'InputChannels'         :     Specify the device's input channels to use
%                                         for the measurement (vector)
%           'OutputChannels'        :     Specify the device's output channels to use
%                                         for the measurement (vector)
%           'NormalizeInput'        :     Normalize Input (default: false)
%           'NormalizeOutput'       :     Normalize Output (default: false)
%           'Block'                 :     Block Matlab till processing is finished (default is true for recording and false for playback only)
%           'RecSamples'            :     Number of samples to record. For playback and record: default is the number of samples of input
%           'samplingRate'          :     SamplingRate for playback/record, default is the SamplingRate of input itaAudio or 44100
%           'Device'                :     Playback and record using Device specified as string, e.g. 'Multiface' (will overwrite 'indevice' and 'outDevice')
%           'inDevice'              :     Record using Device specified as string, e.g. 'Device', 'Multiface'
%           'outDevice'             :     Playback using Device specified as string, e.g. 'Device', 'Multiface'
%           'repeats'               :     Repeats of signal
%           'SinglePrecision'       :     Return data as singles instead of doubles (if memory is a problem)
%           'CancelButton'          :     Display a button where the playback/record can be cancelled
%           'Latencysamples'        :     Latency of soundcard to compensate in samples
%           'KeepSamplingrate'      :     Use default Sampling Rate of device, solves some problems but may use a resampling
%           'NonBlockingBuffersize' :     Size of buffer (pages im memory) when using non-blocking mode (use more if you experience glitches) or if datasize > maxpagesize 
%           'ASIOBuffersize'        :     Size of Buffer, use more (e.g. 2048) if you experience glitches when computer is working
%           'reset'                 :     Reset playrec/portaudio after play/record, default is false
%           'maxpagesize'           :     Maximum number of samples for each page
%
%
%  Examples:
%   Play some sound to check if everything is working:
%       ita_portaudio_run()
%
%   Record 2000 Samples (at default 44100Hz):
%       result = ita_portaudio_run(2000)
%
%   Play demosound:
%       ita_portaudio_run(ita_demosound)
%
%   Play and Record:
%       result = ita_portaudio_run(ita_demosound)
%
%   Measure using an device matching the name 'ModulITA' using the
%   output channels 5, 6:
%
%   recordStruct = ita_portaudio_run(sweepStruct, 'Device', 'ModulITA', 'OutputChannels', [5 6]);
%
%   !!! portaudio will block your soundcard while running. If you
%   !!! experience any trouble with other programms you can enter
%   !!! 'playrec('reset')' to reset your sound device
%
%
%   See also ita_audioplay, ita_fft, ita_ifft, ita_ita_read, ita_ita_write.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_portaudio_run">doc ita_portaudio_run</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Autor: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  18-Feb-2009

%% Get ITA Toolbox preferences
verboseMode = ita_preferences('verboseMode');
hPlayRec    = ita_playrec;

%% Parse and validate the input arguments
if nargin == 0 %Play demosound if no arguments are given
    if nargout == 0 % Gui if called without input and output
        ita_portaudio_gui();
        return;
    end
    varargin{1} = ita_demosound();
end

if isa(varargin{1},'itaAudio')
    sArgs.pos1_data         = 'itaAudioTime';
    playback = true;
else
    sArgs.pos1_data = 'numeric';
    playback = false;
end

if nargout > 0
    record = true;
else
    record = false;
end

%% Init Settings
%unwichtig
sArgs.indevice          = '';
sArgs.outdevice         = '';
sArgs.device            = '';
sArgs.normalizeinput    = false;
sArgs.normalizeoutput   = false;
sArgs.portaudio         = true; %Not used anyway but needed for compatibility

%wichtig
sArgs.samplingRate      = ita_preferences('samplingRate'); %bitte raus aus den sArgs
sArgs.inputchannels     = [];
sArgs.outputchannels    = [];
sArgs.block             = true; %Block soundcard
sArgs.recsamples        = -1;
sArgs.repeats           = 1;
sArgs.cancelbutton      = ita_preferences('portAudioMonitor'); % -1:automatic; 0:off; 1:on
sArgs.latencysamples    = 0;
sArgs.keepsamplingrate  = false; %puh, schwierig
sArgs.nonblockingbuffersize = 16; %if block=false or datasize > maxpagesize!
sArgs.singleprecision   = false;
sArgs.reset             = false;
sArgs.maxpagesize       = 2^18; % Split audio data into several pages - each max. maxpagesize samples!

playrecBufferSize = ita_preferences('playrecBufferSize');
if ~isnumeric(playrecBufferSize)
    error('ita_portaudio_run::wrong value for playrec buffer size');
end

[data, sArgs] = ita_parse_arguments(sArgs,varargin);

if sArgs.maxpagesize < 30
    ita_verbose_info('Assuming maxpagesize to be a (< 30) fft-degree!', 0);
    sArgs.maxpagesize = 2^sArgs.maxpagesize;
end

if ~isempty(sArgs.device) %Use the same device for play and record
    sArgs.indevice = sArgs.device;
    sArgs.outdevice = sArgs.device;
end

if ~playback && sArgs.recsamples == -1
    sArgs.recsamples = data;
end

[playDeviceName, playDeviceInfo] = ita_portaudio_deviceID2string(ita_preferences('playDeviceID')); %#ok<ASGLU>
[recDeviceName, recDeviceInfo] = ita_portaudio_deviceID2string(ita_preferences('recDeviceID')); %#ok<ASGLU>

if isempty(sArgs.samplingRate)
    if sArgs.keepsamplingrate
        if playback
            sArgs.samplingRate = playDeviceInfo.defaultSampleRate;
        else
            sArgs.samplingRate = recDeviceInfo.defaultSampleRate;
        end
    else
        if playback || isa(data,'itaAudio')
            sArgs.samplingRate = data.samplingRate;
        else
            sArgs.samplingRate = recDeviceInfo.defaultSampleRate;
        end
    end
end

if playback && sArgs.samplingRate ~= data.samplingRate
    ita_verbose_info('Set sampling rate does not match input sampling rate! I will resample!',0)
    data = ita_resample(data,sArgs.samplingRate);
end


recDeviceName    = sArgs.indevice;
playDeviceName   = sArgs.outdevice;
in_channel_vec   = sArgs.inputchannels;
out_channel_vec  = sArgs.outputchannels;
normalize_input  = sArgs.normalizeinput;
normalize_output = sArgs.normalizeoutput;
playDeviceID     = -1;
recDeviceID      = -1;
% max_buffer_reached = false;

showMonitor      = true;

if sArgs.cancelbutton == -1; %User did not specify if he wants a cancel button. Lets show one for signals longer than 3 seconds
    if playback
        if (data.nSamples/data.samplingRate) > 3
            sArgs.cancelbutton = true;
        else
            sArgs.cancelbutton = false;
        end
    else
        if (sArgs.recsamples/sArgs.samplingRate) > 3
            sArgs.cancelbutton = true;
        else
            sArgs.cancelbutton = false;
        end
    end
end

if ~playback && ~record
    error('ITA_PORTAUDIO:What do you want? Play or Record, or both? You need to specify an input and/or an output!')
end

%% Find devices
if record
    if isempty(recDeviceName)
        recDeviceID = ita_preferences('recDeviceID');
        [recDeviceName, recDeviceInfo] = ita_portaudio_deviceID2string(recDeviceID);
    else
        [recDeviceID, recDeviceInfo]   = ita_portaudio_string2deviceID(recDeviceName);
    end
    
    if recDeviceID == -1 || isempty(recDeviceInfo)
        error('ITA_PORTAUDIO:No rec device set, please call ita_preferences');
    end
    
    if isempty(in_channel_vec)
        in_channel_vec = 1:recDeviceInfo.inputChans;
    else
        if max(in_channel_vec) > recDeviceInfo.inputChans
            error(['ITA_PORTAUDIO:The AudioDevices does not have ' int2str(max(in_channel_vec)) ' input channels!']);
        end
    end
end

if playback
    if isempty(playDeviceName)
        playDeviceID = ita_preferences('playDeviceID');
        [playDeviceName, playDeviceInfo] = ita_portaudio_deviceID2string(playDeviceID);
    else
        [playDeviceID, playDeviceInfo] = ita_portaudio_string2deviceID(playDeviceName);
    end
    
    if playDeviceID == -1
        error('ITA_PORTAUDIO:No play device set, please call ita_preferences');
    end
    
    if playDeviceInfo.outputChans == 0
        error('ITA_PORTAUDIO:No output channels available');
    end
    
    if isempty(out_channel_vec)
        if data.nChannels > 1
            out_channel_vec = 1:min(data.nChannels, playDeviceInfo.outputChans);
        else
            out_channel_vec = 1:playDeviceInfo.outputChans; %Play on all channels
        end
    else
        if max(out_channel_vec) > playDeviceInfo.outputChans
            error(['ITA_PORTAUDIO:The AudioDevices does not have ' int2str(max(out_channel_vec)) ' output channels!']);
        end
    end
    
    %% Extract channels to play
    % are there enough channels to play
    if data.nChannels == 1 && (length(out_channel_vec) > 1) %playback the same on alle channels activated
        ita_verbose_info('Oh Lord. I will playback the same on all channels.', 2)
        nChannelsToPlay = length(out_channel_vec);
        data = data.ch(ones(1,nChannelsToPlay)); %duplicated data to all channels
    elseif data.nChannels < length(out_channel_vec) %too many output channels for this input data
        ita_verbose_info('Not enough channels in data to play.',0)
        out_channel_vec = out_channel_vec(1:data.nChannels);
    elseif data.nChannels > length(out_channel_vec)
        ita_verbose_info('Too many channels in data file, I will only play the first ones',1);
        data = ita_split(data,1:length(out_channel_vec));
    end
    
    %% Show channel data if requested
    if verboseMode==2, ita_metainfo_show_channelnames(data); end;
    
    %% Check levels - Normalizing
    peak_value = max(max(abs(data.timeData)));
    if (peak_value > 1) || (normalize_output)
        ita_verbose_info('Oh Lord! Levels too high for playback. Normalizing...',0)
        data = ita_normalize_dat(data); %PDI: bugfix, there was no 'data =' on the left handside
    end
end

%% Some checks
if record && playback && recDeviceID ~= playDeviceID
    ita_verbose_info('Oh Lord, Play- and Rec-Device are not the same. Please be careful, this can give you strange results!',0)
end

%% Initialise PlayRec
newSamplingRate = logical(hPlayRec('getSampleRate') ~= sArgs.samplingRate);
newRecDevice    =  logical(hPlayRec('getRecDevice') ~= recDeviceID);
newPlayDevice   = logical(hPlayRec('getPlayDevice') ~= playDeviceID);
newPlayrecBufferSize = logical((playrecBufferSize > 0) && ((ceil(abs(hPlayRec('getPlayLatency')*sArgs.samplingRate - playrecBufferSize)) > 0)  || (ceil(abs(hPlayRec('getRecLatency')*sArgs.samplingRate - playrecBufferSize)) > 0)));


if hPlayRec('isInitialised') && (newSamplingRate || newRecDevice  || newPlayDevice || newPlayrecBufferSize)
    if hPlayRec('isInitialised')
        hPlayRec('reset');
    end
end
if(~hPlayRec('isInitialised'))
    if playrecBufferSize > 0
        hPlayRec('init', sArgs.samplingRate, playDeviceID, recDeviceID,playDeviceInfo.outputChans,recDeviceInfo.inputChans,0,playrecBufferSize/sArgs.samplingRate,playrecBufferSize/sArgs.samplingRate);
    else
        hPlayRec('init', sArgs.samplingRate, playDeviceID, recDeviceID);
    end
    ita_verbose_info('initializing... waiting 1 second...',0);
    pause(1); %pdi: was 1 before
end

%% Extend excitation to compensate soundcard-delay
if playback && record && ~isempty(sArgs.latencysamples) && (sArgs.latencysamples > 0)
    latencysamples = sArgs.latencysamples;
    data = ita_extend_dat(data,data.nSamples+latencysamples,'forcesamples');
end

%% Play sound
timeout = true;
while timeout %normally only one time, one loop
    timeout = false;
    if(~hPlayRec('isInitialised'))
        if playrecBufferSize > 0
            hPlayRec('init', sArgs.samplingRate, playDeviceID, recDeviceID,playDeviceInfo.outputChans,recDeviceInfo.inputChans,0,playrecBufferSize/sArgs.samplingRate,playrecBufferSize/sArgs.samplingRate);
        else
            hPlayRec('init', sArgs.samplingRate, playDeviceID, recDeviceID);
        end
        ita_verbose_info('initializing again... waiting 1 second...',1);
        pause(1);
    end
    if(~hPlayRec('isInitialised'))
        error ('ITA_PORTAUDIO:Unable to initialise PlayRec correctly');
    end
    
    if ~sArgs.singleprecision %Full (double) precision
        recordDatadat = [];
    else
        recordDatadat = single([]);
    end
    
   
    % Check if block-mode and datasize > maxpagesize:
    using_more_pages = false;
    
    if playback % split playback signal to avoid sample errors . krechel 2012
        if (sArgs.maxpagesize < data.nSamples) && sArgs.block
            % Split data into several pages!
            using_more_pages = true;
            % Disable block - we will wait until all pages are send and read!
            sArgs.block = false;
            % total number of pages:
            num_split_pages = ceil(data.nSamples / sArgs.maxpagesize);
            % Check for at least two pages!
            if sArgs.nonblockingbuffersize < 2
                ita_verbose_info(' Oh Lord, I need at least two pages to split audio data!')
                sArgs.nonblockingbuffersize = 2;
            end
            inputpagecounter = 1;
            if ~sArgs.singleprecision
                recordDatadat = zeros(data.nSamples,numel(in_channel_vec),sArgs.repeats);
            else
                recordDatadat = zeros(data.nSamples,numel(in_channel_vec),sArgs.repeats, 'single');
            end
        elseif (sArgs.maxpagesize < data.nSamples) && ~sArgs.block
            ita_verbose_info(' Oh Lord, maxpagesize is smaller than length of audio data, but splitting only allowed in blocking-mode!', 0);
            sArgs.maxpagesize = data.nSamples;
        end
    end
    
    % Make sure no old pages are within the buffer! (This could lead to
    % wrong results!)
    if ~sArgs.block % RSC: only in blocking-mode !!!
        hPlayRec('delPage');
    end
    
    for idrep = 1:sArgs.repeats
        timeout = false;
        try
            if playback && record
                ita_verbose_info('start playback and record',1)
                %                 profile viewer
                if ~using_more_pages
                    pageno = hPlayRec('playrec',data.timeData,out_channel_vec,sArgs.recsamples,in_channel_vec);
                else
                    % Play splitted audio:
                    for idsplit = 1:num_split_pages
                        pageno = hPlayRec('playrec',data.timeData(((idsplit-1)*sArgs.maxpagesize+1):min(idsplit*sArgs.maxpagesize, data.nSamples),:),out_channel_vec,sArgs.recsamples,in_channel_vec);                        
                        pagelist = hPlayRec('getPageList');
                        if numel(pagelist) > 0
                            % If there are pages, check if they are
                            % finished and ready to be read:
                            pageno = pagelist(1);
                            if hPlayRec('isFinished', pageno)
                                    % Store input data in cell array as the
                                    % last one may have a different size!
                                    if ~sArgs.singleprecision %Full (double) precision
                                        recordDatadat(((inputpagecounter-1)*sArgs.maxpagesize+1):min(inputpagecounter*sArgs.maxpagesize, data.nSamples),:,idrep) = hPlayRec('getRec', pageno);
                                    else
                                        recordDatadat(((inputpagecounter-1)*sArgs.maxpagesize+1):min(inputpagecounter*sArgs.maxpagesize, data.nSamples),:,idrep) = single(hPlayRec('getRec', pageno));
                                    end
                                    hPlayRec('delPage',pageno);
                                    inputpagecounter = inputpagecounter +1;
                            end
                            % If number of pages reached maximum number of pages, wait until some
                            % are finished:
                            while numel(pagelist) >= sArgs.nonblockingbuffersize
                                if hPlayRec('isFinished', pageno)
                                    if ~sArgs.singleprecision %Full (double) precision
                                        recordDatadat(((inputpagecounter-1)*sArgs.maxpagesize+1):min(inputpagecounter*sArgs.maxpagesize, data.nSamples),:,idrep) = hPlayRec('getRec', pageno);
                                    else
                                        recordDatadat(((inputpagecounter-1)*sArgs.maxpagesize+1):min(inputpagecounter*sArgs.maxpagesize, data.nSamples),:,idrep) = single(hPlayRec('getRec', pageno));
                                    end
                                    hPlayRec('delPage',pageno);
                                    inputpagecounter = inputpagecounter +1;
                                end
                                pagelist = hPlayRec('getPageList');
                            end
                        end
                    end
                end
                if sArgs.block
                    waitFor = data.nSamples ./ data.samplingRate;
                else
                    waitFor = 0;
                end
            elseif record
                ita_verbose_info('start record',1)
                pageno  = hPlayRec('rec',sArgs.recsamples,in_channel_vec);
                waitFor = sArgs.recsamples ./ sArgs.samplingRate;
            elseif playback
                ita_verbose_info('start playback',1)
                sArgs.block = true;
                pageno = hPlayRec('play',single(data.timeData),out_channel_vec);
                waitFor = data.nSamples ./ data.samplingRate;
            else
                error('ITA_PORTAUDIO:No input and no output, what should I do?')
            end
        catch errmsg
            hPlayRec('reset');
            ita_verbose_info('TIMEOUT, I will try a reset and redo',0)
            ita_verbose_info(errmsg.message,0);
            timeout = true;            
            break
        end
        
        if record && ~timeout
            if ~sArgs.block
                pagelist = hPlayRec('getPageList');
                if numel(pagelist) > sArgs.nonblockingbuffersize
                    pageno = pagelist(1);
                    sArgs.block = true;
                    lostSamples = hPlayRec('getSkippedSampleCount');
                    ita_verbose_info(['ITA_PORTAUDIO:Lost ' int2str(lostSamples) ' samples'],lostSamples == 0)
                    hPlayRec('resetSkippedSampleCount');
                    %                     max_buffer_reached = true;                    
                end                
                ita_verbose_info('Non-Blocking mode in recording, I will return the recorded data from the last run!',1)
            end
        end
        
        pause(0.01) % pdi changed: was 0.1 before
        lastSample = 1;
        if sArgs.block && ~timeout %&& ~using_more_pages
            %if verboseMode || max_buffer_reached, disp('ITA_PORTAUDIO:
            %waiting for results'), end;%pdi:please be quiter
            isfinished = hPlayRec('isFinished',pageno);
            startTime = now;
            if sArgs.cancelbutton
                %for long signals show cancelbutton and monitor
                if ~playback
                    monitorHandle = ita_portaudio_monitor('init',[0,length(in_channel_vec)]);
                elseif ~record
                    if showMonitor
                        monitorHandle = ita_portaudio_monitor('init',[length(out_channel_vec),0]);
                    end
                else %playback + record
                    monitorHandle = ita_portaudio_monitor('init',[length(out_channel_vec),length(in_channel_vec)]);
                end
            end
        
            % Display cancel button
            if sArgs.cancelbutton
                if (showMonitor)
                  CancelButton = monitorHandle;
                else
                  CancelButton = stoploop({'Stop playback / record'});
                end
            end
            
            %Check for timeout : pdi moved before the loop! any problems?
            if playback
                maxtime = max([1, max(size(data.timeData.',2), sArgs.recsamples)/sArgs.samplingRate * 3]);
            else
                maxtime = max([1, sArgs.recsamples/sArgs.samplingRate * 3]);
            end
            while ~isfinished
                if (now-startTime)*24*3600 > maxtime && ~isfinished
                    timeout = true;
                    ita_verbose_info('TIMEOUT, waited so long... I will try a reset and redo',0);
                    hPlayRec('reset');
                end
                % Display cancel button
                % Display cancel Button and check if presses
                if sArgs.cancelbutton
                    if (showMonitor)
                       cancelCondition = strcmp(get(CancelButton,'Visible'),'off');
                    else
                       cancelCondition = CancelButton.Stop();
                    end
                    if cancelCondition
%                         CancelButton.Clear();
                        if nargout > 0
                            varargout{1} = [];
                        end
                        sArgs.reset = 1;
                        ita_portaudio_monitor('close')
                        break %BMA: So we can get the data until this point
                    end
                    pause(0.2)
                    if record
                        z = hPlayRec('getRec',pageno).';
                        if  ~playback
                            out_peak = [];
                        else %here is bug below, but where ! TODO:pdi
                            N = max(size(z));
                            out_peak = 20.*log10(max(abs(data.dat(:,lastSample:N)),[],2));
                        end
                        mon_data = [out_peak; 20.*log10(max(abs(z(:,lastSample:end)),[],2))];
                        lastSample    = size(z,2);
                        ita_portaudio_monitor('update',mon_data);
                    elseif playback && ~record
                          if (showMonitor)
                              [~, currentSample] = hPlayRec('getCurrentPosition');
                              out_peak = 20.*log10(max(abs(data.dat(:,lastSample:currentSample)),[],2));
                              lastSample = currentSample;
                              if ~isempty(out_peak)
                                ita_portaudio_monitor('update',out_peak);
                              end
                          end
                    end
                    pause(0.1);
                else
                    pause(waitFor)
                    pause(0.01)% wait a little bit more to be sure. % TODO % pdi
                end
                %Loop till finished
                isfinished = hPlayRec('isFinished',pageno);
            end
            if sArgs.cancelbutton
                %for long signals, close portAudio monitor
                ita_portaudio_monitor('close')
            end
        end
        
        if ~timeout && ~using_more_pages
            if record
                if sArgs.block
                    if ~sArgs.singleprecision %Full (double) precision
                        recordDatadat(:,:,idrep) = hPlayRec('getRec', pageno);
                    else
                        recordDatadat(:,:,idrep) = single(hPlayRec('getRec', pageno));
                    end
                    hPlayRec('delPage',pageno);
                else
                    recordDatadat(:,:,idrep) = zeros(2,length(in_channel_vec));
                end
            else
                recordDatadat(:,:,idrep) = zeros(2,length(in_channel_vec));
            end
        end

        
        if using_more_pages && record
            
            % check if there are pages not read yet, wait until they are finished
            % and read them:
            pagelist = hPlayRec('getPageList');
            while numel(pagelist) ~= 0
                pageno = pagelist(1);
                % Wait until first page is finished:
                while ~hPlayRec('isFinished',pageno); end;
                if ~sArgs.singleprecision %Full (double) precision
                    recordDatadat(((inputpagecounter-1)*sArgs.maxpagesize+1):min(inputpagecounter*sArgs.maxpagesize, data.nSamples),:,idrep) = hPlayRec('getRec', pageno);
                else
                    recordDatadat(((inputpagecounter-1)*sArgs.maxpagesize+1):min(inputpagecounter*sArgs.maxpagesize, data.nSamples),:,idrep) = single(hPlayRec('getRec', pageno));
                end
                inputpagecounter = inputpagecounter + 1;
                hPlayRec('delPage',pageno);
                pagelist = hPlayRec('getPageList');
            end
        end
        
        if timeout
            break
        end
        % pause
    end %loop for repeats
    
    ita_verbose_info('playback/record finished ',1);
end

% Remove cancel button
if sArgs.block && sArgs.cancelbutton
    if ~showMonitor
        CancelButton.Clear();
    end
end

recordData = itaAudio();
recordData.dataType = class(recordDatadat);
recordData.dataTypeOutput = class(recordDatadat);
% Check if we need to average multiple measurements:
if size(recordDatadat,3) > 1
    % average:
    recordData.timeData = mean(recordDatadat,3);
else
    % no average: (This saves memory!)
    recordData.timeData = recordDatadat;
end
recordData.samplingRate = sArgs.samplingRate;

for idx = 1:numel(in_channel_vec)
    recordData.channelNames{idx} = ['Ch ' int2str(in_channel_vec(idx))];
end

%% Check for aborting
% In case the user cancelled the measurement, set result to empty and
% return
if record
    if playback
        nSamples = data.nSamples;
    else
        nSamples = sArgs.recsamples;
    end
    if recordData.nSamples ~= nSamples
        ita_verbose_info('Cancelled by user, result will be empty!',0);
        varargout{1} = itaAudio;
        return;
    end
end

%% Remove Latency
if playback && record && ~isempty(sArgs.latencysamples) && (sArgs.latencysamples > 0)
    recordData = ita_extract_dat(recordData,recordData.nSamples-latencysamples,'firstsample',latencysamples+1);
end

%% Check for clipping and other errors
clipping = false;
if record
    if any(any(abs(recordData.timeData)>=1)) %Check for clipping
        ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',0);
        ita_verbose_info('!ITA_PORTAUDIO:Careful, Clipping!',0);
        ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',0);
        clipping = true;
    end
    % This check for singularities needs a lot of memory! TODO: find a
    % better solution!:
    if any(any(isnan(recordData.timeData))) || any(any(isinf(recordData.dat))) %Check for singularities
        ita_verbose_info('There are singularities in the audio signal! You''d better check your settings!',0)
        clipping = true;
    end
    if any(all(recordData.timeData == 0,1)) && record
        ita_verbose_info('There are empty channels in the audio signal! You''d better check your settings!',0)
    end
    [channelvolumes, index] = max(max(abs(recordData.timeData),[],1));
    
    % jri: to detect non working microphones etc, the minimum of the
    % maximums on the channels is also outputted
    if length(in_channel_vec) > 1
        [channelvolumesMin, indexMin] = min(max(abs(recordData.timeData),[],1));
        ita_verbose_info(['Minimum digital level: ' int2str(20*log10(channelvolumesMin)) ' dBFS on channel: ' int2str(in_channel_vec(indexMin))],0);
    end
    ita_verbose_info(['Maximum digital level: ' int2str(20*log10(channelvolumes)) ' dBFS on channel: ' int2str(in_channel_vec(index))],0);
end

%% Check if soundcard-settings are right

if record
    [recDeviceName, recDeviceInfo] = ita_portaudio_deviceID2string(hPlayRec('getRecDevice'));
    if recDeviceInfo.defaultSampleRate ~= sArgs.samplingRate
        if sArgs.samplingRate == hPlayRec('getSampleRate')
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
end

if playback
    [playDeviceName, playDeviceInfo] = ita_portaudio_deviceID2string(hPlayRec('getPlayDevice'));
    if playDeviceInfo.defaultSampleRate ~= sArgs.samplingRate
        if sArgs.samplingRate == hPlayRec('getSampleRate')
            ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',1);
            ita_verbose_info('!ITA_PORTAUDIO:Careful, not the device''s default SamplingRate!',1);
            ita_verbose_info(['! Standard Play Device Fs: ' num2str(playDeviceInfo.defaultSampleRate) 'Hz'],1);
            ita_verbose_info(['!  Current Play Device Fs: ' num2str(hPlayRec('getSampleRate')) 'Hz'],1);
            ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',1);
        else
            clipping = true;
            ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',0);
            ita_verbose_info('!ITA_PORTAUDIO:Careful, SamplingRate may not be set correctly!',0);
            ita_verbose_info(['! Play Device seems to have: ' num2str(playDeviceInfo.defaultSampleRate) 'Hz'],0);
            ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',0);
        end
    end
end

%% Terminate Playrec
if sArgs.reset
    hPlayRec('reset')
end

%% Add history line
infosforhistory = struct('PlayDevice',playDeviceName,'Play_Channels',out_channel_vec,'RecDevice',recDeviceName,'Rec_Channels',in_channel_vec,'Sampling_Rate',sArgs.samplingRate,'Normalize_Input',normalize_input,'Normalize_Output',normalize_output,'Rec_Samples',sArgs.recsamples,'Block',sArgs.block,'Repeats',sArgs.repeats);
if sArgs.block %We record the one from last run when not blocking, so there is no use of sub-history
    recordData = ita_metainfo_add_historyline(recordData,'ita_portaudio',[{data}; ita_struct2arguments(infosforhistory)],'withsubs');
else
    recordData = ita_metainfo_add_historyline(recordData,'ita_portaudio',[{data}; ita_struct2arguments(infosforhistory)]);
end

if clipping
    recordData = ita_metainfo_add_historyline(recordData,'!!!ITA_PORTAUDIO:Careful, clipping or something else went wrong!!!');
    recordData = ita_errorlog_add(recordData,'!!!ITA_PORTAUDIO:Careful, clipping or something else went wrong!!!');
end

%% Find output parameters
if nargout ~= 0
    if normalize_input, ita_normalize_dat(recordData); end;
    varargout{1} = recordData;
end

end