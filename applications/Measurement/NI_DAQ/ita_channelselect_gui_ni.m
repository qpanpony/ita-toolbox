function varargout = ita_channelselect_gui_ni( varargin )
% Show gui to select channels for input and output (NI hardware)
%
% Syntax: [in_ch out_ch] = ita_channelselect_gui_ni()
%       [in_ch out_ch] = ita_channelselect_gui_ni(in_ch_preselct, out_ch_preselect)
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

% Author: Markus Mueller-Trapet -- Email: markus.mueller-trapet@nrc.ca
% Created:  10-May-2017

%% Get maximum input and output channels
% Initialization
[inputChannels,outputChannels] = ita_get_ni_deviceinfo();

out = numel(outputChannels.name);
out = max(out,0); %Filter '-1' in case that no device is selected
in  = numel(inputChannels.name);
in  = max(in,0); %Filter '-1' in case that no device is selected
if nargin == 0
   varargin{1} = 1:in; varargin{2} = 1:out; 
end
sArgs   = struct('pos1_a','int','pos2_b','int','onlyinput','false','onlyoutput','false');
[in_ch,out_ch,sArgs] = ita_parse_arguments(sArgs,varargin);

if sArgs.onlyinput
    out = 0;
elseif sArgs.onlyoutput
    in  = 0;
end

%% Draw - 8 channels in a row
if ~mod(out,8)
    out_height = out/8;
else
    out_height = (out - mod(out,8))/8 + 1;
end
if ~mod(in,8)
    in_height = in/8;
else
    in_height = (in - mod(in,8))/8 + 1;
end

%figure
height    = (2 + in_height + 1 + out_height + 1) * 40;
ch_width  = 70;
width     = (8+3)*(ch_width - 15);
persistent hFig
if ~isempty(hFig) && ishandle(hFig) && strcmpi(get(hFig,'Name'),'PortAudio IO Channels')
   close(hFig) 
end
hFig = figure('Name','PortAudio IO Channels',...
    'Position',[300 200 width height],...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'HandleVisibility','on',...
    'NumberTitle','off', ...
    'Color', [0.8 0.8 0.8]);

%ITA toolbox logo with grey background
a_im = importdata(which('ita_toolbox_logo.png'));
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [20 20 200 35]); %TODO: later set correctly the position

%% Headline Texts
if in
    uicontrol(...
        'Parent', hFig,...
        'Position',[20 (1+out_height+1+in_height+1)*40-20 200 20],...
        'HorizontalAlignment','left',...
        'String','Input Channels',...
        'FontSize',13,...
        'FontWeight','bold',...
        'Style', 'text',...
        'ForegroundColor', [0 0 0],...
        'BackgroundColor', [0.8 0.8 0.8]);
end
if out
    uicontrol(...
        'Parent', hFig,...
        'Position',[20 (1+out_height+1)*40-20 200 20],...
        'HorizontalAlignment','left',...
        'String','Output Channels',...
        'FontSize',13,...
        'FontWeight','bold',...
        'Style', 'text',...
        'ForegroundColor', [0 0 0],...
        'BackgroundColor', [0.8 0.8 0.8]);
end

%% Input Channels
for jdx = 1:in
    uicontrol(...
        'Parent', hFig,...
        'Position',[20+(mod(jdx-1,8))*ch_width (1+out_height+1+in_height-(jdx-mod(jdx-1,8)+1)/8)*40+2 30 15],...
        'HorizontalAlignment','right',...
        'String', ['Ch' num2str(jdx)],...
        'Style', 'text',...
        'ForegroundColor', [1 .1 .1],...
        'BackgroundColor', [0.8 0.8 0.8]);
end
if isempty(in_ch)
    in_ch = 1:in;
end
for jdx = 1:in
    h(jdx).in = uicontrol(...
        'Parent', hFig,...
        'Position',[50 + (mod(jdx-1,8))*ch_width (1+out_height+1+in_height-(jdx-mod(jdx-1,8)+1)/8)*40-5 20 30],...
        'Style', 'checkbox',...
        'Value',ismember(jdx,in_ch),...
        'ForegroundColor', [0 0 .7],...
        'BackgroundColor', [0.8 0.8 0.8]);
end


%% Output Channels
for jdx = 1:out
    uicontrol(...
        'Parent', hFig,...
        'Position',[20+(mod(jdx-1,8))*ch_width  (1+out_height-(jdx-mod(jdx-1,8)+1)/8)*40+2 30 15],...
        'HorizontalAlignment','right',...
        'String', ['Ch' num2str(jdx)],...
        'Style', 'text',...
        'ForegroundColor', [.1 0.6 .1],...
        'BackgroundColor', [0.8 0.8 0.8]);
end
if isempty(out_ch)
    out_ch = 1:out;
end
for jdx = 1:out
    
    h(jdx).out = uicontrol(...
        'Parent', hFig,...
        'Position',[50+(mod(jdx-1,8))*ch_width (1+out_height-(jdx-mod(jdx-1,8)+1)/8)*40-5 20 30],...
        'Style', 'checkbox',...
        'Value',ismember(jdx,out_ch),...
        'ForegroundColor', [0 0 .7],...
        'BackgroundColor', [0.8 0.8 0.8]);
end

%% Buttons
% Cancel Button
uicontrol(...
    'Parent', hFig, ...
    'Position',[330 20 80 30],...
    'String', 'Cancel',...
    'Style', 'pushbutton',...
    'Callback', @CancelButtonCallback,...
    'BackgroundColor', [0.7 0.7 0.7]);

% Ok Button
uicontrol(...
    'Parent', hFig, ...
    'Position',[430 20 80 30],...
    'String', 'OK',...
    'Style', 'pushbutton',...
    'Callback', @OkayButtonCallback,...
    'BackgroundColor', [0.7 0.7 0.7]);

uiwait(hFig);

%% Callbacks
    function CancelButtonCallback(hObject,eventdata) %#ok<INUSD>
        uiresume(gcf);
        close(hFig)
        %choose output arguments
        if sArgs.onlyinput
            varargout{1} = in_ch;
        elseif sArgs.onlyoutput
            varargout{1} = out_ch;
        else
            varargout{1} = in_ch;
            varargout{2} = out_ch;
        end
        
        return;
    end

    function OkayButtonCallback(hObject,eventdata) %#ok<INUSD>
        in_ch = [];
        for jdx2 = 1:in
            if get(h(jdx2).in,'Value') == get(h(jdx2).in,'Max')
                in_ch = [in_ch jdx2]; %#ok<*AGROW>
            end
        end
        out_ch = [];
        for jdx2 = 1:out
            if get(h(jdx2).out,'Value') == get(h(jdx2).out,'Max')
                out_ch = [out_ch jdx2];
            end
        end
        uiresume(gcf);
        close(hFig)
        
        %choose output arguments
        if sArgs.onlyinput
            varargout{1} = in_ch;
        elseif sArgs.onlyoutput
            varargout{1} = out_ch;
        else
            varargout{1} = in_ch;
            varargout{2} = out_ch;
        end
        
        return;
    end

end
