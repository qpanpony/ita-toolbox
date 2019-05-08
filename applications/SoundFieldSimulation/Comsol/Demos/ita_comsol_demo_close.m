% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Before you start
% Take a look at and run the following function
itaComsolModelObj = ita_comsol_demo_init();



%% --- COMSOL - Clean up ---
%% Remove model from server to free memory
itaComsolServer.Instance().RemoveModel(itaComsolModelObj.modelNode)

%% Disconnect from server
itaComsolServer.Instance().Disconnect();


