function a = minus(a, b)
% normal minus operation

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if isa(b,'itaSuper')
    a = b - a;
else
    a = itaValue(a);
    b = itaValue(b);
    a.value = a.value - b.value;
    if ~strcmpi(a.unit,b.unit)
        disp('Units do not match. Taking first one.')
    end
end

