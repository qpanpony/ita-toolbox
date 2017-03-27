function varargout = ita_TPA_TPS_playback(varargin)
%ITA_TPA_TPS_PLAYBACK - realtime playback GUI
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_TPA_TPS_playback(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_TPA_TPS_playback(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_TPA_TPS_playback">doc ita_TPA_TPSa = _playback</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  21-Jun-2010



%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>
nChannels = input.nChannels;
h_textbox    = 22;
fontsize     = 9;
% left_margin  = 15;
% space        = 15;

desc_type_weight = 'bold';
width_description = 150;

% if ispc
%     button_height  = 20;
% elseif ismac
%     button_height = 30;
% else
%     button_height = 20; %pdi???
% end

%% Create GUI
mpos = get(0,'Monitor');

width  = 400;
height = 520;

w_position    = (mpos(1,length(mpos)-1)/2)-(width/2);
h_position    = (mpos(1,length(mpos))/2)-(height/2);
MainPosition  = [w_position h_position width height];

gui_bg_color  = [0.8 0.8 0.8];

%% Figure Handling
hFigure = figure( ...       % the main GUI figure
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'on', ...
    'Name', 'RealTime Audio Control', ...
    'NumberTitle', 'off', ...
    'Position' , MainPosition, ...
    'Units','pixel',...
    'Color', gui_bg_color,...
    'CloseRequestFcn',@CloseRequestFcn); 

pause(0.02) % wait for gui to show up

%% ITA toolbox logo with grey bg
a_im = importdata('ita_toolbox_logo.png');
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [20 10 350 65]*0.6);


%%
left_margin = 4;
% button_width = 12;
muteCh = zeros(nChannels,1);

%% mute buttons
for ch_idx = nChannels:-1:1
    name = input.channelNames{ch_idx};
    
    %% channel name
    uicontrol(...
        'Parent', hFigure, ...
        'Position',[left_margin height-7-(ch_idx)*(h_textbox+3) width_description h_textbox-7],...
        'String',name,...
        'FontSize',fontsize,...
        'FontWeight',desc_type_weight,...
        'BackgroundColor',[0.8 0.8 0.8],...
        'HorizontalAlignment','left',...
        'Style', 'text');
    
    %% channel mute
    uicontrol(...
        'FontSize',10,...
        'Position',[left_margin+100 height-7-(ch_idx)*(h_textbox+3) width_description h_textbox-7],...
        'Callback',@SwitchState_chngFcn,...
        'BackgroundColor',[1 0 0],...
        'userdata',[ch_idx , 0],...
        'String',name,...
        'Style','togglebutton',...
        'Value',0,...
        'Tag','togglebuttonNorm');
end

%%
segment_size = 2^13;
% in_channels = 1:2;
nonblockingbuffersize = 2;
sampling_rate = ita_preferences('samplingRate');
asiobuffersize = 0;
oldVerboseMode = ita_preferences('verboseMode');
ita_preferences('verboseMode',-1); % Absolutely no display as it is too slow

%% Select project folder
disp(['Segment duration: ' num2str(segment_size/sampling_rate,2) ' sec'])

input = ita_time_window(input,[100 1 input.nSamples-100 input.nSamples],'samples');
data  = input.ch(1);

timeData = input.timeData;

cancelButton = false;

for idx = 1:floor(input.nSamples/segment_size)
    data.timeData = sum(timeData( [1:segment_size] + (idx-1)*segment_size, ~muteCh ),2);
    %     res.timeData = [res.timeData; data.timeData];
    if cancelButton
        disp('user cancel')
        break
    end
    ita_portaudio(data, 'samplingRate',sampling_rate,'block',false,'reset',false,...
        'cancelbutton',0,'nonblockingbuffersize',nonblockingbuffersize,'singleprecision',true,'AsioBufferSize',asiobuffersize);
end

disp('finished')


%% set back old verbose level
ita_preferences('verboseMode',oldVerboseMode); % Absolutely no display as it is too slow



    function SwitchState_chngFcn(h,event)
        %0 mute -- 1: on
        userdata =  get(h,'userdata');
        switchState = ~userdata(2);
        if ~switchState
            set(h,'BackgroundColor',[0.1 0.1 0.1]);
        else
            set(h,'BackgroundColor',[0 1 1])
        end
        muteCh(userdata(1)) = switchState
        userdata(2) = switchState;
        set(h,'userdata',userdata);
    end


    function CloseRequestFcn(h,event)
        %         playrec('isInitialised')
        cancelButton = true;
        %         pause(0.1);
        %         playrec('reset');
        %        try
        %            playrec('init');
        %        catch
        %                       playrec('reset');
        %
        %        end
        delete(h)
    end

%end function
end



