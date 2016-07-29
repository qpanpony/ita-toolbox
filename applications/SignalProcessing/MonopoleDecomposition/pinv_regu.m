function [opt] = pinv_regu( srcCoord,targetData,f,c,dist)
% PINV_REGU calculates monopole src strength
%   [opt] = pinv_regu( srcCoord,targetData,f,c,,dist)

% <ITA-Toolbox>
% This file is part of the application MonopoleDecomposition for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


k = 2*pi*f/c;
if nargin < 5
    dist = calcDist(targetData,srcCoord);
end

greenMat = exp(-1i.*k.*dist)./(4.*pi.*dist);
lambda = 1e-6;
[U,s,V] = csvd(greenMat);
b = targetData.freq2value(f).';
% lambda = l_curve(U,s,b,'Tikh');
opt = tikhonov(U,s,V,b,lambda);
% opt = (greenMat'*diag(targetData.channelCoordinates.weights)*greenMat + lambda.*eye(srcCoord.nChannels))\(greenMat'*(b.*.*targetData.channelCoordinates.weights));
end