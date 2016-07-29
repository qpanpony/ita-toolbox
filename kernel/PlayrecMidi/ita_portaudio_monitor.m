function varargout = ita_portaudio_monitor(varargin)
%ITA_PORTAUDIO_MONITOR - Monitor of levels for playback/record
%
%  Syntax:
%   ita_portaudio_monitor('init',numberOfChannels) - constructor
%   ita_portaudio_monitor('close') - destructor
%   ita_portaudio_monitor('update',[data,1xnumberOfChannels])
%
%  Example:
%   audioObj = ita_portaudio_monitor(audioObj)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_portaudio_monitor">doc ita_portaudio_monitor</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  15-Jun-2009
% MMT: Major rewrite due to change in bar plot (22-Nov-2014)

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,2);
modeStr = varargin{1};

figHandle = findobj('UserData','LevelMonitor');
if isempty(figHandle)
    figHandle = figure('ResizeFcn',@resizeFunction,'CloseRequestFcn',@closeFunction);
    set(figHandle,'UserData','LevelMonitor');
end
% persistent figHandle
persistent levelHandle
persistent maxValues
persistent nOutChannels
persistent nInChannels
minVal = -101;

switch lower(modeStr)
    case {'init'}
        set(figHandle,'Visible','on');
        clf(figHandle)
        h = [];
        guidata(figHandle,h);
        narginchk(2,2);
        nOutChannels = varargin{2}(1);
        nInChannels  = varargin{2}(2);
        nChannels = nOutChannels + nInChannels + 1; %sepearation by one zero bar
        maxValues = minVal*ones(nChannels,1);
        
        set(figHandle,'menubar','none')
        set(figHandle,'NumberTitle','off');
        pos = get(figHandle,'Position');
        pos(3) = 70 + 50 * nChannels;
        set(figHandle,'Position',pos);
        titleStr = 'ITA PortAudio Monitor';
        set(figHandle,'Name', titleStr)
        
        %% plot init
        levelHandle = [];
        relAxesXPosition = [0 1]+[40 -40]./[pos(4) pos(4)];
        axesHandle = axes('parent', figHandle, 'Visible','on','OuterPosition',[0 relAxesXPosition(1) 1 relAxesXPosition(2)]);
        %max peak plot
        hold off
        levelHandle(1) = patch(bsxfun(@plus,1:nChannels,[-0.1;-0.1;0.1;0.1]),repmat(minVal,[4 nChannels]),ones(4,nChannels));
        set(levelHandle(1),'Visible','on')
        hold on
        %level plot
        levelHandle(2) = patch(bsxfun(@plus,1:nChannels,[-0.3;-0.3;0.3;0.3]),repmat(minVal,[4 nChannels]),ones(4,nChannels));
        set(levelHandle(2),'Visible','on')
        hold on
        
        %baseline
        set(levelHandle(1),'EdgeColor',[1 1 1])
        set(levelHandle(2),'EdgeColor',[1 1 1])
        set(gca,'TickLength',[0 0]);
        
        %% axis
        xlim([0.5 0.5+nChannels])
        ylim([minVal 1]);
        xTicksOUT = '';
        for idx = 1:nOutChannels
            xTicksOUT{idx} = ['OUT ' num2str(idx)];
        end
        xTicksIN = '';
        for idx = 1:nInChannels
            xTicksIN{idx} = ['IN ' num2str(idx)];
        end
        xTicks = [xTicksOUT {' '} xTicksIN];
        set(gca,'XTick',1:nChannels)
        set(gca,'XTickLabel',xTicks)
        title(titleStr)
        if ita_preferences('blackbackground')
            ita_whitebg([0 0 0])
        end
        colormap(gca,meter_bar)
             
        %% coloring
        set(levelHandle(2),'FaceAlpha',0.8)
        
        fvd_max  = get(levelHandle(1),'Faces');
        fvcd_max = get(levelHandle(1),'FaceVertexCData');
        fvd      = get(levelHandle(2),'Faces');
        fvcd     = get(levelHandle(2),'FaceVertexCData');
        
        for idx = 1:nChannels
            fvcd_max(fvd_max(idx,1:4)) = 50;
            fvcd(fvd(idx,1:4))         = 50;
        end
        set(levelHandle(1),'FaceVertexCData',fvcd_max,'CDataMapping','Direct');
        set(levelHandle(2),'FaceVertexCData',fvcd,'CDataMapping','Direct');
        ylabel('dBFS');
        
        %% close button
        figSize = get(figHandle,'Position');
        h.resetPeakButton = uicontrol('style', 'pushbutton', 'parent', figHandle, 'position', [figSize(3)/2-25 20 60 30], 'string', 'Stop', 'callback', @closeButtonCallback);
        h.axesHandle = axesHandle;
        guidata(figHandle,h);
        
    case {'close'}
        %         disp('close')
        if ishandle(figHandle)
            delete (figHandle)
        else
            disp([thisFuncStr 'cannot close figure'])
        end
        
    case {'update'}
        narginchk(2,2);
        data      = max([varargin{2}(1:nOutChannels,1); minVal; varargin{2}(nOutChannels+1:end,1)],minVal); %limit low to minVal
        data = round(data);
        maxValues = max(data,maxValues); %get overall max peaks
        nChannels = nOutChannels + nInChannels + 1;
        
        if ~any(ishandle(figHandle))
            disp('I will do an INIT for you!')
            figHandle = ita_portaudio_monitor('init',length(data));
        end
        
        %% set new data
        minVec = repmat(minVal,1,nChannels);
        set(levelHandle(1),'YData',[minVec; repmat(maxValues(:).',2,1); minVec]);
        set(levelHandle(2),'YData',[minVec; repmat(data(:).',2,1); minVec]);
        
        %% coloring        
        fvd      = get(levelHandle(2),'Faces');
        fvcd     = get(levelHandle(2),'FaceVertexCData');
        fvd_max  = get(levelHandle(1),'Faces');
        fvcd_max = get(levelHandle(1),'FaceVertexCData');
        
        % set the colors
        % round values to half dB and add an offset, so that 0 is red but -1 is green
        % output is never red
        if length(data) >= nOutChannels
            for idx = 1:nOutChannels
                fvcd(fvd(idx,1:4))         = max(round(-data(idx)./0.5).*0.5,2);
                fvcd_max(fvd_max(idx,1:4)) = max(round(-maxValues(idx)./0.5).*0.5,2);
            end
        end
        
        % input
        if length(data) >= nOutChannels + nInChannels
            for idx = nOutChannels+1:length(data) %over nChannels
                fvcd(fvd(idx,1:4))         = round(-data(idx)./0.5).*0.5 + 1;
                fvcd_max(fvd_max(idx,1:4)) = round(-maxValues(idx)./0.5).*0.5 + 1;
            end
        end
        set(levelHandle(2),'FaceVertexCData',fvcd)
        set(levelHandle(1),'FaceVertexCData',fvcd_max)
end
if nargout == 1
    varargout{1} = figHandle;
end

%end function
end

function a = meter_bar()
a = ([1,0,0; repmat([0,0.498039215803146,0],[29 1]);
      0.0833333358168602,0.539869308471680,0; ...
      0.166666671633720,0.581699371337891,0; ...
      0.250000000000000,0.623529434204102,0; ...
      0.333333343267441,0.665359497070313,0; ...
      0.416666656732559,0.707189559936523,0; ...
      0.500000000000000,0.749019622802734,0; ...
      0.583333313465118,0.790849685668945,0; ...
      0.666666686534882,0.832679748535156,0; ...
      0.750000000000000,0.874509811401367,0; ...
      0.833333313465118,0.916339874267578,0; ...
      0.916666686534882,0.958169937133789,0; ...
      repmat([1,1,0],[24 1]); ...
      0.957843124866486,0.953921556472778,0.196078434586525; ...
      0.915686249732971,0.907843112945557,0.392156869173050; ...
      0.873529434204102,0.861764729022980,0.588235318660736; ...
      0.831372559070587,0.815686285495758,0.784313738346100; ...
      0.832418322563171,0.817254900932312,0.786928117275238; ...
      0.833464086055756,0.818823516368866,0.789542496204376; ...
      0.834509789943695,0.820392191410065,0.792156875133514; ...
      0.835555553436279,0.821960806846619,0.794771254062653; ...
      0.836601316928864,0.823529422283173,0.797385632991791; ...
      0.837647080421448,0.825098037719727,0.800000011920929; ...
      0.838692843914032,0.826666653156281,0.802614390850067; ...
      0.839738547801971,0.828235328197479,0.805228769779205; ...
      0.840784311294556,0.829803943634033,0.807843148708344; ...
      0.841830074787140,0.831372559070587,0.810457527637482; ...
      0.842875838279724,0.832941174507141,0.813071906566620; ...
      0.843921601772308,0.834509789943695,0.815686285495758; ...
      0.844967305660248,0.836078464984894,0.818300664424896; ...
      0.846013069152832,0.837647080421448,0.820915043354034; ...
      0.847058832645416,0.839215695858002,0.823529422283173; ...
      0.848104596138001,0.840784311294556,0.826143801212311; ...
      0.849150359630585,0.842352926731110,0.828758180141449; ...
      0.850196063518524,0.843921601772308,0.831372559070587; ...
      0.851241827011108,0.845490217208862,0.833986937999725; ...
      0.852287590503693,0.847058832645416,0.836601316928864; ...
      0.853333353996277,0.848627448081970,0.839215695858002; ...
      0.854379117488861,0.850196063518524,0.841830074787140; ...
      0.855424821376801,0.851764738559723,0.844444453716278; ...
      0.856470584869385,0.853333353996277,0.847058832645416; ...
      0.857516348361969,0.854901969432831,0.849673211574554; ...
      0.858562111854553,0.856470584869385,0.852287590503693; ...
      0.859607875347138,0.858039200305939,0.854901969432831; ...
      0.860653579235077,0.859607875347138,0.857516348361969; ...
      0.861699342727661,0.861176490783691,0.860130727291107; ...
      0.862745106220245,0.862745106220245,0.862745106220245; ...
      1,1,1;]);
end

function resizeFunction(src,evt)
    h = guidata(src);
    if ~isempty(h)
        pos = get(src,'Position');
        relAxesXPosition = [0 1]+[40 -40]./[pos(4) pos(4)];
        set(h.axesHandle,'OuterPosition',[0 relAxesXPosition(1) 1 relAxesXPosition(2)]);
        set(h.resetPeakButton,'Position',[pos(3)/2-25 20 60 30]);
    end
end

function closeButtonCallback(src,evt)
    figureHandle = get(src,'Parent');
    set(figureHandle,'Visible','off'); 
end


function closeFunction(src,evt)
    figureHandle = src;
    set(figureHandle,'Visible','off'); 
end