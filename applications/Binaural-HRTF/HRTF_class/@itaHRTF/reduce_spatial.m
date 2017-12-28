function [ cThis ] = reduce_spatial( this, newCoordinates, varargin )
%
% This function is used to reduce the spatial sampling from the current
% directions. This is done with a findnearest search. For a reduction to
% interpolated values use interp
%
% INPUT:
%
%
% OUTPUT:
%
%
%
% Author:  Jan-Gerrit Richter <jri@akustik.rwth-aachen.de>
% Version: 2017-11-23

oldCoords = this.getEar('L').channelCoordinates;

% if the desired sampling has more points, its probably unfeasable with
% findnearest search. Abort
if oldCoords.nPoints < newCoordinates.nPoints
    error('There are more points in the wanted sampling than are available. You probably want the interp function');
end

% the new coords should have the same radius as the old ones to reduce
% errors
newCoordinates.r = mean(oldCoords.r);

% don't use the mex file to make use of bugfix as poles
% oldCoords = oldCoords.build_search_database;

newIndex = oldCoords.findnearest(newCoordinates);

% calculate all distances from the wanted points to the found points
pointDistances = getVectorLength(newCoordinates,oldCoords.n(newIndex));

% calculate the distance between two neighboring points of the new sampling
newSamplingDistance = getVectorLength(newCoordinates.n(1),newCoordinates.n(2));

% the maximum of the found points should always be smaller
if max(pointDistances) > newSamplingDistance
   ita_verbose_info('The found points are further apart than the sampling allows. Something is wrong',0) 
end


if length(unique(newIndex)) < length(newIndex)
   ita_verbose_info('Multiple identical points found. This is not ideal.'); 
end

cThis = this.direction(newIndex);

end


function length = getVectorLength(pointsA, pointsB)
    
    pointsA.r = pointsB.r;
    vector = pointsA - pointsB;
    length = sqrt(vector.x.^2 + vector.y.^2 + vector.z.^2);

end