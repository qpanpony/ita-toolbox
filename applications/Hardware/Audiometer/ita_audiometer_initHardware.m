function [serialPort, playDeviceID, samplingRate, outputChannles] = ita_audiometer_initHardware()
% init sound card and com port for norsonix audiometer
% Martin Guski, 03-2013

% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



%% init COM port

comPortName = 'COM1';

% delete old ports
oldPorts  = instrfind('Port',comPortName);
delete(oldPorts);

serialPort = serial(comPortName,'BaudRate',9600);


% open serial port
fopen(serialPort);
fprintf('\n serial port %s : open\n', comPortName)



%% init sound card

deviceStruct = playrec('getDevices');
% deviceStructIdx = find(strcmpi({deviceStruct.name}, 'M-Audio USB 2.0 ASIO'));
% deviceStructIdx = find(strcmpi({deviceStruct.name}, 'FireBox ASIO'));

deviceStructIdx = find(strcmpi({deviceStruct.name}, 'ASIO Hammerfall DSP'));
if isempty(deviceStructIdx) % not hammerfall
    deviceStructIdx = find(strcmpi({deviceStruct.name}, 'FireBox ASIO x64'));
    outputChannles = 7:8;
else
    outputChannles = 1:2;
end




playDeviceID = deviceStruct(deviceStructIdx).deviceID;
samplingRate =  deviceStruct(deviceStructIdx).defaultSampleRate;

% init sound card
if ~playrec('isInitialised')
    playrec('init', samplingRate, playDeviceID, -1);
    pause(0.1);
end


end