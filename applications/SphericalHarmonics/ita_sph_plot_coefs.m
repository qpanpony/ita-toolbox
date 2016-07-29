function ita_sph_plot_coefs(coefs)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% check if it is a row vector
sizeCoefs = size(coefs);
if sizeCoefs(1) == 1 && sizeCoefs(2) > 1
    coefs = coefs.';
end

numelCoefs = size(coefs,1);
nmax = sqrt(numelCoefs)-1;

% add one line and row to get complete plot
plotdata = nan(nmax+2,2*nmax+2);

[n,m] = ita_sph_linear2degreeorder(1:numelCoefs);

for ind = 1:numelCoefs
    plotdata(n(ind)+1, m(ind)+nmax+1) = coefs(ind);
end

h = pcolor(abs(plotdata));
set(h, 'EdgeAlpha', 0.1);

x = m(nmax^2+1:end);
y = 0:nmax;

delta = floor(log2(length(y))); if delta == 0; delta = 1; end

aux = 1;
for idx = 1:delta:length(y)
    yaxis(aux) = y(idx)+1.5;
    yaxislabel(aux) = y(idx);
    aux = aux + 1;
end

% for 2:length(yaxislabel)
xaxislabel = [-yaxislabel(end:-1:2) yaxislabel];

for idx = 1:length(xaxislabel)
    xaxis(idx) = find(x == xaxislabel(idx)) + .5;
end

xaxislabel = num2cell(xaxislabel,1);
yaxislabel = num2cell(yaxislabel,1);

set(gca,...
    'YDir','reverse',...
    'YTickLabel',yaxislabel,...
    'YTick',yaxis,...
    'XTickLabel',xaxislabel,...
    'XTick',xaxis);
colormap jet
xlabel('Degree');
ylabel('Order');
title('SH coefs');