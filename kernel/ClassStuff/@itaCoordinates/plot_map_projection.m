function varargout = plot_map_projection(this, varargin)
%PLOT_MAP_PROJECTION - Plot a map projection of data on a sphere
%  This function plots a map projection for a dataset on a full or 
%  partial spherical surface. The x-axis is at latitude = 0 and 
%  longitude = 0 and points into the map. The longitude angle is defined as
%  counter clockwise. The y-axis is defined as latitude = 0 and 
%  longitude = pi/2. The positive z-axis is defined as latitude = pi.
%
%  Syntax:
%   plot_map_projection(this, data, options)
%
%   Options (default):
%           'proj' ('wagner4')   : Specifies the projection type (See mapping toolbox documentation for supported projections)
%           'shading' ('interp') : Specifies the shading algorithm
%           'db' (false)         : db plot
%           'limits' ([])        : Colorbar limits
%
%  Example:
%   plot_map_projection(this, data, 'db', 'limits', [-50, 0])
%
%  See also:
%   itaCoordinates, ita_sph_sampling, surf, scatter
%
%   Reference page in Help browser 
%        <a href="matlab:doc plot_map_projection">doc plot_map_projection</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  06-Jun-2017 

sArgs = struct('pos1_data','double',...
               'proj','wagner4',...
               'db',false,...
               'shading','interp',...
               'limits',[],...
               'fgh',[],...
			   'colormap',[]);
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

% convert to longitude, latitude coordinates required by the mapping toolbox
[azi,ele,~] = cart2sph(this.x,this.y,this.z);
lat = ele*180/pi;
% x = 1 is the origin of the map at lat = 0, lon = 0
% flip sign of the azimuth to define the x-axis as pointing into the map
lon = -(azi)*180/pi;
% longitude, latitude limits for the plot
latLim = [min(lat),max(lat)];
lonLim = [min(lon),max(lon)];

if isempty(sArgs.fgh)
    sArgs.fgh = figure();
end
% project sampling coordinates
mstruct = defaultm(sArgs.proj);
mstruct.origin = [0,0];
mstruct = defaultm(mstruct);
mstruct.maplonlimit = lonLim;
mstruct.maplatlimit = latLim;
mstruct.flinewidth = 1;
mstruct.flatlimit = latLim;
mstruct.flonlimit = lonLim;
[x,y] = mfwdtran(mstruct,lat,lon);

LatTicks = 0:30:latLim(2);
LatTicks = [-fliplr(30:30:abs(latLim(1))),LatTicks(1:end)];
LonTicks = 0:50:lonLim(2);
LonTicks = [-fliplr(50:50:abs(lonLim(1))),LonTicks(1:end)];

[latTicks,lonTicks] = meshgrid(latLim(1),LonTicks);
[XTicks,~] = mfwdtran(mstruct,latTicks,lonTicks);
[latTicks,lonTicks] = meshgrid(LatTicks,lonLim(2));
[~,YTicks] = mfwdtran(mstruct,latTicks,lonTicks);


% calculate delaunay triangulation for the meshgrid
tri = delaunay(x,y);
if sArgs.db
    data = 20*log10(abs(data));
else
    data = abs(data);
end
trisurf(tri,x,y,data);

cb = colorbar;
cb.Label.String = 'Magnitude';
if ~isempty(sArgs.limits)
    caxis(sArgs.limits);
end


% use custom colormap if given
if ~isempty(sArgs.colormap)
	colormap(sArgs.fgh,sArgs.colormap);
end
% set shading, will be set to interpolate by default
shading(sArgs.shading);

% change view to top view
view([0,90])

% create axes corresponding to the chosen map projection
axh = axesm(sArgs.proj, ...
            'MapLatLim', latLim, ...
            'MapLonLim', lonLim, ...
            'Grid','on', ...
            'Frame','on', ...
            'LabelFormat','none', ...
            'PLineLocation',30, ...
            'MLineLocation',50, ...
            'Origin',[0,0]);
axh.YLim = latLim * pi/180;
axh.XLim = lonLim * pi/180;

% set ticks
axh.YTick = YTicks;
axh.YTickLabels = LatTicks;
axh.XTick = XTicks;
% flip sign again, since x-axis points into the map
axh.XTickLabels = -LonTicks;

axh.YTickLabel = strcat(axh.YTickLabel, '^\circ');
axh.XTickLabel = strcat(axh.XTickLabel, '^\circ');

% set labels for x- and y-axes
axh.YLabel.String = 'Latitude';
axh.XLabel.String = 'Longitude';

if nargout
	varargout{1} = sArgs.fgh;
end

%end function
end