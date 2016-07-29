function [srcCoord, N] = gen_srcCoords(src_pos,N,maxDist,varargin)
%GEN_SRCCOORDS generates source Coordinate distributions according to the distribution
%   scheme specified in src_pos
%
%   [srcCoord, N] = gen_srcCoords(src_pos,N,maxDist,varargin)
%
%
%   src_pos =   {'cube','rand','sphere','xyz','xyz+rand',xyz+cube}
%       rand        randomly distributed points
%       xyz         evenly distributed points on x y and z achses
%       sphere      equiangular distributed points on sphere with r =
%                   maxDist
%       cube        cube with w = 0.5*maxdist + 1 center point
%       xyz+cube    13 Points on XYZ + 8 as 1/sqrt2 cube
%       xyz+rand    recommended - nXYZ monopoles on axis + N-nXYZ random
%
%   varargin
%       'nXYZ'  21  number of monopoles on axis in xyz+rand distribution

% <ITA-Toolbox>
% This file is part of the application MonopoleDecomposition for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%%parse Arguments

sArgs = struct('nXYZ',21);
sArgs = ita_parse_arguments(sArgs,varargin);

%% create sources as itaAudio Object
if N == 1
    srcCoord= itaCoordinates([0 0 0]);
    return;
end


src_pos = lower(src_pos);
switch src_pos
    case 'cube'
        N = 9;
        srcCoord= itaCoordinates(N);
        srcCoord.x = [0 1 1 -1 -1 1 1 -1 -1]';
        srcCoord.y = [0 -1 1 1 -1 -1 1 1 -1]';
        srcCoord.z = [0 -1 -1 -1 -1 1 1 1 1]';
    case 'rand'
        srcCoord= itaCoordinates(N);
        srcCoord.x = [0;ones(N-1,1)-2*rand(N-1,1)];
        srcCoord.y = [0;ones(N-1,1)-2*rand(N-1,1)];
        srcCoord.z = [0;ones(N-1,1)-2*rand(N-1,1)];
    case 'sphere'
        d = ceil(sqrt(180*360/N));
        srcCoord = ita_generateSampling_equiangular(d,d);
        N = srcCoord.nPoints;
    case 'xyz'
        N = 3*ceil(N/3);
        if N == 3
            srcCoord= itaCoordinates(N);
            srcCoord.x = zeros(N,1);
            srcCoord.y = [-1;0;1];
            srcCoord.z = zeros(N,1);
        else
            srcCoord= itaCoordinates(N);
            srcCoord.x = ([-1:2/(N/3-1):1,zeros(1,2*N/3)])';
            srcCoord.y = ([zeros(1,N/3),-1:2/(N/3-1):1,zeros(1,N/3)])';
            srcCoord.z = ([zeros(1,2*N/3),-1:2/(N/3-1):1])';
        end
        
    case 'xyz+rand'
        [srcCoord,M] = gen_srcCoords('xyz',sArgs.nXYZ,1);
        [srcCoord] = [srcCoord,gen_srcCoords('rand',N-M,1)];
    case 'xyz+cube'
        tmpCoord = gen_srcCoords('xyz',N,1);
        srcCoord = itaCoordinates(tmpCoord.nPoints+8);
        srcCoord.x = [tmpCoord.x; 1/sqrt(2).*[1,1,-1,-1,1,1,-1,-1].'];
        srcCoord.y = [tmpCoord.y; 1/sqrt(2).*[1,-1,1,-1,1,-1,1,-1].'];
        srcCoord.z = [tmpCoord.z; 1/sqrt(2).*[1,1,1,1,-1,-1,-1,-1].'];
        
    otherwise
        error('src_pos must be one of { cube rand sphere xyz zero }')
end

if ~any((srcCoord.x == 0) & (srcCoord.y == 0) & (srcCoord.z == 0))
    srcCoord = [srcCoord; itaCoordinates([0 0 0])];
else
    % remove non-unique points at the origin
    monoIdx = find((srcCoord.x == 0) & (srcCoord.y == 0) & (srcCoord.z == 0));
    srcCoord = srcCoord.n([monoIdx(1),setdiff(1:srcCoord.nPoints,monoIdx)]);
end

% improve stability of green function matrix
srcCoord.cart = srcCoord.cart + 0.001.*randn(size(srcCoord.cart));

srcCoord.r = maxDist*srcCoord.r;
srcCoord.cart = round(srcCoord.cart.*1e6)./1e6; % round to 1 um
N = srcCoord.nPoints;

if ~isempty(varargin) && ~strcmpi(src_pos,'rot')
    if strcmp(varargin{1},'cart')
        srcCoord = srcCoord.cart;
    end
end

end

