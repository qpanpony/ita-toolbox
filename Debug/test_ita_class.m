function test_ita_class()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% RSC - test ita_struct2audio and ita_audio2struct, test if conversion is transparent
noise = ita_generate('noise',1,44100,3); 

timedata = noise.timeData;
time = noise.time;
freqdata = noise.freqData;
freq = noise.freq;

freqVector = noise.freqVector;
samplingRate = noise.samplingRate;
signalType = noise.signalType;
fftDegree = noise.fftDegree;
trackLength = noise.trackLength;

clear timedata time freqdata freq freqVector samplingRate signalType fftDegree trackLength
end