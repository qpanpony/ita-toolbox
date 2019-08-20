% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Before you start
% Take a look at and run the following function
itaComsolModelObj = ita_comsol_demo_init();


%% Create a monopole source in COMSOL
monopole = itaSource;
monopole.name = 'pointSource';
monopole.type = SourceType.PointSource;
monopole.sensitivityType = SensitivityType.Flat; %Flat source spectrum
monopole.position = itaCoordinates([-1 -1 1]);

comsolMonopole = itaComsolSource.Create(itaComsolModelObj, monopole);

%% Create a piston in COMSOL
%Note: A Piston has to be placed on a wall
piston = itaSource;
piston.name = 'pistonSource';
piston.type = SourceType.Piston;
piston.sensitivityType = SensitivityType.UserDefined; %Arbitry source spectrum
piston.velocityTf = itaResult([0 1 1 0].', [0 100 16000 20000], 'freq');
piston.pistonRadius = 0.3;
piston.position = itaCoordinates([-2 -1 1]);
piston.orientation = itaOrientation.FromViewUp([1 0 0], [0 0 1]);

comsolPiston = itaComsolSource.Create(itaComsolModelObj, piston);

%% Disable a itaComsolSource
%Note, that you have to rebuild the geometry in COMSOL UI to see the
%changes. Nevertheless, the changes would apply when starting a simulation.
comsolPiston.Disable();