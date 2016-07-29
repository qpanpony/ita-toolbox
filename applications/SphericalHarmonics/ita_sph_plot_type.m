function [magn, color, colorMap] = ita_sph_plot_type(data, type)
% internal function, not to be called seperately

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


switch lower(type)
    case 'complex'
        magn = abs(data);
        color = mod(angle(data),2*pi);
        colorMap = 'hsv';
    case 'sphere'
        magn = ones(size(data));
        color = abs(data);
        colorMap = 'jet';
    case 'spherephase'
        magn = ones(size(data));
        color = mod(angle(data),2*pi);
        colorMap = 'hsv';
    case 'magnitude'
        magn = abs(data);
        color = magn;
        colorMap = 'jet';
    case 'db'
        % put the maximum level to a fixed value
        magn = 20*log10(abs(data));
        magn = magn - max(magn) + 50;
        magn = max(magn,0);
        color = magn;
        colorMap = 'jet';        
    otherwise
        error('give a valid type (complex / sphere / spherephase / magnitude / db)')
end
