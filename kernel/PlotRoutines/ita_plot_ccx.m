function varargout = ita_plot_ccx(varargin)
%ITA_PLOT_CCX - multi-plot of the input object
%  This function plots time, freq, phase
%
%  Syntax:
%   audioObjOut = ita_plot_all(audioObjIn, options)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_all">doc ita_plot_all</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  25-Apr-2010

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %#ok<NASGU> %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',false,'unwrap',false,'figure_handle',[],'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'),'fontsize',ita_preferences('fontsize'),'aspectratio',[],'hold','off','precise',true,'ylog',false);
[data sArgs] = ita_parse_arguments(sArgs, varargin);

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


nx = 2; ny = 2;
idx = 0;

%% time
idx = idx + 1;
axh = subplot(ny,nx,idx);
[fgh handles(idx)] = ita_plot_time(varargin{:},'figure_handle',fgh,'axes_handle',axh);
legend off;

%% frequency
idx = idx + 1;
axh = subplot(ny,nx,idx);
[fgh handles(idx)] = ita_plot_freq(varargin{:},'figure_handle',fgh,'axes_handle',axh);
legend off;


%% time
idx = idx + 1;
axh = subplot(ny,nx,idx);
[fgh handles(idx)] = ita_plot_time_dB(varargin{:},'figure_handle',fgh,'axes_handle',axh);
legend off;
linkaxes(handles([1, 3]),'x');


%% phase
idx = idx + 1;
axh = subplot(ny,nx,idx);
[fgh handles(idx)] = ita_plot_phase(varargin{:},'figure_handle',fgh,'axes_handle',axh);
legend off;
linkaxes(handles([2, 4]),'x');


%% Figure stuff
setappdata(fgh,'Title',[]);
setappdata(fgh,'ChannelNames',data.channelNames);
setappdata(fgh,'Filename',data.fileName);
setappdata(fgh,'AxisHandles',handles);
setappdata(fgh,'ActiveAxis',handles(1));

ita_plottools_cursors('on',[],handles(1))
ita_plottools_cursors('off')

%% Return the figure handle
if nargout
    varargout{1} = fgh;
end
end