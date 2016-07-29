function s = ita_sph_sampling_hyperinterpolation(nmax)
% This function creates a spherical sampling with the property that its
% spherical harmonics function can be inverted.
%
% The SHT thus writes:  f_SH = inv(s.Y) * f;
% and the ISHT:         f = s.Y * f_SH;

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

% can be a natural number 1..29
if nmax > 29
    error('pre-calculated points only for hyperinterpolation up to order 29');
end
nSH = (nmax+1).^2;

filename = ['/Womersley/md' num2str(nmax,'%02d') '.' num2str(nSH,'%04d')];

% filepath = '~/MATLAB/Griddata';
% if ~exist(filepath,'dir')
%     error(['Griddata folder missing: ' filepath])
    url = 'http://www.ita-toolbox.org/Griddata';
    hyper = str2num(urlread([url filename])); %#ok<ST2NM>
% else
%     hyper = load([filepath filename]);
% end

s = itaSamplingSph(hyper(:,1:3),'cart');
s.weights = hyper(:,4);
s.nmax = nmax;
