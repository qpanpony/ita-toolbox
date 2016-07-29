function coeff = ita_legendre_polynom(n)
% calculate legendre polynom coefficients

% Author: Pascal Dietrich 2012 - pdi@akustik.rwth-aachen.de

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% coefficents
kmax = floor(n/2); 

coeff = zeros(kmax+1,1);
idxlist = 0:kmax;
for k = idxlist
    idx         = n-2*k+1;
    coeff(idx)  = (-1)^k * factorial(2 * n - 2 * k ) / factorial(n - k) / factorial(n-2*k) / factorial(k) / 2^n;
end
coeff = fliplr(coeff(:).');

end