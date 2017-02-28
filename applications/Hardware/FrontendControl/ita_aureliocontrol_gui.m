function ita_aureliocontrol_gui(varargin)
% ita_aureliocontrol_gui - gui for aurelio remote control

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

[currentSettings, presetNames, currentPresetNumber,presetChanged] = ita_aurelio_control('getSettings');
persistent hFigure

%% nice gui settings
gui_bg_color  = [0.8 0.8 0.8];

if nargin == 0
    width  = 440;
    height = 640;
    
    mpos = get(0,'Monitor'); %try to position in the middle of the screen
    w_position = (mpos(1,length(mpos)-1)/2)-(width/2);
    h_position = (mpos(1,length(mpos))/2)-(height/2);
    MainPosition = [w_position h_position width height];
    
    %% Figure Handling
    if isempty(hFigure) || ~ishandle(hFigure)
        hFigure = figure( ...       % the main GUI figure
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'on', ...
            'Name', 'Aurelio Remote Control', ...
            'NumberTitle', 'off', ...
            'Position' , MainPosition, ...
            'Color', gui_bg_color);
    elseif ~strcmpi(get(hFigure,'Name'),'Aurelio Remote Control')
        hFigure = figure( ...       % the main GUI figure
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'on', ...
            'Name', 'ITA-Toolbox Preferences', ...
            'NumberTitle', 'off', ...
            'Position', MainPosition, ...
            'Color', gui_bg_color);
    else %we are in an ITA-Toolbox Preferences Window (pdi)
        clf(hFigure)
    end
    %% ITA toolbox logo with grey background
    a_im = importdata('ita_toolbox_logo.png');
    image(a_im);axis off
    set(gca,'Units','pixel', 'Position', [20 10 350 65]*0.6);
else %reset mode
    %     clf(hFigure) %clear old settings
end

%%
hor_start = 4;
ver_start = 5;
hor_space = 2;
ver_space = 0.5;

button_height = 1.5;
button_width = 20;
button_space = 0.125;
lower_space = 0.25;

for ch_idx = 1:2
    %% FEED
    userdata.ch = ch_idx;
    
    nameStr = {'NONE','Pol','Pha','P+P','icp','all'};
    nButtons = length(nameStr);
    
    InputFeed{ch_idx}.Size = [button_width+1 (nButtons+1) * (button_height+button_space)];
    InputFeed{ch_idx}.Position = [hor_start ver_start InputFeed{ch_idx}.Size];
    InputFeed{ch_idx}.h = uibuttongroup(...
        'Parent',hFigure,...
        'Units','characters',...
        'FontSize',10,...
        'Title','Feed',...
        'Tag','Mode',...
        'BackgroundColor',gui_bg_color,...
        'Clipping','on',...
        'Position',InputFeed{ch_idx}.Position,...
        'SelectedObject',[],...
        'SelectionChangeFcn',@InputFeedCallback,...
        'OldSelectedObject',[]);

    
    position =  [lower_space button_space button_width button_height];
    for button_idx = 1:nButtons
        InputFeed{ch_idx}.hButton(button_idx) = uicontrol(...
            'Parent',InputFeed{ch_idx}.h,...
            'Units','characters',...
            'FontSize',10,...
            'Position',[position],...
            'BackgroundColor',[1 0 0],...
            'String',nameStr{button_idx},...
            'Style','togglebutton',...
            'UserData',userdata,...
            'Value',strcmpi(nameStr{button_idx},currentSettings.ch(ch_idx).inputfeed),...
            'Tag','togglebuttonNorm');
        position = position + [0 button_height+button_space 0 0];
    end
    
    %% INPUT SELECT
    nameStr = {'Lemo','XLR','gnd','BNC'};
    nButtons = length(nameStr);
    InputSelect{ch_idx}.Size = [button_width+1 (nButtons+1) * (button_height+button_space)];
    InputSelect{ch_idx}.Position = [InputFeed{ch_idx}.Position(1)  InputFeed{ch_idx}.Position(2)+ InputFeed{ch_idx}.Position(4)+ver_space InputSelect{ch_idx}.Size];
    InputSelect{ch_idx}.h = uibuttongroup(...
        'Parent',hFigure,...
        'Units','characters',...
        'FontSize',10,...
        'Title','Select',...
        'Tag','Mode',...
        'Clipping','on',...
        'BackgroundColor',gui_bg_color,...
        'Position',InputSelect{ch_idx}.Position,...
        'SelectedObject',[],...
        'SelectionChangeFcn',@InputSelectCallback,...
        'OldSelectedObject',[]);
    
    position =  [lower_space button_space button_width button_height];
    for button_idx = 1:nButtons
        InputSelect{ch_idx}.hButton(button_idx) = uicontrol(...
            'Parent',InputSelect{ch_idx}.h,...
            'Units','characters',...
            'FontSize',10,...
            'Position',position,...
            'String',nameStr{button_idx},...
            'UserData',userdata,...
            'Style','togglebutton',...
            'Value',strcmpi(nameStr{button_idx},currentSettings.ch(ch_idx).inputselect),...
            'Tag','togglebuttonNorm');
        position = position + [0 button_height+button_space 0 0];
    end
    
    %% INPUT RANGE
    inputRange_vec = -34:10:56;
    nameStr = cellstr(num2str(inputRange_vec'));
    nButtons = length(nameStr);
    
    InputRange{ch_idx}.Size = [button_width+1 (nButtons+1) * (button_height+button_space)];
    InputRange{ch_idx}.Position = [InputSelect{ch_idx}.Position(1)  InputSelect{ch_idx}.Position(2)+ InputSelect{ch_idx}.Position(4)+ver_space InputRange{ch_idx}.Size];
    InputRange{ch_idx}.h = uibuttongroup(...
        'Parent',hFigure,...
        'Units','characters',...
        'FontSize',10,...
        'Title',['Range ch' num2str(ch_idx)],...
        'Tag','Mode',...
        'BackgroundColor',gui_bg_color,...
        'Clipping','on',...
        'Position',InputRange{ch_idx}.Position,...
        'SelectedObject',[],...
        'SelectionChangeFcn',@InputRangeCallback,...
        'OldSelectedObject',[]);
    
    position =  [lower_space button_space button_width button_height];
    for button_idx = 1:nButtons
        InputRange{ch_idx}.hButton(button_idx) = uicontrol(...
            'Parent',InputRange{ch_idx}.h,...
            'Units','characters',...
            'FontSize',10,...
            'Position',[position],...
            'String',nameStr{button_idx},...
            'BackgroundColor',[0.1 0.9 0.1],...
            'UserData',userdata,...
            'Style','togglebutton',...
            'Value',currentSettings.ch(ch_idx).inputrange == inputRange_vec(button_idx),...
            'Tag','togglebuttonNorm');
        position = position + [0 button_height+button_space 0 0];
    end
    
    hor_start = hor_start + button_width + hor_space;
    
end

%% right column
nameStr = {};
argCell = {};
ele = 1;
nameStr{ele} = {'AmpRef'};
argCell{ele} = {'mode','ampref'};
ele = ele + 1;
nameStr{ele} = {'LineRef'};
argCell{ele} = {'mode','lineref'};
ele = ele + 1;
nameStr{ele} = {'ImpRef'};
argCell{ele} = {'mode','impref'};
ele = ele + 1;
nameStr{ele} = {'Imp'};
argCell{ele} = {'mode','imp'};
ele = ele + 1;
nameStr{ele} = {'Norm'};
argCell{ele} = {'mode','norm'};

%% generate modebuttons
InputFeed = InputFeed(1);
nButtons = length(nameStr);
InputFeed{1}.Size = [button_width+1 (nButtons+1) * (button_height+button_space)];
InputFeed{1}.Position = [hor_start+1 ver_start InputFeed{1}.Size];
InputFeed{1}.h = uibuttongroup(...
    'Parent',hFigure,...
    'Units','characters',...
    'FontSize',10,...
    'Title','Mode',...
    'Tag','Mode',...
    'Clipping','on',...
    'Position',InputFeed{1}.Position,...
    'BackgroundColor',gui_bg_color,...
    'SelectedObject',[],...
    'OldSelectedObject',[], ...
    'SelectionChangeFcn',@modePushButtonCallback);
ch_idx = 1;
position =  [lower_space button_space  button_width button_height];
for button_idx = 1:nButtons
    userdata = argCell{button_idx};
    ControlButton{ch_idx}.hButton(button_idx) = uicontrol(...
        'Parent',InputFeed{ch_idx}.h,...
        'Units','characters',...
        'FontSize',10,...
        'Position',position,...
        'String',nameStr{button_idx},...
        'Style','togglebutton',...
        'UserData',userdata,...
        'Value',strcmpi(currentSettings.mode,argCell{button_idx}{2}),...
        'Tag','');
    position = position + [0 button_height+button_space 0 0];
end


%% davolume
nameStr = {};
argCell = {};
ele = 1;
nameStr{ele} = {'Init'};
argCell{ele} = {'init'};
tooltip{ele} = {'Reinitialize the Aurelio'};
% ele = ele + 1;
% nameStr{ele} = {['Reset']};
% argCell{ele} = {'Reset'};
ele = ele + 1;
nameStr{ele} = {'Use Amplifier'};
argCell{ele} = {'Amplifier'};
tooltip{ele} = {'Turn the amplifier on'};
ele = ele + 1;
% nameStr{ele} = {'NoAmplifier'};
% argCell{ele} = {'NoAmplifier'};
% ele = ele + 1;
nameStr{ele} = {'Amp +20dB'};
argCell{ele} = {'Amp26dBu'};
tooltip{ele} = {'Amp + 20 dB'};
ele = ele + 1;
% nameStr{ele} = {'Amp06dBu'};
% argCell{ele} = {'Amp06dBu'};
% ele = ele + 1;
nameStr{ele} = {'AmpHighPower'};
argCell{ele} = {'AmpHighPower'};
tooltip{ele} = {'Activate High power Amp'};
ele = ele + 1;
% nameStr{ele} = {'AmpLowPower'};
% argCell{ele} = {'AmpLowPower'};
% ele = ele + 1;
nameStr{ele} = {'GroundLift'};
argCell{ele} = {'groundLift'};
tooltip{ele} = {'Use ground lift'};
% ele = ele + 1;
% nameStr{ele} = {'NoGroundLift'};
% argCell{ele} = {'NoGroundLift'};


%% controlbuttons (push)
nButtons = length(nameStr);

InputFeed{1}.Size = [button_width+1 (nButtons+1) * (button_height+button_space)];
InputFeed{1}.Position = [InputFeed{1}.Position(1)  InputFeed{1}.Position(2)+ InputFeed{1}.Position(4)+ver_space InputFeed{1}.Size];
%     InputFeed{ch_idx}.Position = [hor_start ver_start InputFeed{ch_idx}.Size];
InputFeed{1}.h = uipanel(...
    'Parent',hFigure,...
    'Units','characters',...
    'FontSize',10,...
    'Title','Control',...
    'Tag','Mode',...
    'Clipping','on',...
    'Position',InputFeed{ch_idx}.Position,...
    'BackgroundColor',gui_bg_color);


position =  [lower_space button_space  button_width button_height];

% checkboxes
for button_idx = 2:length(nameStr)
    userdata = argCell{button_idx};
    ControlButton{ch_idx}.hButton(button_idx) = uicontrol(...
        'Units','characters',...
        'Parent',InputFeed{1}.h,...
        'FontSize',10,...
        'Position',[position],...
        'String',nameStr{button_idx},...
        'Style','checkbox',...
        'Callback',@controlCheckboxCallback,...
        'UserData',userdata,...
        'Value',currentSettings.(argCell{button_idx}{1}),...
        'Tag','', ...
        'Tooltip',tooltip{button_idx}{1});
    position = position + [0 button_height+button_space 0 0];
end

% init button
userdata = argCell{1};
ControlButton{ch_idx}.hButton(1) = uicontrol(...
    'Units','characters',...
    'Parent',InputFeed{1}.h,...
    'FontSize',10,...
    'Position',[position],...
    'String',nameStr{1},...
    'Style','pushbutton',...
    'Callback',@controlPushButtonCallback,...
    'UserData',userdata,...
    'Value',0,...
    'Tag','');
position = position + [0 button_height+button_space 0 0];


%% sampling rate
nameStr = {};
argCell = {};
ele = 1;
nameStr{ele} = {'44100'};
argCell{ele} = {44100};
ele = ele + 1;
nameStr{ele} = {'48000'};
argCell{ele} = {48000};
ele = ele + 1;
nameStr{ele} = {'88200'};
argCell{ele} = {88200};
ele = ele + 1;
nameStr{ele} = {'96000'};
argCell{ele} = {96000};
ele = ele + 1;


samplingValue = 0;
for index = 1:length(nameStr)
   if argCell{index}{1} == currentSettings.samplingRate
       samplingValue = index;
   end
end


nameStr = {'44100','48000','88200','96000'};
%% controlbuttons (push)
nButtons = 1;

InputFeed{1}.Size = [button_width+1 (nButtons+1) * (button_height+button_space)];
InputFeed{1}.Position = [InputFeed{1}.Position(1)  InputFeed{1}.Position(2)+ InputFeed{1}.Position(4)+ver_space InputFeed{1}.Size];
%     InputFeed{ch_idx}.Position = [hor_start ver_start InputFeed{ch_idx}.Size];
InputFeed{1}.h = uipanel(...
    'Parent',hFigure,...
    'Units','characters',...
    'FontSize',10,...
    'Title','SamplingRate',...
    'Tag','Mode',...
    'Clipping','on',...
    'Position',InputFeed{1}.Position,...
    'BackgroundColor',gui_bg_color);

position =  [lower_space button_space  button_width button_height];
ControlButton{1}.hButton(1) = uicontrol(...
    'Units','characters',...
    'Parent',InputFeed{1}.h,...
    'FontSize',10,...
    'Position',position,...
    'String',nameStr,...
    'Style','popupmenu',...
    'Callback',@samplingRateButtonCallback,...
    'UserData',[],...
    'Value',samplingValue,...
    'Tag','');
position = position + [0 button_height+button_space 0 0];



%% presets
nButtons = 2;


% to get it up top to align with InputRange box, get its position and size
inputHeight = InputRange{1}.Position(2) + InputRange{1}.Size(2);


InputFeed{1}.Size = [button_width+1 (nButtons+1) * (button_height+button_space)];
InputFeed{1}.Position = [InputFeed{1}.Position(1)  inputHeight - InputFeed{1}.Size(2)  InputFeed{1}.Size];
%     InputFeed{ch_idx}.Position = [hor_start ver_start InputFeed{ch_idx}.Size];
InputFeed{1}.h = uipanel(...
    'Parent',hFigure,...
    'Units','characters',...
    'FontSize',10,...
    'Title','Settings Presets',...
    'Tag','Mode',...
    'Clipping','on',...
    'Position',InputFeed{1}.Position,...
    'BackgroundColor',gui_bg_color);

position =  [lower_space button_space  button_width button_height];
PresetButton{1}.hButton(1) = uicontrol(...
        'Units','characters',...
        'Parent',InputFeed{1}.h,...
        'FontSize',10,...
        'Position',[position],...
        'String','Save',...
        'Style','pushbutton',...
        'Callback',@presetSaveCallback,...
        'UserData',userdata,...
        'Tag','');
position = position + [0 button_height+button_space 0 0];

names = presetNames;

if ~presetChanged
    popupValue = currentPresetNumber;
else
    currentSettings = {'currentSettings'};
    names = [presetNames currentSettings];
    popupValue = length(names); 
end

PresetMenu{ch_idx}.hButton(1) = uicontrol(...
    'Units','characters',...
    'Parent',InputFeed{1}.h,...
    'FontSize',10,...
    'Position',position,...
    'String',names,...
    'Style','popupmenu',...
    'Callback',@presetMenuCallback,...
    'UserData',[],...
    'Value',popupValue,...
    'Tag','');


%% callback functions

    function modePushButtonCallback(h,event)
        userdata = getfield(get(event.NewValue),'UserData');
        argCell = userdata;
        if ~isempty(argCell)
            ita_aurelio_control(argCell{:});
            ita_aureliocontrol_gui('init');
        end
    end


    function controlPushButtonCallback(h,event)
        argCell = getfield(get(h),'UserData');
        if ~isempty(argCell)
            if strfind(argCell{1},'davolume')
                a = ita_modulita_control('getSettings');
                davolume = a.davolume;
                if strfind(argCell{1},'--')
                    davolume = davolume - 1;
                else
                    davolume = davolume + 1;
                end
                ita_aurelio_control('davolume',davolume);
                %                 set(event.NewValue,'UserData',argCell);
            else
                ita_aurelio_control(argCell{:});
                ita_aureliocontrol_gui('init');
            end
        end
    end

    function controlCheckboxCallback(h,event)
        argCell = getfield(get(h),'UserData');
        if ~isempty(argCell)
            if strfind(argCell{1},'davolume')
                a = ita_modulita_control('getSettings');
                davolume = a.davolume;
                if strfind(argCell{1},'--')
                    davolume = davolume - 1;
                else
                    davolume = davolume + 1;
                end
                ita_aurelio_control('davolume',davolume);
                %                 set(event.NewValue,'UserData',argCell);
            else
                argCell{end+1} = get(h,'Value');
                ita_aurelio_control(argCell{:});
                ita_aureliocontrol_gui('init');
            end
        end    
        
    end
   

    function samplingRateButtonCallback(h,event)
        value = get(h,'Value');
        strings = get(h,'String');
        
        argCell{1} = str2num(strings{value});
        if ~isempty(argCell)
            ita_aurelio_control('samplingRate',argCell{1});
            ita_aureliocontrol_gui('init');
        end
    end


    function InputSelectCallback(h,event)
        userdata = getfield(get(event.NewValue),'UserData');
        inputselect = getfield(get(event.NewValue),'String');
        ita_aurelio_control('channel',userdata.ch,'input',inputselect);
        ita_aureliocontrol_gui('init');
    end


    function InputFeedCallback(h,event)
        userdata = getfield(get(event.NewValue),'UserData');
        inputfeed = getfield(get(event.NewValue),'String');
        ita_aurelio_control('channel',userdata.ch,'feed',inputfeed);
        ita_aureliocontrol_gui('init');
    end


    function InputRangeCallback(h,event)
        userdata = getfield(get(event.NewValue),'UserData');
        value = getfield(get(event.NewValue),'String');
        inputrange = str2num(value); %#ok<ST2NM>
        ita_aurelio_control('channel',userdata.ch,'inputrange',inputrange);
        ita_aureliocontrol_gui('init');
    end


    function presetMenuCallback(h,event)
        value = get(h,'Value');
        strings = get(h,'String');
        
        if value <= length(strings)
            ita_aurelio_control('setPreset',1,'presetName',strings{value});
            ita_aureliocontrol_gui('init');
        end
        
    end


    function presetSaveCallback(h,event)
        
        isValidName = 0;
        abort = 0;
        inputString = 'Please give a preset name';
        while ~isValidName
            newTitle = inputdlg(inputString,'New Preset');
            if ~isempty(newTitle)
                if ~isempty(newTitle{1})
                    isValidName = 1;
                    % check if the name is already in use
                    for index = 1:length(presetNames)
                        if strcmp(newTitle{1},presetNames{index})
                            isValidName = 0;
                            inputString = 'Name already in use:';
                        end
                    end
                else
                    % ok but no name
                    isValidName = 0;
                    inputString = 'Name was empty. Please give a name:';
                end
            else
               % abort case
               abort = 1;
               isValidName = 1;
            end
        end
      
        if ~abort
            ita_aurelio_control('savePreset',1,'presetName',newTitle{1});
            ita_aureliocontrol_gui('init');
        end
    end


end
