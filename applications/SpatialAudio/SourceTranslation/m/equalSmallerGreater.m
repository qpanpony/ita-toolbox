function c = equalSmallerGreqter(left, right)
% equalSmallerGreater.m
% Author: Noam Shabtai
% ITA-RWTH, 13.11.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% c = equalSmallerGreqter(left, right)
% Compares two variables and returns their relation in a character.
%
% Input Parameters:
%   left - Left-side variable.
%   right - Right-side variable.
%
% Output Parameters;
%   c - either '=' or '<' or '>'.

if left==right
    c = '=';
elseif left>right
    c = '>';
else
    c = '<';
end
