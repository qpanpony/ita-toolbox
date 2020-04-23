%% RAVEN simulation: Example for exporting reflection lists and wallhit logs

% Author: las@akustik.rwth-aachen.de
% date:     2020/04/21
%
% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

clear;

%% project settings
myLength=9;
myWidth=6;
myHeight=3;
projectName = [ 'myShoeboxRoom' num2str(myLength) 'x' num2str(myWidth) 'x' num2str(myHeight) ];

%% create project and set input data
rpf = itaRavenProject('C:\ITASoftware\Raven\RavenInput\Classroom\Classroom.rpf');   % modify path if not installed in default directory
rpf.copyProjectToNewRPFFile(['C:\ITASoftware\Raven\RavenInput\' projectName '.rpf' ]);
rpf.setProjectName(projectName);
rpf.setModelToShoebox(myLength,myWidth,myHeight);

% set values of six surfaces:
% 10% absorption and 10% scattering for floor and ceiling
% Identical material with 5% absorption and 20% scattering for walls

for iMat=1:2
    myAbsorp = 0.5 * ones(1,31);
    myScatter = 0.1 * ones(1,31);
    rpf.setMaterial(rpf.getRoomMaterialNames{iMat},myAbsorp,myScatter);
end

for iMat=3:6
    myAbsorp = 0.05 * ones(1,31);
    myScatter = 0.2 * ones(1,31);
    rpf.setMaterial(rpf.getRoomMaterialNames{iMat},myAbsorp,myScatter);
end

rpf.setSourcePositions([7 1.7 -1.5]);

%% set simulation parameters
% Export plane wave lists 
rpf.setExportPlaneWaveList(1); 
% These are the reflections which are inserted to the resulting RIRs.

% Export wall hit logs
rpf.setExportWallHitLog(1);
% Here, all rays are traced. For the image sources, this corresponds to the
% plane wave list, for the ray tracing result, this contains the reflection
% paths of all traced particles, thus this is directly related to the
% particle count in contrast to the plane wave lists, which depend on the
% room geometry

rpf.setSimulationTypeRT(1);
rpf.setSimulationTypeIS(1);
rpf.setNumParticles(2000); % low value just for demonstration
rpf.setISOrder_PS(2);

% this setting deletes all output files from your hard disk after they have been collected by
% the matlab interface
rpf.keepImpulseResponseFiles(0); 
% WARNING: If set to 1, this creates numereous output files/folders and quickly leads to
% a lot of data if you run several simulations. If you want to keep and directly access the output files,
% rpf.keepImpulseResponseFiles(1) - see also  "Other remarks" at the end of
% this file

%% run simulation
rpf.run

%% get results as matlab objects

% wall hit logs
% image sources (IS)
rpf.wallHitLog_IS{1}
% rpf.wallHitLog_IS{1}(IS_ID).materials list wall material intersection
% (empty for the direct sound: rpf.wallHitLog_IS{1}(1))
% rpf.wallHitLog_IS{1}(IS_ID).spectrum contains the energy of the ten octave
% bands from 32 Hz to 16 kHz.

wallHitLogRT=rpf.wallHitLog_RT

% get wall hit logs for different frequency bands 
% returns a matrix of size: detectedParticles x (7+ number of room materials)
wallHitLog16kHz=wallHitLogRT{10}
wallHitLog1kHz=wallHitLogRT{6}

% Structure of 13 (this example contains six room materials) data entries of the ray tracing wall hit logs:
% [TimeStepIndex], [ParticleIndex], [AzimuthSource], [ElevationSource], [AzimuthReceiver], [ElevationReceiver], [EnergyAtDetection], [NumberHitsMaterial0]...[NumberHitsMaterialN]
% TimeStepIndex corresponds to the timeslots (as defined by rpf.timeSlotLength)

% plane wave lists
rpf.planeWaveList_IS{1}
rpf.planeWaveList_RT{1}
numTotalReflectionsOfRIR = length(rpf.planeWaveList_IS{1}.freqData) + length(rpf.planeWaveList_RT{1}.freqData)

% in contrast to the wall hit logs, the plane wave lists contain spectrum
% data in pressure (rpf.planeWaveList_IS{1}.freqData)
% =>
% rpf.wallHitLog_IS{1}(1).spectrum == rpf.planeWaveList_IS{1}.freqData(1,:).^2
% please note that these values are not exactly identical, there are low
% numerical deviations

%% Other remarks
% You can also use rpf.openOutputFolder and navigate to your project's results,
% e.g.,
% 'myShoeboxRoom9x6x3\ImpulseResponses\2020-04-21\10.03.17\PlaneWaveLists\
% 'myShoeboxRoom9x6x3\ImpulseResponses\2020-04-21\10.03.17\WallHitLogs\
% to directly access the results




