function result = ita_utils_pathsep

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    if isunix
        result = '/';
    elseif ispc
        result = '\';
    end
end