function varargout = ita_plottools_cursors(state,options,axh)
%ITA_PLOTTOOLS_CURSORS  Add cursors to the plot and trigger functions
%
%Syntax
%   ita_plottools_cursors('state',opt,axh);
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

if ~ita_preferences('plotcursors') && ((islogical(state) && ~state) || ~ismember(lower(state),{'on','yfocus'})) % no cursors wanted, skip all of this
    varargout{1} = [];
    return;
end

%% IN: If output argument, return the cursor values
if nargout  %See if the user specified a formatting function for the datalabel
    if nargin==0    %Use current axis
        h = gca;
    else
        h = state;
        if strcmp(get(h,'Type'),'line');
            h = get(h,'Parent');
        end;
    end;
    
    ActiveHandle  = getappdata(h,'ActiveCursor');
    PassiveHandle = getappdata(h,'PassiveCursor');
    
    if (isempty(ActiveHandle) || isempty(PassiveHandle)) && ita_preferences('plotcursors')
        warning('I could not find any cursors'); %#ok<WNTAG>
        return
    end
    
    act_pos = get(ActiveHandle, 'XData'); % pdi: change to get instead getappdata(ActiveHandle, 'Coordinates')
    pas_pos = get(PassiveHandle,'XData');
    
    if act_pos(1) < pas_pos(1)
        val = [act_pos(1) pas_pos(1)];
    else
        val = [pas_pos(1) act_pos(1)];
    end
    varargout{1} = val;
    return
end

%% Parse input arguments
if nargin == 1 %pdi added
    options = [];
    axh     = gca;
end
global cursorUtils %important for cursors

%% pdi
% Define constants for zoom
%pdi: @ are all cursorUtils entries really neccessary?

cursorUtils.y_jump           = 10;   % dB's to move y axis
cursorUtils.zoom             = 4/3;	% Ratio the x axis should be zoomed
cursorUtils.VICINITYDELTA    = 440;  % Number of Samples to be showed in each side of the cursors vicinity
cursorUtils.longjump         = 16;	% Number of bins to divide the axis for a long jump
cursorUtils.SHORTJUMP        = 512;  % Number of bins to divide the axis for a short jump

%% decide what to do
switch state
    case {1,'on'} % ON: Set the WindowButtonDownFcn and add the cursors.
        %Marker and color specification
        %if ita_preferences('blackbackground')
        %    ActiveColor  = 'g';
        %   PassiveColor = 'y';
        %else
            ActiveColor  = 'g';
            PassiveColor = [0.46  0.53 0.6]; % grey color works great for both backgroundcolors
        %end
        marker = 'none'; %'+';
        LineWidth = get(axh(1),'LineWidth')*3;
        
        for idx = 1:length(axh); % used for multiple axis in one plot (subplots)
            current_axh = axh(idx);
            
            %If there are already some data cursors on this plot, delete them!
            ita_plottools_cursors('off',state,current_axh);
            
            % Get the handle for the data
            current_figure_handle = getappdata(current_axh,'FigureHandle');
            if isempty(current_figure_handle)
                break
            end
            FigureData = getappdata(current_figure_handle);
            AxisData   = getappdata(current_axh);
            
            % Set mouse callback
            lnh = AxisData.ChannelHandles(AxisData.ActiveChannel);
            %pdi: @ do we need the following lines? what do they do?
            setappdata(current_axh,'ActiveChannelHandle',lnh); %The currently selected line.
            set(AxisData.ChannelHandles,'ButtonDownFcn', ...
                ['setappdata(getappdata(gca,''FigureHandle''),''ActiveChannelHandle'',gco);',...
                'ita_plottools_cursors(''selectline'',[],getappdata(gca,''FigureHandle''))']);
            
            xl = get(current_axh,'Xlim');
            xdata = get(lnh,'XData');
            x_init = local_data2samples(xl,xdata);
            %pdi: @ do we need the following lines? what do they do?
            while xdata(x_init(1)) < xl(1) && xl(1) < xdata(1)
                x_init(1) = x_init(1)+1;
            end
            while xdata(x_init(2)) > xl(2) && xl(2) > xdata(end)
                x_init(2) = x_init(2)-1;
            end
            xv1 = xl(1);
            xv2 = xl(2);
            
            % Save data of current active axis
            if current_axh == FigureData.ActiveAxis
                % Initalization of important global variables
                cursorUtils.xdata = xdata;
                cursorUtils.XLim = xl;
                cursorUtils.sampleXLim = x_init;
                cursorUtils.OriginalXLim = xl;
                cursorUtils.sampleOriginalXLim = x_init;
                cursorUtils.sampleSize = length(xdata);
            end
            
            setappdata(current_axh,'OriginalYLim',AxisData.Limits(3:4));
            % �andrey:
            %             yl = get(current_axh,'YLim'); 
            
            %Add the cursors
            ph1 = line([xv1 xv1],[-1e7 1e7], ... % andrey: it's faster define a big cursor then move it all the time.
                'Color',ActiveColor, ...
                'Marker',marker, ...
                'MarkerEdgeColor','k',...
                'Tag','Cursor', ...
                'LineStyle','-', ...
                'LineWidth',LineWidth, ...
                'Parent',current_axh,...
                'UserData',lnh,...
                'Visible','off'); %do not display cursor initially

            ph2 = line([xv2 xv2],[-1e7 1e7], ...
                'Color',PassiveColor, ...
                'Marker',marker, ...
                'MarkerEdgeColor','k',...
                'Tag','Cursor', ...
                'LineStyle','-', ...
                'LineWidth',LineWidth, ...
                'Parent',current_axh,...
                'UserData',lnh,...
                'Visible','off'); %do not display cursor initially
            
            % hide the cursors from the plot legend
            set(get(get(ph1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            set(get(get(ph2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            
            
            setappdata(ph1,'sample_CurrentPos',x_init(1));
            setappdata(ph2,'sample_CurrentPos',x_init(2));
            
            %Set Application Data.
            setappdata(current_axh,'ActiveCursor',ph1);
            setappdata(current_axh,'PassiveCursor',ph2);
            setappdata(current_axh,'ActiveColor',ActiveColor);
            setappdata(current_axh,'PassiveColor',PassiveColor);
            setappdata(current_axh,'LineWidth',LineWidth);
            setappdata(current_axh,'CursorLock',0);
            setappdata(current_axh,'DeltaLock',0);
        end
        
        fgh = getappdata(current_axh,'FigureHandle');
        set(fgh,'WindowButtonDownFcn','ita_plottools_cursors(''down'',[],getappdata(gca,''FigureHandle''))')
        %         set(fgh,'WindowButtonDownFcn','ita_plottools_cursors(''down'',[],gcf)')
        
        set(fgh,'DoubleBuffer','on');       %eliminate flicker
        
    case 'activate'
        %% ACTIVATE: Exchange the current active and passive cursors
        
        % Update cursors in every axis
        AllAxis = getappdata(getappdata(axh,'FigureHandle'),'AxisHandles');
        for idx = 1:length(AllAxis)
            
            axh = AllAxis(idx);
            act_h = getappdata(axh,'ActiveCursor');
            pas_h = getappdata(axh,'PassiveCursor');
            act_coord = getappdata(act_h,'sample_CurrentPos'); %get cursorposition
            pas_coord = getappdata(pas_h,'sample_CurrentPos');
            
            if (strcmp(options,'left') && (pas_coord(1) < act_coord(1))) ||...
                    (strcmp(options,'right') && (act_coord(1) < pas_coord(1))) ||...
                    strcmp(options,'exchange')
                
                %change colors
                set(act_h,'Color',getappdata(axh,'PassiveColor'));
                set(pas_h,'Color',getappdata(axh,'ActiveColor'));
                
                %update tag
                setappdata(axh,'ActiveCursor',pas_h);
                setappdata(axh,'PassiveCursor',act_h);
                
                if getappdata(axh,'CursorLock');
                    setappdata(axh,'DeltaLock',-getappdata(axh,'DeltaLock'));
                end
            end
        end
        
    case 'update'
        %% UPDATE: Update the cursor value
        try
            ActiveHandle = getappdata(axh,'ActiveCursor');
            active = getappdata(ActiveHandle,'sample_CurrentPos');
            update(active(1),axh); %update location of active cursor
        catch
            ita_verbose_info('no valid cursor handle found.');
        end
        
    case 'yfocus'
        %% YFOCUS: Zoom in the y axis
        YLim = get (axh,'YLim');  %ylim(); %getappdata(axh,'YLim'); pdi changed!!!
        if strcmp(getappdata(axh,'YAxisType'),'freq') %spectrogram
            switch options
                case 'up'
                    set(axh,'Clim',get(axh,'Clim')+1);
                case 'down'
                    set(axh,'Clim',get(axh,'Clim')-1);
                case 'increase'
                    set(axh,'Clim',get(axh,'Clim')+[1 0]);
                case 'decrease'
                    set(axh,'Clim',get(axh,'Clim')-[1 0]);
                otherwise
            end
            
        else %normal plots
            if strcmp(getappdata(axh,'YAxisType'),'linear')
                if strcmp(options,'increase')
                    y_lim = max(abs(YLim-mean(YLim))) * cursorUtils.zoom;
                    aux = floor(log10(y_lim));
                    y_lim = 10^aux * ceil(y_lim / 10^aux);
                    ylim_new = [-y_lim y_lim] + mean(YLim);
                elseif  strcmp(options,'decrease')
                    y_lim = max(abs(YLim-mean(YLim))) / cursorUtils.zoom;
                    aux = floor(log10(y_lim));
                    y_lim = 10^aux * floor(y_lim / 10^aux);
                    ylim_new = [-y_lim y_lim] + mean(YLim);
                elseif strcmp(options,'up')
                    step = abs(diff(YLim))/10;
                    ylim_new = YLim + step;
                elseif strcmp(options,'down')
                    step = abs(diff(YLim))/10;
                    ylim_new = YLim - step;
                end
                
            elseif strcmp(getappdata(axh,'YAxisType'),'db')
                if strcmp(options,'increase')
                    jump = min(cursorUtils.y_jump/2,diff(YLim)/10);
                    ylim_new = [(YLim(1)-jump) YLim(2)]; %pdi:bugfix 0dB cursor stuck
                elseif strcmp(options,'down')
                    if diff(ylim) / 2 <= cursorUtils.y_jump
                        yjump = diff(ylim)/10;
                    else
                        yjump = cursorUtils.y_jump;
                    end
                    ylim_new = YLim + yjump;
                    
                elseif strcmp(options,'decrease')
                    jump = min(cursorUtils.y_jump/2,diff(YLim)/10);
                    ylim_new = [(YLim(1)+jump) YLim(2)];%pdi:bugfix 0dB cursor stuck
                    
                elseif strcmp(options,'up')
                    if diff(ylim) / 2 <= cursorUtils.y_jump
                        yjump = diff(ylim)/10;
                    else
                        yjump = cursorUtils.y_jump;
                    end
                    ylim_new = YLim - yjump;
                else
                    disp(options)
                end
            else
                return
            end
            
            set(axh,'YLim',ylim_new);
        end
        
    case 'xfocus'
        %% XFOCUS: Zoom around the active cursor
        ActiveHandle = getappdata(axh,'ActiveCursor');
        active = getappdata(ActiveHandle,'sample_CurrentPos');
        
        if strcmp(options,'cursor') %show vicinity of active cursor
            delta = cursorUtils.VICINITYDELTA;
            new_lim = [active-delta active+delta];
            
        elseif strcmp(options,'entire')
            new_lim = cursorUtils.sampleOriginalXLim;
            
        elseif strcmp(options,'between')
            PassiveHandle = getappdata(axh,'PassiveCursor');
            passive = getappdata(PassiveHandle,'sample_CurrentPos');
            if passive < active
                new_lim = [passive active];
            elseif active < passive
                new_lim = [active passive];
            else        % if they are the same, then don�t do anything
                return
            end
            
        else
            if strcmp(getappdata(axh,'XAxisType'),'time')
                delta = abs(cursorUtils.sampleXLim - active);
                if strcmp(options,'in')
                    delta = max(delta)/cursorUtils.zoom;
                    
                elseif strcmp(options,'out')
                    delta = max(delta)*cursorUtils.zoom;
                    
                elseif strcmp(options,'center') %center around active cursor
                    delta = min(delta);
                    if delta < 1
                        return
                    end
                end
                new_lim = round([active-delta active+delta]);
                
            elseif strcmp(getappdata(axh,'XAxisType'),'freq')
                active_db = log10(active);
                delta = abs(log10(cursorUtils.sampleXLim) - active_db);
                if strcmp(options,'in')
                    delta = max(delta) / cursorUtils.zoom;
                    
                elseif strcmp(options,'out')
                    delta = max(delta) * cursorUtils.zoom;
                    
                elseif strcmp(options,'center') %center around active cursor
                    delta = min(delta);
                    if delta == 0
                        return
                    end
                end
                new_lim = round(10.^[active_db-delta active_db+delta]);
            else
                error('Such x axis is not defined!')
            end
        end
        
        if new_lim(1) < 1
            new_lim(1) = 1;
        end
        
        if new_lim(2) > cursorUtils.sampleSize
            new_lim(2) = cursorUtils.sampleSize;
        end
        
        cursorUtils.sampleXLim = new_lim;
        new_lim = cursorUtils.xdata(new_lim);
        cursorUtils.XLim = new_lim;
        
        set(axh,'Xlim',new_lim);
        update(active,axh);
        
    case 'exp_move'
        %% EXP_MOVE: Repositon the active cursor based on the passive cursor position
        if getappdata(axh,'CursorLock')
            return
        else
            ActiveHandle = getappdata(axh,'ActiveCursor');
            active = getappdata(ActiveHandle,'sample_CurrentPos');
            PassiveHandle = getappdata(axh,'PassiveCursor');
            passive = getappdata(PassiveHandle,'sample_CurrentPos');
            width = active - passive;
            
            if strcmp(options,'increase')
                step = ceil(log2(abs(width)+1));
                act_new = passive + sign(width)*(2^step);
                
                if (act_new < 1) || (act_new > cursorUtils.sampleSize)
                    return
                end
                
            else
                step = floor(log2(abs(width)-1));
                
                if step < 0
                    return
                end
                
                act_new = passive + sign(width)*(2^step);
            end
        end
        update(act_new,axh);
        
    case 'jump'
        %% JUMP: Move active cursor to defined position
        if strcmp(options,'home')
            act_new = cursorUtils.sampleXLim(1);
            
        elseif strcmp(options,'end')
            act_new = cursorUtils.sampleXLim(2);
            
        elseif strcmp(options,'together')
            % Move active cursor to position from passie cursor
            if getappdata(axh,'CursorLock')
                return
            else
                act_new = getappdata(getappdata(axh,'PassiveCursor'),'sample_CurrentPos');
            end
            
        elseif strcmp(options,'max_act')
            lnh = getappdata(axh,'ActiveChannelHandle');
            ydata = get(lnh,'YData');
            if strcmp(getappdata(axh,'XAxisType'),'time')
                ydata = abs(ydata);
            end
            [junk,ind] = max(ydata); %#ok<ASGLU>
            act_new = ind(1);
            
        elseif strcmp(options,'max_all')
            ChannelHandles = getappdata(axh,'ChannelHandles');
            aux = zeros(size(ChannelHandles,1),1);
            ind = zeros(size(ChannelHandles,1),1);
            for idx = 1:size(ChannelHandles,1)
                ydata = get(ChannelHandles(idx),'YData');
                if strcmp(getappdata(axh,'XAxisType'),'time')
                    ydata = abs(ydata);
                end
                [aux(idx),ind(idx)] = max(ydata);
            end
            [junk,idx] = max(aux); %#ok<ASGLU>
            act_new = ind(idx);
            
        elseif strcmp(options,'begin')
            %TO DO: check if signal has IR characteristics
            if strcmp(getappdata(axh,'XAxisType'),'time')
                lnh = getappdata(axh,'ActiveChannelHandle');
                ydata = get(lnh,'YData');
                act_new = ita_start_IR(ydata);
            else
                return
            end
        end
        update(act_new,axh);
        
        %% CURSOR MOVE: Move the active cursor with keyboard
    case {'long_move','short_move'}
        try %pdi
            ActiveHandle = getappdata(axh,'ActiveCursor');
            active = getappdata(ActiveHandle,'sample_CurrentPos');
            delta = cursorUtils.sampleXLim(2) - cursorUtils.sampleXLim(1);
        catch
            return
        end
        % Define the new cursor position,
        % based on the user choice of short or long
        if strcmp(getappdata(axh,'XAxisType'),'time')
            if strcmp(state,'long_move')
                step = ceil(delta/cursorUtils.longjump);
            else
                step = ceil(delta/cursorUtils.SHORTJUMP);
            end
            
            if strcmp(options,'left')
                act_new = active - step;
                if act_new < 1
                    act_new = 1;
                end
            else
                act_new = active + step;
                if act_new > cursorUtils.sampleSize
                    act_new = cursorUtils.sampleSize;
                end
            end
            
        elseif strcmp(getappdata(axh,'XAxisType'),'freq')
            if strcmp(state,'long_move')
                step = delta^(1/cursorUtils.longjump);
            else
                step = delta^(1/cursorUtils.SHORTJUMP);
            end
            
            if strcmp(options,'left')
                act_new = floor(active / step);
                if act_new < 1
                    act_new = 1;
                end
            else
                act_new = ceil(active * step);
                if act_new > cursorUtils.sampleSize
                    act_new = cursorUtils.sampleSize;
                end
            end
        else
            error('Such x axis is not defined!')
        end
        % Give new value of active cursor position to be updated
        update(act_new,axh)
        
    case 'newlimits' %get cursors to current figure limits
        %% LOCK: Lock the distance between cursors
        %pdi: new
        try
            cursorUtils.XLim = xlim;
            %             cursorUtils.YLim = ylim;
            cursorUtils.sampleXLim = local_data2samples(cursorUtils.XLim,cursorUtils.xdata);
            update(local_data2samples(cursorUtils.XLim(1),cursorUtils.xdata),axh);
            ita_plottools_cursors('activate','exchange',axh);
            update(local_data2samples(cursorUtils.XLim(2),cursorUtils.xdata),axh);
        catch
            ita_verbose_info('ITA_PLOTTOOLS_CURSORS: Could not adjust cursors to new limits');
        end
    case 'lock'
        lock = getappdata(axh,'CursorLock');
        if lock
            setappdata(axh,'CursorLock',0);
        else
            setappdata(axh,'CursorLock',1);
            active = getappdata(getappdata(axh,'ActiveCursor'),'sample_CurrentPos');
            passive = getappdata(getappdata(axh,'PassiveCursor'),'sample_CurrentPos');
            setappdata(axh,'DeltaLock',passive - active);
        end
        
    case {'off',0}
        axh_backup = axh;
        for jdx = 1:length(axh_backup)
            axh = axh_backup(jdx);
            fgh = getappdata(axh,'FigureHandle');
            if isfield(get(fgh),'WindowButtonDownFcn')
                set(fgh,'WindowButtonDownFcn','','WindowButtonUpFcn','')
            end
            
            if strcmp(options,'on')
                h1 = findobj(axh,'Tag','InfoText');       %All text
                h2 = findobj(axh,'Tag','Cursor');           %The cursors
                
                lnh = local_findlines(axh);
                set(lnh,'ButtonDownFcn','');
                delete([h1;h2]);
            else
                try
                    AllAxis = getappdata(getappdata(axh,'FigureHandle'),'AxisHandles');
                    for idx = 1:length(AllAxis)
                        axh = AllAxis(idx);
                        h1 = findobj(axh,'Tag','InfoText');       %All text
                        h2 = findobj(axh,'Tag','Cursor');           %The cursors
                        
                        lnh = local_findlines(axh);
                        set(lnh,'ButtonDownFcn','');
                        delete([h1;h2]);
                    end
                    clear global cursorUtils
                catch
                    ita_verbose_info('ita_plottools_cursors::no cursors found',1)
                end
            end
            
        end
        
end %switch/case end

function samples = local_data2samples(points,data_vector)
%% Converts a value in time or frequency in the x axis into its equivalent
%% sample values
samples = zeros(length(points),1);
for idx = 1:length(points)
    [junk,samples(idx)] = min(abs(data_vector(1,:) - points(idx))); %#ok<ASGLU>
end


function update(act_new,axh)
%% Update the cursors and axis limits for a new active cursor position
% Changed by Andrey and pdi - 02.04.2012
% getappdata(ActiveHandle, 'Coordinates') out
% ylim takes a lot of time, use only when necessary

global cursorUtils

%Case cursors are locked, update also passive cursor
if getappdata(axh,'CursorLock')
    delta = getappdata(axh,'DeltaLock');
    pas_new = act_new + delta;
    
    if pas_new < 1
        pas_new = 1;
    elseif pas_new > cursorUtils.sampleSize
        pas_new = cursorUtils.sampleSize;
    end
    %Don't do anything
else
    PassiveHandle = getappdata(axh,'PassiveCursor');
    pas_new = getappdata(PassiveHandle,'sample_CurrentPos');
end

xva = cursorUtils.xdata(min(act_new,length(cursorUtils.xdata)));
xvp = cursorUtils.xdata(min(pas_new,length(cursorUtils.xdata)));

% Update cursors in every axis
AllAxis = getappdata(getappdata(axh,'FigureHandle'),'AxisHandles');
for idx = 1:length(AllAxis)
    axh = AllAxis(idx);
    
    ActiveHandle  = getappdata(axh,'ActiveCursor');
    PassiveHandle = getappdata(axh,'PassiveCursor');
    
    %finally set x-DATA of cursor - it is also plotted directly
    set(PassiveHandle,'XData',[xvp xvp],'Visible','on'); %display cursor if updated (see "on", it's turned off there initially)
    set(ActiveHandle, 'XData',[xva xva],'Visible','on'); %display cursor if updated
    
    setappdata(PassiveHandle,'sample_CurrentPos',pas_new);
    setappdata(ActiveHandle, 'sample_CurrentPos',act_new);
end
% drawnow

function lnh = local_findlines(axh)
%% Find a line to add cursor to
lnh = findobj(axh,'Type','line');
dots = findobj(axh,'Type','line','Tag','Cursor');  %Ignore existing cursors
lnh = setdiff(lnh,dots);

%Ignore lines with only one or two values - these are annotations
xdtemp = get(lnh,'XData');
lnhtemp = lnh;
lnh=[];
if ~iscell(xdtemp)
    xdtemp = {xdtemp};
end;

for idx=1:length(xdtemp);
    if length(xdtemp{idx})>2
        lnh = [lnh; lnhtemp(idx)]; %#ok<AGROW>
    end
end

