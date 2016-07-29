function a = times(a, b)
% normal times e.g. c = a*b;

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if isa(b,'itaSuper')
    a = ita_amplify(b,a);
else
    a = itaValue(a);
    b = itaValue(b);
    a.value = double(a) .* double(b);
    for idx = 1:size(a,1)
        for jdx = 1:size(a,2)
            a(idx,jdx).unit = ita_deal_units(a(idx,jdx).unit,b(idx,jdx).unit,'*');
        end
    end
end
end