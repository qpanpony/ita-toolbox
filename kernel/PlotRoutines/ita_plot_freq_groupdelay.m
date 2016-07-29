function varargout = ita_plot_freq_groupdelay(varargin)
%ITA_PLOT_FREQ_GROUPDELAY - Plot spectrum and group delay
%  This function plots the spectrum and the group delay in a two window
%  plot. According to the options, one can select a part of the
%  plot('axis') or the aspectratio of the axis ('aspectratio') -> see
%  Options for more details.
%
%  Call: fgh = ita_plot_freq_groupdelay(data_struct)
%  Call: fgh = ita_plot_freq_groupdelay(data_struct,'Option',value)
%
%  Options: (standard: -> )
%   'figure_hadle' ([]) :        Sets the figure_handle
%   'xlim' ([]) :                Sets the limits for the x axis
%   'ylim' ([]) :                Sets the limits for the y axis
%   'axis' ([]) :                Sets the limts for both axis
%   'aspectratio' ([]) :         Sets the ratio of the axis
%
%  Examples:
%  ita_plot_freq_groupdelay(data_struct,'figure_handle',1) plots in figure 1 
%  using hold on 
%
%  ita_plot_freq_groupdelay(data_struct,'axis',[20 2000 -35 -25]) plots only from 
%  20 to 2000 on the X axis and form -35 to -25 on the Y axis
%
%  ita_plot_freq_groupdelay(data_struct,'aspectratio',0.5) Sets the ratio of the 
%  axis Y and X to 0.5
%
%   See also ita_plot, ita_plot_freq, ita_plot_dat, ita_plot_sph.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_freq_groupdelay">doc ita_plot_freq_groupdelay</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  03-Jul-2008

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %#ok<NASGU> %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',true,'unwrap',false,'figure_handle',[],'axes_handle',[],'linfreq','off','linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false,'normalize',false);
[data, sArgs] = ita_parse_arguments(sArgs, varargin); 

if numel(data) > 1
    ita_verbose_info([thisFuncStr 'There is more than one instance stored in that object. Plotting the first one only.'],0);
    varargin{1} = data(1);
end

% set default if the linewidth is not set correct
if isempty(sArgs.linewidth) || ~isnumeric(sArgs.linewidth) || ~isfinite(sArgs.linewidth)
    sArgs.linewidth = 1;
end

%% Figure and axis handle
if ~isempty(sArgs.figure_handle) && ishandle(sArgs.figure_handle)
    fgh = sArgs.figure_handle;
    figure(fgh);
    if ~sArgs.hold
        hold off;
    else
        hold on;
    end
else
    fgh = ita_plottools_figure;
end
setappdata(fgh,'ita_domain', 'frequency and group delay'); 

%% Plotting of Modulus
if isempty(sArgs.axes_handle) || ~ishandle(sArgs.axes_handle(1))
    axh1 = subplot(2,1,1);
else
    axh1 = sArgs.axes_handle(1);
    axes(sArgs.axes_handle(1)); 
end

[fgh,axh1] = ita_plot_freq(varargin{:},'figure_handle',fgh,'axes_handle',axh1);
xlabel(''); % pdi: avoid frequency label here

%% Plotting of Phase
if isempty(sArgs.axes_handle) || ~ishandle(sArgs.axes_handle(2))
    axh2 = subplot(2,1,2);
else
    axh2 = sArgs.axes_handle(2);
    axes(axh2); 
    if ~sArgs.hold
        hold off;
    else
        hold on;
    end
end

[fgh,axh2] = ita_plot_groupdelay(varargin{:},'figure_handle',fgh,'axes_handle',axh2);
title(''); % pdi: avoid title here

%pdi - linkaxes
linkaxes([axh1 axh2],'x');

setappdata(fgh,'AxisHandles',[axh1 axh2]);
setappdata(fgh,'ActiveAxis',axh1);
setappdata(fgh,'ita_domain', 'frequency and group delay');

%% Make first axis current
axes(axh1);  

%% Return the figure handle
if nargout == 1
    varargout{1} = {fgh};
elseif nargout == 2
    varargout{1} = {fgh};
    varargout{2} = [axh1 axh2];
end