function [ dist ] = calcDist( gridCoord, srcCoord )
%CALCDIST calculates distances between all sources and target positions
%
%   calcDist( gridCoord, srcCoord )
%
%   Returns #gridPoints x #sources Matrix with all the distances
%   Can take coordinates either as itaCoordinates or cartesian vectors
%

% <ITA-Toolbox>
% This file is part of the application MonopoleDecomposition for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if isa(gridCoord, 'itaCoordinates')
    nGridCoord = gridCoord.cart;
elseif isa(gridCoord, 'itaSuper') && ~all(isnan(gridCoord.channelCoordinates.cart(:)))
    nGridCoord = gridCoord.channelCoordinates.cart;
else
    nGridCoord = gridCoord(:,1:3);
end
if isa(srcCoord, 'itaCoordinates')
    nSrcCoord = srcCoord.cart;
elseif isa(srcCoord, 'itaSuper') && ~all(isnan(srcCoord.channelCoordinates.cart(:)))
    nSrcCoord = srcCoord.channelCoordinates.cart;
else
    nSrcCoord = srcCoord(:,1:3);
end

N = length(nGridCoord(:,1));
M = length(nSrcCoord(:,1));
dist = zeros(N,M);
for iSrc = 1:M
    tmp = nGridCoord - repmat(nSrcCoord(iSrc,1:3),N,1);
    dist(:,iSrc) = sqrt(sum(tmp.^2,2));
end

end %function