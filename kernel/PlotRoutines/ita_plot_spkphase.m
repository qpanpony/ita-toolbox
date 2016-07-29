function varargout = ita_plot_spkphase(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

ita_verbose_obsolete('please use ita_plot_freq_phase instead');
varargout = {ita_plot_freq_phase(varargin{:})};
if ~nargout, clear varargout, end
end