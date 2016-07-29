function result = isnatural(a)
%returns true of the number in a is natural, false if not.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

try
    if a == round(double(a))
        result = true;
    else
        result = false;
    end
catch %#ok<CTCH>
    result = false;
end
end