function pnm = ita_sph_point_source(s, k, sourcePos)
%ITA_SPH_POINT_SOURCE - calculates coefficients for point sources
% function pnm = ita_sph_point_source(s, f)
%
%   s: itaSamplingSph (needs to have Y defined)
%   k: wave number(s)
%   sourcePos: sourcePosition(s)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
if ~isa(sourcePos,'itaCoordinates')
    sz = size(sourcePos);
    if ~sz(2) == 3
        if sz(1) == 3
            sourcePos = sourcePos.';
        else
            error('wrong dimensions for source positions');
        end
        
    end
    sourcePos = itaCoordinates(sourcePos);
end

nSources    = sourcePos.nPoints;
nCoeffs     = (s.nmax+1)^2;
nFreq       = numel(k);

arrayR = unique(s.r);
if numel(arrayR) > 1
    ita_verbose_info('this only makes sense for a single radius, will chose the mean',0);
    arrayR = mean(arrayR);
end

sourceR = sourcePos.r;
% coefficients for the direction to the source (base functions)
baseFactor = conj(ita_sph_base(sourcePos,s.nmax));

n = ita_sph_linear2degreeorder(1:nCoeffs);
% bessel and hankel terms
pnm = zeros(nFreq,nCoeffs,nSources);
% depends on interior or exterior type
for iSource = 1:nSources
    if arrayR > sourceR(iSource) % interior problem
        besselFactor = ita_sph_besselj(n,k(:).*sourceR(iSource));
        hankelFactor = ita_sph_besselh(n,2,k(:).*arrayR);
    elseif arrayR < sourceR(iSource) % exterior problem
        besselFactor = ita_sph_besselj(n,k(:).*arrayR);
        hankelFactor = ita_sph_besselh(n,2,k(:).*sourceR(iSource));
    end
    pnm(:,:,iSource) = bsxfun(@times,-1i.*k(:),baseFactor(iSource,:)).*besselFactor.*hankelFactor;
end
pnm = squeeze(pnm);