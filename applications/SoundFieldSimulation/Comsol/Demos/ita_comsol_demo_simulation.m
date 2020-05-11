% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Before you start
% Take a look at and run the following function
itaComsolModelObj = ita_comsol_demo_init();

%% Init model for simulation
ita_prepare_comsol_demo_model_for_simulation(itaComsolModelObj);



%% --- Simulation from Matlab ---
%% Set frequencies to be solved
itaComsolModelObj.study.SetFrequencyVector([100 200])

%% Run simulation
showProgress = true;
itaComsolModelObj.study.Run(showProgress);



%% --- Results in COMSOL ---
% In the Comsol GUI, take a look under Results -> 3D Plots


%% --- Read results ---
%% at mesh nodes
%IMPORTANT NOTE:
%Evaluating at mesh nodes only works if using FEM (acpr). It does not work
%if using BEM (pabe).
resultAtMeshNodes = itaComsolModelObj.result.Pressure();

%% at user defined points within mesh
[x,y,z] = meshgrid(-1:1, -1:1, -1:1);
coords = itaCoordinates([x(:) y(:) z(:)]);
resultAtUserDefinedCoords = itaComsolModelObj.result.Pressure(coords);