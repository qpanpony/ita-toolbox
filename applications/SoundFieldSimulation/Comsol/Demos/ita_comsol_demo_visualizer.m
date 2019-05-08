% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Before you start
% Take a look at and run the following function
itaComsolModelObj = ita_comsol_demo_init();


%% ---Init---
visualizer = itaComsolModelVisualizer(itaComsolModelObj);
visualizer.Plot();
view(35,30);



%% ---Edges---
%% Edge color
visualizer.edgeColor = [1 0 0];

%% Hide edges
visualizer.showEdges = false;

%% Reset edges
visualizer.showEdges = true;
visualizer.edgeColor = [0 0 0];



%% ---Boundary Groups---
%% Transparency
visualizer.transparency = 0.8;

%% Hide individual boundary groups
%List boundary group names
disp(visualizer.boundaryGroupNames) %walls ceiling floor

%Hide boundaries belonging to group "walls"
visualizer.boundaryGroupVisibility(1) = false;

%% Hide all boundaries
visualizer.showBoundarySurfaces = false;

%% Reset edges
visualizer.showBoundarySurfaces = true;
visualizer.boundaryGroupVisibility = [1 1 1];
visualizer.transparency = 0.3;


%% ---Mesh---
%% Show mesh
visualizer.showMesh = true;

%% Mesh color
visualizer.meshColor = [0 1 0];


%% Plot in specified axes
f = figure;
ax = axes(f);
visualizer.Plot(ax);

