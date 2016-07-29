function a = mtimes(a, b)
%% times

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if size(a,2) ~= 1 %pdi: was 1 before
    %get units
    for idx = 1:size(a,1)
        unitsA(idx) = itaValue(1,a(idx,1).unit);
    end
    for idx = 1:size(b,2)
        unitsB(idx) = itaValue(1,b(1,idx).unit);
    end
    % get values
    for idx = 1:size(a,1)
        for jdx = 1:size(a,2)
            valuesA(idx,jdx) = a(idx,jdx).value;
        end
    end
        for idx = 1:size(b,1)
        for jdx = 1:size(b,2)
            valuesB(idx,jdx) = b(idx,jdx).value;
        end
    end
    % value mtimes
    valuesRes = valuesA * valuesB;
    
    for idx = 1:size(a,1)
        for jdx = 1:size(b,2)
            aux = unitsA(idx) * unitsB(jdx);
            a(idx,jdx).unit  = aux.unit;
            a(idx,jdx).value = valuesRes(idx,jdx);
        end
    end
    
else
    a = times(a,b);
end
end