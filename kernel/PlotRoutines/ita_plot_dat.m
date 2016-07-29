function varargout = ita_plot_dat(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

ita_verbose_obsolete('please use ita_plot_time instead');
varargout = {ita_plot_time(varargin{:})};
if ~nargout, clear varargout, end
end