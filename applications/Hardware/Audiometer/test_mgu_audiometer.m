%% generate test signal

% testSig = ita_generate('pinknoise', 1,44100,18);
% testSig = ita_normalize_dat(testSig);

% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



testSig = ita_generate('sine', 1,1000,44100,20);


%% play no blocking
ita_portaudio_run(testSig,  'Block' , false)


%% init serial port

port = 'COM1';

% serialObj = serial(port,'BaudRate',9600, 'BytesAvailableFcnMode', 'byte');% , 'BytesAvailableFcn', @rxDataAndPrint);
serialObj = serial(port,'BaudRate',9600);
fopen(serialObj);

%% 

audiometerTestGui(serialObj)
%% bekesy parameter

ita_norsonic838(serialObj, 'daVolume', -120)
ita_norsonic838(serialObj, 'mute',0)

ita_norsonic838(serialObj, 'fadeSpeed', 10)

ita_norsonic838(serialObj, 'minfadelevel', -90)
ita_norsonic838(serialObj, 'maxfadelevel', -50)

%%
ita_norsonic838(serialObj,'soundlevelpresent', 0)


%%
ita_norsonic838(serialObj,'bekesydatarequest')
serialObj.BytesAvailable

%%
ita_norsonic838(serialObj,'timedatarequest')
serialObj.BytesAvailable


%%
pause(1)
ita_norsonic838(serialObj, 'bekesy', 'start')


% ita_norsonic838(serialObj, 'bekesy', 'restart')
 testSig.play

ita_norsonic838(serialObj, 'bekesy', 'stop')


data = fread(serialObj)
printOutput(data)
%%



pause(1)
ita_norsonic838(serialObj, 'bekesy', 'start')


% ita_norsonic838(serialObj, 'bekesy', 'restart')
startTime = now;
trackLength = testSig.trackLength;

while (now-startTime)*24*3600 < trackLength
   
    if serialObj.BytesAvailable
       fprintf('\t %i Bytes available\n', serialObj.BytesAvailable) 
%     data = fread(serialObj)
%     printOutput(data)
end

    
    
end

ita_norsonic838(serialObj, 'bekesy', 'stop')

% if serialObj.BytesAvailable
%     data = fread(serialObj)
%     printOutput(data)
% end
% 



%%

while 1
    testSig.play
end


%%

data = fread(serialObj, serialObj.BytesAvailable)
printOutput(data)



%%

inStruct.bracketingFadeSpeed = 5;

inStruct.pulsingActive = 1
inStruct.pulsingFadeSpeed = 200;
inStruct.pulsingAttenuation = 50;
inStruct.pulsingDuration = 200;


o = ita_audiometer_preferences(inStruct)

%% debug test of algorithm

newSwitchTimeData = [-50 0 2; -18 500 3; -33 750 2; -20 1000 3; -25 1500 2; -23 1600 3; -35 1900 2; -18 2100 3; -33 2300 2];
evalUserResponses(allResponses, newSwitchTimeData, gData)

%% calibrate 
freqVec = [125 160 200 250 315 400 500 630 750 800 1000 1250 1500 1600 2000 2500 3000 3150 4000 5000 6000 6300 8000]

RETSPL_THD = [45 37.5 31.5 25.5 20 15 11.5 8.5 7.5 7 7 6.5 6.5 7 9 9.5 10 10 9.5 13 15.5 15 13];
figure
semilogx(freqVec, RETSPL_THD, 'o-');
grid on
        