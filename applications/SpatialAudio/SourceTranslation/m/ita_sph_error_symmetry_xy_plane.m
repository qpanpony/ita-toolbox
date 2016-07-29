function J = ita_sph_error_symmetry_xy_plane(pnm, Ynm, ind1, ind2) 
% ita_sph_error_symmetry_xy_plane.m
% Author: Noam Shabtai
% ITA-RWTH, 5.12.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% J = ita_sph_error_symmetry_xy_plane(pnm) 
% Calculate an error function based on the symmetry
%   with resplect to the xy plane.
% pnm is assumed to be already rotated such that
%   maximum value collides with z axes.
%
% Input Parameters:
%   pmn - Matrix of rotated pnm values for each frequency (Narray+1)^2 x freqs.
%
% Output Parameters;
%   J - 1 x freqs: error function for each frequency.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the nm coeeficients of
% p* for 0<theta<pi/2, -p* for pi/2<theta<pi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = Ynm * pnm;
g = zeros(size(p));
g(ind1,:) = conj(p(ind1,:)); 
g(ind2,:) = -conj(p(ind2,:)); 
gnm = pinv(Ynm) * g;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the symmetry error function
% 1 x freqs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B = sum(pnm.*conj(gnm),1);
A = sum(pnm.*conj(pnm),1);
J = abs(B./A);
