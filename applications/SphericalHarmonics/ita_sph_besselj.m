function j = ita_sph_besselj(n, x)
%ITA_SPH_BESSELJ - spherical Bessel function
% function j = ita_sph_besselj(n, x)
%
% calculates spherical Bessel function j
% (usage analogous to besselj.m)
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


if any(size(n) ~= size(x)) ...
        % not the same size
    ita_verbose_info('ita_sph_besselj expands your data');
    for ind = 1:ndims(n)
        if (size(n,ind) == 1) && (size(x,ind) > 1)
            mask = ones(ndims(n),1);
            mask(ind) = size(x,ind);
            n = repmat(n,mask(:).');
        end
        if (size(x,ind) == 1) && (size(n,ind) > 1)
            mask = ones(ndims(x),1);
            mask(ind) = size(n,ind);
            x = repmat(x,mask(:).');
        end
    end
end

j = sqrt(0.5 * pi ./ x) .* besselj(n + 0.5, x);
j(~x & ~n) = 1;
j(~x & n)  = 0;