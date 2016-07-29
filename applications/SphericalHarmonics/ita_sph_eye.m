function matrix = ita_sph_eye(nmax, type)
%ITA_SPH_EYE - identity matrix for SH coefficients
% function matrix = ita_sph_eye(nmax, type)
% 
% creates a "spherical harmonic identity matrix"
%
% applications:
%       'nm-n0' create linear index for zero order
%       'n-nm' calculate angular power spectrum
%       'n-n0' convert linear index to degree index
%
% type = 'nm-nm'
%       [1 0 0 0 0 0 0 0 0 0 ...
%       [0 1 1 1 0 0 0 0 0 0 ...
%       [0 1 1 1 0 0 0 0 0 0 ...
%       [0 1 1 1 0 0 0 0 0 0 ...
%       [0 0 0 0 1 1 1 1 1 0 ...
%       [0 0 0 0 1 1 1 1 1 0 ...
%       [0 0 0 0 1 1 1 1 1 0 ...
%       [0 0 0 0 1 1 1 1 1 0 ...
%       [0 0 0 0 1 1 1 1 1 0 ...
%
% type = 'nm-n0'
%       [1 0 0 0 0 0 0 0 0 0 ...
%       [0 0 1 0 0 0 0 0 0 0 ...
%       [0 0 1 0 0 0 0 0 0 0 ...
%       [0 0 1 0 0 0 0 0 0 0 ...
%       [0 0 0 0 0 0 1 0 0 0 ...
%       [0 0 0 0 0 0 1 0 0 0 ...
%       [0 0 0 0 0 0 1 0 0 0 ...
%       [0 0 0 0 0 0 1 0 0 0 ...
%       [0 0 0 0 0 0 1 0 0 0 ...
%
% type = 'n-nm'
%       [1 0 0 0 0 0 0 0 0 0 ...
%       [0 1 1 1 0 0 0 0 0 0 ...
%       [0 0 0 0 1 1 1 1 1 0 ...
%
% type = 'n-n0'
%       [1 0 0 0 0 0 0 0 0 0 ...
%       [0 0 1 0 0 0 0 0 0 0 ...
%       [0 0 0 0 0 0 1 0 0 0 ...
%
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>



% nmax = sqrt(nr_coefs)-1;
nr_coefs = (nmax+1)^2;

switch type
    case {'nm-nm','nm-n0'}
        matrix = zeros(nr_coefs);
    case {'n-nm', 'n-n0'}
        matrix = zeros(nmax+1, nr_coefs);
    otherwise
        error('give an allowed type');
end

% linear index of zero-order coefficients
i = cumsum(0:2:2*nmax) + 1;

for n = 0:nmax
    % linear index of all orders of degree n
    ind = (i(n+1)-n:i(n+1)+n);
    switch type
        case 'nm-nm'
            matrix(ind, ind) = 1;
        case 'nm-n0'
            matrix(ind, i(n+1)) = 1;
        case 'n-nm'
            matrix(n+1, ind) = 1;
        case 'n-n0'
            matrix(n+1, i(n+1)) = 1; 
    end
end
