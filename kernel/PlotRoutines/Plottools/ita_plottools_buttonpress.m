function ita_plottools_buttonpress(src, evnt)
%ITA_PLOTTOOLS_BUTTONPRESS - Provide key press functions to plots
%  This function enables the user to press keys similar as in Monkey Forest
%  to toggle between all channels visible or only one channel visible, etc.
%
%   This function is normally not used by the user!
%
%   See also ita_plot_freq, ita_plot_time.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_buttonpress">doc ita_plottools_buttonpress</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  01-Sep-2008

%% get additional info in the user section of the figure
fgh        = ita_guisupport_getParentFigure(src);
FigureData = getappdata(fgh);
axh        = gca; % not this: FigureData.ActiveAxis; because it does not get updated
AxisData   = getappdata(axh);
try %pdi
    if isempty(fieldnames(FigureData))
        ita_verbose_info('no FigureData found',0)
    elseif ~isempty(FigureData.AxisHandles) % checks if we have a least one axis
        for handleIdx = 1:length(FigureData.AxisHandles)
            AxisDataSet{handleIdx}  = getappdata(FigureData.AxisHandles(handleIdx)); %#ok<AGROW> %pdi: new handling 2011
        end
    end
catch theException
    ita_verbose_info('ITA_PLOTTOOLS_BUTTONPRESS:Something went wrong, reason is: ',0);
    disp(theException.message);
    return;
end

%% persistent variable for cloning axis settings
persistent copyAxisSettings;

%% jri: matlab 2014b: Key is read only. Dirty hack: copy event to struct
eventStruct.Key = evnt.Key;
eventStruct.Character = evnt.Character;
eventStruct.Modifier = evnt.Modifier;

evnt = eventStruct;
%% pdi - pre parsing, use character info
% evnt %used for debugging
switch(evnt.Character)
    case {'*'}
        evnt.Key = '*';
end

%% parsing info
switch (evnt.Key)
    case {'t'} %set title
        if isempty(evnt.Modifier)
            prompt={'Title for the Plot'};
            name='Plot Title';
            numlines=1;
            defaultanswer={get(get(axh,'Title'),'String')};
            options.Resize='on';
            options.WindowStyle='normal';
            options.Interpreter='tex';
            
            answer = inputdlg(prompt,name,numlines,defaultanswer,options);
            if ~isempty(answer)
                title(answer{1})
            end
        end
    case {'s'} %save figure as file
        ita_savethisplot();
        
    case {'b'} %switch to between black and white background
        ita_whitebg();
        ita_preferences('blackbackground',~ita_preferences('blackbackground'));
        
    case {'a'}
        %% toogle all channels, only one channel
        ita_plottools_buttonpress_ChannelSelect('switch');
        
    case {'multiply','rightbracket','*'} %increase channel number % TODO % * and / do not work with wrap arround for fourpoles
        
        %         if strcmpi(evnt.Modifier,'shift')
        %             ita_plottools_buttonpress_ChannelSelect('next', 'highlight')
        %         else
        ita_plottools_buttonpress_ChannelSelect('next');
        %         end
        
    case {'divide','7','/'} %decrese channel number
        %         if strcmpi(evnt.Modifier,'shift')
        %             ita_plottools_buttonpress_ChannelSelect('previous', 'highlight')
        %         else
        ita_plottools_buttonpress_ChannelSelect('previous');
        %         end
    case {'o'} %Lock distance between cursors
        ita_plottools_cursors('lock',[],axh);
        
    case {'d'}
        %% nice gui to change settings, mgu
        if isempty(evnt.Modifier)
            
            axhandles  = FigureData.AxisHandles;
            axisValues = axis(axhandles);
            nSubplots  = numel(axhandles);
            if iscell(axisValues)
                if nSubplots == 2 % spkphase, spkgdelay, imre
                    axisValues = [axisValues{1}(1:4) axisValues{2}(3:4)];
                elseif nSubplots == 6 % plot_all
                    axisValues = [axisValues{1}(1:2) axisValues{4}(1:2)];
                end
            end
            answerValues = ita_plottools_zoom(axisValues);
            
            if ~isempty(answerValues)
                if nSubplots == 6
                    set(axhandles([1 3 5]),'xlim', [answerValues(1,1) answerValues(1,2)]);
                    set(axhandles([2 4 6]),'xlim', [answerValues(2,1) answerValues(2,2)]);
                    set(axhandles(5) ,'ylim', [answerValues(2,1)  answerValues(2,2)] / 1000); % @pdi: tolle achsen!
                else
                    for idx=1:length(axhandles)
                        xlim(axhandles(idx),[answerValues(1,1) answerValues(1,2)]);
                        ylim(axhandles(idx),[answerValues(idx+1,1)  answerValues(idx+1,2)]);
                    end
                end
                if ita_preferences('plotcursors') && nSubplots ~= 6 % no cursors for plot_all
                    ita_plottools_cursors('newlimits');
                end
                ita_plottools_cursors('update',[],FigureData.AxisHandles(1));
                
            end
        end
        if strcmpi(evnt.Modifier,'shift') %set all figures to same axis limits
            axis_set = axis;
            axis_x   = axis_set(1:2);
            axis_y   = axis_set(3:4);
            axis_c   = get(axh,'clim');
            
            figData.PlotType  = getappdata(axh,'PlotType');
            figData.YAxisType = getappdata(axh,'YAxisType');
            figData.XAxisType = getappdata(axh,'XAxisType');
            
            figureVector=findobj(0,'type','figure');
            current_fig = gcf;
            for iFig=figureVector(:)'
                figure(iFig)
                try
                    axhandles = getappdata(iFig,'AxisHandles');
                    for hidx = 1:length(axhandles)
                        if ~strcmpi(getappdata(axhandles(hidx),'PlotType'),figData.PlotType), continue; end;
                        set(axhandles(hidx),'xlim',axis_x);
                        set(axhandles(hidx),'ylim',axis_y);
                        if strcmpi(getappdata(axhandles(hidx),'PlotType'),'spectrogram')
                            set(axhandles(hidx),'clim',axis_c);
                        end
                    end
                    ita_plottools_cursors('newlimits');
                catch theException
                    ita_verbose_info('key:d did not work properly, reason is',0);
                    disp(theException.message);
                end
            end
            figure(current_fig);
        end
        
        
    case {'leftarrow'} %Left arrow: move cursor left
        if strcmp(evnt.Modifier,'control')
            ita_plottools_cursors('long_move','left',axh); % TODO % Give the value for the steps, cause different for every plot!
        else
            ita_plottools_cursors('short_move','left',axh);
        end
        
    case {'rightarrow'} %Left arrow: move cursor left
        if strcmp(evnt.Modifier,'control')
            ita_plottools_cursors('long_move','right',axh);
        else
            ita_plottools_cursors('short_move','right',axh);
        end
    case {'tab'} %Left arrow: move cursor left
        if strcmp(evnt.Modifier,'shift')
            ita_plottools_cursors('exp_move','decrease',axh);
        else
            ita_plottools_cursors('exp_move','increase',axh);
        end
        
    case {'home'} %move active cursor to xlim(1)
        ita_plottools_cursors('jump','home',axh);
        
    case {'end'}  %move active cursor to xlim(end)
        ita_plottools_cursors('jump','end',axh);
        
    case {'m'}  %move active cursor to maximum of the active channel
        if strcmp(evnt.Modifier,'shift')
            ita_plottools_cursors('jump','max_act',axh);
        else
            ita_plottools_cursors('jump','max_all',axh);
        end
        
    case {'i'}  %move active cursor the begining of a impulse response
        ita_plottools_cursors('jump','begin',axh);
        
    case {'0'} %=: Pull cursors together
        if strcmp(evnt.Modifier,'shift')
            ita_plottools_cursors('jump','together',axh);
        end
        
    case {'subtract'} % TODO % update cursors, they do not look nice
        ita_plottools_cursors('xfocus','out',axh);
        
    case {'add'} % TODO % these values do not work for time domain
        ita_plottools_cursors('xfocus','in',axh);
        
    case {'space'}  %Space: change active cursor or subplot
        if strcmp(evnt.Modifier,'control')
            % change active subplot
            NumberAxis = length(FigureData.AxisHandles);
            aux = NumberAxis - mod(FigureData.ActiveChannel + 1,NumberAxis);
            setappdata(fgh,'ActiveChannel',aux);
            setappdata(fgh,'ActiveAxis',FigureData.AxisHandles(aux));
            try
                ita_plottools_cursors('update',[],FigureData.AxisHandles(aux));
            end
        else
            try
                ita_plottools_cursors('activate','exchange',axh);
            end
        end
        
    case {'l'}  %L: make left cursor active
        if strcmp(evnt.Modifier,'shift')
            legend off
        elseif strcmp(evnt.Modifier,'control')
            ita_plottools_cursors('off');  legend off; legend show;
            if ita_preferences('plotcursors')
                ita_plottools_cursors('on');
            end
            
        else
            ita_plottools_cursors('activate','left',axh);
        end
        
    case {'r'}  %R: make right cursor active
        ita_plottools_cursors('activate','right',axh);
        
    case {'u'} %Show vicinity of active cursor
        ita_plottools_cursors('xfocus','cursor',axh);
        
    case {'n'}
        if isempty(evnt.Modifier)
            ita_plottools_cursors('off');
        else
            ita_plottools_cursors('on');
        end
        
    case {'c'}
        if isempty(evnt.Modifier) % shift + c
            ita_plottools_cursors('on');
        elseif strcmp(evnt.Modifier{1},'control') %copy axis settings
            copyAxisSettings.axis = axis;
            copyAxisSettings.PlotType  = getappdata(axh,'PlotType');
            copyAxisSettings.YAxisType = getappdata(axh,'YAxisType');
            copyAxisSettings.XAxisType = getappdata(axh,'XAxisType');
        elseif strcmp(evnt.Modifier{1},'shift') && numel(evnt.Modifier) == 2 %Center around active cursor
            ita_plottools_cursors('xfocus','center',axh);
        else
            ita_plottools_cursors('off');
        end
        
        %==========================================================================
        %                            Zoom Operations
        %==========================================================================
    case {'x'} %zoom in cursors
        if ~isempty(evnt.Modifier)
            if (strcmp(evnt.Modifier,'control') || strcmp(evnt.Modifier,'shift')) && strcmp(AxisData.XAxisType,'freq')
                for idx = 1:length(FigureData.AxisHandles)
                    axh = FigureData.AxisHandles(idx);
                    if strcmp(get(axh,'XScale'),'log')
                        set(axh,'XScale','linear');
                        set(axh,'XTick',FigureData.XTickVecLin',...
                            'XTickLabel',FigureData.XTickLabelLin);
                    else
                        set(axh,'XScale','log');
                        set(axh,'XTick',FigureData.XTickVecLog',...
                            'XTickLabel',FigureData.XTickLabelLog);
                    end
                end
            end
        else
            ita_plottools_cursors('xfocus','between',axh);
        end
        
    case {'e'} %entire
        try %#ok<TRYNC>
            ita_plottools_cursors('xfocus','entire',axh);
            
            % if pressed with shift -> expand cursors
            if strcmp(evnt.Modifier,'shift')
                ita_plottools_cursors('jump','home',axh);
                ita_plottools_cursors('activate','exchange',axh);
                ita_plottools_cursors('jump','end',axh);
                ita_plottools_cursors('activate','exchange',axh);
            end
        end
    case {'z'} % TODO % save current cursor position, otherwise cursor position is lost
        zoom;
        hManager = uigetmodemanager(fgh);
        set(hManager.WindowListenerHandles,'Enable','off');
        set(fgh,'KeyPressFcn',@ita_plottools_buttonpress);
        
    case {'downarrow'}
        if strcmp(evnt.Modifier,'shift')
            ita_plottools_cursors('yfocus','increase',axh);
        else
            ita_plottools_cursors('yfocus','up',axh);
        end
        
    case {'uparrow'}
        if strcmp(evnt.Modifier,'shift')
            ita_plottools_cursors('yfocus','decrease',axh);
        else
            ita_plottools_cursors('yfocus','down',axh);
        end
        
    case {'q'}
        ita_plottools_cursors('off',[],axh);
        set(gcf,'KeyPressFcn',[]);
        close;
        return
        %==========================================================================
        %                            Additional Operations
        %==========================================================================
        
    case {'return','escape'}
        commandwindow();
    case {'p'}
        % PLAY AUDIO
        if strcmp(AxisData.XAxisType,'time')
            cursorPosition = ita_plottools_cursors;
            if ~isempty(cursorPosition)
                timeVector = get(AxisData.ActiveChannelHandle, 'XData');
                timeData   = get(AxisData.ActiveChannelHandle, 'YData');
                [dummy,  startIDX]  = min(abs(timeVector - cursorPosition(1))); %#ok<ASGLU>
                [dummy,  stopIDX]   = min(abs(timeVector - cursorPosition(2))); %#ok<ASGLU>
                
                play(audioplayer(timeData(startIDX:stopIDX), round(1/ diff(timeVector(1:2))),16, 0));
                
            else
                % get(axh, 'xlim') waere ne idee, aber scheint auch mit cursorn zu laufen....
            end
        end
        
    case {'y'} % auto y-axis and log-lin switch
        if ~isempty(evnt.Modifier) % log-lin switch
            if strcmp(evnt.Modifier,'shift') && strcmp(AxisData.XAxisType,'freq')
                for idx = 1:length(FigureData.AxisHandles)
                    axh = FigureData.AxisHandles(idx);
                    if strcmp(AxisData.YAxisType,'linear')
                        if ~isempty(strfind(get(gca,'YScale'),'lin'))
                            set(axh,'YScale','log');
                        else
                            set(axh,'YScale','lin');
                        end
                    else
                        % TODO: from dB values to linear
                    end
                end
            end
        else % auto y-axis
            ita_plottools_cursors('off');
            ylim(gca,'auto');
            ylim(ylim(gca));
            if ita_preferences('plotcursors')
                ita_plottools_cursors('on');
            end
        end
    case {'h'}
        x = ita_plottools_buttonpress_shortcuts('GUI');
    otherwise
        %         disp('Oh Lord. Relax, we are still working on the Function
        %         Keys!')
end


%% write back
if isfield(FigureData,'AxisHandles') %bugfix if-clause pdi
    for handleIdx = 1:length(FigureData.AxisHandles)
        setappdata(FigureData.AxisHandles(handleIdx),'AllChannels',AxisDataSet{handleIdx}.AllChannels);
        setappdata(FigureData.AxisHandles(handleIdx),'ActiveChannel',AxisDataSet{handleIdx}.ActiveChannel);
    end
end

    function ita_plottools_buttonpress_ChannelSelect(mode, option)
        % this function takes care of next/previous and single/all channel switching
        % PDI: Nov 2011
        
        highlightSelectedCh = nargin > 1 && strcmpi(option, 'highlight');
        
        
        factor     = 0;
        switchMode = 0;
        switch mode
            case 'previous'
                factor = -1;
            case 'next'
                factor = 1;
            case 'switch'
                switchMode = 1;
        end
        
        for hAxis = 1:length(FigureData.AxisHandles) %go thru all subplots
            if ~isequal(AxisDataSet{hAxis}.PlotType,'spectrogram')
                if AxisDataSet{hAxis}.AllChannels == 1 && factor
                    factor     = 0; %switch from all channels to single channel
                    switchMode = 1; %force switch
                end
                if switchMode
                    AxisDataSet{hAxis}.AllChannels = ~AxisDataSet{hAxis}.AllChannels;
                end
                
                %increase/decrease channel number
                AxisDataSet{hAxis}.ActiveChannel = mod(AxisDataSet{hAxis}.ActiveChannel -1 + factor,length(AxisDataSet{hAxis}.ChannelHandles)) +1;
                setappdata(FigureData.AxisHandles(hAxis),'ActiveChannel',AxisDataSet{hAxis}.ActiveChannel);
                
                
                if iscell( AxisDataSet{hAxis}.Title ) % pdi:bugfix; is this still possible???
                    figTitle = AxisDataSet{hAxis}.Title{hAxis};
                else
                    figTitle = AxisDataSet{hAxis}.Title;
                end
                
                % change visibility
                
                
                if highlightSelectedCh
                    set(AxisDataSet{hAxis}.ChannelHandles,'Visible','on', 'linewidth', ita_preferences('lineWidth'));
                    if AxisDataSet{hAxis}.AllChannels
                        title(FigureData.AxisHandles(hAxis),figTitle);
                    else
                        set(AxisDataSet{hAxis}.ChannelHandles(AxisDataSet{hAxis}.ActiveChannel), 'linewidth', ita_preferences('lineWidth')*3);
                        title(FigureData.AxisHandles(hAxis),[figTitle ' - CH: ' num2str(AxisDataSet{hAxis}.ActiveChannel) ' - ' AxisDataSet{hAxis}.ChannelNames{AxisDataSet{hAxis}.ActiveChannel}]);
                    end
                else
                    if AxisDataSet{hAxis}.AllChannels
                        set(AxisDataSet{hAxis}.ChannelHandles,'Visible','on', 'linewidth', ita_preferences('lineWidth'));
                        title(FigureData.AxisHandles(hAxis),figTitle);
                    else
                        set(AxisDataSet{hAxis}.ChannelHandles,'Visible','off', 'linewidth', ita_preferences('lineWidth'));
                        set(AxisDataSet{hAxis}.ChannelHandles(AxisDataSet{hAxis}.ActiveChannel),'Visible','on');
                        title(FigureData.AxisHandles(hAxis),[figTitle ' - CH: ' num2str(AxisDataSet{hAxis}.ActiveChannel) ' - ' AxisDataSet{hAxis}.ChannelNames{AxisDataSet{hAxis}.ActiveChannel}]);
                    end
                end
                
            end
            ita_plottools_cursors('update',[],FigureData.AxisHandles(hAxis)); %update cursors of subplot
        end
    end


end %function
