function ao = ita_sph_sht_least_squares(ao, Y)
% works on itaAudioSph/itaResultSph objects (in either freq or time domain)
%

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% the transformation matrix can be stated explicitly to make alternative
% base functions possible

if nargin < 2
    Y = ao.Y;
end

S2 = ao.data;
sizeY = size(Y);
sizeSH = [size(S2,1) sizeY(2:end)];

sizePinvY = sizeY([2 1 3:numel(sizeY)]);
pinvY = zeros(sizePinvY);
sizePinvY3 = size(pinvY,3);

for ind = 1:size(Y,3)
    pinvY(:,:,ind) = pinv(Y(:,:,ind));
end

ao.(ao.domain) = zeros(sizeSH);

for ind = 1:size(S2,1)
    indPinv = min(ind,sizePinvY3); % to cover both cases, with or without frequency dependence
    ao.data(ind,:) = pinvY(:,:,indPinv) * S2(ind,:).';
end
