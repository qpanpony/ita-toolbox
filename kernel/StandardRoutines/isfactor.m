function result = isfactor(a, b)
%isfactor - Check if a is a factor of b
% Returns 1 if a or b are factors of each other, 0 if not.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich
result = false; %init
if b >= a
    if (round(a) == a) && (round(b) == b)
        if round (b/a) == b/a
            result = 1;
        end
    else
        disp(['ISFACTOR:Oh Lord. This only works with integer numbers! ' num2str(a) 'and' num2str(b)])
    end
end