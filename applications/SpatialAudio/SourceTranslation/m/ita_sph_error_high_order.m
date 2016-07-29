function J = ita_sph_error_high_order(cnm, Narray, Nfirst, weights) 
% ita_sph_error_high_order.m
% Author: Noam Shabtai
% ITA-RWTH, 11.11.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% error_func = ita_sph_error_high_order(cnm, Narray, Nfirst) 
% Calculate the error functions indicated in Ben Hagai, Pollow, Vorlaender and Rafaely
% JASA 2003 paper.
%
% Input Parameters:
%   cmn - matrix of cmn values for each frequency (Na+1)^2 x freqs.
%   Narrayc - order of the array or the interpolated function from the translated sampling.
%   Nfirst - Order of first harmonics for J2.
%   weights - vector of size (Narray+1)^2 x 1 with weights for J2 and J3.
%
% Output Parameters;
%   J - 4 x freqs: error functions J0, J1, J2, J3 for each frequency.

cnm = cnm(1:(Narray+1)^2,:);
abs_cnm = abs(cnm);
eng_cnm = abs_cnm.^2;
eng_cnm_first = eng_cnm(1:(Nfirst+1)^2,:);
L2 = sum(eng_cnm,1);
sigma = sum(eng_cnm_first,1);
L1 = sum(abs_cnm,1);
n = repmat(weights,1,size(cnm,2));

J0 = 1 - eng_cnm(1,:)./L2;
J1 = 1 - sigma./L2;
J2 = sum(n.*eng_cnm,1)./L2;
J3 = sum(n.*abs_cnm,1)./L1;
     

J = [J0; J1; J2; J3];
