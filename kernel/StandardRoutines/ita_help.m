function ita_help(varargin)
%ITA_HELP - Show help

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009 

%% Get ITA Toolbox preferences and Function String
helppath = [ita_toolbox_path filesep 'HTML' filesep 'doc'];
if ~exist(helppath,'dir')
    helpdlg('No help found. Run "Help" => "Generate Documentation"');
else
    web index.html -helpbrowser
end

end