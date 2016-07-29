function [hFig, hSurf] = ita_sph_plot_spatial(data, sampling, varargin)
%ITA_SPH_PLOT_SPATIAL - plots a spatial spherical function (and sampling points)
% function ita_sph_plot_spatial(data, varargin)
%
% the optional parameter 'type' can be:
%   'complex'       : radius is magnitude, color is phase
%   'sphere'        : plots magnitude as color on unit sphere
%   'magnitude'     : radius and color is magnitude 
%   'spherephase'   : plots phase as color on unit sphere
%   'db'            : plots 20*log10(abs(data)),putting the maximum level to a fixed value 
%
% the optional GeometryPoints and pointData give the information about
% spherical sampling points
% GeometryPoints.theta: vector of theta values
% GeometryPoints.phi:   vector of phi values
% data:            vector of sampling values
%
%       type: default 'magnitude'
%       GeometryPoints & pointData: default []
%       axes: outer/inner, different 'design' (default: outer)
%       fontsize: default 12, for axis annotations

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>



% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008
% Modified: 14.01.2009 - mpe - parameter-structure:
% Complete rewrite: July-09 - mpo

% if nargin < 2
%     sampling = data;
%     data = ones(size(sampling));
%     
% end

% narginchk(2,3);

paraStruct = ita_sph_plot_parser(varargin);

type = paraStruct.type;

% get the values for the plot
[magn, color, colorMap] = ita_sph_plot_type(data,type);

% reshape for use in plot

sqrtNumel = sqrt(numel(magn));
isWholeNumber = floor(sqrtNumel) == ceil(sqrtNumel);
if isWholeNumber && sqrtNumel > 15;
    dim = [sqrt(numel(magn)) sqrt(numel(magn))];    
    magn = reshape(magn,dim);
    color = reshape(color,dim);
    theta = reshape(sampling.theta,dim);
    phi = reshape(sampling.phi,dim);
else
    error('mist hier')
end

% add one vertical line of values to get a closed balloon
theta = theta(:,[1:end 1]);
phi = phi(:,[1:end 1]);
magn = magn(:,[1:end 1]);
color = color(:,[1:end 1]);

% plot the balloon
[X,Y,Z] = sph2cart(phi, pi/2 - theta, magn);
% hFig = figure;
hFig = gcf;
set(hFig, 'renderer', 'opengl')
hSurf = surf(X,Y,Z,color, 'EdgeAlpha', paraStruct.edgealpha, 'FaceAlpha', paraStruct.facealpha);
colorbar;
colormap(colorMap);

% set axes limits
maxMagn = max(max(magn));
if maxMagn < 0
    error('Magnitude is < 0, how to plot this');
end

if isempty(paraStruct.rlim)
    rlim = maxMagn;
else
    rlim = paraStruct.rlim;
end
xlim([-rlim rlim]);
ylim([-rlim rlim]);
zlim([-rlim rlim]);

daspect([1 1 1]);
axis vis3d

% set colorbar settings
if ismember(type, {'complex','spherephase'})
   caxis([0 2*pi]);
else
    caxis([0 maxMagn]);
end

grid on;
% bigger and fatter fonts
set(gca, 'FontSize', paraStruct.fontsize, 'FontWeight', 'bold');
% set background color to white
set(gcf, 'Color', 'w');
% view(90,0);
view(3);
% view(0,90);
rotate3d;
xlabel('x');
ylabel('y');
zlabel('z');

switch paraStruct.axes
    case 'inner'% alternative Achsen:
        hold on;
        ak = [1.3*rlim -1.3*rlim]; nak = [0 0];
        [X0,Y0] = pol2cart(0:pi/180:2*pi,1.1*rlim);
        [X1,Y1] = pol2cart(0:pi/180:2*pi,1.0*rlim);
        [X2,Y2] = pol2cart(0:pi/180:2*pi,0.9*rlim);
        [X3,Y3] = pol2cart(0:pi/180:2*pi,0.8*rlim);
        [X4,Y4] = pol2cart(0:pi/180:2*pi,0.7*rlim);
        Z0=zeros(1,361);
        plot3(ak, nak, nak, 'k', nak, ak, nak, 'k', nak, nak, ak, 'k');
        text(1.35*rlim, 0, 0, 'x', 'FontSize', paraStruct.fontsize, 'FontWeight', 'bold'); text(0, 1.35*rlim, 0, 'y', 'FontSize', paraStruct.fontsize, 'FontWeight', 'bold'); text(0, 0, 1.35*rlim, 'z', 'FontSize', paraStruct.fontsize, 'FontWeight', 'bold');
        plot3(X0,Y0,Z0,'k' ,X1,Y1,Z0,'k', X2,Y2,Z0,'k', X3,Y3,Z0,'k', X4,Y4,Z0,'k');
        kinder = get(gca,'Children');        
        grid off
        axis off
    case 'outer'
        grid on
        axis on
end

% set(gcf,'KeyPressFcn',@ita_plottools_buttonpress_spherical);