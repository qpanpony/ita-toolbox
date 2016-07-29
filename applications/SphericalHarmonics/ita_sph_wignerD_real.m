function [D, d] = ita_sph_wignerD_real(nmax, alpha, beta, gamma)
%ITA_SPH_WIGNERD_REAL - Wigner-D matrix
% function [D, d] = ita_sph_wignerD_real(nmax, alpha, beta, gamma)
%
% creates the Wigner-D matrix to rotate a spherical function for real bases
% or SH coefficients
%
% see also: ita_sph_wignerD.m

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

[D, d] = ita_sph_wignerD(nmax, alpha, beta, gamma);

T_c2r = ita_sph_complex2real(nmax);
T_r2c = ita_sph_real2complex(nmax);

D = T_c2r * D * T_r2c;

if nargout > 1
    d = T_c2r * d * T_r2c;
end