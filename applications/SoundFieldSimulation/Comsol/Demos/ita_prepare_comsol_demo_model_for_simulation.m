function ita_prepare_comsol_demo_model_for_simulation(itaComsolModelObj)
% ita_prepare_comsol_demo_model_for_simulation This function is a helper
% function of the COMSOL interface demo.
%   See ita_comsol_demo

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


monopole = itaSource;
monopole.name = 'pointSource';
monopole.type = SourceType.PointSource;
monopole.sensitivityType = SensitivityType.Flat; %Flat source spectrum
monopole.position = itaCoordinates([-1 -1 1]);

itaComsolSource.Create(itaComsolModelObj, monopole);