%% RAVEN simulation: Example for creating shoebox room model

% Author: las@akustik.rwth-aachen.de
% date:     2019/04/10
%
% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% project settings
myLength=10;
myWidth=8;
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
    myAbsorp = 0.1 * ones(1,31);
    myScatter = 0.1 * ones(1,31);
    rpf.setMaterial(rpf.getRoomMaterialNames{iMat},myAbsorp,myScatter);
end


for iMat=3:6
    myAbsorp = 0.05 * ones(1,31);
    myScatter = 0.2 * ones(1,31);
    rpf.setMaterial(rpf.getRoomMaterialNames{iMat},myAbsorp,myScatter);
end

% uncomment to see plot of room and absorption coefficient
% rpf.plotMaterialsAbsorption;
% rpf.plotModel;

%% set simulation parameters
rpf.setGenerateRIR(1);
rpf.setGenerateBRIR(1);
rpf.setSimulationTypeRT(1);
rpf.setSimulationTypeIS(1);
rpf.setNumParticles(20000);
rpf.setISOrder_PS(2);

%% run simulation
rpf.run

% RIR = rpf.getMonauralImpulseResponseItaAudio;
% RIR.ptd;
T30_firstRoom = rpf.getT30;

% Now change the room, double all dimensions
rpf.setModelToShoebox(myLength*2,myWidth*2,myHeight*2);
rpf.run;
T30_secondRoom = rpf.getT30;

%% plot results
figure;
semilogx(rpf.freqVectorOct,[T30_firstRoom T30_secondRoom]','LineWidth',1.5,'Marker','x');
grid on;ylabel('T30 in s');xlabel('Frequency in Hz');title('T30 of two shoebox rooms');xlim([20 20000]);
legend(['Room 1 (V= ' num2str(myLength*myWidth*myHeight) ' m³)'],['Room 2 (V= ' num2str(2*myLength*2*myWidth*2*myHeight) ' m³)']);



