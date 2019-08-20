% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Before you start
% Take a look at and run the following function
itaComsolModelObj = ita_comsol_demo_init();


%% --- Apply impedances to boundaries ---
%When applying boundary conditions using this interface, COMSOL selections
%have to be defined in COMSOL beforehand. Make sure to label them properly!
%In the demo model, there are three selections: walls, ceiling and floor.

%% Read boundary group names (labels of 2D selections)
%'user' refers to  a selection filter. See documentation of
%itaComsolSelection -> filter for more information
boundaryGroupNames = itaComsolModelObj.selection.BoundaryGroupNames('user');
disp(boundaryGroupNames)
ceilingLabel = boundaryGroupNames{2};
floorLabel = boundaryGroupNames{3};

%% Create impedance using itaMaterial
matCeiling = itaMaterial();
matCeiling.impedance = itaResult([1+2i; 2+4i; 3+6i],[20; 100; 1000], 'freq');
comsolImpedanceCeiling = itaComsolImpedance.Create(itaComsolModelObj, ceilingLabel, matCeiling);

%% Create impedance using itaResult
impedanceFloor = itaResult([1+1i; 1+1i; 1+1i],[20; 100; 1000], 'freq');
comsolImpedanceFloor = itaComsolImpedance.Create(itaComsolModelObj, floorLabel, impedanceFloor);

%% Disable impedance
comsolImpedanceFloor.Disable();