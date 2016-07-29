function ita_sph_plot_coefs_db(coefs, dynamic)

% plots the SH coefficient triangle with a given dynamic

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

if nargin < 2
    dynamic = 100;
end

coefs_db = 20*log10(abs(coefs));
maxdB = max(coefs_db(:));
isInf = coefs_db == -Inf;
coefs_db_dyn = max(0,coefs_db - maxdB + dynamic);
coefs_db_dyn(isInf) = nan;
ita_sph_plot_coefs(coefs_db_dyn);
caxis([0 dynamic]);
title(['SH coefs plotted logarithmic with a dynamic of ' num2str(dynamic) 'dB']);
