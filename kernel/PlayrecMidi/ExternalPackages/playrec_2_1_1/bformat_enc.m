function [ BFormatSig ] = bformat_enc( srcSig, azimuth, elevation )
%BFORMAT_ENC Encodes a mono signal into a B-Format signal
%
%bformat_enc( srcSig, azimuth, elevation )
%   Encodes srcSig into a B-Format signal using the equation
%   W = srcSig / sqrt(2);
%   X = cos(azimuth) .* cos(elevation) .* srcSig;
%   Y = sin(azimuth) .* cos(elevation) .* srcSig;
%   Z = sin(elevation) .* srcSig;
%
%   azimuth and elevation can either be singular, or the same size as
%   srcSig to have different angles for each sample
%
%   The angles should be supplied in radians relative to due front
%
%   The return value BFormatSig contains 4 columns for W, X, Y and Z
%   respectively and is the same length as srcSig.

[srcSig nDimShift] = shiftdim(srcSig);
azimuth = shiftdim(azimuth, nDimShift);
elevation = shiftdim(elevation, nDimShift);

if((~isequal(size(azimuth),size(srcSig)) && ~isscalar(azimuth)) ...
    || (~isequal(size(elevation),size(srcSig)) && ~isscalar(elevation)))

    error ('Both azimuth and elevation must be either a scalar or the same size as srcSig');
end

if(~isreal(azimuth) || ~isreal(elevation))
    error ('azimuth and elevation must both be real');
end

if((size(srcSig,2)~=1) || (ndims(srcSig) > 2) || ~isreal(srcSig))
    error ('srcSig must be a real vector');
end

BFormatSig = zeros(length(srcSig), 4);

BFormatSig(:, 1) = srcSig / sqrt(2);
BFormatSig(:, 2) = cos(azimuth) .* cos(elevation) .* srcSig;
BFormatSig(:, 3) = sin(azimuth) .* cos(elevation) .* srcSig;
BFormatSig(:, 4) = sin(elevation) .* srcSig;