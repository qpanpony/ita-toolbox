function varargout = ita_plot_time_dB(varargin)
%ITA_PLOT_TIME_DB - Plot energy over time
%  This function plots the the time signal in log Y scale.
%  For syntax and possible options please see the help for ITA_PLOT_TIME.
%
%
%  Examples:
%  ita_plot_time_dB(data_struct,'figure_handle',1) plots in figure 1 using
%  hold on
%
%  ita_plot_time_dB(data_struct,'axis',[0 0.1 -20 -10]) plots only from
%  0 to 0.1 on the X axis and form 0 to 0.3 on the log(Y) axis
%
%  ita_plot_time_dB(data_struct,'aspectratio',0.5) Sets the ratio of the
%  axis log(Y) and X to 0.5
%
%   See also ita_plot_time, ita_plot_freq, ita_read, ita_write.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_time_dB">doc ita_plot_time_dB</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  01-May-2005


%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %set ita toolbox preferences and get the matlab default settings
[fgh,axh] = ita_plot_time(varargin{:},'nodb',false);


%% Return the figure handle
if nargout
    varargout(1) = {fgh};
    varargout(2) = {axh};
end

ita_restore_matlab_default_plot_preferences(matlabdefaults) % restore matlab default settings