function ita_preferences_load(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if nargin >= 1
    filepath = varargin{1};
else
    [filename, pathname] = uigetfile();
end

filepath = fullfile(pathname, filename);

if ischar(filepath) && exist(filepath,'file')
    prefs = load(filepath);
    ita_preferences(prefs);
    ita_verbose_info('Preferences loaded',1);
else
    ita_verbose_info('ita_preferences_load: File not found',0);
end

