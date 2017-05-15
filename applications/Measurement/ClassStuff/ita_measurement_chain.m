function varargout = ita_measurement_chain(varargin)
%ITA_MEASUREMENT_CHAIN - Set Channel information
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
% error(nargchk(1,2,nargin,'string'));
show_GUI = 1;
if isa(varargin{1} , 'itaMeasurementChain')
    CS = varargin{1}.MC2CS;
else % only number of channels given - show gui
    %% NEW CASE
    channelVec = varargin{1,1};
    nChannels = length(channelVec);
    
    % Dummy Settings
    if isnumeric(channelVec)
        for idx = 1:nChannels
            CS(idx).Name = ['HWch' num2str(channelVec(idx))]; %#ok<AGROW>
            CS(idx).hw_ch = num2str(channelVec(idx)); %#ok<AGROW>
            CS(idx).Unit = 'Pa'; %#ok<AGROW>
            CS(idx).AD = ''; %#ok<AGROW>
            CS(idx).PreAmp = ''; %#ok<AGROW>
            CS(idx).Sensitivity_AD = '1'; %#ok<AGROW>
            CS(idx).Sensitivity_PreAmp = '1'; %#ok<AGROW>
            CS(idx).Sensitivity_Sensor = '1'; %#ok<AGROW>
            CS(idx).Sensor = ''; %#ok<AGROW>
            CS(idx).Coordinates  = itaCoordinates(); %#ok<AGROW>
            CS(idx).Orientation  = itaCoordinates(); %#ok<AGROW>
            CS(idx).UserData  = ''; %#ok<AGROW>
        end
    elseif exist(channelVec,'file') %seems to be a file
        %% FILE
        CS = squeeze(load(channelVec,'ChannelSettings','-mat'));
        if isfield(CS,'ChannelSettings') % stupid bug, don't know how to fix that right now
            CS = CS.ChannelSettings;
        end
        show_GUI = false;
    end
end

% draw all elements for the channels
if show_GUI
    CS = DrawChannelElements(CS);
end

varargout(1) = {itaMeasurementChain(CS)};

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
gui_bg_color  = [0.8 0.8 0.8];

clear figSet

%% name, helptext,size
for count = 1:nChannels
    %hwch channel number
    figSet.size_gui1(count,:) = [40 20];
    figSet.pos_gui1(count,:)  = [left_margin (height-top_margin-count*vert_space_s)-5 figSet.size_gui1(count,:)];
    %channel names
    figSet.size_gui2(count,:) = [170 20];
    figSet.pos_gui2(count,:)  = [(figSet.pos_gui1(count,1)+figSet.size_gui1(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui2(count,:)];
    
    %channel sensors
    figSet.size_gui3(count,:) = [160 20];
    figSet.pos_gui3(count,:)  = [(figSet.pos_gui2(count,1)+figSet.size_gui2(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui3(count,:)];
    
    %sensitivity_PreAmp
    figSet.size_gui4(count,:) = [160 20];
    figSet.pos_gui4(count,:)  = [(figSet.pos_gui3(count,1)+figSet.size_gui3(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui4(count,:)];
    
    %sensitivity_AD
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
gui_elements(3).text = 'Sensor';
gui_elements(4).column_title = figSet.pos_gui4(1,:) + [4 18 0 0];
gui_elements(4).text = 'Preamp';
gui_elements(5).column_title = figSet.pos_gui5(1,:) + [4 18 0 0];
gui_elements(5).text = 'AD';
gui_elements(6).column_title = figSet.pos_gui6(1,:) + [4 18 0 0];
gui_elements(6).text = 'Coordinates';
gui_elements(7).column_title = figSet.pos_gui7(1,:) + [4 18 0 0];
gui_elements(7).text = 'Orientation';
gui_elements(8).column_title = figSet.pos_gui8(1,:) + [4 18 0 0];
gui_elements(8).text = 'UserData';

hMainFigure = figure( ...       % the main GUI figure
    'MenuBar','none', ...
    'Toolbar','none', ...
    'HandleVisibility','on', ...
    'Name', [mfilename ' - Define Input Measurement Chain'], ...
    'NumberTitle','off', ...
    'Position' , MainPosition, ...
    'Color', [0.8 0.8 0.8]);

set(hMainFigure,'KeyPressFcn',@ButtonCallback)

figSet.hMainFigure = hMainFigure;

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
    % some init stuff for old settings
    CS_AD_str = '';
    if ~isempty(CS(count).AD)
        CS_AD_str = ['[' CS(count).AD '](' num2str(CS(count).Sensitivity_AD) ')|'];
    end
    CS_PreAmp_str = '';
    if ~isempty(CS(count).PreAmp)
        CS_PreAmp_str = ['[' CS(count).PreAmp '](' num2str(CS(count).Sensitivity_PreAmp) ')|'];
    end
    CS_Sensor_str = '';
    if ~isempty(CS(count).Sensor)
        CS_Sensor_str = ['[' CS(count).Sensor '](' num2str(CS(count).Sensitivity_Sensor) ')|'];
    end
    devListHandle = ita_device_list_handle;
    
    % Channel ID
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
        'Callback', @UpdateUiChannelNames_txt );  %#ok<AGROW>
    
    % Channel Sensor Type
    hUiSensitivities_Sensor(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui3(count,:),...
        'HorizontalAlignment','right',...
        'FontWeight','bold',...
        'String',[CS_Sensor_str devListHandle('sensor','guilist') '|custom...'],...
        'Style', 'popup',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelSensitivities_Sensor_txt ); %#ok<AGROW>
    
    % Channel Sensitivities_PreAmp
    hUiSensitivities_PreAmp(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'HorizontalAlignment','right',...
        'Position', figSet.pos_gui4(count,:),...
        'String',[CS_PreAmp_str devListHandle('preamp','guilist',CS(count).hw_ch), '|custom...'],...
        'FontWeight','bold',...
        'Style', 'popup',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelSensitivities_PreAmp_txt ); %#ok<AGROW>
    
    % Channel Sensitivities_AD
    hUiSensitivities_AD(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'HorizontalAlignment','right',...
        'Position', figSet.pos_gui5(count,:),...
        'String',[CS_AD_str devListHandle('ad','guilist',CS(count).hw_ch), '|custom...'],...
        'FontWeight','bold',...
        'Style', 'popup',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelSensitivities_AD_txt ); %#ok<AGROW>
    
    
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
    function UpdateUiChannelSensitivities_AD_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2double(get(hObject,'Tag'));
        
        if strcmp(get(hObject,'style'),'popupmenu')
            tokenList = get(hObject,'String');
            ChannelSensitivity_AD = tokenList(get(hObject,'Value'),:);
            
            if strncmp(ChannelSensitivity_AD,'custom...',6)    %Style is converted to edit
                hUiSensitivities_AD(channel_id) = uicontrol(...
                    'Parent', figSet.hMainFigure,...
                    'HorizontalAlignment','left',...
                    'Position', figSet.pos_gui5(channel_id,:),...
                    'String','[name](sensitivity unit)',...
                    'FontWeight','bold',...
                    'Style', 'edit',...
                    'Tag',num2str(channel_id) ,...
                    'BackgroundColor', [1 1 1],...
                    'Callback', @UpdateUiChannelSensitivities_AD_txt );
            end
            ChannelSensitivity_AD = ChannelSensitivity_AD(ChannelSensitivity_AD ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_AD = (ChannelSensitivity_AD);
            
        else                                                %Style is converted to popup
            CS(channel_id).Sensitivity_AD = get(hObject,'String');
            
            hUiSensitivities_AD(channel_id) = uicontrol(...
                'Parent', figSet.hMainFigure,...
                'HorizontalAlignment','right',...
                'Position', figSet.pos_gui5(channel_id,:),...
                'String',[CS(channel_id).Sensitivity_AD '|' ,devListHandle('string',1,'type','AD'), 'auto' '|' 'custom...'],...
                'FontWeight','bold',...
                'Style', 'popup',...
                'Tag',num2str(channel_id) ,...
                'BackgroundColor', [1 1 1],...
                'Callback', @UpdateUiChannelSensitivities_AD_txt );
            
            tokenList = get(hObject,'String');
            ChannelSensitivity_AD = tokenList;
            ChannelSensitivity_AD = ChannelSensitivity_AD(ChannelSensitivity_AD ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_AD = ChannelSensitivity_AD;
        end
    end

%----------------------------------------------------------------------
    function UpdateUiChannelSensitivities_PreAmp_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2double(get(hObject,'Tag'));
        
        if strcmp(get(hObject,'style'),'popupmenu')
            tokenList = get(hObject,'String');
            ChannelSensitivity_PreAmp = tokenList(get(hObject,'Value'),:);
            
            if strncmp(ChannelSensitivity_PreAmp,'custom...',6)    %Style is converted to edit
                hUiSensitivities_PreAmp(channel_id) = uicontrol(...
                    'Parent', figSet.hMainFigure,...
                    'HorizontalAlignment','left',...
                    'Position', figSet.pos_gui4(channel_id,:),...
                    'String','[name](sensitivity unit)',...
                    'FontWeight','bold',...
                    'Style', 'edit',...
                    'Tag',num2str(channel_id) ,...
                    'BackgroundColor', [1 1 1],...
                    'Callback', @UpdateUiChannelSensitivities_PreAmp_txt );
            end
            ChannelSensitivity_PreAmp = ChannelSensitivity_PreAmp(ChannelSensitivity_PreAmp ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_PreAmp = (ChannelSensitivity_PreAmp);
            
        else                                                %Style is converted to popup
            CS(channel_id).Sensitivity_PreAmp = get(hObject,'String');
            
            hUiSensitivities_PreAmp(channel_id) = uicontrol(...
                'Parent', figSet.hMainFigure,...
                'HorizontalAlignment','right',...
                'Position', figSet.pos_gui4(channel_id,:),...
                'String',[CS(channel_id).Sensitivity_PreAmp '|' ,devListHandle('string',1,'type','pre'), 'auto' '|' 'custom...'],...
                'FontWeight','bold',...
                'Style', 'popup',...
                'Tag',num2str(channel_id) ,...
                'BackgroundColor', [1 1 1],...
                'Callback', @UpdateUiChannelSensitivities_PreAmp_txt );
            
            tokenList = get(hObject,'String');
            ChannelSensitivity_PreAmp = tokenList;
            ChannelSensitivity_PreAmp = ChannelSensitivity_PreAmp(ChannelSensitivity_PreAmp ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_PreAmp = ChannelSensitivity_PreAmp; 
        end
    end

%----------------------------------------------------------------------
    function UpdateUiChannelSensitivities_Sensor_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2double(get(hObject,'Tag'));
        
        if strcmp(get(hObject,'style'),'popupmenu')
            tokenList = get(hObject,'String');
            ChannelSensitivity_Sensor = tokenList(get(hObject,'Value'),:);
            
            if strncmp(ChannelSensitivity_Sensor,'custom...',6)    %Style is converted to edit
                hUiSensitivities_Sensor(channel_id) = uicontrol(...
                    'Parent', figSet.hMainFigure,...
                    'HorizontalAlignment','left',...
                    'Position', figSet.pos_gui3(channel_id,:),...
                    'String','[name](sensitivity unit)',...
                    'FontWeight','bold',...
                    'Style', 'edit',...
                    'Tag',num2str(channel_id) ,...
                    'BackgroundColor', [1 1 1],...
                    'Callback', @UpdateUiChannelSensitivities_Sensor_txt );
            end
            ChannelSensitivity_Sensor = ChannelSensitivity_Sensor(ChannelSensitivity_Sensor ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_Sensor = (ChannelSensitivity_Sensor);
            
        else                                                %Style is converted to popup
            CS(channel_id).Sensitivity_Sensor = get(hObject,'String');
            
            hUiSensitivities_Sensor(channel_id) = uicontrol(...
                'Parent', figSet.hMainFigure,...
                'HorizontalAlignment','right',...
                'Position', figSet.pos_gui3(channel_id,:),...
                'String',[CS(channel_id).Sensitivity_Sensor '|' ,devListHandle('string',1,'type','sens'), 'auto' '|' 'auto WB' '|' 'custom...'],...
                'FontWeight','bold',...
                'Style', 'popup',...
                'Tag',num2str(channel_id) ,...
                'BackgroundColor', [1 1 1],...
                'Callback', @UpdateUiChannelSensitivities_Sensor_txt );
            
            tokenList = get(hObject,'String');
            ChannelSensitivity_Sensor = tokenList;
            ChannelSensitivity_Sensor = ChannelSensitivity_Sensor(ChannelSensitivity_Sensor ~= ' '); %delete spaces
            CS(channel_id).Sensitivity_Sensor = ChannelSensitivity_Sensor;
        end
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
        CS = [];
        return;
    end

    function OkayButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        thisFuncStr  = [upper(mfilename) ':'];
        
        for idx = 1:length(hUiChannelNames)
            CS(idx).Name  = get(hUiChannelNames(idx), 'String');
            
            % ChannelSensorType = ChannelSensorType(ChannelSensorType ~= ' '); %delete spaces
            CS(idx).hw_ch = str2num(CS(idx).hw_ch); %#ok<ST2NM>
            if (get(hUiSensitivities_AD(idx),'Value')==0)
                error([thisFuncStr ' Sensitivity of AD is missing ']);
            else
                tokenListSensitivities_AD = get(hUiSensitivities_AD(idx),'String');
                Sensitivities_AD = tokenListSensitivities_AD(get(hUiSensitivities_AD(idx),'Value'),:);
                CS(idx).AD = 'no name';
                if Sensitivities_AD(1) == '['
                    [Sensitivities_AD CS(idx).AD] = devListHandle('ad',Sensitivities_AD);
                else
                    Sensitivities_AD = deblank(Sensitivities_AD);
                end
                %Sensitivities_AD = Sensitivities_AD(Sensitivities_AD ~= ' '); %delete spaces
                CS(idx).Sensitivity_AD = Sensitivities_AD;
            end
            
            %% Preamp
            if (get(hUiSensitivities_PreAmp(idx),'Value')==0)
                error([thisFuncStr ' Sensitivity of PreAmp is missing ']);
            else
                tokenListSensitivities_PreAmp = get(hUiSensitivities_PreAmp(idx),'String');
                Sensitivities_PreAmp = tokenListSensitivities_PreAmp(get(hUiSensitivities_PreAmp(idx),'Value'),:);
                CS(idx).PreAmp = 'no name';
                if Sensitivities_PreAmp(1) == '['
                    [Sensitivities_PreAmp CS(idx).PreAmp] = devListHandle('preamp',Sensitivities_PreAmp);
                else
                    Sensitivities_PreAmp = deblank(Sensitivities_PreAmp);
                end
                %Sensitivities_PreAmp = Sensitivities_PreAmp(Sensitivities_PreAmp ~= ' '); %delete spaces
                CS(idx).Sensitivity_PreAmp = Sensitivities_PreAmp;
            end
            
            %% Sensor
            if (get(hUiSensitivities_Sensor(idx),'Value')==0)
                error([thisFuncStr ' Sensitivity of Sensor is missing ']);
            else
                tokenListSensitivities_Sensor = get(hUiSensitivities_Sensor(idx),'String');
                Sensitivities_Sensor = tokenListSensitivities_Sensor(get(hUiSensitivities_Sensor(idx),'Value'),:);
                if Sensitivities_Sensor(1) == '['
                    [Sensitivities_Sensor CS(idx).Sensor] = devListHandle('sensor',Sensitivities_Sensor);
                else
                    Sensitivities_Sensor = deblank(Sensitivities_Sensor);
                end
                %Sensitivities_Sensor = Sensitivities_Sensor(Sensitivities_Sensor ~= ' '); %delete spaces
                CS(idx).Sensitivity_Sensor = Sensitivities_Sensor;
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
        
        %end function
    end
end %end function
