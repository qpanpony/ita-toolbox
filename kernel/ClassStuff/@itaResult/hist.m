function varargout = hist(varargin)
% overloaded histogram plot routine for time itaResults

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

sIn = struct('pos1_input','itaResult','nodb',true,'figure_handle',[],'axes_handle',[],'linfreq','off','linewidth',ita_preferences('linewidth'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','ylog',false);
[input sArgs] = ita_parse_arguments(sIn, varargin);

if isFreq(input)
   error('itaResult.hist:this is a time plot function, use bar() instead'); 
end
dat = input.timeData;
if sArgs.ylog
    sArgs.nodb = 1;
end
%% cut down on the amount of data
time_vector = input.timeVector;
if input.nSamples > 2500 && ~sArgs.precise
    decimation_factor = ceil(data.nSamples ./100);
    ita_verbose_info('itaResult.hist:Oh Lord. A lot of data, I will do some decimation first.',0);
    dat = dat(1:decimation_factor:end,:);
    time_vector = time_vector(1:decimation_factor:end);
end

%% 20 uPa Support
if ~sArgs.nodb
    [p_0,P_0] = ita_constants({'p_0','P_0'});
    dat(:,strcmp(input.channelUnits,'Pa')) = dat(:,strcmp(input.channelUnits,'Pa'))./p_0.value;
    dat(:,strcmp(input.channelUnits,'W')) = dat(:,strcmp(input.channelUnits,'W'))./P_0.value;
    dat = 10 .* log10(abs(dat));
    if any(~ismember(input.channelUnits,{'W','Pa^2','kg/(s m^2)'}))
        dat(:,~ismember(input.channelUnits,{'W','Pa^2','kg/(s m^2)'})) = 2.*dat(:,~ismember(input.channelUnits,{'W','Pa^2','kg/(s m^2)'}));
    end
    if any(ismember(input.channelUnits,{'W','Pa^2','kg/(s m^2)'})) % power in dB
        ita_verbose_info('itaResult.bar:10 .* log10 (input) plotting is used',1);
    end
    input.channelUnits(strcmp(input.channelUnits,'Pa')) = {'20u Pa'};
    input.channelUnits(strcmp(input.channelUnits,'W')) = {'1p W'};
    maxDat = max(dat(:));
    dat(abs(dat-maxDat)<-100) = maxDat-100;
    minDat = min(dat(:));
    dat = dat-minDat;
else
    abs_min = min(min(dat));
    abs_max = max(max(dat));
    if abs_max == 0; %only zeros
        abs_max = 0.01;
    end
    abs_max = max(abs(abs_min),abs(abs_max)); %make symmetric limits
    abs_max = 2.^ceil (log2(double(abs_max*1.01))); % a little bit more than the signal
    abs_min = -abs_max;
end
%% Start Plotting
old_figure_mode = false;
if ~isempty(sArgs.figure_handle)
    fgh = sArgs.figure_handle;
    figure(fgh);
    old_figure_mode = true;
else
    fgh = ita_plottools_figure();
end

resize_axes = false;
if isempty(sArgs.axes_handle)
    resize_axes = true;
    sArgs.axes_handle = axes();
end

lnh = bar(sArgs.axes_handle,time_vector(:),dat,'histc');

if ~sArgs.nodb
    titleStr = ['Time Domain (dB) - ' input.comment];
else
    titleStr = ['Time Domain - ' input.comment];
end

axh = gca;
if resize_axes
    set(axh,'Units','normalized', 'OuterPosition', [-.05 0 1.1 1]); %pdi new scaling
end

%% Axis Labeling and Properties
xlabel('Time in seconds')
xlim([time_vector(1), time_vector(end)]);

if sArgs.nodb
    ylabel('Amplitude')
    ylim([abs_min abs_max]);
else
    ylabel('Amplitude in dB')
    ylower_lim = max( min(min((dat))) , max(max((dat))) - 100 );
    ylower_lim = min(ylower_lim, max(max((dat))) - 20);
    yupper_lim = max(max((dat))) + 10;
    ylower_lim = 10*floor(ylower_lim./10);
    yupper_lim = 10*ceil(yupper_lim./10);
    if yupper_lim > ylower_lim +100 %set max range to 100 dB
        ylower_lim = yupper_lim -100;
    end
    if ~isinf([ylower_lim yupper_lim])
        ylim([ylower_lim, yupper_lim]);
    else
        ylim([-100 100]);
    end
    set(axh,'YTickLabel',num2str(round(get(axh,'YTick').'+minDat)));
end

set(fgh,'NumberTitle','off');
set(fgh,'Name', titleStr)
title(titleStr)

grid on

%% Black background?
ita_whitebg(repmat(~ita_preferences('blackbackground'),1,3)) 

%% Sets limits of x axis
if ~isempty(sArgs.xlim), xlim([sArgs.xlim(1) sArgs.xlim(2)]); end

%% Sets limits of y axis
if ~isempty(sArgs.ylim), ylim([sArgs.ylim(1) sArgs.ylim(2)]); end

%% Sets both x and y axis limits 
if ~isempty(sArgs.axis), axis(sArgs.axis); end

%% Changes aspectratio of plot
if ~old_figure_mode
    if ~isempty(sArgs.aspectratio)
        ita_plottools_aspectratio(fgh,sArgs.aspectratio);
    else
        ita_plottools_aspectratio(fgh,ita_preferences('aspectratio'));
    end
end

%% Get a grid!
grid on

%% Find legend
if sArgs.nodb
    for idx = 1:input.nChannels
        ChannelNames{idx} = [input.channelNames{idx} ' [' input.channelUnits{idx} ']']; %#ok<AGROW>
    end
else
    for idx = 1:input.nChannels
        ChannelNames{idx} = [input.channelNames{idx} ' [dB re ' input.channelUnits{idx} ']']; %#ok<AGROW>
    end
end
lgh = legend(ChannelNames);

%% Save information in the figure userdata section
setappdata(fgh,'AxisHandles',axh);
setappdata(fgh,'ActiveAxis',axh);

%% Save information in the axes userdata section
limits = [xlim ylim];
setappdata(axh,'Title',titleStr);
setappdata(axh,'ChannelNames',ChannelNames);
setappdata(axh,'AllChannels',1);   %used for all channel /single channel switch
setappdata(axh,'ActiveChannel',1); %used for all channel /single channel switch
setappdata(axh,'Limits',limits);
setappdata(axh,'PlotType','time')    %Types: time, mag, phase, gdelay
setappdata(axh,'YAxisType','linear');  %Types: linear and db
setappdata(axh,'XAxisType','time');  %Types: time and freq
setappdata(axh,'ChannelHandles',lnh);
setappdata(axh,'LegendHandles',lgh); %Not shure if put this in axh or fgh (sfi)
setappdata(axh,'XUnit','s');
setappdata(axh,'YUnit',input.channelUnits{1});

%% Maximize plot window in WIN32
if isempty(sArgs.aspectratio) && ~old_figure_mode
    ita_plottools_maximize(fgh);
end

%% Cursors
ita_plottools_cursors(ita_preferences('plotcursors'),[],gca);

%% Return the figure handle
if nargout == 1
    varargout(1) = {fgh};
end

end