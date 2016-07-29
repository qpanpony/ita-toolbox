function ita_norsonic838(serialObject, parameterName, value)
% function to control norsonic 838 via COM port
% mgu 2013


% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

switch lower(parameterName)
    
    case 'davolume'
        parameterNo    = '41';
        parameterValue = dBFS_level2hex(value);
        
        
    case 'mute'
        parameterNo    = '98';
        
        %         parameterValue = sprintf('%02i', value);
        switch value
            case {0, 'off', 'false'}
                parameterValue = '00';
            case {1, 'on', 'true'}
                parameterValue = '01';
            otherwise
                error('unkown value for %s (0 or 1)', upper(parameterName))
        end
        
        
    case 'bracketingfadespeed'
        parameterNo = '8D';
        blockSize = 4;
        samplingRate = 44100;
        
        fadeFak = 2^23 * (1-10 ^(-value*blockSize/20/samplingRate));
        parameterValue = dec2hex(round(fadeFak), 4);
        
        
    case {'minfadelevel', 'maxfadelevel'}
        
        parameterNo = num2str(find(strcmpi({'minfadelevel', 'maxfadelevel'}, parameterName)) - 1 + 90);
        parameterValue = dBFS_level2hex(value);
        
    case 'bekesy'
        parameterNo    = '8F';
        optNumber = find(strcmpi({'stop', 'start', 'restart'}, value));
        
        if isempty(optNumber)
            error('wrong value for %s option', parameterName)
        else
            parameterValue = num2str( optNumber -1, '%02i');
        end
        
    case 'bekesydatarequest'
        parameterNo = '99';
        %         parameterNo = 'A0';
        parameterValue = '00';
        
    case 'timedatarequest'
        parameterNo = '4F';
        parameterValue = '00';
        
    case 'pulsingactive'
        parameterNo = '9E';
        
        switch value
            case {0, 'off', 'false'}
                parameterValue = '00';
            case {1, 'on', 'true'}
                parameterValue = '01';
            otherwise
                error('unkown value for %s (0 or 1)', upper(parameterName))
        end
        
    case 'pulsingattenuation'
        parameterNo    = '9B';
        parameterValue = dBFS_level2hex(value);
        
        
    case 'pulseingabelung' % ??
        parameterNo    = '4D';
        parameterValue = dBFS_level2hex(value);
        
        
    case 'soundlevelpresent'
        parameterNo    = '4E';
        parameterValue = dBFS_level2hex(value);
    
    case 'pulsingperiod'
        parameterNo    = '9F';
        
        if value > 2550 || value < 0
            error(' 0 ms < pulsing duration  < 2550 ms ')
        end
        parameterValue = dec2hex(round(value/10),2);
        
        
    case 'pulsingfadespeed'
        parameterNo = '9C';
        blockSize = 4;
        samplingRate = 44100;
        
        fadeFak = 2^23 * (1-10 ^(-value*blockSize/20/samplingRate));
        parameterValue = dec2hex(round(fadeFak), 4);
        
        
        
        
    otherwise
        error('unknown parameter name: %s', parameterName)
        
        
end

% {parameterNo parameterValue}


commandDec = generateFullCommand(parameterNo, parameterValue);

fwrite(serialObject, commandDec)

% print to console
% tmpSendCode = dec2hex(commandDec);
% tmpSendCode = reshape([tmpSendCode repmat(' ', size(tmpSendCode,1),1)].', 1, []);
% % fprintf('\t%s   %s   %s   %s \n',tmpSendCode(1:21), tmpSendCode(22:33), tmpSendCode(34:45), tmpSendCode(46:end))
% fprintf('\t%s   %s   %s   %s \n',tmpSendCode(1:21), tmpSendCode(22:33), tmpSendCode(34:end-4), tmpSendCode(end-3:end))

end


function commandDec = generateFullCommand(parameterNo, parameterValue)

commandStart = [240     0    32    64     0     0     7]; % F0 00 20 40 00 00 07
commandEnd   =  247;                                      % F7

if numel(parameterValue) ==2
    command = sprintf('00000%c0%c0%c0%c',parameterNo, parameterValue );
elseif numel(parameterValue) == 4
    command = sprintf('00000%c0%c0%c0%c0%c0%c',parameterNo, parameterValue([3 4 1 2]) );
end
% erase spaces
% final_command = final_command(final_command ~= ' ');



commandDec = zeros(1,size(command,2) /2);
for iHex = 1:size(command,2)/2
    commandDec(iHex) = hex2dec(command(((iHex-1)*2+1) + [0 1]));
end

commandDec = [commandStart commandDec commandEnd];

end


function hexLevel = dBFS_level2hex(dBFS_level)

hexLevel = dec2hex(dBFS_level +127,2);

end