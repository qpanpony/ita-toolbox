function varargout = ita_plot_freq_phase(varargin)
%ITA_PLOT_FREQ_PHASE - Plot spectrum amplitude and phase
%  This function plots the spectrum and the phase in a two subwindow plot.
%  According to the options, one can select a part of the plot('axis'), or 
%  the aspectratio of the axis ('aspectratio') -> see Options for more
%  details.
%
%  Syntax: fgh = ita_plot_freq_phase(data_struct)
%  Syntax: fgh = ita_plot_freq_phase(data_struct,'Option',value)
%  Syntax: fgh = ita_plot_freq_phase(data_struct,'figure_handle',ref,'nodB')
%
%  Options: (standard: -> )
%   'precise' ('on'|->'off') : Plots all data, no decimation
%   'unwrap' ('on'|->'off')  : Unwraps phase
%   'figure_hadle' ([])      : Sets the figure_handle
%   'xlim' ([])              : Sets the limits for the x axis
%   'ylim' ([])              : Sets the limits for the y axis
%   'axis' ([])              : Sets the limts for both axis
%   'aspectratio' ([])       : Sets the ratio of the axis
%   'hold' ('on'|->'off')    : Sets hold
%
%  Examples:
%  Two plots in one figure using hold
%  [fig axes] = ita_plot_freq_phase(ita_Audio_1);
%  ita_plot_freq_phase(ita_Audio_2,'hold','on','figure_handle',fig,'axes_handle',axes);
%
%  ita_plot_freq_phase(data_struct,'axis',[20 100 -60 -40]) plots in both windows 
%  on the X axis from 20 to 100 and on the Y axis from -60 to -40
%
%  ita_plot_freq_phase(data_struct,'aspectratio',0.5) Sets the ratio of the 
%  axis Y and X to 0.5
%
%  Syntax: ita_plot_freq_phase(itaAudio)
%
%  Options:
%       precise (false) - plot all data, no decimation
%       unwrap (false) - unwrap phase
%
%   See also ita_plot_freq_groupdelay, ita_plot_freq, ita_plot_time, ita_plot_time_dB, ita_plot_freq.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_freq_phase">doc ita_plot_freq_phase</a>
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  23-Jun-2008
%% Get Function String
thisFuncStr  = [upper(mfilename) ':']; %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %#ok<NASGU> %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',true,'unwrap',false,'wrapTo360',false,'figure_handle',[],'axes_handle',[],'linfreq','off','linewidth',ita_preferences('linewidth'),...
    'fontname',ita_preferences('fontname'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false,'plotargs',[]);
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

[fgh,axh2] = ita_plot_phase(varargin{:},'figure_handle',fgh,'axes_handle',axh2); 
title(''); % pdi: avoid title here

%pdi - linkaxes
linkaxes([axh1 axh2],'x');

setappdata(fgh,'AxisHandles',[axh1 axh2]);
setappdata(fgh,'ActiveAxis',axh1);
setappdata(fgh,'ita_domain', 'frequency and phase');
%% Make first axis current
%axes(axh1); hbr - produce error on 2016b
set(fgh,'CurrentAxes',axh1)
%% Return the figure handle
if nargout
    varargout{1} = fgh;
    varargout{2} = [axh1 axh2];
end
end