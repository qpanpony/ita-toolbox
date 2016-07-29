function varargout = ita_plot_cmplx(varargin)
%ITA_PLOT_CMPLX - Complex plot
%  This function plots the real and imaginary part of itaAudio objects in
%  the frequency domain.
%
%  Call: fgh = ita_plot_cmplx(data_struct)
%  Call: fgh = ita_plot_cmplx(data_struct,'Option',value)
%  Call: fgh = ita_plot_cmplx(data_struct,'figure_handle',ref,'nodB')
%
%  Options: (standard: -> )
%   'precise'('on'|->'off')      Plots all data, no decimation
%   'figure_handle' ([]) :       Sets the figure_handle
%   'xlim' ([]) :                Sets the limits for the x axis
%   'ylim' ([]) :                Sets the limits for the y axis
%   'axis' ([]) :                Sets the limts for both axis
%   'aspectratio' ([]) :         Sets the ratio of the axis
%   'nodB' (true) :              nodB option
%
%  Examples:
%  Two plots in one figure using hold
%  [fig axes] = ita_plot_cmplx(ita_audio_1);
%  ita_plot_cmplx(test_strukt,'hold','on','figure_handle',fig,'axes_handle',axes);
%
%  ita_plot_cmplx(data_struct,'axis',[20 100 -60 -40]) plots in both windows
%  on the X axis from 20 to 100 and on the Y axis from -60 to -40
%
%  ita_plot_cmplx(data_struct,'aspectratio',0.5) Sets the ratio of the
%  axis Y and X to 0.5
%
%  Call: ita_plot_cmplx(itaAudio)
%
%   See also: ita_plot, ita_plot_freq, ita_plot_freq_phase
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_cmplx">doc ita_plot_cmplx</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Johannes Klein -- Email: johannes.klein@akustik.rwth-aachen.de
% Created:  11-Jun-2009

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %#ok<NASGU> %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',true,'unwrap',false,'figure_handle',[],'axes_handle',[],'linfreq','off',...
    'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'),'fontsize',ita_preferences('fontsize'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false);
[data, sArgs] = ita_parse_arguments(sArgs, varargin); 

% set default if the linewidth is not set correct
if isempty(sArgs.linewidth) || ~isnumeric(sArgs.linewidth) || ~isfinite(sArgs.linewidth)
    sArgs.linewidth = 1;
end

%% Plotting of multi-instances
if numel(data) > 1
    fgh = ita_plot_cmplx(data(1), varargin{2:end});
    for idx = 2:numel(data)
        ita_plot_cmplx(data(idx), varargin{2:end},'figure_handle',fgh,'hold','on');
    end
    return;
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


%% Plotting of Real Part
if isempty(sArgs.axes_handle) || ~ishandle(sArgs.axes_handle(1))
    axh1 = subplot(2,1,1);
else
    axh1 = sArgs.axes_handle(1);
    axes(sArgs.axes_handle(1));
end

tmp = varargin{1};
varargin{1} = ita_real(tmp);
[fgh,axh1] = ita_plot_freq(varargin{:},'figure_handle',fgh,'axes_handle',axh1);

% MAR: If the comment in the itaAudio is a an array of chars with '\n' in
%      it, then get(get(axh1,'Title'),'String') returns an array with
%      multiple rows. this produces a error when the title is reset. 
%      Therefore we only consider the first line of the comment. 
newTitle = get(get(axh1,'Title'),'String');
if ~isempty(newTitle)
    newTitle = newTitle(1,:);
end
set(get(axh1,'Title'),'String',['Real Part - ' newTitle ]);

%% Plotting of Imaginary Part
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

varargin{1} = ita_imag(tmp);
[fgh,axh2] = ita_plot_freq(varargin{:},'figure_handle',fgh,'axes_handle',axh2);

newTitle = get(get(axh2,'Title'),'String');
if ~isempty(newTitle)
    newTitle = newTitle(1,:);
end
set(get(axh2,'Title'),'String',['Imaginary Part - ' newTitle]);

%pdi - linkaxes
linkaxes([axh1 axh2],'x');

setappdata(fgh,'AxisHandles',[axh1 axh2]);
setappdata(fgh,'ActiveAxis',axh1);
setappdata(fgh,'ita_domain', 'real and imaginary part');
setappdata(fgh,'audioObj',tmp);
%% Make first axis current
axes(axh1);

%% Return the figure handle
if nargout
    varargout{1} = fgh;
    varargout{2} = [axh1 axh2];
end
end