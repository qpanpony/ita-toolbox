function h = ita_sph_besselh(n, k, x)
%ITA_SPH_BESSELH - spherical Hankel function
% function h = ita_sph_besselh(n, k, x)
%
% calculates spherical Hankel function h (k'th kind)
% (usage analogous to besselh.m)
%
% the definition was taken from:
% E. G. Williams, "Fourier Acoustics", 
% Academic Press, San Diego, 1999. p.194
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


if nargin < 3
    x = k;
    k = 1;
    disp(['using Hankel function of type ' num2str(k)]);
end

if any(size(n) ~= size(x)) ...
    % not the same size    
%     ita_verbose_info('ita_sph_besselh expands your data',2);
    for ind = 1:ndims(n)
        if (size(n,ind) == 1) && (size(x,ind) > 1)
            mask = ones(ndims(n),1);
            mask(ind) = size(x,ind);
            n = repmat(n,mask(:).');
        elseif (size(x,ind) == 1) && (size(n,ind) > 1)
            mask = ones(ndims(x),1);
            mask(ind) = size(n,ind);
            x = repmat(x,mask(:).');
        end            
    end
end

warning off all
hankelTerm = besselh(n + 0.5, k, x);
hankelTerm(isnan(hankelTerm)) = 0;
warning on all

h = bsxfun(@times, sqrt(0.5 * pi ./ x), hankelTerm);
h(isnan(h)) = 0;