% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% The ITA Toolbox COMSOL interface
% This interface allows to do modifications to COMSOL models and execute
% certain commands. It is based on COMSOL LiveLink for Matlab.
% It is important to mention, that the basis of the model should be
% developed in in COMSOL itself (using the GUI or LiveLink).


%% Demos
% Below you can find a list of demo scripts for the COMSOL interface.
% Open the scripts listed here to learn more!


%% Connecting to COMSOL Server and loading a model
ita_comsol_demo_init();


%% Running a simulation
ita_comsol_demo_simulation();


%% Visualize model in Matlab
ita_comsol_demo_visualizer();


%% Create sources
ita_comsol_demo_sources();


%% Adjust boundary conditions
ita_comsol_demo_boundary_conditions();


%% Create a binaural receiver
ita_comsol_demo_binaural_receiver();


%% Remove model from server and disconnect
ita_comsol_demo_close();