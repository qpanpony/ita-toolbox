function ita_plot_dots(sampling, varargin)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% color is optional
% 'symbol', 'o'

if nargin == 0, error; end;

sampling = makeCart(sampling);

% if isempty(color)
%     % default: black color
%     color = 0 * sampling.r;
% end

nDots = size(sampling.x,1);

paraStruct = ita_sph_plot_parser(varargin);
colorValue = paraStruct.dotColor;

%% set the color ranges
if isempty(paraStruct.caxis)
    % there are no defined caxis preferences
    if length(colorValue) == nDots
        % obviously the colorValue is a continuous color entry
        % so use it:
        cminmax = [min(colorValue) max(colorValue)];
    else
        % use given caxis
        cminmax = caxis;
    end
else
    % use input parameter for colormap
    cminmax = paraStruct.caxis;
end
cmin = cminmax(1);
cmax = cminmax(2);
caxis([cmin cmax]);

%% set colormap
cmap = colormap;
nCmap = size(cmap,1);

%% set the colorRGB values
if all(size(colorValue) == [1 3]);
    % the given color seems to be a RGB color
    % enlarge to number of dots
%     colorRGB = colorValue(ones(nDots,1),:);
    colorRGB = colorValue;
elseif length(colorValue) == nDots;
    % specific colors are given
    % convert to used colorMap
    index = fix((colorValue-cmin)/(cmax-cmin)*(nCmap-1))+1;
    indexBound = max(min(index,nCmap),1);
    colorRGB = cmap(indexBound,:);
else
    error('invalid colors given')
end
    

hold on

if length(colorRGB) == 3
    % only one color
    iPoints = 1:nDots;
    colorMarker = colorRGB;

    x = sampling.x(iPoints);
    y = sampling.y(iPoints);
    z = sampling.z(iPoints);
    plot3(x, y, z, paraStruct.symbol, 'MarkerEdgeColor',paraStruct.MarkerEdgeColor, ...
        'MarkerFaceColor', colorMarker,'MarkerSize',paraStruct.MarkerSize);
else
    % every point has a color
    for iColor = 1:nCmap
        iPoints = (indexBound == iColor);
        if any(iPoints)            
            % use the color of first point (as all are equal anyway)
            colorMarker = colorRGB(find(iPoints,1),:);
            x = sampling.x(iPoints);
            y = sampling.y(iPoints);
            z = sampling.z(iPoints);
            plot3(x, y, z, paraStruct.symbol, 'MarkerEdgeColor',paraStruct.MarkerEdgeColor, ...
                'MarkerFaceColor', colorMarker,'MarkerSize',paraStruct.MarkerSize);
        end
    end        
end

% now set xlim, ylim & zlim

% maxlimold = max([xlimold(2) ylimold(2) zlimold(2)]);
% maxlimnew = max(max(sampling.cart));
% maxlim = max(maxlimold, maxlimnew);

% maxVal = max(max(sampling.cart));
% % range(2,:) = [min(sampling.y) max(sampling.y)];
% % range(3,:) = [min(sampling.z) max(sampling.z)];
% 
% factor = 1.2;
% range = [-maxVal maxVal] * factor;
% 
% xlim(range);
% ylim(range);
% zlim(range);

colorbar;

axis vis3d
view(3);
rotate3d;
daspect([1 1 1]);
xlabel('x');
ylabel('y');
zlabel('z');
grid on
hold off