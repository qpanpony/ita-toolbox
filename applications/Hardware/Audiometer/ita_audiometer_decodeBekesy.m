function [decodeData, remainingRaw] = ita_audiometer_decodeBekesy(rawData)
%ITA_AUDIOMETER_DECODEBEKESY - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_audiometer_decodeBekesy(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_audiometer_decodeBekesy(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_audiometer_decodeBekesy">doc ita_audiometer_decodeBekesy</a>

% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  25-Jan-2013


%  resultData = [nPoints x 3]. 2nd dimension: [level, nTicks, switchState]

verboseMode = true;

decodeData = zeros(0,3);

messageIncomplete = false;

while ~isempty(rawData) && ~messageIncomplete
    
    switch(rawData(1))
        case 171 % normal data
            
            if length(rawData) < 8
                messageIncomplete = true;
            else
                
                nTicks = rawData(2)*256 + rawData(3);
                faktor = rawData(4)*256^2 + rawData(5)*256 + rawData(6);
                switchLevel = 20*log10( faktor / 8388607); %   hex2dec('7FFFFF') = 8388607
                
                switchState = rawData(7);
                
                if rem(sum(rawData(1:7)),256) ~= rawData(8)
                    if verboseMode
                        fprintf('invalid checksum\n')
                    end
                    decodeData(end+1,:) = nan;
                else
                    if verboseMode
                        fprintf('level %2.2f dBFS, %1.2f s (%i) switchState: %i\n', switchLevel, nTicks * 0.01, nTicks, switchState);
                    end
                    decodeData(end+1,:) = [switchLevel, nTicks *10e-3, switchState]; %#ok<*AGROW>
                end
                
                rawData = rawData(9:end);
                
            end
        case 172
            if length(rawData) < 3
                messageIncomplete = true;
            else
                switchState = rawData(2);
                if sum(rawData(1:2)) ~= rawData(3)
                    if verboseMode
                        fprintf('invalid checksum\n')
                    end
                end
                
                if verboseMode
                    fprintf(' switchState: %i ???\n',  switchState)
                end

                rawData = rawData(4:end);
            end
            
        otherwise
            fprintf('\t broken frame. skipping value: %i', rawData(1))
            rawData = rawData(2:end);
%             error('unknown header %i', rawData(1))
            
            
    end
end

remainingRaw = rawData;

%end function
end