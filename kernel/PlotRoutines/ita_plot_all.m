function varargout = ita_plot_all(varargin)
%ITA_PLOT_ALL - multi-plot of the input object
%  This function plots time, time in dB, spectrogram, freq, phase and groupdelay
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


%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %#ok<NASGU> %set ita toolbox preferences and get the matlab default settings

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',false,'unwrap',false,'figure_handle',[],'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'),'fontsize',ita_preferences('fontsize'),'aspectratio',[],'hold','off','precise',true,'ylog',false);
[data, sArgs] = ita_parse_arguments(sArgs, varargin);

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


nx = 3; ny = 2;
%% time
handles(1) = subplot(ny,nx,1);
ita_plot_time(varargin{:},'figure_handle',fgh,'axes_handle',handles(1));
legend off;

%% frequency
handles(2) = subplot(ny,nx,4);
ita_plot_freq(varargin{:},'figure_handle',fgh,'axes_handle',handles(2));
legend off;

%% time in dB
handles(3) = subplot(ny,nx,2);
ita_plot_time_dB(varargin{:},'figure_handle',fgh,'axes_handle',handles(3));
legend off;

%% phase
handles(4) = subplot(ny,nx,5);
ita_plot_phase(varargin{:},'figure_handle',fgh,'axes_handle',handles(4));
legend off;

%% spectrogram
handles(5) = subplot(ny,nx,3);
ita_plot_spectrogram(varargin{:},'figure_handle',fgh,'axes_handle',handles(5)); 
title(data.comment);
legend off;

%% groupdelay
handles(6) = subplot(ny,nx,6);
ita_plot_groupdelay(varargin{:},'figure_handle',fgh,'axes_handle',handles(6));
legend off;

%% Figure stuff
setappdata(fgh,'Title',[]);
setappdata(fgh,'ChannelNames',data.channelNames);
setappdata(fgh,'Filename',data.fileName);
setappdata(fgh,'AxisHandles',handles);
setappdata(fgh,'ActiveAxis',handles(1));
setappdata(fgh,'ita_domain', 'all');
ita_plottools_cursors('on',[],handles(1))
ita_plottools_cursors('off')

%% Return the figure handle
if nargout
    varargout{1} = fgh;
end
end