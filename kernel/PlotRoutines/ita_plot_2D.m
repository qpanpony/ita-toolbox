function varargout = ita_plot_2D(varargin)
%ITA_PLOT_2D - plot two-dimensional data
%  This function takes an itaAudio/itaResult as input argument and plots
%  the data for a given time instant or frequency.
%  The output argument is a handle to the plot axes.
%
%  Syntax:
%   handle = ita_plot_2D(audioObjIn, numeric, options)
%
%   Options (default):
%           'plotDomain' ('freq') : domain to plot (time or freq)
%           'plotType' ('mag')    : can be mag, lin or phase
%           'plotRange' (50)      : which part of the data to display (can
%                                   also be a vector with [lowLimit highLimit]
%           'currentAxes' (-1)    : axes to plot the data into
%           'backgroundImage' (1) : image for data overlay
%           'aspectMat' (-1)      : aspect data for the image
%           'alpha' (1)           : transparency of the overlay data
%           'newFigure' (true)    : whether to open a new figure
%
%  Example:
%   axes = ita_plot_2D(audioObjIn,1000)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_2D">doc ita_plot_2D</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  09-Jan-2010 

% For some more help read the 'ITA Toolbox Getting Started.pdf' 
% delivered with the ITA-Toolbox in the documentation directory, or use the
% wiki which provides more or less actual informations about the
% development. (https://www.akustik.rwth-aachen.de/ITA-Toolbox/wiki)

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_input','itaSuper','pos2_plotInstant','numeric','plotDomain','freq','plotType','mag','plotRange',50,'alpha',1,'currentAxes',-1,'backgroundImage',uint8(1),'aspectMat',-1,'newFigure',true,'filename','');
[input,plotInstant,sArgs] = ita_parse_arguments(sArgs,varargin);

% check data dimensions
if numel(input.dimensions) ~= 2
    error([thisFuncStr 'data must have two dimensions']);
end

sArgs.plotRange = sort(sArgs.plotRange);

% if axes are given, they will be used for plotting
if sArgs.currentAxes == -1
    axesMode = 0;
else
    axesMode = 1;
end

% only display image if one is given and alpha is not zero
if (ndims(sArgs.backgroundImage) < 3) || (sArgs.alpha <= 0)
    displayImage = 0;
else
    displayImage = 1;
    if ndims(sArgs.aspectMat) > 1 % is a correct aspect matrix is given
        x = sArgs.aspectMat(1,:);
        y = sArgs.aspectMat(2,:);
    else % standard aspect ratio 4/3
        x = [-1,1];
        y = (3/4).*x;
    end
end

%% plot preparations
switch sArgs.plotDomain
    case 'freq'
        plotUnit = ' Hz';
    case 'time'
        plotUnit = ' s';
    otherwise
        error([thisFuncStr 'incorrect plot domain']);
end

% plot id
abscissa = input.([sArgs.plotDomain 'Vector']);
abscissaIdx = eval(['input.' sArgs.plotDomain '2index(' num2str(plotInstant) ')']);
abscissaVal =round(abscissa(abscissaIdx));
ita_verbose_info([thisFuncStr 'plotting at ' sArgs.plotDomain ': ' num2str(abscissaVal)],2);
data = eval(['input.' sArgs.plotDomain '2value(' num2str(plotInstant) ')']);

switch sArgs.plotType
    case {'lin','real','imag'}
        if strcmpi(sArgs.plotType,'lin')
            if ~all(isreal(data))
                plotData = abs(data);
            else
                plotData = data;
            end
            titleStr = ['Magnitude (linear, ' input.channelUnits{1} ') at ' sArgs.plotDomain ': ' num2str(abscissaVal) plotUnit];
        elseif strcmpi(sArgs.plotType,'real')
            plotData = real(data);
            titleStr = ['Real part (linear, ' input.channelUnits{1} ') at ' sArgs.plotDomain ': ' num2str(abscissaVal) plotUnit];
        else
            plotData = imag(data);
            titleStr = ['Imaginary part (linear, ' input.channelUnits{1} ') at ' sArgs.plotDomain ': ' num2str(abscissaVal) plotUnit];
        end
        
        if numel(sArgs.plotRange) == 1
            lim1 = 10*round(0.1*min(min(plotData)));
            lim2 = 10*round(0.1*max(max(plotData)));
        else
            lim1 = sArgs.plotRange(1);
            lim2 = sArgs.plotRange(2);
        end
        if lim1 == lim2
            lim1 = lim1 - 5;
            lim2 = lim2 + 5;
        end
    case 'mag'
        %get logarithmic frequency data log_prefix*log10(abs(Obj.freq)/referenceValue)
        [dataUnits,  refValues, log_prefix] = itaValue.log_reference(input.channelUnits);
        % changed from log10(x) to log(x)/log(10) because it is faster
        plotData = log_prefix(1).'./log(10).*log(abs(data + realmin)); % to avoid -Inf
        plotData = bsxfun(@plus, plotData, log_prefix(1).'./log(10).*log(1./refValues(1).'));
        titleStr = ['Magnitude (dB re ' dataUnits{1} ') at ' sArgs.plotDomain ': ' num2str(abscissaVal) plotUnit];
        % levels below the plotRange are set to -inf
        magMax = max(max(plotData));
        % if only one value for the range is given
        if numel(sArgs.plotRange) == 1
            tmp = 10*round(0.1*magMax)+10;
            sArgs.plotRange = [tmp-sArgs.plotRange tmp];
        end
        plotData(plotData < sArgs.plotRange(1)) = -inf;
        % colorbar limits
        lim1 = sArgs.plotRange(1);
        lim2 = sArgs.plotRange(2);
    case 'phase'
        plotData = (180/pi).*angle(data);
        titleStr = ['Phase (deg) at ' sArgs.plotDomain ': ' num2str(abscissaVal) plotUnit];
        % colorbar limits
        lim1 = -180;
        lim2 = 180;
    otherwise
        error([thisFuncStr 'incorrect plot type']);
end
levelStep = diff([lim1 lim2])/50;

inputUserData = input.userData;
xLabel = 'X (m)'; yLabel = 'Y (m)';
try
    X = reshape(input.channelCoordinates.x(~isnan(input.channelCoordinates.x)),input.dimensions);
    Y = reshape(input.channelCoordinates.y(~isnan(input.channelCoordinates.y)),input.dimensions);
catch %#ok<CTCH>
    ita_verbose_info([thisFuncStr 'could not get coordinates from channel data, trying something else'],0);
    % backward compability
    if ~isempty(find(strcmpi(inputUserData,'x')==1, 1)) && ~isempty(find(strcmpi(inputUserData,'y')==1, 1))
        [X,Y] = ndgrid(inputUserData{find(strcmpi(inputUserData,'x')==1)+1},inputUserData{find(strcmpi(inputUserData,'y')==1)+1});
    else
        [Nx,Ny] = size(plotData);
        [X,Y] = ndgrid(1:Nx,1:Ny);
        xLabel = 'X'; yLabel = 'Y';
    end
end

%% plot
% if axes were specified use them for the plots
if axesMode
    % get all the different axes
    chdr = get(sArgs.currentAxes,'Children');
    for i = 1:numel(chdr)
        % image axes
        if strcmp(get(chdr(i),'Type'),'image') && displayImage
            imageAxes = chdr(i);
            set(imageAxes,'CData',sArgs.backgroundImage,'AlphaData',sArgs.alpha);
        % axes for the surface plot
%         elseif ~isempty(strfind(get(chdr(i),'Type'),'surface'))
%             surfaceAxes = chdr(i);
%             set(surfaceAxes,'XData',X,'YData',Y,'ZData',plotData);
%             set(sArgs.currentAxes,'CLim',[lim1 lim2]);
%             title(sArgs.currentAxes,titleStr);
        % axes for the contour plot
        elseif ~isempty(strfind(get(chdr(i),'Type'),'hg'))
            contourAxes = chdr(i);
            set(contourAxes,'XData',X,'YData',Y,'ZData',plotData);
            set(sArgs.currentAxes,'CLim',[lim1 lim2]);
            title(sArgs.currentAxes,titleStr);
        end
    end
    % no axes specified, create new figure
else
    scrsz = get(0,'ScreenSize');
    if sArgs.newFigure
        visible = 'on';
        
        if ~isempty(sArgs.filename);
            visible = 'off';
        end
        hgf = figure('Name',titleStr,'Position',[1 (1/3)*scrsz(4) (1/3)*scrsz(3) scrsz(4)/3],'Visible',visible);
    end
    ita_whitebg([0 0 0]);
    if sArgs.alpha < 1
%         surfaceAxes = surf(X,Y,plotData,'EdgeColor','none');
        [C,contourAxes] = contourf(X,Y,plotData,'EdgeColor','none','LevelStep',levelStep);
        axis([min(X(:)) max(X(:)) min(Y(:)) max(Y(:)) lim1 lim2]);
%         view(0,90);
        hold on;
        if displayImage
            image(x,y,sArgs.backgroundImage,'AlphaData',sArgs.alpha);
            axis image
            set(gca,'YDir','normal')
        end
    else
        if displayImage
            image(x,y,sArgs.backgroundImage,'AlphaData',sArgs.alpha);
            axis image
            set(gca,'YDir','normal')
        end
        hold on;
%         surfaceAxes = surf(X,Y,plotData,'EdgeColor','none');
        [C,contourAxes] = contourf(X,Y,plotData,'EdgeColor','none','LevelStep',levelStep);
        axis([min(X(:)) max(X(:)) min(Y(:)) max(Y(:)) lim1 lim2]); 
%         view(0,90);
    end
    hold off;
    colorbar; set(gca,'CLim',[lim1 lim2]);
    xlabel(xLabel); ylabel(yLabel);
    axis equal;
    axis tight;
    title(titleStr);    
end

%% save figure?
if ~isempty(sArgs.filename)
       print('-dpng','-r300',fullfile(pwd, [sArgs.filename]))
end


%% Set Output
if nargout
    % varargout(1) = {get(surfaceAxes,'Parent')};
    varargout(1) = {get(contourAxes,'Parent')};
end

%end function
end