function ao = ita_sph_makeSH(ao, s, type)

% This functions takes a spatial distribution of data points and converts
% it to spherical harmonic coefficients. The spherical sampling scheme is
% given in s and must include sampling weights and the spherical harmonic
% base functions.
% Works in time and frequency domain.

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

if isempty(s.Y)
    error('Please define the base functions first.')
end
if isempty(s.weights)
    error('Please define the sampling weights first.')
end

nData = size(ao.data,1);
nSH = size(s.Y,2);
SH = zeros(nData, nSH);

for iData = 1:size(ao.data,1)
    dataVector = ao.data(iData,:).';
    if nargin > 2 && strcmpi(type,'pinv')
        SH(iData,:) = lscov(s.Y, dataVector, s.weights);
    else
        weightedData = dataVector .* s.weights;
        SH(iData,:) = (s.Y' * weightedData).';
    end
end

ao.data = SH;
