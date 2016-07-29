function nm = ita_sph_degreeorder2linear(n,m)
%ITA_SPH_DEGREEORDER2LINEAR - linear index for SH-coefficients
% function nm = ita_sph_degreeorder2linear(n,m)
%
% converts the 2D-index (n,m) of the spherical harmonics
% to the linear 1D-index (nm)
%
% See also ita_sph_linear2degreeorder.m
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% if wrong input
if n < 0
    nm = 0;
    return;
end

% if only n is given, set lm to number of coefficients
if nargin < 2
    m = n;
end

if abs(m) > n
    nm = 0;
    ita_verbose_info('order m has to be between -l and l (degree l)',0);
    return;
end

nm = n.^2 + n + m + 1;
