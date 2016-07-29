

% <ITA-Toolbox>
% This file is part of the application Microflown for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Measurement setup
ms_microflown = itaMSTF;


%% Latency measurement
ms_microflown.useMeasurementChain = 0;

ms_microflown.inputChannels  = [1 2];
ms_microflown.outputChannels = 1;

ms_microflown.fftDegree = 17;

ms_microflown.freqRange = [100 22050];

ms_microflown.outputamplification = -15;

ms_microflown.run_latency;

