function result = eq(a,b)
% eq, ==

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

result = false;
if isa(b,'itaValue')
    if strcmpi(a.unit,b.unit)
        if (size(a.value) == size(b.value))
            maxAbsError = max(max(abs(a.value - b.value)));
            relerror = maxAbsError ./ max(max(abs(a.value)));
            if relerror < 1e-15 && ~isnan(relerror) && ~isinf(relerror)
                result = true;
            end
        end
    end
end