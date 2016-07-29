function ita_sph_plot_coefs_over_freq(coefs, freq, varargin)
% function ita_sph_plot_coefs_over_freq(coefs, freq, varargin)
% creates a contour plot:
% -  y-axis: order of spherical harmonic coefficient
% -  x-axis: frequency (freq)
% -  color : absolute value of coefficients [dB(default) / linear]
%
% options:
% - unit : 'dB'(default) / 'linear'
% - 'type' : 'mean'     : energetic average of all coefficients of same order
%            'max'      : maximum value of coefficients of same order
%            'min'      : minimum value of coefficients of same order
%            'none'     : every single coefficient will be plotted
%    all the coefficients of same order.
%
% Martin Kunkemöller, 09.02.2011

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% initialize
sArgs = struct('unit','dB','type','mean');
if nargin > 2
    sArgs = ita_parse_arguments(sArgs, varargin);
end

coefs = squeeze(coefs);

if size(coefs, 1) == length(freq)
    coefs = coefs.';
end
if size(coefs, 2) ~= length(freq)
    error('size of coefs and frequency vector does not match');
end

nmax = sqrt(size(coefs,1))-1;
if mod(nmax,1)
    error('size of coefs does is no good');
end


%% proceed
val = zeros(nmax+1, length(freq));
if strcmpi(sArgs.type, 'mean')
    for idxN = 0:nmax
        val(idxN+1,:) = sqrt(mean(abs(coefs(ita_sph_degreeorder2linear(idxN,-idxN:idxN),:)).^2,1));
    end
elseif strcmpi(sArgs.type, 'max')
    for idxN = 0:nmax
        val(idxN+1,:) = max(abs(coefs(ita_sph_degreeorder2linear(idxN,-idxN:idxN), :)).^2,[],1);
    end
elseif strcmpi(sArgs.type, 'min')
    for idxN = 0:nmax
        val(idxN+1,:) = min(abs(coefs(ita_sph_degreeorder2linear(idxN,-idxN:idxN), :)).^2,[],1);
    end
elseif strcmpi(sArgs.type, 'none')    
    val = abs(coefs);
else
    error('unknown type');
end

if strcmpi(sArgs.unit, 'db')
    val = 20*log10(val/max(max(val)));
    unit = ' dB';
    ca = [-80 0];
else
    unit = ' linear';
    ca = [1e-4 1]*max(max(val));
end

%% plot
val = val(end:-1:1,:);
imagesc(1:length(freq), 1:size(val,1), val);



if ~strcmpi(sArgs.type, 'none')
    ystep = 2;
    ytick = nmax:-ystep:0;
    set(gca,'ytick',(nmax+1)-ytick, 'yticklabel',int2str(ytick'));
else
    lNmax = (nmax+1)^2;
    ystep = round(lNmax/20);
    ytick = lNmax:-ystep:0;
    set(gca,'ytick',(lNmax+1)-ytick, 'yticklabel',int2str(ytick'));
end
xstep = 2;    
xtick = 1:xstep:length(freq);
set(gca,'xtick', xtick, 'xTickLabel',int2str(freq(xtick).'));


title(['coefficients over frequency (absolute, ' unit ')  averaging: ' sArgs.type]);
xlabel('Frequency in Hz');
if ~strcmpi(sArgs.type, 'none')
    ylabel('Order of Spherical Harmonics');
else
    ylabel('Linear Order of Spherical Harmonics');
end

colorbar; caxis(ca);