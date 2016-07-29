function pnm = ita_sph_plane_wave(s, k, sourcePos)
%ITA_SPH_PLANE_WAVE - calculates coefficients for plane waves
% function pnm = ita_sph_plane_wave(s, f)
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
sourcePos.r = arrayR;
baseIds = findnearest(s,sourcePos,'sph');

% coefficients for the direction to the source
baseFactor = conj(s.Y(baseIds,:));

n = ita_sph_linear2degreeorder(1:nCoeffs);
% bessel and hankel terms
pnm = zeros(nFreq,nCoeffs,nSources);

for iSource = 1:nSources
    besselFactor = ita_sph_besselj(n,k(:).*arrayR);
    pnm(:,:,iSource) = 4*pi.*bsxfun(@times,exp(-1i.*k(:).*sourceR),(1i.^n).*baseFactor(iSource,:)).*besselFactor;
end
pnm = squeeze(pnm);