function [ speakerFeeds ] = bformat_dec( BFormatSig, azimuth, elevation, directivity )
%BFORMAT_DEC Decode a B-Format signal to a speaker feed
%
%bformat_dec( BFormatSig, azimuth, elevation, directivity )
%   Decodes BFormatSig to speaker feeds, based on the azimuth and
%   elevation of the speakers as well as the directivity value (between 0
%   and 2).
%
%   BFormatSig must be a 2-dimensional matrix where there are either
%   3 (W X Y) or 4 (W X Y Z) columns.  The number of rows is the number of
%   samples.
%
%   azimuth and elevation can be either scalar or row vectors, provided
%   they are both the same size, where each value in the vector
%   corresponds to the position of a speaker (in radians).  The returned
%   speaker feeds contains the same number of columns as azimuth and elevation
%   - one per speaker - whist the number of rows is the same as BFormatSig.
%
%   directivity must either be a scalar, or the same size as azimuth and
%   elevation.

if((ndims(BFormatSig)~=2) || ((size(BFormatSig, 2)~=3) && (size(BFormatSig, 2)~=4)))
    error ('BFormatSig is not the correct dimensions');
end

if((ndims(azimuth)~=2) || (size(azimuth, 1)~=1) || ~isreal(azimuth))
    error ('azimuth must be a real scalar or row vector');
end

if((ndims(elevation)~=2) || (size(elevation, 1)~=1) || ~isreal(elevation))
    error ('elevation must be a real scalar or row vector');
end    

if(~isequal(size(azimuth), size(elevation)))
    error ('azimuth and elevation must be the same size');
end

if(~isreal(directivity) || (~isscalar(directivity) && ~isequal(size(directivity), size(azimuth))))
    error ('directivity must be real and either a scalar value or the same size as azimuth and elevation');
end

if(any(directivity < 0))
    warning ('Setting directivity value to 0');
    directivity((directivity < 0)) = 0;
end

if(any(directivity > 2))
    warning ('Setting directivity value to 2');
    directivity(directivity > 2) = 2;
end

% Make directivity the same size as the two angle variables
if(isscalar(directivity))
    directivity = repmat(directivity, size(azimuth));
end

%Determine the speaker feed, depending on the number of channels of data
%supplied
if(size(BFormatSig, 2)==3)
    %Assume Z channel contains zeros
    speakerFeeds = 0.5 * (BFormatSig(:,1) * sqrt(2) * (2-directivity)...
        + BFormatSig(:,2) * (directivity .* cos(azimuth) .* cos(elevation)) ...
        + BFormatSig(:,3) * (directivity .* sin(azimuth) .* cos(elevation)) );
else
    speakerFeeds = 0.5 * (BFormatSig(:,1) * sqrt(2) * (2-directivity)...
        + BFormatSig(:,2) * (directivity .* cos(azimuth) .* cos(elevation)) ...
        + BFormatSig(:,3) * (directivity .* sin(azimuth) .* cos(elevation)) ...
        + BFormatSig(:,4) * (directivity .* sin(elevation)) );
end