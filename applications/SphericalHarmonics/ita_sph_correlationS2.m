function correlation = ita_sph_correlationS2(F, G)
%ITA_SPH_CORRELATIONS2 - spatial correlation in SH-domain
% function correlation = ita_sph_correlationS2(F, G)
% 
% computes the normalized spatial correlation of two functions
% on the 2-sphere in the spherical harmonic domain
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 05.11.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

ita_verbose_obsolete('Please use ita_sph_xcorr in future.')

if ~exist('G', 'var')
    G = F;
end
    
if size(F,1) ~= size(G,1)
    error('coefficient vectors must have the same size');
end

correlation = zeros(size(F,1),1);
for iFreq = 1:size(F,1)
    correlation(iFreq) = conj(F(iFreq,:))*G(iFreq,:).'/(norm(F(iFreq,:))*norm(G(iFreq,:)));
end