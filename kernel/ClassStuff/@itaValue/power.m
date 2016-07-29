function a = power(a,n)
%Power function a^x

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if isa(n,'itaValue')
    n = n.value;
end
if ~isa(a,'itaValue')
    a = itaValue(a);
end
if n < 0
    a = 1 / a;
    n = abs(n);
end
a.value = a.value.^n;
a.unit = ita_deal_units(a.unit,['^' num2str(n)]);
%a.unit = ita_deal_units(a.unit,'^n'); % TODO %
end