function varargout = ita_plottools_colortable(varargin)
%ITA_PLOTTOOLS_COLORTABLE - Change Color Table
% Creates a Colororder that is not repeating every 8 colors
%
%  ita_plottools_colortable(0) - Creates the new DEFAULT
%  colortable for 29 different colors (i.e. Channels) The colors are not
%  the same as in MonkeyForest. The created colortable is written into the
%  ITA preferences and will be automatically used by all ITA plotting
%  functions
%
%  Call: ita_plottools_colortable('test')   demo of the colors
%  Call: ita_plottools_colortable('demo')   demo of the colors
%  Call: color_out = ita_plottools_colortable(N) gives the Nth color
%  Call: colorTableMatrix = ita_plottools_colortable('ita') Sets a colororder defined in this file
%  Call: colorTableMatrix = ita_plottools_colortable('winter(N)') If you have only N channels %
%  Call: ita_plottools_colortable('custom') to retain previous settings
%        best done by calling: ita_preferences('colortablename','custom');
%        before the toolbox plot functions
%   Then you can set it as default with set(0,'DefaultAxesColorOrder',colorTableMatrix)
%
%   See also ita_toolbox_setup.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_colortable">doc ita_plottools_colortable</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Sebastian Fingerhuth + Matthias Lievens -- Email: sfi@akustik.rwth-aachen.de
% Created:  05-Sep-2008

%% Initialization
narginchk(0,1);
if nargin == 0
    varargin{1} = 0;
end

%% Get current ITA preferences
PlotSettings_colorTable = ita_preferences('colorTableName');

%% Defining all the colors
colorTable(2,:) = [1     0     0];
colorTable(3,:) = [0.4000    0.4000    0.4000];
colorTable(1,:) = [0     0     1];
colorTable(4,:) = [1     0     1];
colorTable(5,:) = [1.0000    0.4000         0];
colorTable(6,:) = [0.2205    0.8775    0.7276];
colorTable(7,:) = [ .2 .2 .2];
colorTable(8,:) = [0.1686    0.5059    0.3373];
colorTable(9,:) = [0.3059    0.3961    0.5804];
colorTable(10,:) = [0.7490         0    0.7490];
colorTable(11,:) = [0.8000    0.8000    0.8000];
colorTable(12,:) = [0.7000    0.3000    0.2000];
colorTable(13,:) = [0.3000    0.2000    0.8000];
colorTable(14,:) = [0.8549    0.7020    1.0000];
colorTable(15,:) = [0.8000         0    0.5000];
colorTable(16,:) = [1.0000    0.5000    0.4000];
colorTable(17,:) = [0.3000    0.4000    1.0000];
colorTable(18,:) = [0.6000    1.0000    0.5000];
colorTable(19,:) = [1.0000    0.8000         0];
colorTable(20,:) = [0.6000    0.6000    0.6000];
colorTable(21,:) = [0.4784    0.0627    0.8941];
colorTable(22,:) = [     0    0.4000    0.4000];
colorTable(23,:) = [     0    0.7490    0.7490];
colorTable(24,:) = [0.7000    0.3000    0.4000];
colorTable(25,:) = [0.9852    0.6369    0.2331];
colorTable(26,:) = [0.1686    0.5059    0.3373];
colorTable(27,:) = [0.6499    0.9464    0.4637];
colorTable(28,:) = [0.5033    0.7629    0.9443];
colorTable(29,:) = [0.1340    0.3020    0.4603];
colorTable(30,:) = [0.5 0.5 0.5];
colorTableName = '';
result         = [];

%% Check if you want to make demo, or want some color
if nargin == 1
    if ~isnumeric(varargin{1})
        if or(strcmpi(varargin{1},'demo') ,strcmp(varargin{1},'test'))
            hfig = figure; %#ok<NASGU> % problems in using ita plot function, since preferences are not ready at this point
            axes
            for i=1:size(colorTable,1)
                line([i i],[0 10],'color',colorTable(i,:),'linewidth',2);
            end
            axis([0.5 size(colorTable,1) 0 10])
            ita_verbose_info('ITA_PLOTTOOLS_COLORTABLE:Keeping Color Order. Just showing',2);
        elseif strcmpi(varargin{1},'ita')
            colorTableName = 'ita';
            ita_verbose_info('ITA_PLOTTOOLS_COLORTABLE:Setting ITA Color Order.',2);
            result = colorTable;
        elseif strcmpi(varargin{1},'4paper')
            colorTableName = '4paper';
            set(0,'DefaultAxesLineStyleOrder','-|-.|--|:')
            ita_verbose_info('ITA_PLOTTOOLS_COLORTABLE:Setting ITA Color Order.',2);
            result = [0 0 0];
        elseif strcmpi(varargin{1},'custom')
            colorTableName = 'custom';
%             set(0,'DefaultAxesLineStyleOrder','-|-.|--|:')
            ita_verbose_info('ITA_PLOTTOOLS_COLORTABLE:Setting Custom Color Order.',2);
            result = get(0,'defaultAxesColorOrder');
        else
            colorTableName = varargin{1};
            hfig = figure;
            colorTable     = colormap(varargin{1});
            result = colorTable;            
            close(hfig)
            ita_verbose_info('ITA_PLOTTOOLS_COLORTABLE:Setting a standard Matlab Color Order.',2);
        end
        
    else % numeric varargin{1}
        if varargin{1}==0
            set(0,'DefaultAxesColorOrder',PlotSettings_colorTable)
            ita_verbose_info('ITA_PLOTTOOLS_COLORTABLE:Default Color Order has been set.',2);
            result = colorTable;
        else
            result = colorTable(varargin{1},:);
            ita_verbose_info('ITA_PLOTTOOLS_COLORTABLE:From the standard Matlab Colortables',1);
        end
    end
else %% nargin == 0
    result = ita_plottools_colortable('demo');
end

%% Save to preferences - pdi
ita_preferences('colortablename', colorTableName);
% ita_preferences('colortable', colorTable);
% ita_verbose_info('ITA_PLOTTOOLS_COLORTABLE:Preferences Set.',1);

%% Set it as default
if ~strcmp(colorTableName,'custom')
    set(0,'DefaultAxesColorOrder',colorTable)
end

%% Find output parameters
varargout(1) = {result};
%end function
end