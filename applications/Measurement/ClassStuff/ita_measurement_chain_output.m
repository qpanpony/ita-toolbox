function varargout = ita_measurement_chain_output(varargin)
%ITA_MEASUREMENT_CHAIN_OUTPUT - Set Channel information for output
%  This function produces a generic GUI to specify the channel settings.

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



%% Get ITA Toolbox preferences

narginchk(0,1);
if nargin == 0
    varargin{1} = 1;
end

%% Initialization
channelVec = varargin{1,1};
nChannels = length(channelVec);
% Dummy Settings
if isa(varargin{1} , 'itaMeasurementChain')
    CS = varargin{1}.MC2CS;
else % only number of channels given - show gui
    if isnumeric(channelVec)
        for idx = 1:nChannels
            % Dummy Settings
            CS(idx).Name = ['HWch' num2str(channelVec(idx))]; %#ok<AGROW>
            CS(idx).hw_ch = num2str(channelVec(idx)); %#ok<AGROW>
            CS(idx).DA                   = ''; %#ok<AGROW>
            CS(idx).Sensitivity_DA       = '1'; %#ok<AGROW>
            CS(idx).Amp                  = ''; %#ok<AGROW>
            CS(idx).Sensitivity_Amp      = '1'; %#ok<AGROW>
            CS(idx).Actuator             = ''; %#ok<AGROW>
            CS(idx).Sensitivity_Actuator = '1'; %#ok<AGROW>
            CS(idx).Coordinates  = itaCoordinates(); %#ok<AGROW>
            CS(idx).Orientation  = itaCoordinates(); %#ok<AGROW>
            CS(idx).UserData  = ''; %#ok<AGROW>
        end
    end
end
% draw all elements for the channels
CS = DrawChannelElements(CS);
if isempty(CS)
    varargout{1} = itaMeasurementChain(1);
else
    varargout(1) = {itaMeasurementChain(CS)};
end

end

%----------------------------------------------------------------------
function CS = DrawChannelElements(CS)

nChannels = length(CS);

%% Initialization
left_margin  =  5;
top_margin   = 25;
hor_space_s  =  5;
vert_space_s = 20; %small
height       = top_margin + 60 + nChannels * (hor_space_s + 15);
width        = 1100;
mpos = get(0,'Monitor');
w_position = (mpos(1,length(mpos)-1)/2)-(width/2);
h_position = (mpos(1,length(mpos))/2)-(height/2);
MainPosition = [w_position h_position width height];

clear figSet

%% name, helptext,size
for count = 1:nChannels
    %channel number
    figSet.size_gui1(count,:) = [30 20];
    figSet.pos_gui1(count,:)  = [left_margin (height-top_margin-count*vert_space_s)-5 figSet.size_gui1(count,:)];
    %channel names
    figSet.size_gui2(count,:) = [170 20];
    figSet.pos_gui2(count,:)  = [(figSet.pos_gui1(count,1)+figSet.size_gui1(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui2(count,:)];
    
    %channel Actuators
    figSet.size_gui3(count,:) = [160 20];
    figSet.pos_gui3(count,:)  = [(figSet.pos_gui2(count,1)+figSet.size_gui2(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui3(count,:)];
    
    %sensitivity_Amp
    figSet.size_gui4(count,:) = [160 20];
    figSet.pos_gui4(count,:)  = [(figSet.pos_gui3(count,1)+figSet.size_gui3(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui4(count,:)];
    
    %sensitivity_Actuator
    figSet.size_gui5(count,:) = [160 20];
    figSet.pos_gui5(count,:)  = [(figSet.pos_gui4(count,1)+figSet.size_gui4(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui5(count,:)];
    
    %channel coordinates
    figSet.size_gui6(count,:) = [120 20];
    figSet.pos_gui6(count,:)  = [(figSet.pos_gui5(count,1)+figSet.size_gui5(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui6(count,:)];
    %channel orientation
    figSet.size_gui7(count,:) = [120 20];
    figSet.pos_gui7(count,:)  = [(figSet.pos_gui6(count,1)+figSet.size_gui6(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui7(count,:)];
    %channel user data
    figSet.size_gui8(count,:) = [120 20];
    figSet.pos_gui8(count,:)  = [(figSet.pos_gui7(count,1)+figSet.size_gui7(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui8(count,:)];
end

gui_elements(1).column_title = figSet.pos_gui1(1,:) + [4 22 0 0];
gui_elements(1).text = 'HWch';
gui_elements(2).column_title = figSet.pos_gui2(1,:) + [4 18 0 0];
gui_elements(2).text = 'Name';
gui_elements(3).column_title = figSet.pos_gui3(1,:) + [4 18 0 0];
gui_elements(3).text = 'DA';
gui_elements(4).column_title = figSet.pos_gui4(1,:) + [4 18 0 0];
gui_elements(4).text = 'Amp';
gui_elements(5).column_title = figSet.pos_gui5(1,:) + [4 18 0 0];
gui_elements(5).text = 'Actuator';
gui_elements(6).column_title = figSet.pos_gui6(1,:) + [4 18 0 0];
gui_elements(6).text = 'Coordinates';
gui_elements(7).column_title = figSet.pos_gui7(1,:) + [4 18 0 0];
gui_elements(7).text = 'Orientation';
gui_elements(8).column_title = figSet.pos_gui8(1,:) + [4 18 0 0];
gui_elements(8).text = 'UserData';

persistent hMainFigure
if isempty(hMainFigure) || ~ishandle(hMainFigure)
    hMainFigure = figure( ...       % the main GUI figure
        'MenuBar','none', ...
        'Toolbar','none', ...
        'HandleVisibility','on', ...
        'Name', [mfilename ' - Define Measurement Chain'], ...
        'NumberTitle','off', ...
        'Position' , MainPosition, ...
        'Color', [0.8 0.8 0.8]);
elseif ~strcmpi(get(hMainFigure,'Name'),'Define Channels')
    hMainFigure = figure( ...       % the main GUI figure
        'MenuBar','none', ...
        'Toolbar','none', ...
        'HandleVisibility','on', ...
        'Name', 'Define Channels', ...
        'NumberTitle','off', ...
        'Position' , MainPosition, ...
        'Color', [0.8 0.8 0.8]);
else
    clf(hMainFigure)
end
figSet.hMainFigure = hMainFigure;
set(hMainFigure,'KeyPressFcn',@ButtonCallback)

%% ITA toolbox logo with grey background
a_im = importdata(which('ita_toolbox_logo.png'));
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [20 10 350 65]*0.6); %TODO: later set correctly the position

%% pushbuttons - ui control elements
pb_offset = 400;

uicontrol(...
    'Parent', hMainFigure, ...
    'Position',[270+pb_offset 10 100 30],...
    'String', 'Cancel',...
    'Style', 'pushbutton',...
    'Callback', @CancelButtonCallback);

uicontrol(...
    'Parent', hMainFigure, ...
    'Position',[375+pb_offset 10 100 30],...
    'String', 'OK',...
    'Style', 'pushbutton',...
    'Callback', @OkayButtonCallback);

%% text elements
% title stuff
for jdx = 1:length(gui_elements)
    uicontrol(...
        'Parent', hMainFigure,...
        'Position', gui_elements(jdx).column_title,...
        'FontWeight','bold',...
        'String',gui_elements(jdx).text,...
        'TooltipString','Hardware channel ID of sound card',...
        'Style', 'text',...
        'ForegroundColor', [0 0 .7],...
        'BackgroundColor', [0.8 0.8 0.8]);
end

% field stuff
for count = 1:nChannels
    if ~isempty(CS(count).DA)
        CS_DA_str = ['[' CS(count).DA '](' num2str(CS(count).Sensitivity_DA) ')|'];
    else
        CS_DA_str = '';
    end
    
    if ~isempty(CS(count).Amp)
        CS_Amp_str = ['[' CS(count).Amp '](' num2str(CS(count).Sensitivity_Amp) ')|'];
    else
        CS_Amp_str = '';
    end
    
    if ~isempty(CS(count).Actuator)
        CS_Actuator_str = ['[' CS(count).Actuator '](' num2str(CS(count).Sensitivity_Actuator) ')|'];
    else
        CS_Actuator_str = '';
    end
    
    % Channel ID
    devListHandle = ita_device_list_handle;
    uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui1(count,:),...
        'HorizontalAlignment','right',...
        'String',['' CS(count).hw_ch ],...
        'FontWeight','bold',...
        'Style', 'text',...
        'Tag',num2str(count),...
        'BackgroundColor', [0.8 0.8 0.8] );
    
    % Channel Names
    hUiChannelNames(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'HorizontalAlignment','left',...
        'Position', figSet.pos_gui2(count,:),...
        'String', CS(count).Name,...
        'Style', 'edit',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 0.9 1],...
        'Callback', @UpdateUiChannelNames_txt ); %#ok<AGROW>
    
    % Channel DA Type
    hUiSensitivities_DA(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui3(count,:),...
        'HorizontalAlignment','right',...
        'FontWeight','bold',...
        'String',[CS_DA_str devListHandle('da','guilist',CS(count).hw_ch) '|custom...'],...
        'Style', 'popup',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelSensitivities_DA_txt ); %#ok<AGROW>
    
    
    % Channel Sensitivities_Amp
    hUiSensitivities_Amp(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'HorizontalAlignment','right',...
        'Position', figSet.pos_gui4(count,:),...
        'String',[CS_Amp_str devListHandle('amp','guilist',CS(count).hw_ch), '|auto|custom...'],...
        'FontWeight','bold',...
        'Style', 'popup',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelSensitivities_Amp_txt ); %#ok<AGROW>
    
    % Channel Sensitivities_Actuator
    hUiSensitivities_Actuator(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'HorizontalAlignment','right',...
        'Position', figSet.pos_gui5(count,:),...
        'String',[CS_Actuator_str devListHandle('actuator','guilist',CS(count).hw_ch), '|auto|custom...'],...
        'FontWeight','bold',...
        'Style', 'popup',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelSensitivities_Actuator_txt ); %#ok<AGROW>
    
    
    % Channel Coordinates
    hUiChannelCoordinates(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui6(count,:),...
        'HorizontalAlignment','right',...
        'String', mat2str(CS(count).Coordinates.cart),...
        'Style', 'edit',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelCoordinates_txt ); %#ok<AGROW>
    
    % Channel Orientation
    hUiChannelOrientation(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui7(count,:),...
        'HorizontalAlignment','right',...
        'String', mat2str(CS(count).Orientation.cart),...
        'Style', 'edit',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelOrientation_txt ); %#ok<AGROW>
    
    % Channel User Data
    hUiChannelUserData(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui8(count,:),...
        'HorizontalAlignment','right',...
        'String', CS(count).UserData,...
        'Style', 'edit',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelUserData_txt ); %#ok<AGROW>
end

% Make the GUI blocking
uiwait(figSet.hMainFigure);

%----------------------------------------------------------------------
    function UpdateUiChannelNames_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        CS(channel_id).Name = get(hObject,'String');
    end

%----------------------------------------------------------------------
    function UpdateUiChannelSensitivities_Actuator_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2double(get(hObject,'Tag'));
        if strcmp(get(hObject,'style'),'popupmenu')
            tokenList = get(hObject,'String');
            ChannelSensitivity_Actuator = tokenList(get(hObject,'Value'),:);
            
            if strncmp(ChannelSensitivity_Actuator,'custom...',6)    %Style is converted to edit
                hUiSensitivities_Actuator(channel_id) = uicontrol(...
                    'Parent', figSet.hMainFigure,...
                    'HorizontalAlignment','right',...
                    'Position', figSet.pos_gui5(channel_id,:),...
                    'String','[name](sensitivity unit)',...
                    'FontWeight','bold',...
                    'Style', 'edit',...
                    'Tag',num2str(channel_id) ,...
                    'BackgroundColor', [1 1 1],...
                    'Callback', @UpdateUiChannelSensitivities_Actuator_txt );
            end
            ChannelSensitivity_Actuator = ChannelSensitivity_Actuator(ChannelSensitivity_Actuator ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_Actuator = ChannelSensitivity_Actuator;
            
        else                                                %Style is converted to popup
            CS(channel_id).Sensitivity_Actuator = get(hObject,'String');
            
            hUiSensitivities_Actuator(channel_id) = uicontrol(...
                'Parent', figSet.hMainFigure,...
                'HorizontalAlignment','right',...
                'Position', figSet.pos_gui5(channel_id,:),...
                'String',[CS(channel_id).Sensitivity_Actuator '|' ,devListHandle('string',1,'type','Actuator'), 'auto' '|' 'custom...'],...
                'FontWeight','bold',...
                'Style', 'popup',...
                'Tag',num2str(channel_id) ,...
                'BackgroundColor', [1 1 1],...
                'Callback', @UpdateUiChannelSensitivities_Actuator_txt );
            
            tokenList = get(hObject,'String');
            ChannelSensitivity_Actuator = tokenList;
            ChannelSensitivity_Actuator = ChannelSensitivity_Actuator(ChannelSensitivity_Actuator ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_Actuator = ChannelSensitivity_Actuator;
        end
    end

%----------------------------------------------------------------------
    function UpdateUiChannelSensitivities_Amp_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2double(get(hObject,'Tag'));
        
        if strcmp(get(hObject,'style'),'popupmenu')
            tokenList = get(hObject,'String');
            ChannelSensitivity_Amp = tokenList(get(hObject,'Value'),:);
            
            if strncmp(ChannelSensitivity_Amp,'custom...',6)    %Style is converted to edit
                hUiSensitivities_Amp(channel_id) = uicontrol(...
                    'Parent', figSet.hMainFigure,...
                    'HorizontalAlignment','right',...
                    'Position', figSet.pos_gui4(channel_id,:),...
                    'String','[name](sensitivity unit)',...
                    'FontWeight','bold',...
                    'Style', 'edit',...
                    'Tag',num2str(channel_id) ,...
                    'BackgroundColor', [1 1 1],...
                    'Callback', @UpdateUiChannelSensitivities_Amp_txt );
            end
            ChannelSensitivity_Amp = ChannelSensitivity_Amp(ChannelSensitivity_Amp ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_Amp = {ChannelSensitivity_Amp};
            
        else                                                %Style is converted to popup
            CS(channel_id).Sensitivity_Amp = get(hObject,'String');
            
            hUiSensitivities_Amp(channel_id) = uicontrol(...
                'Parent', figSet.hMainFigure,...
                'HorizontalAlignment','right',...
                'Position', figSet.pos_gui4(channel_id,:),...
                'String',[CS(channel_id).Sensitivity_Amp '|' ,devListHandle('string',1,'type','pre'), 'auto' '|' 'custom...'],...
                'FontWeight','bold',...
                'Style', 'popup',...
                'Tag',num2str(channel_id) ,...
                'BackgroundColor', [1 1 1],...
                'Callback', @UpdateUiChannelSensitivities_Amp_txt );
            
            tokenList = get(hObject,'String');
            ChannelSensitivity_Amp = tokenList;
            ChannelSensitivity_Amp = ChannelSensitivity_Amp(ChannelSensitivity_Amp ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_Amp = ChannelSensitivity_Amp;
        end
    end

%----------------------------------------------------------------------
    function UpdateUiChannelSensitivities_DA_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2double(get(hObject,'Tag'));
        
        if strcmp(get(hObject,'style'),'popupmenu')
            tokenList = get(hObject,'String');
            ChannelSensitivity_DA = tokenList(get(hObject,'Value'),:);
            
            if strncmp(ChannelSensitivity_DA,'custom...',6)    %Style is converted to edit
                hUiSensitivities_DA(channel_id) = uicontrol(...
                    'Parent', figSet.hMainFigure,...
                    'HorizontalAlignment','right',...
                    'Position', figSet.pos_gui3(channel_id,:),...
                    'String','[name](sensitivity unit)',...
                    'FontWeight','bold',...
                    'Style', 'edit',...
                    'Tag',num2str(channel_id) ,...
                    'BackgroundColor', [1 1 1],...
                    'Callback', @UpdateUiChannelSensitivities_DA_txt );
            end
            ChannelSensitivity_DA = ChannelSensitivity_DA(ChannelSensitivity_DA ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_DA = ChannelSensitivity_DA;
            
        else                                                %Style is converted to popup
            CS(channel_id).Sensitivity_DA = get(hObject,'String');
            
            hUiSensitivities_DA(channel_id) = uicontrol(...
                'Parent', figSet.hMainFigure,...
                'HorizontalAlignment','right',...
                'Position', figSet.pos_gui3(channel_id,:),...
                'String',[CS(channel_id).Sensitivity_DA '|' ,devListHandle('string',1,'type','sens'), 'auto' '|' 'auto WB' '|' 'custom...'],...
                'FontWeight','bold',...
                'Style', 'popup',...
                'Tag',num2str(channel_id) ,...
                'BackgroundColor', [1 1 1],...
                'Callback', @UpdateUiChannelSensitivities_DA_txt );
            
            tokenList = get(hObject,'String');
            ChannelSensitivity_DA = tokenList;
            ChannelSensitivity_DA = ChannelSensitivity_DA(ChannelSensitivity_DA ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_DA = ChannelSensitivity_DA;
        end
    end

    function UpdateUiChannelDAType_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2double(get(hObject,'Tag'));
        tokenList = get(hObject,'String');
        ChannelDAType = tokenList(get(hObject,'Value'),:);
        ChannelDAType = ChannelDAType(ChannelDAType ~= ' '); %delete spaces
        CS(channel_id).DA = ChannelDAType;
    end
%----------------------------------------------------------------------
    function UpdateUiChannelCoordinates_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        CS(channel_id).Coordinates = itaCoordinates(str2num(get(hObject,'String')),'cart');
    end

%----------------------------------------------------------------------
    function UpdateUiChannelOrientation_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        CS(channel_id).Orientation = itaCoordinates(str2num(get(hObject,'String')),'cart');
    end

%----------------------------------------------------------------------
    function UpdateUiChannelUserData_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        CS(channel_id).UserData = get(hObject,'String');
    end

%----------------------------------------------------------------------
    function CancelButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        uiresume(gcf);
        close(gcf)
        return;
    end

    function OkayButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        thisFuncStr  = [upper(mfilename) ':'];
        
        for idx = 1:length(hUiChannelNames)
            CS(idx).Name  = get(hUiChannelNames(idx), 'String');
            
            % ChannelDAType = ChannelDAType(ChannelDAType ~= ' '); %delete spaces
            CS(idx).hw_ch = str2num(CS(idx).hw_ch); %#ok<ST2NM>
            if (get(hUiSensitivities_Actuator(idx),'Value')==0)
                error([thisFuncStr ' Sensitivity of Actuator is missing ']);
            else
                tokenListSensitivities_Actuator = get(hUiSensitivities_Actuator(idx),'String');
                Sensitivities_Actuator = tokenListSensitivities_Actuator(get(hUiSensitivities_Actuator(idx),'Value'),:);
                CS(idx).Actuator = 'no name';
                if Sensitivities_Actuator(1) == '['
                    [Sensitivities_Actuator CS(idx).Actuator] = devListHandle('actuator',Sensitivities_Actuator);
                else
                    Sensitivities_Actuator = deblank(Sensitivities_Actuator);
                end
                %Sensitivities_Actuator = Sensitivities_Actuator(Sensitivities_Actuator ~= ' '); %delete spaces
                CS(idx).Sensitivity_Actuator = Sensitivities_Actuator;
            end
            
            %% Amp
            if (get(hUiSensitivities_Amp(idx),'Value')==0)
                error([thisFuncStr ' Sensitivity of Amp is missing ']);
            else
                tokenListSensitivities_Amp = get(hUiSensitivities_Amp(idx),'String');
                Sensitivities_Amp = tokenListSensitivities_Amp(get(hUiSensitivities_Amp(idx),'Value'),:);
                CS(idx).Amp = 'no name';
                if Sensitivities_Amp(1) == '['
                    [Sensitivities_Amp CS(idx).Amp] = devListHandle('Amp',Sensitivities_Amp);
                else
                    Sensitivities_Amp = deblank(Sensitivities_Amp);
                end
                %Sensitivities_Amp = Sensitivities_Amp(Sensitivities_Amp ~= ' '); %delete spaces
                CS(idx).Sensitivity_Amp = Sensitivities_Amp;
            end
            
            %% DA
            if (get(hUiSensitivities_DA(idx),'Value')==0)
                error([thisFuncStr ' Sensitivity of DA is missing ']);
            else
                tokenListSensitivities_DA = get(hUiSensitivities_DA(idx),'String');
                Sensitivities_DA = tokenListSensitivities_DA(get(hUiSensitivities_DA(idx),'Value'),:);
                CS(idx).DA = 'no name';
                if Sensitivities_DA(1) == '['
                    [Sensitivities_DA CS(idx).DA] = devListHandle('DA',Sensitivities_DA);
                else
                    Sensitivities_DA = deblank(Sensitivities_DA);
                end
                %Sensitivities_DA = Sensitivities_DA(Sensitivities_DA ~= ' '); %delete spaces
                CS(idx).Sensitivity_DA = Sensitivities_DA;
            end
            
            CS(idx).Coordinates = itaCoordinates(str2num(get(hUiChannelCoordinates(idx),'String')),'cart');
            CS(idx).Orientation = itaCoordinates(str2num(get(hUiChannelOrientation(idx),'String')),'cart');
            CS(idx).UserData = get(hUiChannelUserData(idx),'String');
        end
        uiresume(gcf);
        close(gcf);
        return;
    end

%----------------------------------------------------------------------

    function ButtonCallback(s,e)
        % fprintf('Button callback: %s \n', e.Key);
        switch(e.Key)
            case 'return'
                OkayButtonCallback(s,[])
            case 'escape'
                CancelButtonCallback(s,[])
        end
        
    end %end function

end
