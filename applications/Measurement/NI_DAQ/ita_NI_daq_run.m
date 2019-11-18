function varargout = ita_NI_daq_run(varargin)
% ITA_NI_DAQ_RUN play and record sound with NI card and DAQ toolbox (adapted from ita_portaudio_run)
% see ita_portaudio_run for options and help

% Autor: Markus Mueller-Trapet -- Email: markus.mueller-trapet@nrc.ca
% Created:  13-Apr-2017

%% ITA Toolbox preferences for verbose level
verboseMode = ita_preferences('verboseMode');

%% Input checks
if isa(varargin{1},'itaAudio')
    % if a signal is the first input, then playback that signal
    sArgs.pos1_data = 'itaAudioTime';
    playback = true;
else
    % otherwise just record for the given number of samples
    sArgs.pos1_data = 'numeric';
    playback = false;
end

% second argument has to be the DAQ NI session
sArgs.pos2_niSession = 'anything';

% only do recording if requested
if nargout > 0
    record = true;
else
    record = false;
end

%% Init Settings
sArgs.normalizeinput    = false;
sArgs.normalizeoutput   = false;

sArgs.inputchannels     = [];
sArgs.outputchannels    = [];
sArgs.recsamples        = -1;
sArgs.repeats           = 1;
sArgs.samplingRate      = -1; % will always be taken from NI session
% cancel button and monitor not supported currently, but kept for compatibility
sArgs.cancelbutton      = ita_preferences('portAudioMonitor'); % -1:automatic; 0:off; 1:on
sArgs.latencysamples    = 0;
sArgs.singleprecision   = false;

[data, niSession, sArgs] = ita_parse_arguments(sArgs,varargin);

if ~playback && sArgs.recsamples == -1
    sArgs.recsamples = data;
end

if ~playback && ~record
    error('ITA_NI_DAQ_RUN:What do you want? Play or Record, or both? You need to specify an input and/or an output!')
end

sArgs.samplingRate = round(niSession.Rate); % NI rate is not exact

in_channel_vec   = sArgs.inputchannels;
out_channel_vec  = sArgs.outputchannels;
normalize_input  = sArgs.normalizeinput;
normalize_output = sArgs.normalizeoutput;

if playback
    % Extract channels to play
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
    
    % Show channel data if requested
    if verboseMode==2
        ita_metainfo_show_channelnames(data);
    end
    
    % Check levels - Normalizing
    % determine clipping limit from NI session information
    outputClipping = 1; % standard
    for iChannel = 1:numel(niSession.Channels)
        isOutput = ~isempty(strfind(niSession.Channels(iChannel).ID,'ao'));
        if isOutput
            outputClipping = max(outputClipping,max(abs(double(niSession.Channels(iChannel).Range))));
        end
    end    
    peak_value = max(max(abs(data.timeData)));
    if (peak_value > outputClipping) || (normalize_output)
        ita_verbose_info('Oh Lord! Levels too high for playback. Normalizing...',0)
        data = data/peak_value*outputClipping;
    end
end

%% Extend excitation to compensate soundcard latency
if playback && record && ~isempty(sArgs.latencysamples) && (sArgs.latencysamples > 0)
    latencysamples = sArgs.latencysamples;
    data = ita_extend_dat(data,data.nSamples+latencysamples,'forcesamples');
end

% record as many samples as are in the playback signal
if playback
    sArgs.recsamples = data.nSamples;
end

if record
    % Full (double) precision
    recordDatadat = zeros(sArgs.recsamples,numel(in_channel_vec),sArgs.repeats);
    if sArgs.singleprecision
        % only single precision
        recordDatadat = single(recordDatadat);
    end
end

% run measurement, possibly repeated
for idrep = 1:sArgs.repeats
    if playback && record
        niSession.queueOutputData(double(data.time));
        ita_verbose_info('start playback and record',1)
    elseif record
        niSession.queueOutputData(zeros(sArgs.recsamples,1));
        ita_verbose_info('start record',1)
    elseif playback
        niSession.queueOutputData(double(data.time));
        ita_verbose_info('start playback',1)
    else
        error('ITA_NI_DAQ_run:No input and no output, what should I do?')
    end
    pause(0.01)
    % do the measurement
    if record
        if ~sArgs.singleprecision % Full (double) precision
            recordDatadat(:,:,idrep) = niSession.startForeground();
        else
            recordDatadat(:,:,idrep) = single(niSession.startForeground());
        end
    else
        niSession.startForeground();
    end
end % loop for repeats

ita_verbose_info('playback/record finished ',1);

if record
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
end

%% Remove Latency
if playback && record && ~isempty(sArgs.latencysamples) && (sArgs.latencysamples > 0)
    recordData = ita_extract_dat(recordData,recordData.nSamples-latencysamples,'firstsample',latencysamples+1);
end

%% Check for clipping and other errors
clipping = false;
if record
    % determine clipping limit from NI session information
    clippingLimit = Inf;
    for iChannel = 1:numel(niSession.Channels)
        isInput = ~isempty(strfind(niSession.Channels(iChannel).ID,'ai'));
        if isInput
            clippingLimit = min(clippingLimit,max(abs(double(niSession.Channels(iChannel).Range))));
        end
    end    
    
    if any(any(abs(recordData.timeData)>=clippingLimit)) % Check for clipping (NI card actually handles up to 10Vpk)
        ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',0);
        ita_verbose_info('!ITA_NI_DAQ_RUN:Careful, Clipping!',0);
        ita_verbose_info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',0);
        clipping = true;
    end
    % This check for singularities needs a lot of memory! TODO: find a
    % better solution!:
    if any(isnan(recordData.timeData(:))) || any(isinf(recordData.timeData(:))) %Check for singularities
        ita_verbose_info('There are singularities in the audio signal! You''d better check your settings!',0)
        clipping = true;
    end
    if any(all(recordData.timeData == 0,1)) && record
        ita_verbose_info('There are empty channels in the audio signal! You''d better check your settings!',0)
    end
    % maximum for each channel
    maxData = max(abs(recordData.timeData),[],1);
    [channelMax, indexMax] = max(maxData);
    
    % jri: to detect non working microphones etc, the minimum of the
    % maximums on the channels is also outputted
    if length(in_channel_vec) > 1
        [channelMin, indexMin] = min(maxData);
        ita_verbose_info(['Minimum digital level: ' int2str(20*log10(channelMin)) ' dBFS on channel: ' int2str(in_channel_vec(indexMin))],0);
    end
    ita_verbose_info(['Maximum digital level: ' int2str(20*log10(channelMax)) ' dBFS on channel: ' int2str(in_channel_vec(indexMax))],0);
    
    % Add history line
    infosforhistory = struct('PlayDevice','NI','Play_Channels',out_channel_vec,'RecDevice','NI','Rec_Channels',in_channel_vec,'Sampling_Rate',niSession.Rate,'Normalize_Input',normalize_input,'Normalize_Output',0,'Rec_Samples',sArgs.recsamples,'Block',1,'Repeats',sArgs.repeats);
    recordData = ita_metainfo_add_historyline(recordData,'ita_NI_daq_run',[{data}; ita_struct2arguments(infosforhistory)],'withsubs');
    
    if clipping
        recordData = ita_metainfo_add_historyline(recordData,'!!!ITA_NI_DAQ_RUN:Careful, clipping or something else went wrong!!!');
        recordData = ita_errorlog_add(recordData,'!!!ITA_NI_DAQ_RUN:Careful, clipping or something else went wrong!!!');
    end
end

%% Find output parameters
if nargout ~= 0 && record
    if normalize_input
        recordData = ita_normalize_dat(recordData);
    end
    varargout{1} = recordData;
end

end % function