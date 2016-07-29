function T = ita_chebyshev_polynom(degree)
%ITA_CHEBYSHEV_POLYNOM - Calculate Chebyshev Polynomial Coefficients
%  This function realizes the iterative solution to determine the
%  coefficients of a chebyshev polynom of the specified degree;
%
%  Syntax:
%    coeffs = ita_chebyshev_polynom(degree)
%
%  Example:
%    coeffs = ita_chebyshev_polynom(0:6)
%
%   Output is in ascending polynomial order [1 x x^2 ... x^N]

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  04-Feb-2011

%% Init
N = max(degree) + 1;
T = zeros(N);

%% first two chebychev polynom coeffs, see e.g. http://en.wikipedia.org/wiki/Chebyshev_polynomials with x=1 !
T(1,1) = 1; 
T(2,2) = 1;

%% higher order polynomial coeffs
% for idx = (2:N)+1 % plus 1 shift due to non-zero indexing
%     T(idx,:) = circshift(2*T(idx-1,:),[0 1]) - T(idx-2,:);
% end
% T = T(degree+1,:); %get all requested degrees
% T = T.'; %get the transpose

%% new formulation - pdi - march 2013
for idx = 3:N % plus 1 shift due to non-zero indexing
    T(:,idx) = circshift(2*T(:,idx-1),[1 0]) - T(:,idx-2);
end

%end function
end