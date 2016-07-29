function ita_preferences_save(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if nargin >= 1
   filepath = varargin{1}; 
else
   [filename, pathname] = uiputfile();
end

filepath = fullfile(pathname, filename);

if ischar(filepath)
    prefs = ita_preferences;
    save(filepath, '-struct', 'prefs');

end

ita_verbose_info('Preferences saved',1);