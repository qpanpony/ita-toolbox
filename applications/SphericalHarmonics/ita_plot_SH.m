function ita_plot_SH(coefs, sampling, varargin)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

global sPlotPoints;

if nargin == 0, error; end;
if nargin > 1
    % check if is a plot grid
    if ~isa(sampling,'itaCoordinates')
        varargin = [{sampling} varargin];
    else
        sPlotPoints = sampling;
    end
end

% create sampling for plot if necessary
if isempty(sPlotPoints)
    sPlotPoints = ita_sph_sampling_equiangular(31);
end

paraStruct = ita_sph_plot_parser(varargin);
% plottype = paraStruct.type;

% convert to given spatial grid
data = ita_sph_ISHT(coefs, sPlotPoints);

% call spatial plot function
[hFig, hSurf] = ita_sph_plot_spatial(data, sPlotPoints, varargin{:});

% now check if to plot dots also
colorSize = size(paraStruct.dotColor);
if colorSize(2) ~= 3
    % there must be color dots given
    % so plot them on the sphere
    radiusBalloon = abs(ita_sph_functionvalue(coefs, paraStruct.dotSampling));
    if strcmpi(paraStruct.type,'dB')
        radiusBalloon = 20*log10(radiusBalloon);
    end
    % now set the radii
    dotSampling_modifiedR = itaSamplingSph(paraStruct.dotSampling);
    dotSampling_modifiedR.r = radiusBalloon;
    
    [magn, color, colorMap] = ita_sph_plot_type(paraStruct.dotColor, paraStruct.type);
    
    % set caxis
    cminmax = caxis;
    cmin = cminmax(1);
    cmax = cminmax(2);
    cmin = min(cmin, min(color));
    cmax = max(cmax, max(color));
    
    ita_plot_dots(dotSampling_modifiedR, 'dotColor', color,'caxis', [cmin cmax]);
end
    
