function a = rdivide(a,factor)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


if ~isnumeric(factor)
    error('I dont know what to do');
else
    a.cart = a.cart./factor;
    
end

