function ita_sph_plot_flat(GeometryGrid, GeometryPoints, GeometrySource, data, dataPoints, minmax, colorType)
%ITA_SPH_PLOT_FLAT - plots a projected spherical function (and sampling points)
% function ita_sph_plot_flat(GeometryGrid, GeometryPoints, GeometrySource, data, dataPoints, minmax, colorType)
%
% plots the approximated spherical function (data) on a flat surface, using
% cylindrical projection
% the discrete positions of sampling points are hereby given as circles,
% filled with an apropriate color
%
% GeometryGrid.theta: 2D-meshgrid of theta values (radians)
% GeometryGrid.phi:   2D-meshgrid of phi values (radians, '[0..2*pi)')
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% convert to spatial domain if given as SH vector
if size(data,1) == size(GeometryGrid.Y,2)
    data = ISHT(data, g);
end

if nargin < 7
    colorType = jet;
end

% rotate the target by pi
rot_steps = [0 size(GeometryGrid.phi,2)/2];
% phi = circshift(GeometryGrid.phi, rot_steps);
% theta = circshift(GeometryGrid.theta, rot_steps);
target = circshift(reshape(data, size(GeometryGrid.phi)), rot_steps);

% add another line to have full range between 0 and 2*pi
phi = [GeometryGrid.phi GeometryGrid.phi(:,1)+2*pi];
theta = [GeometryGrid.theta GeometryGrid.theta(:,1)];
target = [target target(:,1)];

% figure;
hold on

set(gcf, 'renderer', 'painters')

% white background, Position
set(gcf, 'color', 'w');%, 'Position', [1 1 700 500]);

cmap = colormap(colorType);

% extrema of color bar is calculated out of both directivity and pressure
% on microphones:
min_dataPoints = min(abs(dataPoints));
min_target = min(abs(data));
max_dataPoints = max(abs(dataPoints));
max_target = max(abs(data));

if nargin < 6
    minmax = [min_dataPoints; max_dataPoints];
end

cmin = min([minmax(1) min_dataPoints min_target]);
cmax = max([minmax(2) max_dataPoints max_target]);

caxis([cmin cmax]);

% length of color points
m = size(cmap,1);

C = abs(dataPoints);
% from MatLab help "caxis":
index = fix((C-cmin)/(cmax-cmin)*m)+1;
% fix the problem for the maximum value
index(find(index >= m)) = m;


% set ranges
xlim([0 2*pi]);
ylim([0 pi]);

% put the north pole up
set(gca,'YDir','reverse')

% pcolor(con*phi2, con*theta2, abs(data2));
pcolor(phi, theta, abs(target));

for m = 1:size(dataPoints,1)

    if m == 23, pointsign = 'v';
    else pointsign = 'o';
    end

    C1 = mod(GeometryPoints.phi(m)+pi, 2*pi);
    C2 = GeometryPoints.theta(m);
    C3 = cmap(index(m),:);

    plot(C1, C2, pointsign,'MarkerEdgeColor','k', ...
        'MarkerFaceColor',C3,'MarkerSize',12);
end

for m = 1:length(GeometrySource.phi)

    C1 = GeometrySource.phi(m);
    C2 = GeometrySource.theta(m);
    C3 = 'k';
    
    pointsign = 'd';
    
    plot(C1, C2, pointsign,'MarkerEdgeColor','k', ...
        'MarkerFaceColor',C3,'MarkerSize',6);
end

% set ticks to pi values
set(gca, 'XTick', 0:pi:2*pi, 'YTick', 0:pi/4:pi);
 
% % set ticks to degree values
set(gca, 'XTick', (0:pi/2:2*pi), 'YTick', (0:pi/4:pi));
set(gca, 'XTicklabel', {'back', 'right', 'front', 'left', 'back'}, 'FontSize', 15);
set(gca, 'YTicklabel', {'  0 ', ' 45 ', ' 90 ', '135 ', '180 '}, 'FontSize', 15);

% avoid that the upper dot gets cut
set(gca, 'OuterPosition', [0 0 1 0.98])
 
shading interp;

% look from top
view(0,90);
