 function f = ita_sph_ISHT(F, s)
%ITA_SPH_ISHT - inverse spherical harmonic transform
% function f = ita_sph_ISHT(F, s)
%
% performs an inverse spherical harmonic transform
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


sizeF = size(F);
sizeY = size(s.Y);

% if a row vector was given, take it
if sizeF(1) == 1 && sizeF(2) > 1
    F = F.';
    sizeF = size(F);
end

% reshape F to a maximum of 2 dimentions
nHighDim = sum(sizeF(2:end));
F = reshape(F, [sizeF(1) nHighDim]);

if sizeY(2) > sizeF(1)
    % add zeros to F
    nAdd = sizeY(2) - sizeF(1);
    F = cat(1,F,zeros([nAdd sizeF(2:end)]));    
elseif sizeY(2) < sizeF(1)
    warning(['ita_sph_ISHT: truncating degrees of function, to match grid']);
    F = F(1:sizeY(2));
    sizeF(1) = sizeY(2);
end

f = s.Y * F;
f = reshape(f, [sizeY(1) sizeF(2:end)]);


% 
% nSHg = size(g.Y,2);
% nSHf = size(F,1);
% if nSHg ~= nSHf
%     if nSHg > nSHf
%         nAdd = nSHg - nSHf;
%         F = cat(1,F,zeros([nAdd sizeF(2:end)]));
%     else
%     end
% end
% f = zeros(size(g.Y,1), sizeF(2:end));
% f = bsxfun(@mtimes, g.Y, F);
%     