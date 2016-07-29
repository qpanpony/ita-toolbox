function a = rdivide(a, b)
% Divide

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if isa(b,'itaSuper')
    a = ita_amplify(1/b,a);
else
    a = itaValue(a); 
    b = itaValue(b);
    a.value = a.value ./ b.value;
    a.unit = ita_deal_units(a.unit,b.unit,'/');
end
end
