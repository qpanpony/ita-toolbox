%% Tutorial for itaWaitbar
% Author: Martin Gustik - mgu

% init:
%     wb = itaWaitbar(nLoops);     % init with number of loops  OR
%     wb = itaWaitbar(nLoops, 'start calculation...' );     % init with number of loops and message
%
% increas counter
%     wb.inc;                         % increase loop counter OR
%     wb.inc('calculating level');    % increase loop counter and update message
%     
% close
%     close(wb)    OR
%     wb.close
    
%% simplest call
nChannels = 11;

wb = itaWaitbar(nChannels);     % init with number of loops

for iChannel = 1:nChannels
    wb.inc;                     % increase loop counter
    % calculate....
    pause(0.5)
end

wb.showTotalTime
pause(2)
wb.close                        % close

%% call with update messages

nChannels = 11;

wb = itaWaitbar(nChannels, 'start calculation...' );     % init with number of loops and message

pause(1) % just to see first message
for iChannel = 1:nChannels
    updateMsgStr = sprintf('channel %i', iChannel);
    wb.inc(updateMsgStr);                     % increase loop counter and update message
    
    % calculate....
    pause(0.5)
end
wb.close                        % close


%% nested loops
nChannels = 5;
nFreq = 3;
nSamples = 25;
wb = itaWaitbar([nChannels, nFreq, nSamples], 'example with nested loops', {'channel' 'frequency' 'sample' });
for iChannel = 1:nChannels
    for iFreq = 1:nFreq
        updateMsg = sprintf('calculating freq %i', iFreq);
        for iSample = 1:nSamples
            wb.inc(updateMsg);
            
            % calculate....
            pause(0.05)
        end
    end
end
wb.close




%% calling of more than one waitbar
nChannels = 5;
nFreq = 3;
nSamples = 25;
wb1 = itaWaitbar([nChannels], 'first waitbar', {'channel'  });
for iChannel = 1:nChannels
    wb1.inc
    
    % this could be a subfunction
    wb2 = itaWaitbar([nFreq, nSamples], 'second waitbar', {'frequency' 'sample' });
    for iFreq = 1:nFreq
        str = sprintf('calculating freq %i', iFreq);
        
        for iSample = 1:nSamples
            wb2.inc(str);
            
            % calculate....
            pause(0.05)
        end
    end
    wb2.close
    % end of subfunction
    
end
wb1.close


%%

