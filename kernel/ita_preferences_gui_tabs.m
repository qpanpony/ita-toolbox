function ita_preferences_gui_tabs(defined_preferences,tab_names,singleTab)
% This function creates a GUI interface for setting all the preferences of
% the toolbox at setup

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

if nargin < 3
    singleTab = false;
end

%% List of Defined Preferences
tabvec = cell2mat( defined_preferences(:,6) );
if singleTab
    defined_preferences(tabvec > 0,:) = [];
    tabvec(tabvec>0) = [];
end
n      = size(defined_preferences,1); %number of prefs
uniqueTabs = unique(tabvec);
nh = 1;
if singleTab
    nh = numel(tabvec);
else
    for idx = 1:numel(uniqueTabs)
        if uniqueTabs(idx) > 0 % No hidden app tabs
            nh_tab = sum(tabvec == uniqueTabs(idx)); %number of potential lines
            nh_tab = nh_tab - sum(cell2mat( strfind(defined_preferences(tabvec == uniqueTabs(idx),3),'*'))); %subtract non-visible items
            nh     = max(nh_tab, nh); %number of max prefs per tab
        end
    end
end

% show the nice names in gui help text
for idx = 1:size(defined_preferences,1)
    defined_preferences{idx,5} = ['''' defined_preferences{idx,1} '''' ':' defined_preferences{idx,5}];
end

%% GUI Initialization
h_textbox    = 22; %height of each line
top_margin   = 22+40; %space on top of the ita logo
%height of the entire gui (with some headroom +1)
height       = top_margin + (nh+4)*(h_textbox+1); 
width        = 600;
bgColor      = [0.94 0.94 0.94];
bgColorLine  = [0.94 0.94 0.94];
fgColorLine  = [0 0 0.8];
mpos         = get(0,'Monitor');
w_position   = (mpos(1,length(mpos)-1)/2)-(width/2);
h_position   = (mpos(1,length(mpos))/2)-(height/2);
MainPosition = [w_position h_position width height];
TabPosition  = [5 64 width-10 height-65];
height       = height - 100;
fontsize     = 10;
rightMargin  = 720; % where ui elements end
stPos        = 280; % where the second column starts
topMargin    = 0;  %space before first line starts
popupStart   = stPos;
popupSpace   = 450; %space to right after dropdown menu - control the popup width
textSpace    = popupSpace; %space to right after text/double fields - control the width

%% Figure Handling
xx = warning; % save old warning settings
warning off %#ok<*WNOFF>
hFigure = figure( ...       % the main GUI figure
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'on', ...
    'Name', 'ITA-Toolbox Preferences', ...
    'NumberTitle', 'off', ...
    'Position', MainPosition, ...
    'KeyPressFcn',@ButtonCallback,...
    'Color', bgColor);

handles.hFigure = hFigure;
h = uitabgroup('Parent',handles.hFigure,'Tag','tabs');
set(h,'Units','Pixel');
set(h,'Position',TabPosition);
% set(h,'BackgroundColor',bgcolor);

minTab = max(min(cell2mat(defined_preferences(:,6))),1); %Find minimum Tab definition (but not zero)

for idx=1:size(defined_preferences,1) % Shift all tabs if first is not 1
    if singleTab
        defined_preferences{idx,6} = 1;
    else
        defined_preferences{idx,6} = defined_preferences{idx,6} - minTab +1;
    end
end

nTabs = min(max(cell2mat(defined_preferences(:,6))), numel(tab_names));
for idx=1:nTabs
    tab(idx) = uitab(h,'title' , tab_names{idx}); %#ok<AGROW>
    tab_no_elements(idx) = 0; %#ok<AGROW>
    set(tab(idx),'Units','Pixel');
end
warning(xx) %write back old warning settings

%% ita toolbox logo
a_im = importdata(which('ita_toolbox_logo_lightgrey.jpg'));
ax    = axes('Parent',hFigure);
image(a_im);axis off
set(ax,'Units','pixel', 'Position', [50 20 300 60]*0.8); %pdi new scaling

%% port audio and COMports
if exist('ita_portaudio_menuStr','file')
    [inDevStr, inDevID, outDevStr, outDevID]   = ita_portaudio_menuStr();
else
    inDevStr = ''; inDevID = 0; outDevStr = ''; outDevID = 0;
end
if exist('ita_midi_menuStr','file')
    [midi_inDevStr, midi_inDevID, midi_outDevStr, midi_outDevID]   = ita_midi_menuStr();
else
    midi_inDevStr = ''; midi_inDevID = 0; midi_outDevStr = ''; midi_outDevID = 0;
end
if exist('ita_get_available_comports','file')
    com_DevStr = ita_get_available_comports();
else
    com_DevStr = '';
end

%% show/draw GUI for Preferences
clear h
idx2 = 0;

for I = 1:nTabs %go thru all tabs to plot
    for idx  = 1:n %go thru the list
        tabNo       = defined_preferences{idx,6}; %tab number to plot the information in
        if (tabNo == I) && tabNo <= numel(tab_names) && tabNo > 0
            type        = defined_preferences{idx,3};
            draw_line   = true;
            if ~ (type(1) == '*') %do not do anything if * in the beginning
                tab_no_elements(tabNo) = tab_no_elements(tabNo) + 1;
                idx2 = tab_no_elements(tabNo);
            end
            switch(type)
                case {'simple_button'} %pdi
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo), ...
                        'Position', [stPos height-topMargin-(idx2)*(h_textbox+3) rightMargin-textSpace h_textbox],...
                        'FontSize', fontsize,...
                        'HorizontalAlignment','left',...
                        'Style', 'pushbutton',...
                        'String',defined_preferences{idx,2},...
                        'TooltipString',defined_preferences{idx,5},...
                        'Userdata',defined_preferences{idx,2},...
                        'Callback',@simpleButtonCallback,...
                        'BackgroundColor',bgColor);
                case {'numeric','double','int'}
                    pref = ita_preferences(defined_preferences{idx,1});
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo),...
                        'Position',[stPos height-topMargin-(idx2)*(h_textbox+3) rightMargin-textSpace h_textbox],...
                        'FontSize',fontsize,...
                        'BackgroundColor',[1 1 1],...
                        'HorizontalAlignment','left',...
                        'Style', 'edit',...
                        'BackgroundColor',bgColor,...
                        'String',num2str(pref), ...
                        'TooltipString',defined_preferences{idx,5});
                    
                case {'LicenseFile'}
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo),...
                        'Position',[stPos height-topMargin-(idx2)*(h_textbox+3) rightMargin-textSpace h_textbox],...
                        'FontSize',fontsize,...
                        'BackgroundColor',[1 1 1],...
                        'HorizontalAlignment','left',...
                        'Style', 'edit',...
                        'Enable','off',...
                        'BackgroundColor',bgColor);
                    pref = ita_preferences(defined_preferences{idx,1});
                    set(h.(defined_preferences{idx,1}),'String',num2str(pref));
                case {'popup_double','popup_string','popup_char'}
                    token = defined_preferences{idx,5};
                    startIdx = strfind(token,'[')+1;endIdx = strfind(token,']')-1;
                    token = ['|' token(startIdx:endIdx) '|'];
                    pref  = ita_preferences(defined_preferences{idx,1});
                    token = strrep(token,['|' num2str(pref) '|'],'|'); %remove the current from the list
                    token = [num2str(pref) token(1:end-1)]; %add our choosen element in the beginning
                    
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo),...
                        'Position',[popupStart height-topMargin-8-(idx2)*(h_textbox+3) rightMargin-popupSpace h_textbox+8],...
                        'FontSize',fontsize,...
                        'HorizontalAlignment','right',...
                        'String',token,...
                        'Value',1,...
                        'Style', 'popup',...
                        'BackgroundColor',bgColor);
                    
                case {'int_verboseMode'}
                    pref = ita_preferences(defined_preferences{idx,1});
                    verboseModeLevel = '0: see only warnings|1: see some info|2: see all info';
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo),...
                        'Position',[popupStart height-topMargin-8-(idx2)*(h_textbox+3) rightMargin-popupSpace h_textbox+8],...
                        'FontSize',fontsize,...
                        'HorizontalAlignment','right',...
                        'String',verboseModeLevel,...
                        'Value',pref+1,...
                        'Style', 'popup',...
                        'BackgroundColor',bgColor);
                    
                case {'playrecFunctionHandle'}
                    pref = ita_preferences(defined_preferences{idx,1});
                    playrecStrings = ita_playrec_show_strings();
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo),...
                        'Position',[popupStart height-topMargin-8-(idx2)*(h_textbox+3) rightMargin-popupSpace h_textbox+8],...
                        'FontSize',fontsize,...
                        'HorizontalAlignment','right',...
                        'String',playrecStrings,...
                        'Value',pref,...
                        'Style', 'popup',...
                        'BackgroundColor',bgColor);
                    
                case {'int_portAudio'}
                    if strcmpi(defined_preferences{idx,1},'recDeviceID')
                        devicelist = inDevStr;
                    elseif strcmpi(defined_preferences{idx,1},'playDeviceID')
                        devicelist = outDevStr;
                    end
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo),...
                        'Position',[popupStart height-topMargin-4-(idx2)*(h_textbox+3) rightMargin-popupSpace h_textbox+8],...
                        'FontSize',fontsize,...
                        'BackgroundColor',[1 1 1],...
                        'HorizontalAlignment','right',...
                        'String',devicelist,...
                        'Style', 'popup',...
                        'BackgroundColor',bgColor);
                    
                case {'str_comPort'}
                    comportlist = com_DevStr;
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo),...
                        'Position',[popupStart height-4-(idx2)*(h_textbox+3) rightMargin-popupSpace h_textbox+8],...
                        'FontSize',fontsize,...
                        'HorizontalAlignment','right',...
                        'String',comportlist,...
                        'Style', 'popup',...
                        'BackgroundColor',bgColor);
                    pref = ita_preferences(defined_preferences{idx,1});
                    index = find(strcmpi(com_DevStr,pref), 1);
                    if isempty(index),index = length(com_DevStr); end
                    set(h.(defined_preferences{idx,1}),'Value',index);
                    
                case {'int_portMidi'}
                    if strcmpi(defined_preferences{idx,1},'in_midi_DeviceID')
                        devicelist = midi_inDevStr;
                    elseif strcmpi(defined_preferences{idx,1},'out_midi_DeviceID')
                        devicelist = midi_outDevStr;
                    end
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo),...
                        'Position',[popupStart height-topMargin-4-(idx2)*(h_textbox+3) rightMargin-popupSpace h_textbox+8],...
                        'FontSize',fontsize,...
                        'HorizontalAlignment','right',...
                        'String',devicelist,...
                        'Style', 'popup',...
                        'BackgroundColor',bgColor);
                    
                case {'string','char'}
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo), ...
                        'Position',[stPos height-topMargin-(idx2)*(h_textbox+3) rightMargin-textSpace h_textbox],...
                        'FontSize',fontsize,...
                        'BackgroundColor',[1 1 1],...
                        'HorizontalAlignment','left',...
                        'Style', 'edit',...
                        'BackgroundColor',bgColor);
                    pref = ita_preferences(defined_preferences{idx,1});
                    set(h.(defined_preferences{idx,1}),'String',pref);
                case {'password'}
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo), ...
                        'Position',[stPos height-topMargin-(idx2)*(h_textbox+3) rightMargin-textSpace h_textbox],...
                        'FontSize',fontsize,...
                        'BackgroundColor',[1 1 1],...
                        'HorizontalAlignment','left',...
                        'Style', 'edit',...
                        'BackgroundColor',bgColor);
                    pref = repmat('*',1,40);
                    set(h.(defined_preferences{idx,1}),'String',pref);
                case {'bool','bool_ispc'}
                    if strcmpi(type,'bool_ispc') && ispc || strcmpi(type,'bool')
                        h.(defined_preferences{idx,1}) = uicontrol(...
                            'Parent', tab(tabNo), ...
                            'Position',[stPos height-topMargin-(idx2)*(h_textbox+3) 18 h_textbox],...
                            'FontSize',fontsize,...
                            'BackgroundColor',bgColor,...
                            'Style', 'checkbox');
                        
                        pref = ita_preferences(defined_preferences{idx,1});
                        %pdi: be on the save side
                        if ischar(pref), pref = str2double(pref); end
                        if isnan(pref),  pref = 0; end
                        
                        set(h.(defined_preferences{idx,1}),'Value',pref);
                    else
                        idx2 = idx2-1; %pdi: skip this entry and put another gui element instead
                        draw_line = false;
                    end
                case {'path'}
                    h.(defined_preferences{idx,1}) = uicontrol(...
                        'Parent', tab(tabNo), ...
                        'Position',[stPos height-topMargin-(idx2)*(h_textbox+3) rightMargin-popupSpace h_textbox],...
                        'FontSize',fontsize,...
                        'BackgroundColor',[1 1 1],...
                        'HorizontalAlignment','left',...
                        'Style', 'edit',...
                        'BackgroundColor',bgColor);
                    x = uicontrol(...
                        'Parent', tab(tabNo), ...
                        'Position',[stPos+rightMargin-popupSpace height-topMargin-(idx2)*(h_textbox+3) 20 h_textbox],...
                        'String', '...',...
                        'TooltipString', 'Browse for directory',...
                        'Style', 'pushbutton',...
                        'Callback', @BrowseCallback,...
                        'BackgroundColor',bgColor);
                    set(x,'Userdata',h.(defined_preferences{idx,1}));
                    
                    pref = ita_preferences(defined_preferences{idx,1});
                    if ~ischar(pref), pref = ''; end;
                    if ~isdir(pref)
                        pref = ''; %ita_preferences(defined_preferences{idx-1,1});
                    end
                    set(h.(defined_preferences{idx,1}),'String',pref);
                otherwise
                    draw_line = false;
                    idx2 = idx2-1;% if there is preference of type *bool, *int, *path, idx2 should stay constant
            end
            
            if draw_line
                uicontrol(...
                    'Parent', tab(tabNo), ...
                    'Position',[15 height-topMargin+3-(idx2)*(h_textbox+3) 210 h_textbox-7],...
                    'String', defined_preferences{idx,4},...
                    'TooltipString', defined_preferences{idx,5},...
                    'FontSize',fontsize,...
                    'BackgroundColor',bgColorLine,...
                    'ForegroundColor',fgColorLine,...
                    'HorizontalAlignment','left',...
                    'FontWeight','bold',...
                    'Style', 'text');
            end
        end
    end
    a{I} = h;
    
    
    %% GUI key press functions
    x = get(tab(I),'children');
    for idx = 1:numel(x)
        token = get(x(idx));
        if strcmpi(token.Type,'uicontrol') && ~strcmpi(token.Style,'pushbutton') && ~strcmpi(token.Style,'edit')
            set(x(idx),'KeyPressFcn',@ButtonCallback)
        end
    end
    
end

%% Pushbutton
uicontrol(...
    'Parent', hFigure, ...
    'Position',[330 20 100 30],...
    'String', 'Cancel',...
    'Style', 'pushbutton',...
    'Callback', @CancelButtonCallback);
uicontrol(...
    'Parent', hFigure, ...
    'Position',[450 20 100 30],...
    'String', 'OK',...
    'TooltipString','Just set all preferences and restore the Toolbox paths.',...
    'Style', 'pushbutton',...
    'Callback', @OkayButtonCallback);


%% Callbacks: GenerateDocumentation, Ok and Cancel Buttons and Tabs

    function simpleButtonCallback(hObject,eventdata)
        funStr = get(hObject,'Userdata');
        switch lower(class(funStr))
            case {'function_handle'}
                funStr(hObject,eventdata);
            otherwise
                eval(funStr);
        end
    end

% OK button - check for all settings and store them in the preferences
% variable
    function OkayButtonCallback(hObject,eventdata)
        % fgh = get(hObject,'Parent');
        %         if fgh == 0
        %             fgh = hObject;
        %         end
        fgh = gcf;
        set(fgh,'visible','off')
        pause(0.02);
        ita_verbose_info('ita_preferences: still heating up the valves...',1)
        for idxn = 1:n
            type = defined_preferences{idxn,3};
            tabNumber = defined_preferences{idxn,6};
            if tabNumber <= numel(tab_names) && tabNumber > 0
                switch(type)
                    case {'numeric','double','int'} % ask for strings, convert to double
                        try
                            pref = str2num(get(a{tabNumber}.(defined_preferences{idxn,1}),'String')); %#ok<*ST2NM>
                            ita_preferences(defined_preferences{idxn,1},pref);
                        catch %#ok<CTCH>
                            disp(['Value for ' defined_preferences{idxn,1} ' invalid.' ])
                        end
                    case {'int_verboseMode'} %ask for value, minus 1
                        pref = get(a{tabNumber}.(defined_preferences{idxn,1}),'Value');
                        ita_preferences(defined_preferences{idxn,1}, pref-1);
                    case {'popup_char','popup_string','popup_double'} %ask for value, no conversion
                        pref = get(a{tabNumber}.(defined_preferences{idxn,1}),'Value');
                        list = get(a{tabNumber}.(defined_preferences{idxn,1}),'String');
                        pref = strtrim(list(pref,:));
                        if strcmpi(type,'popup_double')
                            pref = str2num(pref);
                        end
                        ita_preferences(defined_preferences{idxn,1}, pref);
                        
                    case {'playrecFunctionHandle'} %ask for value, no conversion
                        pref = get(a{tabNumber}.(defined_preferences{idxn,1}),'Value');
                        ita_preferences(defined_preferences{idxn,1}, pref);
                        
                    case {'int_portAudio'} %only for portAudio stuff
                        dev_idx = get(a{tabNumber}.(defined_preferences{idxn,1}),'Value');
                        if strcmpi(defined_preferences{idxn,1},'recDeviceID')
                            pref = inDevID(dev_idx);
                        elseif strcmpi(defined_preferences{idxn,1},'playDeviceID')
                            pref = outDevID(dev_idx);
                        end
                        ita_preferences(defined_preferences{idxn,1}, pref);
                        
                    case {'str_comPort'} % only for RS232 stuff
                        com_idx = get(a{tabNumber}.(defined_preferences{idxn,1}),'Value');
                        ita_preferences(defined_preferences{idxn,1}, com_DevStr{com_idx});
                        
                    case {'int_portMidi'} % only for MIDI stuff
                        dev_idx = get(a{tabNumber}.(defined_preferences{idxn,1}),'Value');
                        if dev_idx
                            if strcmpi(defined_preferences{idxn,1},'in_midi_DeviceID')
                                pref = midi_inDevID(dev_idx);
                            elseif strcmpi(defined_preferences{idxn,1},'out_midi_DeviceID')
                                pref = midi_outDevID(dev_idx);
                            end
                            ita_preferences(defined_preferences{idxn,1}, pref);
                        end
                    case {'string','char'} %ask for string, no conversion
                        pref = get(a{tabNumber}.(defined_preferences{idxn,1}),'String');
                        ita_preferences(defined_preferences{idxn,1},pref);
                    case {'bool'}
                        pref = cast(get(a{tabNumber}.(defined_preferences{idxn,1}),'Value'),'logical');
                        ita_preferences(defined_preferences{idxn,1},pref);
                    case {'bool_ispc'} %only for windows
                        if ispc
                            pref = cast(get(a{tabNumber}.(defined_preferences{idxn,1}),'Value'),'logical');
                            ita_preferences(defined_preferences{idxn,1},pref);
                        end
                    case {'path'}
                        pref = get(a{tabNumber}.(defined_preferences{idxn,1}),'String');
                        if ~isdir(pref) && ~isempty(pref)
                            ita_preferences(defined_preferences{idxn,1},defined_preferences{idxn,2});
                            disp(['Path does not exist : ' defined_preferences{idxn,1}])
                        else
                            ita_preferences(defined_preferences{idxn,1},pref);
                        end
                    otherwise
                        %                     ita_verbose_info(['ita_preferences_GUI::ignoring to write back ' type],2)
                end
            end
        end
        ita_verbose_info('ita_preferences: valves are burning as hell!',1)
        uiresume(fgh);
        close(fgh);
        
        if ~isempty(ita_preferences('fontsize'))
            set(0,'defaultaxesfontsize',ita_preferences('fontsize')); %mli
        end
        if ~isempty(ita_preferences('colorTableName')) %mli
            colorTableMatrix = ita_plottools_colortable('ita');
            set(0,'DefaultAxesColorOrder',colorTableMatrix)
        end
        
        ita_verbose_info('closing ita_preferences. finished.',2)
        return;
    end

% CANCEL button
    function CancelButtonCallback(hObject,eventdata)
        %         fgh = get(hObject,'Parent');
        %         if fgh == 0
        %             fgh = hObject;
        %         end
        fgh = gcf;
        uiresume(fgh);
        close(fgh);
        pause(0.1)
        return;
    end
    function BrowseCallback(hObject,eventdata)
        currentPath = get(get(hObject,'Userdata'),'String');
        try
            if isdir(currentPath)
                dir_str = uigetdir(currentPath);
            else
                dir_str = uigetdir(currentPath);
            end
        catch %Sometimes isdir return true for a path in the MatlabPath, but uigetdir will break down with an error
            dir_str = uigetdir();
        end
        if ischar(dir_str) && isdir(dir_str)
            x = get(hObject,'Userdata'); %handle for text field
            set(x,'String',dir_str);
        end
    end

    function ButtonCallback(s,e)
        % fprintf('Button callback: %s \n', e.Key);
        pause(0.001)
        switch(e.Key)
            case 'return'
                if strcmpi(get(s,'Type') , 'uicontrol') && strcmpi((get(s,'Style')),'edit' )
                    try
                        newValue = ita_str2num( get(s,'String'));
                        set(s, 'String', num2str(newValue));
                        
                    catch errMSG
                        set(s, 'String', '');
                        ita_verbose_info(['ita_str2num: ' errMSG.message],0)
                    end
                end
                
                OkayButtonCallback(s,e)
                
            case 'escape'
                CancelButtonCallback(s,e)
                
        end
    end

end


