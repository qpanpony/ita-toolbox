function ita_HRTFarc_measurementScript(varargin)
%ita_HRTFarc_measurementScript - +++ example of continuous measurement with the new HRTFarc +++
%
% This is an example of a step-wise measurement. Only use this with the
% turntable and subject rotation
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

coords = ita_generateSampling_equiangular(5,5);
coords_cut = coords.n(coords.theta_deg == 90);

iMS.measurementSetup = ms;
iMS.measurementPositions = coords_cut;

iMS.waitBeforeMeasurement = 1;

saveName = 'test';
iMS.dataPath = saveName;
iMS.reference;
iMS.doSorting = 0;
iMS.run;

% always leave the turntable in reference position
iMS.reference

end