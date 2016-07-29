function result = ita_sph_besseldiff(handle, n, k, x)
%ITA_SPH_BESSELDIFF - derivative of a spherical radial functions
% function erg = ita_sph_besseldiff(handle, n, k, x)
%
% calculates the derivative of the spherical Bessel, Hankel or Neumann
% function given in handle (e.g. handle = @sph_besselj)
%
% the definition was taken from:
% E. G. Williams, "Fourier Acoustics",
% Academic Press, San Diego, 1999. p.197
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% the next if statement needs the sizes of x and y. this is of importance
% for the spherical bessely and besselj as they dont need k as an input
% parameter and may yield worng results as the argument gets lost in
% varargin
if nargin < 4
    x = k; % marco: moved this up from line 49
end

if any(size(n) ~= size(x))
        % not the same size
    ita_verbose_info('ita_sph_besseldiff expands your data');
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

if nargin == 4
    result = handle(n-1,k,x) - bsxfun(@rdivide, (n+1), x) .* handle(n,k,x);
else
%     x = k;
    result = handle(n-1,x) - bsxfun(@rdivide, (n+1), x) .* handle(n,x);
    %     result = handle(n-1,x) - (n+1)./x .* handle(n,x);
end
