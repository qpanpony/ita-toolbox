% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Before you start
% Take a look at and run the following function
itaComsolModelObj = ita_comsol_demo_init();

%% Init model
ita_prepare_comsol_demo_model_for_simulation(itaComsolModelObj);



%% --- IMPORTANT NOTE ---
% When using a binaural receiver you have consider the following:
% 1)    Make sure that your physics does not consider the interior of the
%       receiver geometry. Therefore in the COMSOL GUI, click on the
%       physics node and manually select the domain (instead of all domains).
% 
% 2)    If the geometry has a much finer structure than the rest of the
%       model (e.g. pinna), the mesher might through an error. You have to
%       make sure that the mesh can be fine enough. Thus, you should allow
%       a very small "Minimum element size".
%       There is no guaranty that a binaural receiver with arbitrary
%       geometries will function. It has only been tested for the ITA
%       Kunstkopf geometry.



%% --- Importing CAD data for binaural receivers ---
%% Create ITA Dummyhead
% NOTE:
% The following process requires access to a geometry file of the ITA
% Kunstkopf which is not publicly available. If you dont have access to
% this file, use the next option.

receiver = itaReceiver();
receiver.name = 'ITA_Dummyhead';
receiver.type = ReceiverType.ITADummyHead;
receiver.position = itaCoordinates([0 0 0]);
receiver.orientation = itaOrientation.FromViewUp([-1 -1 0], [0 0 1]);

comsolReceiver = itaComsolReceiver.Create(itaComsolModelObj, receiver);

%% Create user-defined binaural receiver
% NOTE:
% This is just an example. You need to provide a geometry file that can be
% imported in Comsol. The model should be centered at [0 0 0] and oriented
% in a way that the view vector shows in positive x-direction and up vector
% shows in positive z-direction. Additionally, you need to specify the
% relative position of the left and right ear canal (local coordinates).

receiver = itaReceiver();
receiver.name = 'Dummyhead';
receiver.type = ReceiverType.UserDefined;
receiver.position = itaCoordinates([0 0 0]);
receiver.orientation = itaOrientation.FromViewUp([-1 -1 0], [0 0 1]);

% Insert your personal data here!
receiver.geometryFilename = 'myfile.myext';
receiver.relativeLeftEarMicPosition = itaCoordinates([0 0.075 0]);
receiver.relativeRightEarMicPosition = itaCoordinates([0 -0.075 0]);

comsolReceiver = itaComsolReceiver.Create(itaComsolModelObj, receiver);



%% Disable receiver
%Note, that you have to rebuild the geometry in COMSOL UI to see the
%changes. Nevertheless, the changes would apply when starting a simulation.
comsolReceiver.Disable();

%% Enable receiver
comsolReceiver.Enable();


%% --- Run simulation ---
showProgress = true;
itaComsolModelObj.study.Run(showProgress);


%% --- Read binaural results ---
binauralResult = itaComsolModelObj.result.Pressure(receiver);

