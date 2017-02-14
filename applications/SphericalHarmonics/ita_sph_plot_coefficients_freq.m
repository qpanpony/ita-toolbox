function varargout = ita_sph_plot_coefficients_freq(varargin)
%ITA_SPH_PLOT_COEFFICIENTS_FREQ - Plot SH coefficients over frequency
%  This function plot the spherical harmonic coefficients (y-axis) over frequency (x-axis).
%  The frequency information can either be given as a vector containing all frequencies 
%  or the first and last frequency to be plotted.
%  The dynamic range of the colorbar can be limited using the limits option following a 
%  1x2 array containing the corresponding lower and upper limits.
%
%  Syntax:
%   ita_sph_plot_coefficients_freq(data, options)
%
%   Options (default):
%           'freq' ([])				: frequency axis information
%           'kr' ([])				: give a kr vector instead of a freq vector
%           'db' (true)				: logarithmic color scaling
%           'limits' ([])			: dynamic range of the color scaling
%           'shading' ('interp')	: shading algorithm
%           'stepSize' (1)			: step size for the sh order
%           'coefficients' ('nm')	: choose whether to plot all degrees, only degree 0 ('n-n0') or
%									  the sum of all degrees for all order respectively ('n-nm')
%
%  Example:
%   audioObjOut = ita_sph_plot_coefficients_freq(data,'freq',freqVector,'limits',[-80,0])
%
%  See also:
%   ita_plot_freq, ita_sph_sampling, ita_sph_base, ita_sph_modal_strength
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_plot_coefficients_freq">doc ita_sph_plot_coefficients_freq</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  13-Jan-2017 


%% Initialization and Input Parsing
sArgs = struct('pos1_data','double', ...
               'freq',[],...
               'kr',[],...
               'db',true,...
               'limits',[],...
               'shading','interp',...
               'stepSize',1,...
			   'coefficients','nm');
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

if ~isempty(sArgs.freq) && ~isempty(sArgs.kr)
    ita_verbose_info('You cannot choose kr and freqency x-axis at the same time');
    return;
end

% number of coefficients and SH order
nCoeff = size(data,1);
Nmax = floor(sqrt(nCoeff)-1);

if ~isempty(sArgs.freq)
    if numel(sArgs.freq > 2)
        freqVec = sArgs.freq;
    else
        freqVec = linspace(sArgs.freq(1),sArgs.freq(end),size(data,2));
    end
elseif ~isempty(sArgs.kr)
    freqVec = linspace(sArgs.kr(1),sArgs.kr(2),size(data,2));
else
    freqVec = 1:size(data,2);
end

fgh = figure;

% preprocess spherical harmonic degrees
if strcmp(sArgs.coefficients,'nm')
	% do nothing
elseif strcmp(sArgs.coefficients,'n-n0')
	data = ita_sph_eye(Nmax,sArgs.coefficients) * data;
elseif strcmp(sArgs.coefficients,'n-nm')
	data = ita_sph_eye(Nmax,sArgs.coefficients) * abs(data);
end

% plot the actual data
y = 1:size(data,1);
if sArgs.db
    pcolor(freqVec,y,20*log10(abs(data)));
else
    pcolor(freqVec,y,(abs(data)));
end

% set shading method
shading(sArgs.shading);

cb = colorbar;
if sArgs.db
	cb.Label.String = 'Magnitude dB';
else
	cb.Label.String = 'Magnitude';
end

% if freqency vector is given, use logarithmic freq axis
if ~isempty(sArgs.freq)
    axh = gca;
    axh.Layer = 'top';
    axh.XScale = 'log';
    axh.XGrid = 'on';
    [XTickVec_log, XTickLabel_val_log] = ita_plottools_ticks('log');
    axh.XTick = XTickVec_log;
    axh.XTickLabel = XTickLabel_val_log;
end

% create labels for sh order
grid on
if strcmp(sArgs.coefficients,'nm')
	coeffVec = zeros(1,floor((Nmax+1)/sArgs.stepSize));
	orderVec = zeros(1,floor((Nmax+1)/sArgs.stepSize));
	idxSave=1;
	for idx=0:sArgs.stepSize:Nmax
		coeffVec(idxSave) = (idx+1)^2;
		orderVec(idxSave) = idx;
		idxSave=idxSave+1;
	end
else
	orderVec = 0:sArgs.stepSize:Nmax;
	coeffVec = orderVec;
end
axh.YTick = coeffVec+1;
axh.YTickLabel = orderVec;

axh.GridAlpha = .3;
axh.LineWidth = 1;
axh.XColor = 'k';
axh.YColor = 'k';

if ~isempty(sArgs.limits)
    caxis(sArgs.limits);
end

% X and Y labels
axh.YLabel.String = 'SH-Order';
axh.XLabel.String = 'Frequency in Hz';

% return figure and axis handle if wanted
if nargout > 1
    varargout{1} = fgh;
    if nargout > 2
        varargout{2} = axh;
    end
end

%end function
end
