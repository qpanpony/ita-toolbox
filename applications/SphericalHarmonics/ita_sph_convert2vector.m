function sph = ita_sph_convert2vector(sph)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

sph.theta = sph.theta(:);
sph.phi = sph.phi(:);
if isfield(sph,'r')
    sph.r = sph.r(:);
end
sph.weights = sph.weights(:);
