function result = ita_read_au(filename,varargin)
%ITA_WAVREAD - Read NeXT/SUN (".au") sound file.
%   This function is completely based on the MATLAB auvread function.
%
%   It returns an itaAudio object containing the files data and metadata.
%
%   See also ita_read, ita_write, auread.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Return type of data this function can read
if nargin == 0
    result{1}.extension = '.au';
    result{1}.comment = 'SUN au Files (*.au)';
    result{2}.extension = '.snd';
    result{2}.comment = 'SUN snd Files (*.snd)';
    return
else
    % initialize standard values
    sArgs = struct('interval','vector',...
        'isTime',false,...
        'channels','vector',...
        'metadata',false);
    sArgs = ita_parse_arguments(sArgs,varargin);
end

if ~sArgs.metadata && isempty(sArgs.interval) && isempty(sArgs.channels)
    result = itaAudio(1);
    [Y,Fs] = auread(filename);
    result.timeData = Y;
else
    [SIZE,Fs] = auread(filename,'size');
    
    if sArgs.metadata
        result = itaAudioDevNull(1);
        result.timeData = zeros(SIZE);
    else
        result = itaAudio(1);
        [samples,channels] = check_limits(SIZE,Fs,sArgs);
        [Y,Fs] = auread(filename,samples);
        result.timeData = Y(:,channels);
    end
end

result.samplingRate = Fs;
result.fileName = filename;
result.comment = '.au file import';

end % EOF ita_read_au


function [samples,channels] = check_limits(size, Fs, sArgs)
% if we have to read only a part of the file

nSamples = size(1);
nChannels = size(2);

if isempty(sArgs.interval)
    samples = [];
else
    if sArgs.isTime
        % convert time interval to samples
        if numel(sArgs.interval) == 1
            intervalStart = 1;
            intervalEnd = ceil(sArgs.interval .* Fs);
        elseif numel(sArgs.interval) == 2
            intervalStart = ceil(sArgs.interval(1) .* Fs);
            intervalEnd = ceil(sArgs.interval(2) .* Fs);
        else
            error('Sample limit vector must have 2 elements.')
        end
    else
        if numel(sArgs.interval) == 1
            intervalStart = 1;
            intervalEnd = sArgs.interval;
        elseif numel(sArgs.interval) == 2
            intervalStart = sArgs.interval(1);
            intervalEnd = sArgs.interval(2);
        else
            error('Sample limit vector must have 2 elements.')
        end
    end

    % interval has to be in range of the track
    if (intervalStart < 1)
        intervalStart = 1;
        ita_verbose_info('ita_read: start time set to 0',2); 
    end
    if (intervalEnd > nSamples)
        intervalEnd = nSamples;
        ita_verbose_info(['ita_read: end time set to ' nus2str(nSamples)],2);
    end
    samples = [intervalStart intervalEnd];
end

if isempty(sArgs.channels)
    channels = 1:nChannels;
elseif isscalar(sArgs.channels) && sArgs.channels <= nChannels
    channels = sArgs.channels;
elseif isvector(sArgs.channels)
    channels = sArgs.channels(sArgs.channels <= nChannels);
else
    error('Channel limit must be an integer or a vector.');
end

end