function [ ] = loop_back( playDeviceID, recDeviceID, playChanList, recChan, Fs)
%LOOP_BACK Loops back an input channel onto output channel(s)
%

pageSize = 256;    %size of each page processed
pageBufCount = 10;   %number of pages of buffering

runMaxSpeed = false;  %When true, the processor is used much more heavily 
                     %(ie always at maximum), but the chance of skipping is 
                     %reduced

if ~isreal(recChan) || length(recChan) ~= 1 ...
    || ndims(recChan)~=2 || size(recChan, 1)~=1

    error ('recChan must be a single channel');
end

if ~isreal(playChanList) || length(playChanList) < 1 ...
    || ndims(playChanList)~=2 || size(playChanList, 1)~=1

    error ('playChanList must be a real row vector with at least 1 element');
end

%Test if current initialisation is ok
if(playrec('isInitialised'))
    if(playrec('getSampleRate')~=Fs)
        fprintf('Changing playrec sample rate from %d to %d\n', playrec('getSampleRate'), Fs);
        playrec('reset');
    elseif(playrec('getPlayDevice')~=playDeviceID)
        fprintf('Changing playrec play device from %d to %d\n', playrec('getPlayDevice'), playDeviceID);
        playrec('reset');
    elseif(playrec('getRecDevice')~=recDeviceID)
        fprintf('Changing playrec record device from %d to %d\n', playrec('getRecDevice'), recDeviceID);
        playrec('reset');       
    elseif(playrec('getPlayMaxChannel')<max(playChanList))
        fprintf('Resetting playrec to configure device to use more output channels\n');
        playrec('reset');
    elseif(playrec('getRecMaxChannel')<recChan)
        fprintf('Resetting playrec to configure device to use more input channels\n');
        playrec('reset');
    end
end

%Initialise if not initialised
if(~playrec('isInitialised'))
    fprintf('Initialising playrec to use sample rate: %d, playDeviceID: %d and recDeviceID: %d\n', Fs, playDeviceID, recDeviceID);
    playrec('init', Fs, playDeviceID, recDeviceID, max(playChanList), recChan);
    
    % This slight delay is included because if a dialog box pops up during
    % initialisation (eg MOTU telling you there are no MOTU devices
    % attached) then without the delay Ctrl+C to stop playback sometimes
    % doesn't work.
    pause(0.1);
end
    
if(~playrec('isInitialised'))
    error ('Unable to initialise playrec correctly');
end

if(playrec('pause'))
    fprintf('Playrec was paused - clearing all previous pages and unpausing.\n');
    playrec('delPage');
    playrec('pause', 0);
end

pageNumList = [];

nextPageSamples = zeros(pageSize, 1);

for repeatCount = 1:(15*Fs/pageSize)
        
    pageNumList = [pageNumList playrec('playrec', repmat(nextPageSamples, 1, length(playChanList)), ...
        playChanList, -1, recChan)];

    if(repeatCount==1)
        %This is the first time through so reset the skipped sample count
        playrec('resetSkippedSampleCount');
    end
    
    % runMaxSpeed==true means a very tight while loop is entered until the
    % page has completed whereas when runMaxSpeed==false the 'block'
    % command in playrec is used.  This repeatedly suspends the thread
    % until the page has completed, meaning the time between page
    % completing and the 'block' command returning can be much longer than
    % that with the tight while loop
    if(length(pageNumList) > pageBufCount)
        if(runMaxSpeed)
            while(playrec('isFinished', pageNumList(1)) == 0)
            end
        else        
            playrec('block', pageNumList(1));
        end

        nextPageSamples = playrec('getRec', pageNumList(1));
        playrec('delPage', pageNumList(1));
        
        pageNumList = pageNumList(2:end);
    end
end

fprintf('Loop back complete with %d samples worth of glitches\n', playrec('getSkippedSampleCount'));

%delete all pages now loop has finished
playrec('delPage');
    