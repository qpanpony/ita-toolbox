function plot_toblerone(this, freq, dynamic)
% y is freq axis

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if nargin < 3
    dynamic = 120;
    ita_verbose_info('using default dynamic');
end

f = this.freqVector.';

data = 20.*log10(abs(this.freq));
maxData = max(data(:));

isBelow = data < (maxData - dynamic);
data(isBelow) = -inf;

% data = max(maxData - dynamic, data);
% limited to the dynamic range

mat = ita_sph_vector2matrix(data.','nan');

nmax = (size(mat,2) - 1)./2;
m = -nmax:nmax;
n = nmax:-1:0;

[x,y,z] = meshgrid(m,f,n);
z = z - nmax;

xslice = []; yslice = freq; zslice = [];

mat = permute(mat,[3 2 1]);

% maxVal = max(mat(:));
% minVal = maxVal * 10^(-dynamic/20);
% mat(mat<minVal) = nan;

h = slice(x,y,z,mat,xslice,yslice,zslice);

for ih = 1:numel(h)
    set(h(ih),'FaceAlpha',0.8,'EdgeAlpha',0);
end

shading interp
fV = this.freqVector;
ylim(fV([1 end]));

caxis
colormap(flipud(hot))
colormap jet
colorbar
end