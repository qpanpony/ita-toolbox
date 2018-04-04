function s = ita_sph_sampling_hyperinterpolation(nmax)
% This function creates a spherical sampling with the property that its
% spherical harmonics function can be inverted.
% 
% The set of points is downloaded from Womersleys homepage:
%  http://web.maths.unsw.edu.au/~rsw/Sphere/Extremal/New/index.html
%
% The SHT thus writes:  f_SH = inv(s.Y) * f;
% and the ISHT:         f = s.Y * f_SH;

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

% can be a natural number 1..165
if nmax > 165
    error('pre-calculated points only for hyperinterpolation up to order 29');
end
nSH = (nmax+1).^2;

filename = ['md' num2str(nmax,'%03d') '.' num2str(nSH,'%05d')];

url = 'http://web.maths.unsw.edu.au/~rsw/Sphere/Extremal/New/';
hyper = str2num(urlread([url filename])); %#ok<ST2NM>

s = itaSamplingSph(hyper(:,1:3),'cart');
s.r = ones(s.nPoints,1);
s.weights = hyper(:,4);
s.nmax = nmax;