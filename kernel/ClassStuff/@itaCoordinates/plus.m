function result = plus(a,b)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Minus for 1-point - n-points
if a.nPoints == 1 && b.nPoints > 1
    a.cart = repmat(a.cart,b.nPoints,1);
elseif a.nPoints > 1 && b.nPoints == 1
    b.cart = repmat(b.cart,a.nPoints,1);
end
result = a;
result.cart = a.cart + b.cart;
end
