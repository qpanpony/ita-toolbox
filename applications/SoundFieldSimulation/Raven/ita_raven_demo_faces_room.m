%% RAVEN simulation: Example for creating a room model specifying points 
% and planes 

% Author: eac@akustik.rwth-aachen.de
% date:     2020/01/07
%
% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% project settings
projectName = 'my_Fan_shape';

h1=10; h2 = 4;
w1=14; w2 =24;
l = 30;

% Example shape: Fan shape
points=[-w1/2 0 h1-h2; w1/2 0 h1-h2; w2/2 l 0; -w2/2 l 0; -w2/2 l h1; ...
    w2/2 l h1; w1/2 0 h1; -w1/2 0 h1];
faces={[5 4 3 2 1];[1 8 7 6 5];[2 1 2 7 8];[3 3 4 5 6];[4 2 3 6 7]; ...
    [6 1 8 5 4]};

for i=1:length(faces)
    faces{i}(2:end)=fliplr(faces{i}(2:end));
end
materials={'ceiling';'backwall';'frontwall';'sidewall1';'floor';'sidewall2';};

nM=length(materials);
%% Create project and set input data
rpf = itaRavenProject('C:\ITASoftware\Raven\RavenInput\Classroom\Classroom.rpf');   % modify path if not installed in default directory
rpf.copyProjectToNewRPFFile(['C:\ITASoftware\Raven\RavenInput\' projectName '.rpf' ]);
rpf.setProjectName(projectName);
rpf.setModelToFaces(points,faces,materials)

% source and receiver
hs=1.2; %source height
hr=1.2; %receiver height
rpf.setSourcePositions([0.1*w2      3     (h1-h2)-(h1-h2)/l*(3) + hs])
rpf.setReceiverPositions([0.1*w1    l-5       (h1-h2)-(h1-h2)/l*(l-5)   + hr])

% Coefficients
for iMat=1:nM
    myAbsorp = 0.1 * ones(1,31);
    myScatter = 0.1 * ones(1,31);
    rpf.setMaterial(rpf.getRoomMaterialNames{iMat},myAbsorp,myScatter);
end

%% Check: Plane normals should point to the inner side of the room
rpf.model.plotModel([], [1 2 3], 0,1)
axis equal
%% set simulation parameters
rpf.setGenerateRIR(1);
rpf.setGenerateBRIR(1);
rpf.setSimulationTypeRT(1);
rpf.setSimulationTypeIS(1);
rpf.setNumParticles(50000);
rpf.setISOrder_PS(2);
%% run simulation
rpf.run


%% plot results

rpf.plotSphereEnergy();
RIR = rpf.getImpulseResponseItaAudio;
RIR.ptd;
T30 = rpf.getT30;
%%
figure;
semilogx(rpf.freqVectorOct,T30','LineWidth',1.5,'Marker','x');
grid on;ylabel('T30 in s');xlabel('Frequency in Hz');
title('T30 of a Fan shape room');xlim([20 20000]);

