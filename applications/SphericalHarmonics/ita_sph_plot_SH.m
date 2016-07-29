function ita_sph_plot_SH(coefs, varargin)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% check if 2nd parameter is the cell for the point plot
pointdata = [];
pointsampling = [];
if numel(varargin) && iscell(varargin{1})
    pointcell = varargin{1};
    if numel(pointcell) == 1
       pointsampling = pointcell{1};
       pointdata = pointsampling.r;
    else
        pointdata = pointcell{1};
        pointsampling = pointcell{2};
    end
    varargin = varargin(2:end);
end

paraStruct = ita_sph_plot_parser(varargin);
plottype = paraStruct.type;

% load or make grid for plotting
persistent sampling
if ~isempty(paraStruct.sampling) && isa(paraStruct.sampling,'itaSamplingSph')
    % a valid sampling given from input parameter
    sampling = paraStruct.sampling;
elseif ~isa(sampling,'itaSamplingSph')
    % persistant variable doesnt contain a valid grid
    sampling = ita_sph_sampling_equiangular(64,64,'[]','[)');
end

% convert to given spatial grid
data = ita_sph_ISHT(coefs, sampling);

% call spatial plot function
[hFig, hSurf] = ita_sph_plot_spatial(data, sampling, varargin{:});

% do we want points on the sphere?
if ~isempty(pointdata)
    
    % convert to spherical coordinates
%     if ~strcmp(pointsampling.type,'sph')
        pointsampling = cart2sph(pointsampling);
%     end
    
    [magn, color, colorMap] = ita_sph_plot_type(pointdata,plottype);

%     sizeGrid = size(sampling.weights);
    theta = pointsampling.theta;
    phi = pointsampling.phi;
    magn = reshape(magn,size(theta));
    color = reshape(color,size(theta));

    if numel(coefs) == 1
        r_balloon = ones(size(theta)) .* coefs ./ sqrt(4*pi);
    else
        r_balloon = abs(ita_sph_functionvalue(coefs, pointsampling));
        r_balloon = reshape(r_balloon,size(theta));
    end
    
    % find location of the dots
    switch paraStruct.onballoon
        case 'greater'
            % all dots on or inside balloon
            lineStyle = '-';
            lineWidth = 3;
            r_point = min(r_balloon, magn);
        case 'smaller'
            % all dot on or outsied balloon
            lineStyle = ':';
            lineWidth = 2;
            r_point = max(r_balloon, magn);
        case 'all'
            % all dots on balloon
            r_point = r_balloon;
        otherwise 
            r_point = magn;
    end

    
    % find balloon radii
    X = get(hSurf,'XData');
    Y = get(hSurf,'YData');
    Z = get(hSurf,'ZData');
    R = sqrt(X.^2 + Y.^2 + Z.^2);
    
    % maximum of balloon and dots
%     maxVal = max(max(max(R(:)),max(magn)));
    colorSurf = get(hSurf,'CData');
%     maxColorSurf = max(max(colorSurf));
    maxVal = max(max(colorSurf(:),max(color(:))));

    % set colorbar data
    if isempty(paraStruct.caxis)
        % fix values
        cmin = 0;
        if strcmp(plottype,'complex') ...
                || strcmp(plottype,'spherephase')
            cmax = 2*pi;
        else
            cmax = maxVal;
        end        
    else
        % parameter can change the colorbar data
       cmin = paraStruct.caxis(1);
       cmax = paraStruct.caxis(2);       
       if numel(cmax)
           cmax = cmin;
       end       
    end
    caxis([cmin cmax]);
    
    hold on
    cmap = colormap(colorMap);
    
    % length of color points
    nPoints = size(cmap,1);
    % from MatLab help "caxis":
%     index = fix((color-cmin)/(cmax-cmin)*m)+1;
    % fix the problem for the maximum value
%     index(index >= m) = m;
    
    index = fix((color-cmin)/(cmax-cmin)*(nPoints-1))+1;
    
    x = r_point .* cos(phi) .* sin(theta);
    y = r_point .* sin(phi) .* sin(theta);
    z = r_point .* cos(theta);
    nCmap = size(cmap,1);
    for n = 1:nCmap        
        % indexBound element of 1..nCmap
        indexBound = max(min(index,nCmap),1);
        ind = (indexBound(:) == n);
        plot3(x(ind), y(ind), z(ind), 'o', 'MarkerEdgeColor','k', 'MarkerFaceColor', cmap(n,:), 'MarkerSize',10);
    end
    if paraStruct.line
        xSurf = r_balloon .* sin(theta) .* cos(phi);
        ySurf = r_balloon .* sin(theta) .* sin(phi);
        zSurf = r_balloon .* cos(theta);
        line([xSurf x],[ySurf y],[zSurf z], 'LineWidth', lineWidth, 'Color', 'black','LineStyle',lineStyle);
    end
end

hold off;