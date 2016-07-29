function J = ita_sph_error_directivity(pnm) 
% ita_sph_error_directivity.m
% Author: Noam Shabtai
% ITA-RWTH, 19.11.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% J = ita_sph_error_directivity(pnm) 
% Calculate an error functions which is based on the directivity
%   preservation for directional source.
% pnm is assumed to be already rotated such that
%   maximum value collides with z axes.
%
% Input Parameters:
%   pmn - Matrix of rotated pnm values for each frequency (Narray+1)^2 x freqs.
%
% Output Parameters;
%   J - 1 x freqs: error function for each frequency.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the n0 coeeficients (m=0) 
% (N+1) x freqs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = sqrt(size(pnm,1))-1;
n = (0 : N).';
ind = n.^2+n+1;
pn0 = pnm(ind,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the directivity preservation error function
% 1 x freqs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A = sum(conj(pnm).*pnm,1);
B = sum(conj(pn0).*pn0,1);
J = -(B./A);
