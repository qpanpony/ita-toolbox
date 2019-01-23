function varargout = ita_plot_nyquist(varargin)
%ITA_PLOT_NYQUIST - Nyquist plot
%  This function makes a Nyquist plot from input audioObject
%
%  Syntax:
%   audioObjOut = ita_plot_nyquist(audioObjIn, options)
%
%   options:
%       freqRange:  User can specify the frequency in Hz that should be plotted
%                   [from, to] -> [-inf, inf], e.g. [20,10000]
%       freqMarkers: User can activate markers that are marking certain frequencies in the Nyquist plot
%                   [frequenciesToMark] -> [0], e.g. [20:10:100]
%                       Alternative: 'interactive'
%                                       include interactive slider to adjust the marker positions for all markers at once 
%
%  Example:
%   audioObjOut = ita_plot_nyquist(audioObjIn)
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_nyquist">doc ita_plot_nyquist</a>


% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Date:  21-Jan-2019


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Get Defaults
matlabdefaults = ita_set_plot_preferences; %#ok<NASGU> %set ita toolbox preferences and get the matlab default settings


%% Input argument handling
sArgs = struct('pos1_data','itaAudio', 'freqRange', [-inf, inf], 'freqMarkers', [],...
        'nominal', [],'showUncertainty', false,'addUnc', [],...
        'nodb',ita_preferences('nodb'),'figure_handle',[],'axes_handle',[],...
        'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'),...
    'fontsize',ita_preferences('fontsize'),'color',[],...
    'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off',...
    'ylog',false,'plotcmd',@plot,'plotargs',[],'fastmode',0);

[data, sArgs] = ita_parse_arguments(sArgs, varargin); 

%% internal variables
boolMarkersInteractive = false;


%% checks
% check if new figure should be created
if isempty(sArgs.figure_handle)
    fgh = figure;
else
    fgh = sArgs.figure_handle;
end
hold all;

% check if any bound is inf
if isinf(sArgs.freqRange(1)) %lower bound given
    sArgs.freqRange(1) = 0;
end
if isinf(sArgs.freqRange(2)) %upper bound given
    sArgs.freqRange(2) = data.samplingRate/2; 
end

if( ischar(sArgs.freqMarkers) )
    if( strcmpi(sArgs.freqMarkers,'interactive') )
        boolMarkersInteractive = true;
        sArgs.freqMarkers = sArgs.freqRange(1);
    end
end

% check if the markers exceed the plotted range
if( ~isempty( sArgs.freqMarkers ) )
    if( min(sArgs.freqMarkers) < sArgs.freqRange(1) )
        sArgs.freqMarkers(sArgs.freqMarkers < sArgs.freqRange(1)) = [];
        warning('Marker frequency range goes further down than shown frequency range. Ignoring markers out of bounds.')
    end
    if( max(sArgs.freqMarkers) > sArgs.freqRange(2) )
        sArgs.freqMarkers(sArgs.freqMarkers > sArgs.freqRange(2)) = [];
        warning('Marker frequency range goes further up than shown frequency range. Ignoring markers out of bounds.')
    end
end

%% extract data and calculate real and imaginary part
idxRange = data.freq2index(sArgs.freqRange);% translate frequency to index
dataFreq = data.freqData(idxRange(1):idxRange(2),:);
Z_im=imag(dataFreq);
Z_real=real(dataFreq);
userData.freqVec = data.freqVector(idxRange(1):idxRange(2));
limStatic = [];

%% (optional) plot uncertainty in the background (first)
if( ~isempty(sArgs.nominal) && sArgs.showUncertainty)
    
    % calculate additive uncertainty
    if( isempty(sArgs.addUnc) )
        Wa = max(abs((data - sArgs.nominal)));
    else
        Wa = sArgs.addUnc;
    end
    
    % plot uncertainty with circles
    radius = Wa.freqData(idxRange(1):idxRange(2));
    contourNom = sArgs.nominal.freqData(idxRange(1):idxRange(2));
    hCont = viscircles([real(contourNom),imag(contourNom)], radius,'Color',[0.9,0.9,0.9]); 
    
    % calculate limits
    xData = hCont.Children(1).XData;
    yData = hCont.Children(1).YData;
    limStatic = [min(xData),max(xData),min(yData),max(yData)];
elseif( isempty(sArgs.nominal) && sArgs.showUncertainty)
    warning('no nominal path given for calculation of uncertainty');
end

%% plot data
hPl = plot(Z_real,Z_im, 'LineWidth',sArgs.linewidth,'UserData',userData,'Tag','contours');
xlabel('Real Part')
ylabel('Imaginary Part')
title('Nyquist Plot')
grid on;
hold all;
axis equal

if ~isempty(sArgs.color)
    set(hPl,'Color',sArgs.color);
end

% determine limits
if( isempty(limStatic) )
    limStatic = [min(min(Z_real)),max(max(Z_real)),min(min(Z_im)),max(max(Z_im))];    
end

%% apply static limits 
% much faster!
addSpace = 1.05;
xlim(limStatic(1:2)*addSpace); % additional 10%
ylim(limStatic(3:4)*addSpace);

%% Nyquist specifics (-1,0) point and circle around origin
plot(-1,0,'rx','Tag','helpers') % nyquist reference point

x = 0; y = 0; r = 1;
th = 0:pi/25:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
plot(xunit, yunit,'k--','Tag','helpers');


%% (optional) plot nominal
if( ~isempty(sArgs.nominal) )
    dataFreqNom = sArgs.nominal.freqData(idxRange(1):idxRange(2),:);
    Z_nom_real=real(dataFreqNom);
    Z_nom_imag=imag(dataFreqNom);
    hNom = plot(Z_nom_real,Z_nom_imag, 'LineWidth',2,'Color',[0,0,0],'UserData',userData,'Tag','nominal');
end


%% save axes handle
axh = get(fgh,'CurrentAxes');


%% place markers

% helper functions
getLocalIdx = @(f) data.freq2index(f) - idxRange(1) + 1;
getXMarkerPos = @(f) Z_real(getLocalIdx(f),:);
getYMarkerPos = @(f) Z_im(getLocalIdx(f),:);
    
if( ~boolMarkersInteractive ) % place markers at specified frequencies
    possibleMarks = ['+','o','*','.','x','s','d','v','p','h','<','>'];
    idxMarkers = data.freq2index(sArgs.freqMarkers);
    idxMarkersLocal = idxMarkers - idxRange(1) + 1; % consider the local frequency data vector
    for idM = 1:length(sArgs.freqMarkers)
        plot(Z_real(idxMarkersLocal(idM),:),Z_im(idxMarkersLocal(idM),:),['k',possibleMarks(mod(idM,length(possibleMarks)))],'Tag','markers');
    end
    
else % interactive marker placement

    % plot initial set of markers
    curFreq = sArgs.freqRange(1);
    hMark = plot(getXMarkerPos(curFreq),getYMarkerPos(curFreq),'k+','Tag','markers');
    
    % initial marker for nominal
    if( ~isempty(sArgs.nominal) )
        freqIdx = getLocalIdx(curFreq);
        hMarkNom = plot(Z_nom_real(freqIdx),Z_nom_imag(freqIdx),'kx','Tag','nominalMarker');
    end
    
    if( sArgs.showUncertainty )
    % initial plot for circle
        freqIdx = getLocalIdx(curFreq);
        idxCircles = (freqIdx-1)*182+1 : (freqIdx)*182; % each circle contains 182 points
        circleXData = hCont.Children(1).XData(idxCircles);
        circleYData = hCont.Children(1).YData(idxCircles);
        plot(circleXData,circleYData,'k-','Tag','currentUncertainty');
    end

    % Generate constants for use in uicontrol initialization
    pos=get(axh,'position');
%     newposSlider = [pos(1)+0.1 pos(2)-0.1 pos(3)-0.1 0.05]; % position below
%     newposTxt = [pos(1)-0.1 pos(2)-0.1 0.05 0.05];
    newposSlider = [pos(1)+pos(3)+0.03, pos(2), 0.03, pos(4)];
    newposTxt = [pos(1)+pos(3)-0.06, pos(2)-0.1, 0.1, 0.05];

    % Creating Uicontrol
    h=uicontrol('style','slider',...
        'units','normalized','position',newposSlider,...
        'callback',@changeMarkerPos,'min',0,'max',1,'Tag','slider');
    
    txt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',newposTxt,'FontSize',9,...
        'String',['f=',mat2str(curFreq),'Hz'],'Visible','on','Tag','sliderText');
end
%% create legend
% lnh = legend(data.channelNames);
% if( length(lnh.String) > 6)
%     lnh.Visible = 'off';
% end

%% deactivate hold
hold off;

%% axes tweeking
set(axh,'NextPlot','replace'); %much faster with background circles


%% return handle
varargout{1} = fgh;
varargout{2} = axh;
end


function changeMarkerPos(source,event)
% helper function to adjust the marker positions

    %% get objects from source
    hFig = source.Parent;
%     hAx = findobj(hFig.Children,'Type','axes');
    hAx = hFig.Children(end);
    hSliderText = findobj(hFig.Children,'Tag','sliderText');
    hMarkers = findobj(hAx.Children,'Tag','markers');
    hLines = findobj(hAx.Children,'Tag','contours');
    hGroup = findobj(hAx.Children,'Type','hggroup');
    hCurUnc = findobj(hAx.Children,'Tag','currentUncertainty');
    hCurNom = findobj(hAx.Children,'Tag','nominalMarker');
    hNom = findobj(hAx.Children,'Tag','nominal');

    
    %% extract freq data
    freqVec = hLines(1).UserData.freqVec;
    
    % get new freq value
    sliderValue = source.Value;
    
    %% scale slider value between min and max of freqVec
    freqLogSpan = log10(freqVec(end)) - log10(freqVec(1)); % scale between smallest and largest frequency value
    freqValue = 10.^(sliderValue * freqLogSpan + log10(freqVec(1)));
%     disp(['sliderValue:',mat2str(sliderValue),'freqValue:',mat2str(freqValue)]); % for debugging
        
    %% calc and set new point positions
    [~,freqIdx] = min(abs(freqVec-freqValue));
    newXMarkerPos = hMarkers.XData;
    newYMarkerPos = hMarkers.YData;
    for idy = 1:length(hLines)
        newXMarkerPos(idy) = hLines(idy).XData(freqIdx);
        newYMarkerPos(idy) = hLines(idy).YData(freqIdx);
    end
    
    % update marker positions
    set(hMarkers,'XData',newXMarkerPos,'YData',newYMarkerPos)
    
    %% update nominal marker
    if( ~isempty(hCurNom) )
        newXMarkerPosNom = hNom.XData(freqIdx);
        newYMarkerPosNom = hNom.YData(freqIdx);
        set(hCurNom,'XData',newXMarkerPosNom,'YData',newYMarkerPosNom)
    end
    
    
    
    %% mark currenct uncertainty circle
    if( ~isempty(hGroup) )
        idxCircles = (freqIdx-1)*182+1 : (freqIdx)*182; % each circle contains 182 points
        circleXData = hGroup.Children(1).XData(idxCircles);
        circleYData = hGroup.Children(1).YData(idxCircles);
        set(hCurUnc,'XData',circleXData);
        set(hCurUnc,'YData',circleYData);
    end
        
    
    %% update text
    s = sprintf('f=%dHz',round(freqValue));
    set(hSliderText,'String',s);
    drawnow;
    
end