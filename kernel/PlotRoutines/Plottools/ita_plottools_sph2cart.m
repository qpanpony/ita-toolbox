function cartesian = ita_plottools_sph2cart(GeometryGrid, data, type)
%ITA_PLOTTOOLS_SPH2CART - converts spherical data to cartesian

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created: 12-Sep-2008 

% convert to spatial domain if neccessary
if isfield(GeometryGrid, 'Y') && size(data,1) == size(GeometryGrid.Y,2)
    dataSH = data;
    data = ita_sph_ISHT(data, GeometryGrid);
elseif nargin > 3 % convert to SH domain only if the points are given also
    dataSH = ita_sph_SHT(data, GeometryGrid);
end
data = reshape(data, size(GeometryGrid.theta,1), size(GeometryGrid.theta,2), []);
nFreqs = size(data,3);

switch type
    case 'complex'
        magn = abs(data);
        color = angle(data);
%         colormap(hsv);
    case 'sphere'
        magn = ones(size(data));
        color = abs(data);
%         colormap(jet);
    case 'magnitude'
        magn = abs(data);
        color = magn;
%         colormap(jet);
    otherwise
        error('give a valid type (complex / sphere / magnitude)')
end

theta = [GeometryGrid.theta, GeometryGrid.theta(:,1)];
phi = [GeometryGrid.phi, 2*pi+GeometryGrid.phi(:,1)];
magn = cat(2,magn, magn(:,1,:));
cartesian.color = cat(2,color, color(:,1,:));
[cartesian.X,cartesian.Y,cartesian.Z] = ...
    sph2cart(repmat(phi, [1 1 nFreqs]), pi/2 - repmat(theta, [1 1 nFreqs]), magn);

% give the used frequencies also to the cartesian data
if isfield(GeometryGrid, 'usedFreqs')
    cartesian.usedFreqs = GeometryGrid.usedFreqs;
end

cartesian.maxValue = max(max(max(magn)));
cartesian.maxColor = max(max(max(color)));
cartesian.comment = GeometryGrid.comment;
cartesian.type = type;