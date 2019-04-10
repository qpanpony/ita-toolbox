function ita_HRTFarc_measurementScript_continuous(varargin)
%ita_HRTFarc_measurementScript_continuous - +++ example of continuous measurement with the new HRTFarc +++
%
%   Reference page in Help browser 
%        <a href="matlab:doc test">doc test</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  04-Oct-2018 

% set this to 1 if you want to measure the system latency
options.measureLatency = 0;

% init the motor object
iMS = test_itaEimarMotorControl;

% init the measurement object
ms = itaMSTFinterleaved;

if options.measureLatency == 0
    ms.latencysamples = 629;
else
    ms.inputChannels = 11;
    ms.outputChannels = 20;
    
    input('Connect the amp to ch 11')
    ms.run_latency;
    input('Disconnect the amp')
end


ms.outputChannels = (1:64)+18;
% for continuous measurement, three inputs are required, left right and the
% switch
ms.inputChannels = [11 12 13];

%define a freq range
ms.freqRange = [500 22050];

ms.optimize
ms.twait = 0.03;

% the number of repetitions defines the rotation speed
% 64 is ~ 3 minutes
numRepetitions = 64;

ms.repetitions = numRepetitions;

iMS.measurementSetup = ms;


% this prepares the full measurement. 
% it does a reference move, and moves back the arc by 45 degrees
iMS.prepareContinuousMeasurement;


[res,raw] = iMS.runContinuousMeasurement;

saveName = 'test';
ita_write(res,sprintf('%s_%d',saveName,numRepetitions))
ita_write(raw,sprintf('%s_%d_raw',saveName,numRepetitions))

% this moves the arc back faster
iMS.moveTo('HRTFArc',20, 'absolut', true, 'speed', 5, 'wait', true);

%always leave the arc in reference position
iMS.reference

end