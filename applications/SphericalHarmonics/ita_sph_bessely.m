function y = ita_sph_bessely(n, x)
%ITA_SPH_BESSELY - spherical Bessel function (2nd kind)
% function y = ita_sph_bessely(n, x)
%
% calculates spherical Bessel function y
% (usage analogous to bessely.m)
%
% the definition was taken from:
% E. G. Williams, "Fourier Acoustics",
% Academic Press, San Diego, 1999. p.194
%
% MMT (mmt@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if any(size(n) ~= size(x)) ...
        % not the same size
    ita_verbose_info('ita_sph_bessely expands your data');
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

y = sqrt(0.5 * pi ./ x) .* bessely(n + 0.5, x);
y(~x & ~n) = 1;
y(~x & n)  = 0;