function resp = motor_move(s,motorID,maxFreq,transmission,microsteps,angle,direction)


% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if ~strcmpi(s.status,'open')
    fopen(s);
end
% ramp
b = @(x) round((3000/(x + 11.7))^2); % x is Hz/ms
fwrite(s,sprintf('#%db%d\r',motorID,b(100))); % acceleration ramp
fwrite(s,sprintf('#%dB0\r',motorID)); % break ramp (0 means sequal to acc ramp)

% direction = 0;
steps = floor(microsteps*angle/1.8*transmission);

% microsteps
fwrite(s,sprintf('#%dg%d\r',motorID,microsteps)); % 1,2,4, ...

% steps
fwrite(s,sprintf('#%ds%d\r',motorID,steps));
% direction
fwrite(s,sprintf('#%dd%d\r',motorID,direction)); % 0:left, 1:right

fwrite(s,sprintf('#%du%d\r',motorID,50)); % minimal freq
fwrite(s,sprintf('#%do%d\r',motorID,maxFreq)); % maximal freq

pause(0.05);
% empty serial buffer
flushinput(s);

% read out current set
fwrite(s,sprintf('#%dZ|\r',motorID)); % relative positioning
pause(0.05);
resp = '';
while s.bytesAvailable
    resp = fgetl(s);
end
if ~isempty(resp)
    parts = regexp(resp(3:end),'+','split');
    setupStruct = struct();
    for iPart = 1:numel(parts)-1
        if iPart == numel(parts)-1
            setupStruct.(parts{iPart}(end)) = str2double(parts{iPart+1}(1:end));
        else
            setupStruct.(parts{iPart}(end)) = str2double(parts{iPart+1}(1:end-1));
        end
    end
    % show settings
    disp(setupStruct);
end
pause(1);

% move
fwrite(s,sprintf('#%dA\r',motorID)); % run with settings sent before
pause(0.05);
flushinput(s);

status = 0;
counter = 0;
while ~abs(status)
    counter = counter + 1;
    fwrite(s,sprintf('#%d$\r',1)); % what's the status
    resp = fgetl(s);
    if ~isempty(resp) && (strcmpi(resp(4), 'j') || strcmpi(resp(4), '$')) % got status
        byte = str2double(resp(5:end));
        if isnumeric(byte) && ~isinf(byte) && ~isnan(byte)
            byte = dec2bin(byte, 8);
            if strcmp(byte(end),'1') && ~strcmp(byte(end-2), '1')
                disp('position reached, all is well!');
                status = 1;
            elseif strcmp(byte(end-2), '1')
                disp('positioning error, something went wrong (maybe)!');
                status = -1;
            elseif ~mod(counter,20)
                disp('still moving ...');
            end
        end
    end
    pause(0.05);
end

fclose(s);
end
% end function