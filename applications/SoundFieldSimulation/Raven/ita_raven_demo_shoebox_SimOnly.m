%% RAVEN simulation: Example for creating shoebox room model

% Author: las@akustik.rwth-aachen.de
% date:     2020/06/16
%
% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% project settings
ravenBasePath='C:\ITASoftware\Raven\';
myLength=10;
myWidth=8;
myHeight=3;
projectName = [ 'myShoeboxRoom' num2str(myLength) 'x' num2str(myWidth) 'x' num2str(myHeight) ];

%% create project and set input data
rpf = itaRavenProject([ ravenBasePath 'RavenInput\Classroom\Classroom.rpf']);   % modify path if not installed in default directory
rpf.copyProjectToNewRPFFile([ ravenBasePath '\RavenInput\' projectName '.rpf' ]);
rpf.setProjectName(projectName);
rpf.setModelToShoebox(myLength,myWidth,myHeight);

% set values of six surfaces:
% 15% absorption and 20% scattering to all room surfaces
for iMat=1:6
    myAbsorp = 0.15 * ones(1,31);
    myScatter = 0.2 * ones(1,31);
    rpf.setMaterial(rpf.getRoomMaterialNames{iMat},myAbsorp,myScatter);
end



%% set sound source and receiver (including HRTF)
rpf.setSourcePositions([9.0000    1.7000   -2.5000]);
rpf.setSourceViewVectors([ -1     0     0]);
rpf.setSourceUpVectors([ 0     1    0]);
rpf.setSourceDirectivity('');

rpf.setSourcePositions([9.0000    1.7000   -2.5000]);
rpf.setSourceViewVectors([ -1     0     0]);
rpf.setSourceUpVectors([ 0     1    0]);

rpf.setReceiverPositions([4.4500    1.0000   -3.9000]);
rpf.setReceiverUpVectors([0 1 0]);
rpf.setReceiverViewVectors([1 0 0]);
rpf.setReceiverHRTF([ ravenBasePath 'RavenDatabase\HRTF\ITA-Kunstkopf_HRIR_AP11_Pressure_Equalized_3x3_256.daff']);

%% set simulation parameters
rpf.setGenerateRIR(1);
rpf.setGenerateBRIR(1);
rpf.setSimulationTypeRT(1);
rpf.setSimulationTypeIS(1);
rpf.setNumParticles(20000);
rpf.setISOrder_PS(2);
rpf.setFilterLength(1900);

%% run simulation
rpf.run

%% get results
monoRIR = rpf.getImpulseResponseItaAudio;
binaural = rpf.getBinauralImpulseResponseItaAudio;



