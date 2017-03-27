function varargout = ita_channel_settings(varargin)
%ITA_CHANNEL_SETTINGS - Set Channel information
%  This function produces a generic GUI to specify the channel settings.
%  Useful for measurement setups and intialization. It can also change the
%  header entries in an audioObj and multiply the channel data with a
%  given factor. Everything can be saved in a file. The file is a standard
%  matlab workspace file (.mat) with the extension (.ich).
%
%  Call: ChannelSettings = ita_channel_settings(nChannels) - opens GUI
%        ChannelSettings = ita_channel_settings(nChannels, ChannelSettings) - opens GUI, with preset fields
%
%  Call: audioObj = ita_channel_settings(audioObj) - opens GUI
%
%  Call: audioObj = ita_channel_settings(audioObj,ChannelSettings) -
%          this will compensate everything
%  Call: audioObj = ita_channel_settings(audioObj,'ChannelSettings.filename') -
%          this will compensate everything with the information in the .ich file
%  Call: ChannelSettings = ita_channel_settings('ChannelSettings.filename') -
%          read channel settings from .ich file and return struct
%
%   See also ita_measurement_setup.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_channel_settings">doc ita_channel_settings</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  22-Sep-2008


%% Initialization
 narginchk(1,2);

if isa(varargin{1},'itaSuper')
    
    data = varargin{1};
    %get real settings
    
    
    %show gui and get the user channel settings there
    % empty channelsettings struct
    ChannelSettings = struct('Unit',{},'Coordinates',itaCoordinates(),...
        'Orientation',itaCoordinates,'UserData',{},'Name',{},'comment',{},'samplingRate',{},'signalType',{},'dateCreated',{},'dateModified',{},'fileName',{});
    ChannelSettings = repmat(ChannelSettings,1,data.nChannels);
    
    for idx = 1:data.nChannels
        ChannelSettings(idx).Unit = data.channelUnits{idx};
        ChannelSettings(idx).Coordinates = data.channelCoordinates.n(idx);
        ChannelSettings(idx).Orientation = data.channelOrientation.n(idx);
        ChannelSettings(idx).UserData = data.channelUserData{idx};
        ChannelSettings(idx).Name = data.channelNames{idx};
        if (idx==1)
            ChannelSettings.Comment = data.comment;
            if isa(data,'itaAudio')
                ChannelSettings.samplingRate = data.samplingRate;
                ChannelSettings.signalType = data.signalType;
                ChannelSettings.dateCreated = data.dateCreated;
                ChannelSettings.dateModified = data.dateModified;
                ChannelSettings.fileName = data.fileName;
            end
        end
    end
    
else
    error('ITA_CHANNEL_SETTINGS: That does not work. Input has to be ita_Audio')
end

% draw all elements for the channels

ChannelSettings = DrawChannelElements(ChannelSettings,data);

if isa(varargin{1},'itaSuper')
    for idx = 1:data.nChannels
        data.channelNames(idx) = {ChannelSettings(idx).Name};
        data.channelUnits(idx) = {ChannelSettings(idx).Unit};
        try %pdi:out
            if isa(ChannelSettings(idx).Coordinates,'itaCoordinates')
                data.channelCoordinates.cart(idx,:) = ChannelSettings(idx).Coordinates.cart;
            else
                data.channelCoordinates(idx) = itaCoordinates(ChannelSettings(idx).Coordinates,'cart');
            end
            
            if isa(ChannelSettings(idx).Orientation,'itaCoordinates')
                data.channelOrientation.cart(idx,:) = ChannelSettings(idx).Orientation.cart;
            else
                data.channelOrientation(idx) = itaCoordinates(ChannelSettings(idx).Orientation,'cart');
            end
        end
        data.channelUserData(idx) = {ChannelSettings(idx).UserData};
        
    end
    data.comment = ChannelSettings(1).Comment;
    if isa(data,'itaAudio')
        data.samplingRate = ChannelSettings(1).samplingRate;
        data.signalType   = ChannelSettings(1).signalType;
        data.dateCreated  = ChannelSettings(1).dateCreated;
        data.dateModified = ChannelSettings(1).dateModified;
        data.fileName     = ChannelSettings(1).fileName;
    end
    varargout(1) = {data};
end
end
%----------------------------------------------------------------------
function ChannelSettings = DrawChannelElements(ChannelSettings,data)

nChannels = length(ChannelSettings);

%% Initialization

mpos = get(0,'Monitor');

left_margin  =  5;
top_margin   = 40;
hor_space_s  =  5;
vert_space_s = 20; %small
height       = top_margin + 60 + nChannels * (hor_space_s + 15);
width        = 900;
w_position = (mpos(1,length(mpos)-1)/2)-(width/2);
h_position = (mpos(1,length(mpos))/2)-(height/2);

MainPosition = [w_position h_position width height];

clear figSet
for count = 1:nChannels
    %channel number
    figSet.size_gui1(count,:) = [25 20];
    figSet.pos_gui1(count,:)  = [left_margin (height-top_margin-count*vert_space_s)-5 figSet.size_gui1(count,:)];
    %channel names
    figSet.size_gui2(count,:) = [250 20];
    figSet.pos_gui2(count,:)  = [(figSet.pos_gui1(count,1)+figSet.size_gui1(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui2(count,:)];
    %channel units
    figSet.size_gui3(count,:) = [80 20];
    figSet.pos_gui3(count,:)  = [(figSet.pos_gui2(count,1)+figSet.size_gui2(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui3(count,:)];
    %channel coordinates
    figSet.size_gui4(count,:) = [190 20];
    figSet.pos_gui4(count,:)  = [(figSet.pos_gui3(count,1)+figSet.size_gui3(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui4(count,:)];
    %channel orientation
    figSet.size_gui5(count,:) = [190 20];
    figSet.pos_gui5(count,:)  = [(figSet.pos_gui4(count,1)+figSet.size_gui4(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui5(count,:)];
    %channel user data
    figSet.size_gui6(count,:) = [125 20];
    figSet.pos_gui6(count,:)  = [(figSet.pos_gui5(count,1)+figSet.size_gui5(count,1) + hor_space_s) (height-top_margin-count*vert_space_s) figSet.size_gui6(count,:)];
end

%channel comment
figSet.size_gui7 = [200 20];
figSet.pos_gui7  = [(figSet.pos_gui3(nChannels,1)-50) 12 figSet.size_gui7()];

column1_title = figSet.pos_gui1(1,:) + [4 22 0 0];
column2_title = figSet.pos_gui2(1,:) + [4 18 0 0];
column3_title = figSet.pos_gui3(1,:) + [4 18 0 0];
column4_title = figSet.pos_gui4(1,:) + [4 18 0 0];
column5_title = figSet.pos_gui5(1,:) + [4 18 0 0];
column6_title = figSet.pos_gui6(1,:) + [4 18 0 0];
column7_title = figSet.pos_gui7(1,:) + [4 18 0 0];

persistent hMainFigure
if isempty(hMainFigure) || ~ishandle(hMainFigure)
    hMainFigure = figure( ...       % the main GUI figure
        'MenuBar','none', ...
        'Toolbar','none', ...
        'HandleVisibility','on', ...
        'Name', 'Define Channels', ...
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

%% ITA toolbox logo with grey background
a_im = importdata('ita_toolbox_logo.png');
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [10 10 350 65]*0.6); %TODO: later set correctly the position

%% pushbuttons - ui control elements
pb_offset = 515;

uicontrol(...
    'Parent', hMainFigure, ...
    'Position',[65+pb_offset 10 100 30],...
    'String', 'ita_metainfo_GUI',...
    'Style', 'pushbutton',...
    'Callback', @metainfo_guiButtonCallback);

uicontrol(...
    'Parent', hMainFigure, ...
    'Position',[170+pb_offset 10 100 30],...
    'String', 'Cancel',...
    'Style', 'pushbutton',...
    'Callback', @CancelButtonCallback);

uicontrol(...
    'Parent', hMainFigure, ...
    'Position',[275+pb_offset 10 100 30],...
    'String', 'OK',...
    'Style', 'pushbutton',...
    'Callback', @OkayButtonCallback);

%% text elements
uicontrol(...
    'Parent', hMainFigure,...
    'Position', column1_title,...
    'FontWeight','bold',...
    'String','Ch',...
    'Style', 'text',...
    'ForegroundColor', [0 0 .7],...
    'BackgroundColor', [0.8 0.8 0.8]);

uicontrol(...
    'Parent', hMainFigure,...
    'Position', column2_title,...
    'FontWeight','bold',...
    'String','Name',...
    'Style', 'text',...
    'ForegroundColor', [0 0 .7],...
    'BackgroundColor', [0.8 0.8 0.8] );

uicontrol(...
    'Parent', hMainFigure,...
    'Position', column3_title,...
    'FontWeight','bold',...
    'String','Unit',...
    'Style', 'text',...
    'ForegroundColor', [0 0 .7],...
    'BackgroundColor', [0.8 0.8 0.8] );

uicontrol(...
    'Parent', hMainFigure,...
    'Position', column4_title,...
    'FontWeight','bold',...
    'String','Coordinates',...
    'Style', 'text',...
    'ForegroundColor', [0 0 .7],...
    'BackgroundColor', [0.8 0.8 0.8] );

uicontrol(...
    'Parent', hMainFigure,...
    'Position', column5_title,...
    'FontWeight','bold',...
    'String','Orientation',...
    'Style', 'text',...
    'ForegroundColor', [0 0 .7],...
    'BackgroundColor', [0.8 0.8 0.8] );

uicontrol(...
    'Parent', hMainFigure,...
    'Position', column6_title,...
    'FontWeight','bold',...
    'String','User Data',...
    'Style', 'text',...
    'ForegroundColor', [0 0 .7],...
    'BackgroundColor', [0.8 0.8 0.8] );

uicontrol(...
    'Parent', hMainFigure,...
    'Position', column7_title,...
    'FontWeight','bold',...
    'String','Comment',...
    'Style', 'text',...
    'ForegroundColor', [0 0 .7],...
    'BackgroundColor', [0.8 0.8 0.8] );

for count = 1:nChannels
    % Channel ID
    uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui1(count,:),...
        'HorizontalAlignment','right',...
        'String',['' num2str(count)],...
        'FontWeight','bold',...
        'Style', 'text',...
        'Tag',num2str(count),...
        'BackgroundColor', [0.8 0.8 0.8] );
    % Channel Names
    hUiChannelNames(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'HorizontalAlignment','left',...
        'Position', figSet.pos_gui2(count,:),...
        'String', ChannelSettings(count).Name,...
        'Style', 'edit',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 0.9 1],...
        'Callback', @UpdateUiChannelNames_txt );
    % Channel Units
    hUiChannelUnits(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui3(count,:),...
        'HorizontalAlignment','right',...
        'String',[ChannelSettings(count).Unit,'|Pa|N|m/s|m/s^2|V|A|1|custom'],...
        'Style', 'popup',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelUnits_txt );
    % Channel Coordinates
    hUiChannelCoordinates(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui4(count,:),...
        'HorizontalAlignment','right',...
        'String', mat2str(ChannelSettings(count).Coordinates.cart),...
        'Style', 'edit',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelCoordinates_txt );
    
    % Channel Orientation
    hUiChannelOrientation(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui5(count,:),...
        'HorizontalAlignment','right',...
        'String', mat2str(ChannelSettings(count).Orientation.cart),...
        'Style', 'edit',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelOrientation_txt );
    
    % Channel User Data
    hUiChannelUserData(count) = uicontrol(...
        'Parent', figSet.hMainFigure,...
        'Position', figSet.pos_gui6(count,:),...
        'HorizontalAlignment','right',...
        'String', ChannelSettings(count).UserData,...
        'Style', 'edit',...
        'Tag',num2str(count) ,...
        'BackgroundColor', [1 1 1],...
        'Callback', @UpdateUiChannelUserData_txt );
    
end


%% GUI key press functions
x = get(gcf,'children');
for idx = 1:numel(x)
    token = get(x(idx));
    if strcmpi(token.Type,'uicontrol') && ~strcmpi(token.Style,'pushbutton')
        set(x(idx),'KeyPressFcn',@ButtonCallback)
    end
end
set(gcf,'KeyPressFcn',@ButtonCallback)



% Channel Comment
hUiChannelComment(1) = uicontrol(...
    'Parent', figSet.hMainFigure,...
    'Position', figSet.pos_gui7,...
    'HorizontalAlignment','left',...
    'String', ChannelSettings(1).Comment,...
    'Style', 'edit',...
    'BackgroundColor', [1 1 1],...
    'Callback', @UpdateUiChannelComment_txt );


% Make the GUI blocking
uiwait(figSet.hMainFigure);

%----------------------------------------------------------------------
    function UpdateUiChannelNames_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        ChannelSettings(channel_id).Name = get(hObject,'String');
    end

%----------------------------------------------------------------------
    function UpdateUiChannelUnits_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2double(get(hObject,'Tag'));
        
        if strcmp(get(hObject,'style'),'popupmenu')
            tokenList = get(hObject,'String');
            ChannelUnit = tokenList(get(hObject,'Value'),:);
            
            if strncmp(ChannelUnit,'custom...',6)    %Style is converted to edit
                
                hUiChannelUnits(count) = uicontrol(...
                    'Parent', figSet.hMainFigure,...
                    'Position', figSet.pos_gui3(count,:),...
                    'HorizontalAlignment','right',...
                    'String',[],...
                    'Style', 'edit',...
                    'Tag',num2str(count) ,...
                    'BackgroundColor', [1 1 1],...
                    'Callback', @UpdateUiChannelUnits_txt );
            end
            %         ChannelUnit = ChannelUnit(ChannelUnit ~= ' '); %delete spaces
            ChannelSettings(channel_id).Unit = ChannelUnit;
        else                                                %Style is converted to popup
            ChannelSettings(channel_id).Unit = get(hObject,'String');
            
            hUiChannelUnits(count) = uicontrol(...
                'Parent', figSet.hMainFigure,...
                'Position', figSet.pos_gui3(count,:),...
                'HorizontalAlignment','right',...
                'String',[ChannelSettings(count).Unit,'|Pa|N|m/s|m/s^2|V|A|1|custom'],...
                'Style', 'popup',...
                'Tag',num2str(count) ,...
                'BackgroundColor', [1 1 1],...
                'Callback', @UpdateUiChannelUnits_txt );
            
            tokenList = get(hObject,'String');
            ChannelUnit = tokenList;
            %             ChannelUnit = ChannelUnit(ChannelUnit ~= ' '); %delete spaces
            ChannelSettings(channel_id).Unit = ChannelUnit;
        end
    end


%----------------------------------------------------------------------

    function UpdateUiChannelCoordinates_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        %         ChannelSettings(channel_id).Coordinates = itaCoordinates(str2num(get(hObject,'String')),'cart');
    end

%----------------------------------------------------------------------
    function UpdateUiChannelOrientation_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        %         ChannelSettings(channel_id).Orientation = itaCoordinates(str2num(get(hObject,'String')),'cart');
    end

%----------------------------------------------------------------------
    function UpdateUiChannelUserData_txt(hObject, eventdata) %#ok<INUSD>
        channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        ChannelSettings(channel_id).UserData = get(hObject,'String');
    end

%----------------------------------------------------------------------
    function UpdateUiChannelComment_txt(hObject, eventdata) %#ok<INUSD>
        %         channel_id = str2num(get(hObject,'Tag')); %#ok<ST2NM>
        %         ChannelSettings(channel_id).Comment = get(hObject,'String');
    end

%----------------------------------------------------------------------
    function CancelButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        uiresume(gcf);
        close(gcf)
        return;
    end

%----------------------------------------------------------------------
    function metainfo_guiButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        if isa(data,'itaAudio')
            info = ita_metainfo_GUI(data);
            ChannelSettings.samplingRate=info.samplingRate;
            ChannelSettings.signalType=info.signalType;
            ChannelSettings.dateCreated=info.dateCreated;
            ChannelSettings.dateModified=info.dateModified;
            ChannelSettings.fileName=info.fileName;
        else
            ita_verbose_info([upper(mfilename) 'only works for itaAudios'],0)
        end
    end
%----------------------------------------------------------------------
    function OkayButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        for idx = 1:length(hUiChannelNames)
            
            ChannelSettings(idx).Name  = get(hUiChannelNames(idx), 'String');
            
            tokenListUnits = get(hUiChannelUnits(idx),'String');
            ChannelUnit = tokenListUnits(get(hUiChannelUnits(idx),'Value'),:);
            ChannelUnit = ita_deal_units(ChannelUnit);
            ChannelSettings(idx).Unit = ChannelUnit;
            
            if (isempty((get(hUiChannelCoordinates(idx),'String'))))
                Coordinates = '[NaN NaN NaN]';
            else
                Coordinates = get(hUiChannelCoordinates(idx),'String');
            end
            
            if (isempty((get(hUiChannelOrientation(idx),'String'))))
                Orientation = '[NaN NaN NaN]';
            else
                Orientation = get(hUiChannelOrientation(idx),'String');
            end
            
            try
                ChannelSettings(idx).Coordinates = itaCoordinates(str2num(Coordinates),'cart');
                ChannelSettings(idx).Orientation = itaCoordinates(str2num(Orientation),'cart');
            catch
                error('ITA_CHANNEL_SETTINGS:Oh Lord. This is the wrong format of coordinates or orientation. Please check!!!')
            end
            
            ChannelSettings(idx).UserData = get(hUiChannelUserData(idx),'String');
            ChannelSettings(idx).Comment = get(hUiChannelComment(1),'String');
        end
        uiresume(gcf);
        close(gcf);
        return;
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
                
                OkayButtonCallback(s,[])
                
            case 'escape'
                close
        end
        
        %end function
    end

end %end function
