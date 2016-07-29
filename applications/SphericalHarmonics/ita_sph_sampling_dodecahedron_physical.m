function s = ita_sph_sampling_dodecahedron_physical
%ITA_SPH_SAMPLING_DODECAHEDRON_PHYSICAL - angles of a dodecahedron as wired

% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany, 2008
% 21.11.13

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
s = ita_sph_sampling_dodecahedron;
s.sph = s.sph([2 1 3 8 5 11 7 4 10 9 6 12],:);
