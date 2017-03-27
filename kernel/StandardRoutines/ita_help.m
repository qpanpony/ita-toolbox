function ita_help(varargin)
%ITA_HELP - Show help

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009 

%% Get ITA Toolbox preferences and Function String
helppath = fullfile(ita_toolbox_path, 'HTML', 'doc');
if ~exist(helppath,'dir')
    ita_verbose_info('No help found. Please run ita_generate_documentation to generate it.',0);
else
    web(fullfile(helppath, 'index.html'),'-helpbrowser')
end


end