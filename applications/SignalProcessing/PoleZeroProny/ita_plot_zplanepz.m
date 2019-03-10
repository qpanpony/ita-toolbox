function ita_plot_zplanepz(varargin)
%ITA_PLOT_ZPLANE - plot zplane w poles zeroes
%  This function plots poles and zeros in z plane
%
%  Syntax:
%   audioObjOut = ita_plot_zplane(z,p,k,options)
%               'channelNames'
%               'arrangement': 'combine', 'split', 'subplot'
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_zplane">doc ita_plot_zplane</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  26-Aug-2010 

% %% Initialization
sArgs = struct('pos1_data','cell,numeric','pos2_data','cell,numeric','pos3_data','cell,numeric',...
    'channelNames',[],'arrangement','combine');
%     'nodb',ita_preferences('nodb'),'figure_handle',[],'axes_handle',[],'linfreq',ita_preferences('linfreq'),'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname')...
%     ,'fontsize',ita_preferences('fontsize'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false,'unwrap',false,'wrapTo360',false,'plotcmd',@plot,'plotargs',[],'fastmode',0);
[z,p,k, sArgs] = ita_parse_arguments(sArgs, varargin);

% if nargin == 3
%     z = varargin{1};
%     p = varargin{2};
%     k = varargin{3};
%     channelNames = [];
% if nargin == 4
%     z = varargin{1};
%     p = varargin{2};
%     k = varargin{3};
%     channelNames = varargin{4};
% else
%    [z,p,k] = tf2zpk(varargin{1},varargin{2});
% end

% handle no channel Names input
if isempty(sArgs.channelNames)
    if iscell(p) % extension to cells for varying numbers of pole/zeros, e.g. due to simplify
        sArgs.channelNames = cell(1,length(p));
        sArgs.channelNames(1:length(z)) = {''};
    else
        sArgs.channelNames = {''};
    end
end
    
fgh = ita_plottools_figure();
x = colormap;
if iscell(p) % extension to cells for varying numbers of pole/zeros, e.g. due to simplify
    for idx = 1:length(p)
        switch sArgs.arrangement
            case {'combine'}
                % do nothing
            case {'split'}
                ita_plottools_figure();
            case {'subplot'}
                [m,n]=numSubplots(length(p)); % nicely arrange subplots
                subplot(m,n,idx);
            otherwise
                error('arrangement unknown');
        end
        
        color = x( 1+mod((idx-1)*21+1,size(x,1) ),:);
        zplaneplot(z{idx},p{idx},repmat({color},1,2) );
        hold on
    end
    legend(channelNames)
else
    if size(p,2)>size(p,1)
        p = p(:).';z=z(:).';
    end
    for idx = 1:size(p,2)
        color = x( 1+mod((idx-1)*21+1,size(x,1) ),:);
        zplaneplot(z(:,idx),p(:,idx),repmat({color},1,2) );
        hold on
    end
end

axis([-2 2 -2 2])

% %% call help function
% if isempty(sArgs.axes_handle)
%     axh = get(fgh,'CurrentAxes');
% else
%     axh = sArgs.axes_handle;
% end
% lnh = findobj(axh,'Type','line');
% sArgs.abscissa = real(z);
% sArgs.plotData = imag(z);
% 
% sArgs.xAxisType  = 'linear'; %Types: linear
% sArgs.yAxisType  = 'linear'; %Types: linear
% sArgs.plotType   = 'pzplane'; %Types: time, mag, phase, gdelay
% sArgs.xUnit      = '';
% sArgs.yUnit      = '';
% sArgs.titleStr   = '';
% sArgs.xLabel     = 'Real';
% sArgs.yLabel     = 'Imag';
% sArgs.figureName = 'PZ Plane';
% % sArgs.data       = data; %used for domain entries in gui
% % sArgs.ita_domain = 'frequency';
% % setappdata(fgh,'ita_domain', 'frequency');
% data = itaAudio; % empty itaAudio
% [fgh,axh] = ita_plottools_figurepreparations(data,fgh,axh,lnh,'options',sArgs);

%end function
end