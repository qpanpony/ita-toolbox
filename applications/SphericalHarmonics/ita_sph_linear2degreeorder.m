function [n, m] = ita_sph_linear2degreeorder(nm)
%ITA_SPH_LINEAR2DEGREEORDER - degree/order index for SH-coefficients
% function [n, m] = ita_sph_linear2degreeorder(nm)
%
% converts the linear 1D-index (nm) of the spherical harmonics
% to the 2D-index (n,m)
%
% See also ita_sph_degreeorder2linear.m
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


if nm < 1
    error('n has to be positive');
end

% make sure it is no integer anymore
nm = double(nm);

n = ceil(sqrt(nm)) - 1;
m = nm - n.^2 - n -1;
