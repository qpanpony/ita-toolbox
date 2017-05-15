function varargout = ita_parametric_GUI(varargin)
%ITA_PARAMETRIC_GUI - Modular GUI
%  This function generates a GUI based on a list of parameters coming in.
%
%  Syntax:
%   parameterList = ita_parametric_GUI(parameterList,name, Options)
%
%   Options (default):
%       'wait' ('on') - wait till ok-button is pressed. You wont get the results from the fields if you set it to 'off', but buttons etc will work
%
%  Example:
%   pList{1}.description = 'Numerator_spectrum'; %this text will be shown in the GUI
%   pList{1}.helptext    = 'This is the spectrum on top'; %this text should be shown when the mouse moves over the textfield for the description
%   pList{1}.datatype    = 'itaAudio'; %based on this type a different row of elements has to drawn in the GUI
%   pList{1}.default     = []; %default value, could also be empty, otherwise it has to be of the datatype specified above
%
%   pList{2}.description = 'Limiter'; %this text will be shown in the GUI
%   pList{2}.helptext    = 'This value specifies the maximum for the limitation, some kind of regularization'; %this text should be shown when the mouse moves over the textfield for the description
%   pList{2}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
%   pList{2}.default     = 100; %default value, could also be empty, otherwise it has to be of the datatype specified above
%
%   pList{3}.description = 'showInfo'; %this text will be shown in the GUI
%   pList{3}.helptext    = 'Show some verbose Info'; %this text should be shown when the mouse moves over the textfield for the description
%   pList{3}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
%   pList{3}.default     = false; %default value, could also be empty, otherwise it has to be of the datatype specified above
%
%   pList{4}.datatype    = 'line'; %just draw a simple line
%
%   pList{5}.description = 'Just a simple text'; %this text will be shown in the GUI
%   pList{5}.datatype    = 'text'; %only show text
%
%   parameterList = ita_parametric_GUI(pList,'ITA-GUI')
%
%   If you want to change the buttonnames, use the option
%   'buttonnames',{'button1','button2'}
%
%   See also: test_ita_parametric_GUI.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_parametric_GUI">doc ita_parametric_GUI</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  10-Jun-2009


%% Check if Toolbox Setup is up-to-date
ita_check4toolboxsetup();

%% Get ITA Toolbox preferences and Function String

varargout = cell(nargout,1);

if nargout >= 1
    varargout{1} = 'exitItaParametricGUI';
end

if ~usejava('jvm') %Only if jvm available (non_cluster)
    ita_verbose_info('No GUI in NOJVM mode',1);
    return
end

%% Initialization and Input Parsing
%pList = varargin{1}; %parameter list as shown below
%name  = varargin{2}; %name of window

sArgs = struct('pos1_pList','cell','pos2_name','char','wait','on','ita_menu','off',...
    'ita_menu_disable',cell(1),'logo','ita_toolbox_logo.png','backgroundlogo','','logo2','','return_handles',false,'fgh',[],'position',[]);
sArgs.buttonnames = {'Cancel','Okay'};
narginchk(2,2*numel(fields(sArgs)));
[pList, name, sArgs] = ita_parse_arguments(sArgs,varargin);

%% List of Prameters
n = numel(pList); % Number of parameters

% Find total number of lines needed for GUI (new since multiline objects)
nlines = 0; % Number of lines
for idl = 1:n
    if isfield(pList{idl},'height')
        nlines = nlines + pList{idl}.height;
    else
        nlines = nlines + 1;
    end
end


%% GUI Initialization
%% new centering - kurt weigelt
if isempty(sArgs.position)
    left_margin  = 15;
    top_margin   = 25;
else
    left_margin  = sArgs.position(1);
    top_margin  = sArgs.position(2);
end

h_textbox    = 22;
height       = top_margin + 100 + (nlines)*h_textbox;
width        = 700;

mpos = get(0,'Monitor');
w_position = (mpos(1,length(mpos)-1)/2)-(width/2);
h_position = (mpos(1,length(mpos))/2)-(height/2);
MainPosition = [w_position h_position width height];

fontsize     = 10;
space        = 15;
popup_length = 160;
pListFinal   = {};
text_short   = 160; %text, char, int, double input fields
text_long    = 470;
path_length  = 370;
desc_type_weight = 'bold';
width_description = 180;
left_space   = left_margin + width_description + space; %margin until the input field starts
button_space = left_space + space + 350 + space;
pListFinalFinal = {};
button_bg_color = [0.7 0.7 0.7];
width_itaAudioDD = 200;
if ispc
    button_height  = 20;
elseif ismac
    button_height = 30;
else
    button_height = 20; %pdi???
end

pReturnList = pList;
h = struct();
f = struct();

%% Figure Handling
if isempty(sArgs.fgh) || ~ishandle(sArgs.fgh)
    hFigure = figure( ...       % the main GUI figure
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'HandleVisibility', 'on', ...
        'Name', name, ...
        'NumberTitle', 'off', ...
        'Position' , MainPosition, ...
        'Color', [0.8 0.8 0.8]);
else
    hFigure = sArgs.fgh;
end

set(hFigure,'KeyPressFcn',@ButtonCallback)

if sArgs.ita_menu
    ita_menu('handle',hFigure,'ita_menu_disable',sArgs.ita_menu_disable);
end

%% ITA toolbox logo
a_im = importdata(which(sArgs.logo));
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [left_margin 10 210 40]);

%% Second logo?
filename2 = which(sArgs.logo2);
if ~isempty(filename2)
    axes;
    a_im = importdata(filename2);
    image(a_im);axis off
    size_y = size(a_im,1);
    size_x = size(a_im,2);
    set(gca,'Units','pixel', 'Position', [400 10 size_x/size_y*65 65]*0.6);
end

%% Background picture
if ~isempty(sArgs.backgroundlogo)
    try %#ok<TRYNC>
        a_im = importdata(sArgs.backgroundlogo);
        axes
        image(a_im);axis off
    end
end

%% List of all workspace variables of type itaAudio
list = ita_guisupport_getworkspacelist();

%% Offset
linesoffset = 0; % Used for mukltiline objects (textfield)

%% GUI appearance
for idx  = 1:n %#ok<FXUP>
    type = pList{idx}.datatype;
    
    %% description text
    if isfield(pList{idx},'description')  && isfield(pList{idx}, 'helptext')
        fcolor = [0 0 .7];
        if isfield(pList{idx},'color')
            fcolor = pList{idx}.color;
        end
        uicontrol(...
            'Parent', hFigure, ...
            'Position',[left_margin height-7-(idx+linesoffset)*(h_textbox+3) width_description h_textbox-7],...
            'String',pList{idx}.description,...
            'FontSize',fontsize+1,...
            'FontWeight',desc_type_weight,...
            'BackgroundColor',[0.8 0.8 0.8],...
            'ForegroundColor',fcolor,...
            'HorizontalAlignment','left',...
            'Style', 'text',...
            'TooltipString',pList{idx}.helptext);
    end
    %% draw the rest of elements
    switch(type)
        case {'picture'} %this takes 6by4 picture formats
            try
                a_im = importdata(pList{idx}.filename);
                axes;
                image(a_im);axis off
                pos = [left_space+130 height-10-(idx+linesoffset)*(h_textbox+3)-10 60 40];
                set(gca,'Units','pixel', 'Position', pos);
            catch %#ok<CTCH>
                ita_verbose_info('Sorry picture did not work.',0);
            end
        case {'itaAudio', 'itaAudioFix' }
            
            if strcmpi(type, 'itaAudioFix')
                objectEnabled = 'off';
            
                comment = pList{idx}.default.comment;
                if length(comment) > 20
                    comment = [comment(1:20) '...'];
                end
                list = ['Object in GUI' ' (' comment ')|'];
                ch_available = ita_sprintf('Ch %i - %s',1:pList{idx}.default.nChannels, pList{idx}.default.channelNames);
            else
                objectEnabled = 'on';
                if isfield(pList{idx},'class') && ~isempty(pList{idx}.class)
                    list = ita_guisupport_getworkspacelist('class',pList{idx}.class);
                else
                    list = ita_guisupport_getworkspacelist();
                end
                ch_available = [];
            end
            
            defaultname = pList{idx}.default;
            try % Find defaultindex for popup-menu
                var = evalin('base',defaultname); % Try to get this variable
                comment     = var.comment;
                nSamples    = int2str(var.nSamples);
                sr          = int2str(var.samplingRate);
                clear var;
                if length(comment) > 20
                    comment = [comment(1:20) '...'];
                end
                comment = [comment '[' nSamples ';' sr 'Hz]']; %#ok<AGROW>
                VarNameString = [defaultname ' (' comment ')'];
                defaultindex = popup_string_to_index(list,VarNameString);
            catch errmsg%#ok<NASGU> %Not found in base workspace, set default to 1
                defaultindex = 1;
            end
            if ~isfield(pList{idx},'defaultchannels')
                if isnumeric(pList{idx}.default)
                    pList{idx}.defaultchannels = pList{idx}.default;
                else
                    pList{idx}.defaultchannels = [];
                end
            end
            
            
            
            
            f.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) width_itaAudioDD h_textbox],...
                'String',list,...
                'Value',defaultindex,...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','right',...
                'Callback',@refreshitaAudiopopups,...
                'UserData',list,...
                'Enable', objectEnabled, ...
                'Style', 'popup');
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_margin + width_description + space + width_itaAudioDD + space height-10-(idx+linesoffset)*(h_textbox+3)+2 350-width_itaAudioDD h_textbox],...
                'String',num2str(pList{idx}.defaultchannels),...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'edit', ...
                'TooltipString', 'Select Channels');
            userdata = {h.(ita_guisupport_removewhitespaces(pList{idx}.description)), f.(ita_guisupport_removewhitespaces(pList{idx}.description)), list, ch_available};
            uicontrol(...
                'Parent', hFigure, ...
                'Position',[button_space  height-10-(idx+linesoffset)*(h_textbox+3) 100 button_height],...
                'String','Select Channel',...
                'FontSize',fontsize,...
                'BackgroundColor',button_bg_color,...
                'HorizontalAlignment','center',...
                'Style', 'pushbutton',...
                'UserData',userdata,...
                'Callback',@SelChannelButton);
            
        case {'itaAudioResult'}
            defaultname = pList{idx}.default;
            list = [defaultname '| |' ita_guisupport_getworkspacelist()];
            f.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) width_itaAudioDD h_textbox],...
                'String',list,...
                'Value',1,...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','right',...
                'Callback',@refreshitaAudiopopups,...
                'UserData',list,...
                'Style', 'popup');
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_margin + width_description + space + width_itaAudioDD + space height-10-(idx+linesoffset)*(h_textbox+3)+2 350-width_itaAudioDD h_textbox],...
                'String','',...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'edit', ...
                'TooltipString', 'Type new varianle name');
            
        case {'path' 'getfile' 'setfile'}
            if isfield(pList{idx},'filter')
                filter = pList{idx}.filter;
            else
                filter = '';
            end
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space  height-10-(idx+linesoffset)*(h_textbox+3)  path_length  h_textbox],...
                'String',pList{idx}.default,...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'UserData', {type filter},...
                'Style', 'edit');
            f.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[button_space  height-10-(idx+linesoffset)*(h_textbox+3)-5 100 button_height],...
                'String',pList{idx}.description,...
                'FontSize',fontsize,...
                'BackgroundColor',button_bg_color,...
                'HorizontalAlignment','left',...
                'Style', 'pushbutton',...
                'TooltipString',pList{idx}.helptext,...
                'Callback',@BrowseCallback,...
                'Userdata',h.(ita_guisupport_removewhitespaces(pList{idx}.description)));
            
        case {'simple_button'} %pdi
            buttonname = pList{idx}.description;
            if isfield(pList{idx},'buttonname')
                buttonname = pList{idx}.buttonname;
            end
            f.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[button_space  height-10-(idx+linesoffset)*(h_textbox+3) 100 button_height],...
                'String',buttonname,...
                'FontSize',fontsize,...
                'BackgroundColor',button_bg_color,...
                'HorizontalAlignment','left',...
                'Style', 'pushbutton',...
                'TooltipString',pList{idx}.helptext,...
                'Callback',@simpleButtonCallback,...
                'Userdata',pList{idx}.callback);
            
        case {'char_result_button','int_result_button'} %pdi
            if strcmpi(type,'int_result_button')
                pList{idx}.default = num2str(pList{idx}.default);
            end
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space  height-10-(idx+linesoffset)*(h_textbox+3)  320+50  h_textbox],...
                'String',pList{idx}.default,...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'edit');
            f.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[button_space height-10-(idx+linesoffset)*(h_textbox+3)-5 100 button_height],...
                'String',pList{idx}.description,...
                'FontSize',fontsize,...
                'BackgroundColor',button_bg_color,...
                'HorizontalAlignment','left',...
                'Style', 'pushbutton',...
                'TooltipString',pList{idx}.helptext,...
                'Callback',@resultButtonCallback,...
                'Userdata',{pList{idx}.callback, h.(ita_guisupport_removewhitespaces(pList{idx}.description)), type});
            
        case {'int','double','char'}
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) text_short h_textbox],...
                'String',num2str(pList{idx}.default),...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'edit');
            
        case {'slider'}
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-13-(idx+linesoffset)*(h_textbox+3) text_short h_textbox],...
                'Value',(pList{idx}.default),...
                'Min', min(pList{idx}.range),...
                'Max', max(pList{idx}.range),...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'slider',...
                'Callback', @sliderchange_callback); %Slider itself
            set(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'UserData', uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space+text_short+10 height-10-(idx+linesoffset)*(h_textbox+3) text_short/3 h_textbox],...
                'String',num2str(pList{idx}.default),...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'edit',...
                'Callback', @slidertextchange_callback,...
                'UserData',h.(ita_guisupport_removewhitespaces(pList{idx}.description)))); %Textbox
            
        case {'int_long','double_long','char_long'} %pdi longer text fields
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) text_long h_textbox],...
                'String',num2str(pList{idx}.default),...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'edit');
        case {'textfield'}
            if ~isfield(pList{idx},'height')
                pList{idx}.height = 1;
            end
            linesoffset = linesoffset + pList{idx}.height-1; % More than one line, increase offset
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) text_long h_textbox*pList{idx}.height],...
                'String',num2str(pList{idx}.default),...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'edit',...
                'Max', 10,...
                'Min', 0);
        case {'bool'}
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) 30 h_textbox],...
                'FontSize',fontsize,...
                'BackgroundColor',[0.8 0.8 0.8],...
                'HorizontalAlignment','left',...
                'Style', 'checkbox',...
                'Value',pList{idx}.default);
            
        case {'line'}
            uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_margin height-2 - (idx+linesoffset)*(h_textbox+3) width - 2*left_margin 1],...
                'FontSize',fontsize,...
                'BackgroundColor',[0.8 0.8 0.8],...
                'HorizontalAlignment','left',...
                'Style', 'frame');
            
        case {'text'}
            fcolor = [0 0 .7];
            if isfield(pList{idx},'color')
                fcolor = pList{idx}.color;
            end
            uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_margin height- 7 - (idx+linesoffset)*(h_textbox+3) width - 2*left_margin h_textbox],...
                'String',pList{idx}.description,...
                'FontSize',fontsize+2,...
                'FontWeight','bold',...
                'ForegroundColor',fcolor,...
                'BackgroundColor',[0.8 0.8 0.8],...
                'HorizontalAlignment','left',...
                'Style', 'text');
            
            
        case {'simple_text'}
            if isfield(pList{idx},'text')
                addtext = pList{idx}.text;
                fcolor = [0 0 .7];
                if isfield(pList{idx},'color')
                    fcolor = pList{idx}.color;
                end
                
                uicontrol(...
                    'Parent', hFigure, ...
                    'Position',[left_space height-14-(idx+linesoffset)*(h_textbox+3) width - 2*left_margin h_textbox],...
                    'FontSize',fontsize,...
                    'BackgroundColor',[0.8 0.8 0.8],...
                    'HorizontalAlignment','left',...
                    'Style', 'text',...
                    'String',addtext);
            end
            
            
        case {'char_popup'}
            defaultindex = popup_string_to_index(pList{idx}.list,pList{idx}.default);
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) popup_length h_textbox],...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'popupmenu',...
                'String',pList{idx}.list,...
                'Value',defaultindex,...
                'UserData',pList{idx}.list);
            
        case {'char_popup2'}
            disp('pdi: Still unter contruction')
            defaultindex = popup_string_to_index(pList{idx}.list1,pList{idx}.default1);
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) popup_length+65 h_textbox],...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'popupmenu',...
                'String',pList{idx}.list1,...
                'Value',defaultindex,...
                'UserData',pList{idx}.list1);
            
            defaultindex = popup_string_to_index(pList{idx}.list2,pList{idx}.default2);
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space+250 height-10-(idx+linesoffset)*(h_textbox+3) popup_length+65 h_textbox],...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'popupmenu',...
                'String',pList{idx}.list2,...
                'Value',defaultindex,...
                'UserData',pList{idx}.list2);
            
        case {'char_popup3'}
            disp('pdi: Still unter contruction')
            defaultindex = popup_string_to_index(pList{idx}.list1,pList{idx}.default1);
            offset = -5;
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) popup_length+offset h_textbox],...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'popupmenu',...
                'String',pList{idx}.list1,...
                'Value',defaultindex,...
                'UserData',pList{idx}.list1);
            
            defaultindex = popup_string_to_index(pList{idx}.list2,pList{idx}.default2);
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space+160 height-10-(idx+linesoffset)*(h_textbox+3) popup_length+offset h_textbox],...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'popupmenu',...
                'String',pList{idx}.list2,...
                'Value',defaultindex,...
                'UserData',pList{idx}.list2);
            
            defaultindex = popup_string_to_index(pList{idx}.list3,pList{idx}.default3);
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space+320 height-10-(idx+linesoffset)*(h_textbox+3) popup_length+offset h_textbox],...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'popupmenu',...
                'String',pList{idx}.list3,...
                'Value',defaultindex,...
                'UserData',pList{idx}.list3);
            
            
            
        case {'int_popup'}
            defaultindex = find(pList{idx}.list == pList{idx}.default,1);
            charlist = '';
            for idthisidx = 1:numel(pList{idx}.list)
                charlist = [charlist num2str(pList{idx}.list(idthisidx)) '|']; %#ok<AGROW>
            end
            charlist = charlist(1:end-1);
            h.(ita_guisupport_removewhitespaces(pList{idx}.description)) = uicontrol(...
                'Parent', hFigure, ...
                'Position',[left_space height-10-(idx+linesoffset)*(h_textbox+3) popup_length h_textbox],...
                'FontSize',fontsize,...
                'BackgroundColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'Style', 'popupmenu',...
                'String',charlist,...
                'Value',defaultindex,...
                'UserData',pList{idx}.list);
        otherwise
            error([' Sorry, I dont know that datatype: ' pList{idx}.datatype])
    end
end

%% GUI key press functions
x = get(gcf,'children');
for idx = 1:numel(x)
    token = get(x(idx));
    if strcmpi(token.Type,'uicontrol') && ~strcmpi(token.Style,'pushbutton')
        set(x(idx),'KeyPressFcn',@ButtonCallback)
    end
end


% Store handles in UserData, in case they are needed again
set(hFigure,'UserData',{h,f});

if ~isempty(sArgs.buttonnames)
    % Cancel Button
    uicontrol(...
        'Parent', hFigure, ...
        'Position',[480 10 80 button_height],...
        'String', sArgs.buttonnames{1},...
        'Style', 'pushbutton',...
        'BackgroundColor', button_bg_color,...
        'Callback', @CancelButtonCallback);
    if numel(sArgs.buttonnames)>1
        % Ok Button
        uicontrol(...
            'Parent', hFigure, ...
            'Position',[580 10 80 button_height],...
            'String', sArgs.buttonnames{2},...
            'Style', 'pushbutton',...
            'BackgroundColor', button_bg_color,...
            'Callback', @OkayButtonCallback);
    end
end

%% Find output parameters
if sArgs.wait
    uiwait(hFigure);
end
idx2 = 1;
for idx = 1:numel(pListFinal) %#ok<FXUP>
    if strcmpi(pListFinal{idx},'to_be_deleted')
        idx2 = idx2 -1;
    else
        pListFinalFinal{idx2} = pListFinal{idx}; %#ok<AGROW>
    end
    idx2 = idx2 + 1;
end
varargout{1} = pListFinalFinal; %return the final parameter list
pause(0.01);
if nargout > 1
    if sArgs.return_handles
        varargout{2} = h;
    else
        varargout{2} = pReturnList;
    end
    
end


% Ok Button for Error Message
    function OkButtonCallback(hObject, eventdata) %#ok<INUSD>
        uiresume(gcf);
        close gcf
        return;
    end

%% Function definitions
    function OkayButtonCallback(hObject,eventdata)
        for idx = 1:n %#ok<FXUP>
            type = pList{idx}.datatype;
            switch(type)
                case {'itaAudio'}
                    var_idx = get(f.(ita_guisupport_removewhitespaces(pList{idx}.description)),'Value');
                    all_var = get(f.(ita_guisupport_removewhitespaces(pList{idx}.description)),'String');
                    var = all_var(var_idx,:);
                    var = var(1:findstr(var,' ')); %(var~=' ');% delete spaces in string
                    var = ita_getfrombase(var);
                    
                    channels = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'String');
                    ch_vector = str2num(channels); %#ok<ST2NM>
                    if ~isempty(ch_vector) && ~any(isnan(ch_vector))
                        ch_vector(ch_vector>var.nChannels) = []; %Remove ChannlNumbers that dont exist
                        var = ita_split(var,ch_vector);
                    end
                case 'itaAudioFix'
                    var = pList{idx}.default;
                    
                    channels = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'String');
                    ch_vector = str2num(channels); %#ok<ST2NM>
                    if ~isempty(ch_vector) && ~any(isnan(ch_vector))
                        ch_vector(ch_vector>var.nChannels) = []; %Remove ChannlNumbers that dont exist
                        var = ita_split(var,ch_vector);
                    end
                case {'itaAudioResult'}
                    var_idx = get(f.(ita_guisupport_removewhitespaces(pList{idx}.description)),'Value');
                    all_var = get(f.(ita_guisupport_removewhitespaces(pList{idx}.description)),'String');
                    var = all_var(var_idx,:);
                    endIdx = findstr(var,' ');
                    if isempty(endIdx)
                        endIdx = numel(var);
                    end
                    frompopup = ita_guisupport_removewhitespaces(var(1:endIdx));
                    fromtext = ita_guisupport_removewhitespaces(get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'String'));
                    if isempty(frompopup) && ~isempty(fromtext)
                        savename = fromtext;
                    elseif ~isempty(frompopup) && isempty(fromtext)
                        savename = frompopup;
                    elseif ~isempty(frompopup) && ~isempty(fromtext)
                        savename = fromtext;
                    else
                        savename = 'ans';
                    end
                    var = savename;
                    
                case {'int','double','int_result_button','int_long','double_long'}
                    z = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'String');
                    if isempty(z)
                        empty_field = 1;
                    end
                    
                    try
                        var = str2num(get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'String')); %#ok<ST2NM>
                    catch %#ok<CTCH>
                        var = pList{idx}.default;
                    end
                    
                case {'slider'}
                    var = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'Value');
                    
                case {'char','char_result_button','char_long','path','getfile','setfile','textfield'}
                    var = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'String');
                    
                case {'bool'}
                    var = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'Value');
                    if var == 1
                        var = true;
                    else
                        var = false;
                    end
                    
                case {'line','text','picture','simple_button','simple_text'}
                    var = 'to_be_deleted';
                    
                case {'char_popup'}
                    list = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'UserData');
                    value = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'Value');
                    var = popup_index_to_string(list,value);
                    
                case {'int_popup'}
                    list = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'UserData');
                    value = get(h.(ita_guisupport_removewhitespaces(pList{idx}.description)),'Value');
                    var = list(value);
                    
                otherwise
                    disp('wow nice error')
                    disp(type)
            end
            pListFinal{idx} = var;
            if strcmpi(class(var),'itaAudio')
                pReturnList{idx}.default = '';
            else
                pReturnList{idx}.default = var;
            end
        end
        uiresume(gcf);
        close(hFigure)
        return;
    end

    function SelChannelButton(hObject,eventdata)
        userdata     = get(hObject,'UserData');
        ch_available= userdata{4};
        handle_text  = userdata{1};
        
        if isempty(ch_available)     % popup with all objects from workspace
            handle_popup = userdata{2};
            var_list = userdata{3};
            var_idx = get(handle_popup,'Value'); %index
            var_name = popup_index_to_string(var_list, var_idx);
            var_name = var_name(1:findstr(var_name,' ')); % delete spaces in string
            var = ita_getfrombase(var_name);
            
            if isempty(var)
                set(handle_text,'String','')
                return
            end
            
            ch_available = ita_sprintf('Ch %i - %s',1:var.nChannels, var.channelNames);
        end
        ch_select = str2num(get(handle_text,'String')); %#ok<ST2NM>
        if isempty( ch_select)
            ch_select = 1:numel(ch_available);
        end
        
        [index] = listdlg('Name','Select Channels',...
            'PromptString','Select channels:',...
            'SelectionMode','multiple',...
            'ListString',ch_available,'InitialValue',ch_select);

        set(handle_text,'String',num2str(index));
    end

    function BrowseCallback(hObject,eventdata)
        x = get(hObject,'UserData'); %handle for text field
        startpath = get(x,'String');
        dlgname = get(hObject,'String');
        moreinfos = get(x,'UserData');
        type = moreinfos{1};
        filter = moreinfos{2};
        switch type
            case 'path'
                dir_str = uigetdir(startpath, dlgname);
            case 'getfile'
                [filename filepath] = uigetfile(filter, dlgname, startpath);
                dir_str = [filepath filename];
            case 'setfile'
                [filename filepath] = uiputfile(filter, dlgname, startpath);
                dir_str = [filepath filename];
        end
        set(x,'String',dir_str);
    end

    function CancelButtonCallback(hObject,eventdata)
        uiresume(gcf);
        close(hFigure)
        return;
    end

    function simpleButtonCallback(hObject,eventdata)
        funStr = get(hObject,'Userdata');
        switch lower(class(funStr))
            case {'function_handle'}
                funStr(hObject,eventdata);
            otherwise
                eval(funStr);
        end
    end

    function resultButtonCallback(hObject,eventdata)
        %pdi
        userdata = get(hObject,'Userdata');
        funStr   = userdata{1};
        
        switch(lower(userdata{3}))
            case {'char_result_button'}
                handle = userdata{2};
                value = get(handle,'string');
                strrep (funStr,'$$',value);
                result = eval(funStr);
                set(handle,'String',result);
            case {'int_result_button'}
                handle = userdata{2};
                try
                    value  = str2num(get(handle,'string')); %#ok<ST2NM>
                catch %#ok<CTCH>
                    value = [];
                end
                funStr = strrep (funStr,'$$',[num2str(value)]);
                result = eval(funStr);
                set(handle,'String',num2str(result));
        end
    end

    function refreshitaAudiopopups(hObject,eventdata)
        for idfield = 1:numel(pList)
            if strcmpi(pList{idfield}.datatype, 'itaAudio')
                popuphandle = f.(ita_guisupport_removewhitespaces(pList{idfield}.description));
                currentindex = get(popuphandle,'Value');
                currentvalue = popup_index_to_string(get(popuphandle,'UserData'),currentindex);
                newlist = ita_guisupport_getworkspacelist();
                set(popuphandle,'String',newlist);
                set(popuphandle,'UserData',newlist);
                set(popuphandle,'Value',popup_string_to_index(newlist,currentvalue))
            end
            
        end
    end

    function sliderchange_callback(hObject,eventdata) %Callback when slider is moved (changes text in textbox)
        set(get(hObject,'UserData'),'String',num2str(get(hObject,'Value')));
    end
    function slidertextchange_callback(hObject,eventdata) % Calback when textbox of slider is changes (changes value of slider)
        try
            set(get(hObject,'UserData'),'Value',str2double(get(hObject,'String')));
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
                
                OkayButtonCallback(s,[])
                
            case 'escape'
                CancelButtonCallback(s,[])
                
        end
        
        %end function
    end


end
