function ita_plottools_aspectratio(varargin)
%ITA_PLOTTOOLS_ASPECTRATIO - Scale Figure according to aspect ratio
%  This function rescales a figure according to a given aspect ratio or an
%  aspect ratio set in the Toolbox Preferences. If an  aspect ratio of 0,
%  is set, the plot will be maximized to full screen.
%
%  Syntax: ita_plottools_aspectratio(aspectratio)
%  Syntax: ita_plottools_aspectratio(hfig,aspectratio)
%
%   Parameters: aspect ratio = height/width, rational number e.g. 0.8
%               hfig : figure handle
%
%   See also ita_plottools_figure, ita_plottools_maximize, ita_preferences_aspectratio.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_aspectratio">doc ita_plottools_aspectratio</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Author: Sebastian Fingerhuth -- Email: sfi@akustik.rwth-aachen.de
% Created:  04-Mar-2009


%% Initialization and Input Parsing
narginchk(0,2);

if nargin == 0
    %% use preferences aspect ratio and scale current figure
    aspectratio = ita_preferences('aspectratio');
    hfig = gcf;
elseif nargin == 1
    %use this aspect ratio
    hfig = gcf;
    aspectratio = varargin{1};
  
else % handle and aspect ratio given
    hfig        = varargin{1};
    aspectratio = varargin{2};
end

if isempty(aspectratio)
    return;
end

set(hfig,'Units','pixels')
%% scale figure
if aspectratio || isunix
    % TODO % maximum monitor size / figure
    mpos = get(0,'Monitor');
    if size(mpos,1) > 1
        monitorSizes = mpos(:,3:4)-mpos(:,1:2)+1;
        [del idxBigScreen ] = max(prod(monitorSizes,2));
        mpos = mpos(idxBigScreen,:); %get only main monitor, which is the bigger one
    end
    
    monitor_width  = mpos(3)-mpos(1)+1;
    monitor_height = mpos(4)-mpos(2)+1;
    
    if aspectratio > 0
        if aspectratio > monitor_height / monitor_width;
            figure_height = monitor_height;
            figure_width  = monitor_height ./ aspectratio;
        else
            figure_height = monitor_width * aspectratio;
            figure_width  = monitor_width;
        end
    else
        figure_height = monitor_height;
        figure_width  = monitor_width;
    end
    
    figure(hfig)
    abs_mon_position = [mpos(1) 0  figure_width figure_height] + ...
        [monitor_width-figure_width monitor_height-figure_height  0 0 ];
    
    %apply settings
    set(hfig,'OuterPosition',abs_mon_position);
    set(hfig,'Units','normalized');
    set(hfig,'PaperPositionMode','auto');
    
else
    ita_plottools_maximize(hfig);
end


%end function
end