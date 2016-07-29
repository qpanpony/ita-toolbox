function [slash, home] = setSlash
% setSlash.m
% Author: Noam Shabtai
% ITA-RWTH, 15.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% [slash, home] = setSlash
% Define the slash sign according to the operating system.
%
% Input Parameters:
%   None.
%
% Output Parameters;
%   slash - A string indicating the slash sign, either '/' or '\'.
%   home  - A string indicating the home directory.

if isunix
    slash = '/';

    if nargout>1
        home = '~';
    end
else
    slash = '\';

    if nargout>1
        home = '%HOMEPATH%';
    end
end
