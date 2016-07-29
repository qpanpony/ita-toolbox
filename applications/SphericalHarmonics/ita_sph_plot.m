function ita_sph_plot(data, varargin)
%ITA_SPH_PLOT - plots a spherical function (and sampling points)
% function ita_sph_plot(data, varargin)
%
% the input data can be given as a spherical harmonic coefficient vector
%
% the optional parameter 'type' can be:
%   'complex'       : radius is magnitude, color is phase
%   'sphere'        : plots magnitude as color on unit sphere
%   'magnitude'     : radius and color is magnitude 
%   'spherephase'   : plots phase as color on unit sphere
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

% default parameters
def.type = 'magnitude';
def.facealpha = 0.7;
def.edgealpha = 0.1;
def.grid = [];
def.samplingpoints = [];
def.sampledvalues = [];
def.geometrypoints = [];
def.axes = 'outer';
def.fontsize = 12;
def.onballoon = 'none'; % 'smaller', 'greater', 'all'
% def.angunit = 'rad'; % ToDo: Winkeldarstellung Bogenma�/Grad ('deg')
% def.plottype = 'ita_sph_plot'; evtl. noch f�r update-Funktion
def.caxis = [];
def.line = false;

if nargin > 1
%     if isstruct(varargin{1}) && isfield(varargin{1},'pos')% this is sampling points
    if isa(varargin{1},'itaSampling') || isa(varargin{1},'itaCoordinates'); % this is sampling points
        def.samplingpoints = varargin{1};
        % and delete first element ion list
        varargin = varargin(2:end);
        if nargin > 2 && isnumeric(varargin{1})% the values of the points are also given
            def.sampledvalues = varargin{1};
            varargin = varargin(2:end);
        else % use weights (enlarge, if it only theta weights)
            def.sampledvalues = def.samplingpoints.weights;
%             def.sampledvalues = weights;
        end
    end    
end    

% % test if the sampling points are given
% if nargin > 1 && isstruct(samplingPoints)    
%     if ~exist('sampledValues','var')
%         sampledValues = samplingPoints.weights;
%     end
%     % or if they are not given, either way plot weights
%     if ~isnumeric(sampledValues)
%         varargin = {sampledValues varargin{:}};
%         sampledValues = samplingPoints.weights;
%     end
%     % now handle it via parser
%     varargin = {'samplingPoints' samplingPoints ...
%         'sampledValues' sampledValues varargin{:}};
%     clear samplingPoints sampledValues;
% end 

% take over parameters from arguments (varargin)
paraStruct = ita_parse_arguments(def,varargin);

% load or make grid for plotting
persistent plotGrid
if ~isempty(paraStruct.grid) && ...
    (isa(paraStruct.grid,'itaCoordinates') || isa(paraStruct.grid,'itaSampling'));
    plotGrid = paraStruct.grid;
elseif ~isstruct(plotGrid)    
    plotGrid = ita_sph_sampling_equiangular(64,64,'[]','[)');%equiangular(15);
end
%     plotGrid = ita_sph_grid_regular_weights(plotGrid,31);
%     plotGrid = ita_sph_base(plotGrid, 31);
% theta = reshape(plotGrid.coord(:,1),length(plotGrid.weights),[]);
% phi = reshape(plotGrid.coord(:,2),length(plotGrid.weights),[]);
theta = plotGrid.theta;
phi = plotGrid.phi;

type = paraStruct.type;
samplingPoints = paraStruct.samplingpoints;
sampledValues = paraStruct.sampledvalues;

if numel(data) == numel(theta)
    disp('it must be spatial data');
    dataSH = ita_sph_SHT(data, plotGrid);
else
    if numel(data) == 1
        data = sqrt(4*pi);
    elseif size(data,1) == 1
        data = data.';
    end
    dataSH = data;
    data = ita_sph_ISHT(dataSH, plotGrid);
    data = reshape(data, length(plotGrid.weights), []);
end    

switch type
    case 'complex'
        magn = abs(data);
        color = mod(angle(data),2*pi);
        colormap(hsv);
    case 'sphere'
        magn = ones(size(data));
        color = abs(data);
        colormap(jet);
    case 'spherephase'
        magn = ones(size(data));
        color = angle(data);
        colormap(hsv);
    case 'magnitude'
        magn = abs(data);
        color = magn;
        colormap(jet);
    otherwise
        error('give a valid type (complex / sphere / spherephase / magnitude)')
end

% magn = abs(data);
% angle = angle(data)

% theta = [plotGrid.theta, plotGrid.theta(:,1)];
% phi = [plotGrid.phi, 2*pi+plotGrid.phi(:,1)];
theta = theta(:,[1:end 1]);
phi = phi(:,[1:end 1]);
magn = magn(:,[1:end 1]);
color = color(:,[1:end 1]);
% color = [color, color(:,1)];

[X,Y,Z] = sph2cart(phi, pi/2 - theta, magn);
% cla;
set(gcf, 'renderer', 'opengl')
surf(X,Y,Z,color, 'EdgeAlpha', paraStruct.edgealpha, 'FaceAlpha', paraStruct.facealpha);

colorbar;
% shading interp
m_val = max(max(magn));
if m_val > 0
    xlim([-m_val m_val]);
    ylim([-m_val m_val]);
    zlim([-m_val m_val]);
end
daspect([1 1 1]);
axis vis3d % off
% axis([-1 1 -1 1 -1 1])

switch type
    case {'complex','spherephase'}
        caxis([0 2*pi]);
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

% do we want points on the sphere?
if ~isempty(samplingPoints)
    if ~strcmp(samplingPoints.type,'sph')
        samplingPoints = cart2sph(samplingPoints);
    end
    
    switch type
    case 'complex'
        pointRadius = abs(sampledValues);
        pointColor = mod(angle(sampledValues), 2*pi);
    case 'sphere'
        pointRadius = ones(size(sampledValues));
        pointColor = abs(sampledValues);
    case 'magnitude'
        pointRadius = abs(sampledValues);
        pointColor = abs(sampledValues);
    case 'spherephase'
        pointRadius = ones(size(sampledValues));
        pointColor = mod(angle(sampledValues), 2*pi);        
    end

    hold on;
    
%     target = magn(:);
    
    cmap = colormap;
    
    % extrema of color bar is calculated out of both directivity and pressure
    % on microphones:    
    minRadiusSphere = min(magn(:));
    maxRadiusSphere = max(magn(:));
    
    minRadiusPoints = min(pointRadius(:));
    maxRadiusPoints = max(pointRadius(:));
    
%     minRadiusTotal = min(minRadiusSphere, minRadiusPoints);
%     maxRadiusTotal = max(maxRadiusSphere, maxRadiusPoints);
    

    if strcmp(type,'complex')
        cmin = 0;
        cmax = 2*pi;
    else
        cmin = 0; % min([min_pointData min_target]);
        cmax = max(max(color(:)), max(pointColor(:)));
    end
    
    if ~isempty(paraStruct.caxis)
       cmin = paraStruct.caxis(1);
       cmax = paraStruct.caxis(2);       
       if numel(cmax)
           cmax = cmin;
           caxis([cmin cmax]);
       end       
    end
    
    
    % length of color points
    m = size(cmap,1);

    % from MatLab help "caxis":
    index = fix((pointColor-cmin)/(cmax-cmin)*m)+1;
    % fix the problem for the maximum value
    index(index >= m) = m;
    
    for m = 1:length(sampledValues)

        % find radius on balloon plot
        sizeDataSH = size(dataSH);
        dataSHused = zeros([size(samplingPoints.Y,2) sizeDataSH(2:end)]);
        % doesnt work on multiple dimensions of dataSH !!
        dataSHused(1:length(dataSH)) = dataSH;
        
        % data of balloon on sampling points
        r = abs(dataSHused.' * samplingPoints.Y(m,:).');
        theta = samplingPoints.coord(m,1);
        phi = samplingPoints.coord(m,2);
%                 
% 
        
        if numel(index(m)) == 1 && ~isnan(index(m)) 
            c = cmap(index(m),:);
        else
            c = zeros(1,size(cmap,2));
        end
        if strcmp(type,'sphere')
            r_used = 1;
%             plot3(x, y, z, 'o', 'MarkerEdgeColor','k', 'MarkerFaceColor', c, 'MarkerSize',10);            
        else             
            if pointRadius(m) > r % reconstruction too silent
                lineStyle = ':';
                lineWidth = 2;
                switch paraStruct.onballoon
                    case {'greater','all'}
                        r_used = r;
                    otherwise
                        r_used = pointRadius(m);
                end
            else
                lineStyle = '-';
                lineWidth = 3;
                switch paraStruct.onballoon
                    case {'smaller','all'}
                        r_used = r;
                    otherwise
                        r_used = pointRadius(m);
                end
            end
        end
        x = r_used .* cos(phi) .* sin(theta);
        y = r_used .* sin(phi) .* sin(theta);
        z = r_used .* cos(theta);
        plot3(x, y, z, 'o', 'MarkerEdgeColor','k', 'MarkerFaceColor', c, 'MarkerSize',10);
        if paraStruct.line
            xSurf = r .* sin(theta) .* cos(phi);
            ySurf = r .* sin(theta) .* sin(phi);
            zSurf = r .* cos(theta);            
            line([xSurf x],[ySurf y],[zSurf z], 'LineWidth', lineWidth, 'Color', 'black','LineStyle',lineStyle);
        end
    end
end

switch paraStruct.axes
    case 'inner'% alternative Achsen:
        hold on;
        maxim = max([max(max(abs(X))) max(max(abs(Y))) max(max(abs(Z)))]);
        ak = [1.3*maxim -1.3*maxim]; nak = [0 0];
        [X0,Y0] = pol2cart(0:pi/180:2*pi,1.1*maxim);
        [X1,Y1] = pol2cart(0:pi/180:2*pi,1.0*maxim);
        [X2,Y2] = pol2cart(0:pi/180:2*pi,0.9*maxim);
        [X3,Y3] = pol2cart(0:pi/180:2*pi,0.8*maxim);
        [X4,Y4] = pol2cart(0:pi/180:2*pi,0.7*maxim);
        Z0=zeros(1,361);
        plot3(ak, nak, nak, 'k', nak, ak, nak, 'k', nak, nak, ak, 'k');
        text(1.35*maxim, 0, 0, 'x', 'FontSize', paraStruct.fontsize, 'FontWeight', 'bold'); text(0, 1.35*maxim, 0, 'y', 'FontSize', paraStruct.fontsize, 'FontWeight', 'bold'); text(0, 0, 1.35*maxim, 'z', 'FontSize', paraStruct.fontsize, 'FontWeight', 'bold');
        plot3(X0,Y0,Z0,'k' ,X1,Y1,Z0,'k', X2,Y2,Z0,'k', X3,Y3,Z0,'k', X4,Y4,Z0,'k');
        kinder = get(gca,'Children');        
%         for k=1:11
%             set(kinder(k),'Visible','on');
%         end
        grid off
        axis off
    case 'outer'
%         for k=1:11
%             set(kinder(k),'Visible','off');
%         end
%         grid on
%         axis on
end

hold off;

% set(gcf,'KeyPressFcn',@ita_plottools_buttonpress_spherical);