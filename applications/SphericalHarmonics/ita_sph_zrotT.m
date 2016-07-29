function T = ita_sph_zrotT(a,n_max)
%ITA_SPH_ZROTT - Transformation matrix for azimuth rotation around axis z 
% function T = ita_sph_zrotT(a,n_max)
% a: Rotation angle in radian.
% n_max: Maximum SH order.
% 
% Creates the transformation Matrix for a azimuth rotation around the z
% axis. 
% 
% application: f_rotated(n,m) = T * f(n,m)
% f(n,m) being an SH/Multipole vector.
%
% Algorythm from "Analysis and Synthesis of Sound-Radiaton with Spherical
% Arrays", Zotter, 2009 and "Recursions for the Computation of Multipole
% Translatiuon and Rotation Coefficients for the 3-D Helmholtz Equation",
% Gumerov and Duraiswami , 2003
%
% Johannes Klein (johannes.klein@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 19.11.2011

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% 1 Compute azimuth Legendre base solution for given angle.
phi_1 = exp(-1i*a);

% 2 Generate degree vector
m_vec = ita_sph_matrix2vector(repmat([(-n_max:+1:0) (1:n_max)],n_max+1,1));

% 3 Apply addition theorem to base solution and assemble T
T = diag(bsxfun(@power,phi_1,m_vec));

end