function SH = ita_sph_swap_SH_convention(SH)
%ITA_SPH_SWAP_SH_CONVENTION - creates spherical harmonics (SH) base functions
% function SH = ita_sph_swap_SH_convention(SH)
%   converts a SH coef vector from one base function convention (Williams:
%   "Fourier Acoustics", p.190) to another convention (Gumerov/Duraiswami:
%   e.g. "Recursions for the computation of multipole translation and ..., p.1346)
%
%   This conversion is bidirectional.
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 29.7.2011

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
if size(SH,1) == 1 && size(SH,2) > 1
    % make a column vector
    SH = SH(:);
end

[n,m] = ita_sph_linear2degreeorder(1:size(SH,1)); %#ok<ASGLU>
% negate for pos. degrees that are even
negateCoef = m>0 & mod(m,2);
SH(negateCoef,:) = -SH(negateCoef,:);
