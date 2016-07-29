function params = loadCfgFile(params, cfg_file)
% loadCfgFile.m
% Author: Noam Shabtai
% ITA-RWTH, 15.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% loadCfgFile(cfg_file)
% Load configuration parameters.
% To be used between configuration and initialization
%   of the simulation parameters.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   cfg_file - config file name.
%
% Output Parameters:
%   params - input parameters of main simulation.

dot_ind = strfind(cfg_file,'.m');
command = cfg_file(1:dot_ind-1);
params.display.p_samp.show = 0;         % Display sampled radiation pattern of the source.
run(command);
