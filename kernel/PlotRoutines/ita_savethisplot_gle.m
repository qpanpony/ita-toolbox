function ita_savethisplot_gle(varargin)
%ITA_SAVETHISPLOT_GLE - saves plot as gle script and pdf
%  This function creates a gle-script file which can be used with the gle
%  package to be converted into a nice pdf
%
%  This function was inspired by fig2gle by Javier Kypuros.
%
%  Syntax:
%   ita_savethisplot_gle(options)
%
%   Options (default):
%           'fgh' (gcf)                 : figure handle
%           'fileName' (saved_plotDATE) : filename for output files
%           'output' ('pdf')            : resulting filetype(s) (for multi output use e.g. 'pdf png eps')
%           'tex' (0)                   : create inc file for tex
%           'texincprefix' (pics/)      : folder-prefix for tex option
%           'cleanup' (0)               : delete temporary files
%           'font_scale' (1)            : to scale font by (e.g. 1.5 for large fonts)
%           'legend_position'           : where to put the legend
%                   ('tl offset 0.1 0.1')   (can include offset)
%           'palette' ('palette_axes')   : color palette used (only for
%                                           images jet), 'palette_axes' uses the colormap of the current axes
%                                           use 'grey' for b&w
%                                           or 'palette_artemis' for artemis style plots
%           'blackandwhite' (false)     : convert to bw printable graphic
%           'graph_size' ([])           : size of graph. Also accepts e.g. 0.6*linewidth
%                                         (use this only to override template size)
%           'font_size'  ([])           : size of fonts used. Accept units,
%                                         as in latex. (use this only to override template size)
%           'templateFolder' ('')       : where the templates are, default is in the
%                                         folder where this function is
%           'template' ('line_present') : which template, can be either of
%                                         -> line_present (presentations)
%                                         -> line_1column (single column A4)
%                                         -> line_2column (double column A4)
%                                         -> or define your own
%           'encoding' ('UTF-8')        : Encoding for GLE File
%           'comment' ('')              : Some comment to be written in the
%                                           gle file (not in the image)
%           'ratio' (1.5)               : aspect ratio of plot
%           'fill' (0)               : fill beneath the plots
%
%  Example:
%   ita_savethisplot_gle('fileName','test')
%   ita_savethisplot_gle('output','png') % make a png file
%   % set legend position bottom left and move 1cm to the right
%   ita_savethisplot_gle('legend_position','bl offset 1.0 0.0')
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_savethisplot_gle">doc ita_savethisplot_gle</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  19-Apr-2010

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
if nargin == 1
    ita_verbose_info('ita_savethisplot_gle:assuming input as filename...')
    varargin = [{'fileName'} varargin];
    
end
sArgs = struct('fgh',gcf,'fileName', ['saved_plot' datestr(now,'yyyy-mmm-dd_HH-MM-SS')],...
    'output','pdf','tex',0,'texincprefix',['pics' filesep],'dpi',250,'cleanup',false,'font_scale',1,...
    'legend_position','tl offset 0.1 0.1','graph_size',[],'font_size',[],'keep_cursors',false,'palette','palette_axes',...
    'blackandwhite',false,'templateFolder','','template','line_present_2012','encoding','UTF-8','comment','',...
    'stem',false,'ratio',1.5,'fill',0);
sArgs = ita_parse_arguments(sArgs,varargin);

if ~isempty(sArgs.font_size)
    sArgs.tex = 1;
end

%% preparations
% remove cursors, unless the user wants them
if ~sArgs.keep_cursors
    try
        ita_plottools_cursors('off');
    catch theError
        ita_verbose_info([thisFuncStr 'could not switch off the cursors because: ' theError.message],0);
    end
end

% folder is the same as fileName
comeFrom = pwd;
folder = fileparts(sArgs.fileName);
if isempty(folder)
    folder = [comeFrom filesep sArgs.fileName];
    parentFolder = comeFrom;
else
    parentFolder = [folder filesep '..'];
end

if ~exist(folder,'dir')
    if ~mkdir(folder)
        error([thisFuncStr 'could not create folder']);
    end
end
cd(folder);

if sArgs.blackandwhite
    sArgs.palette = 'grey';
end

try
    % plot handles
    figure(sArgs.fgh);
    % Legend handles
    Lold = findobj(sArgs.fgh,'Type','axes','Tag','legend'); % before R2014b
    Lnew = findobj(sArgs.fgh,'Type','Legend'); % from R2014b
    
    if isempty(Lold) && isempty(Lnew)
        L = [];
    else
        if ~isempty(Lold)
            L = sort(Lold);
        elseif ~isempty(Lnew)
            L = sort(Lnew);
        end
    end

    % Axes handles
    axesHandles = findobj(sArgs.fgh,'Type','axes','Tag','');
    
    %% find image axes (that's a toolbox logo, we assume)
    % kick those out, we can't handle them
    % also look for contourplots
    removeIndex = [];
    contourMode = false;
    for i = 1:numel(axesHandles)
        chdr = get(axesHandles(i),'Children');
        if ~isempty(findobj(chdr,'Type','image')) && ~isempty(findobj(chdr,'UserData','ITA-Toolbox-Logo'))
            removeIndex = [removeIndex i]; 
        end
        if ~isempty(findobj(chdr,'Type','hggroup')) || ~isempty(findobj(chdr,'Type','surface'))
            contourMode = true;
        end
    end
    axesHandles(removeIndex) = [];
    Ngraphs     = length(axesHandles);
    axesHandles = sort(axesHandles);
    
    %% Request Subplot Layout From User
    if Ngraphs > 2
        fprintf(['NOTE %d subplots have been detected!! Please ' ...
            'tell me how they are arranged in rows and ' ...
            'columns...\n'],Ngraphs);
        rows = input('How many rows of subplots are there? ','s');
        cols = input('How many columns of subplots are there? ','s');
        rows = str2double(rows); cols = str2double(cols);
    elseif Ngraphs == 2
        rows = 2; cols = 1;
    else
        rows = 1; cols = 1;
    end
    
    %% legend
    % Generate a matrix to determine subplot order
    % Note that the subplots are numbered from left to right and
    % top to bottom.  However, the position, which is being used
    % below to determine the placement of the legend is measured
    % from the bottom left corner, hence the reason the rows are
    % reversed to generate the matrix A.
    GraphCount = 1;
    for p = rows:-1:1
        for q = 1:cols
            A(p,q) = GraphCount;
            GraphCount = GraphCount+1;
        end
    end
    
    % Initialize cell array for legend keys
    PlotLegends = cell(numel(axesHandles),1);
    for jj = 1:length(L)
        LgndPos = get(L(jj),'Position');
        LgndRow = max(ceil(LgndPos(2)*rows),1);
        LgndCol = max(ceil(LgndPos(1)*cols),1);
        %[ii LgndPos(1:2) LgndRow LgndCol]
        PlotLegends{A(LgndRow,LgndCol)} = get(L(jj),'String');
    end
    
    %% Initialize GLE File
    GLE_File = [sArgs.fileName '.gle'];
    fid = fopen(GLE_File,'wt','n',sArgs.encoding);
    if fid == -1
        error([thisFuncStr 'could not open file']);
    end
    
    fprintf(fid,'!GLE file to plot MATLAB figure in %s.gle\n',sArgs.fileName);
    fprintf(fid,'!Created on %s\n\n',date);
    fprintf(fid,'!%s\n\n',sArgs.comment);
    
    % look for templates
    if isempty(sArgs.templateFolder)
        templateFolder = [fileparts(which(mfilename)) filesep 'gle_templates' filesep];
    else
        templateFolder = sArgs.templateFolder;
    end
    
    % copy the template file for easier access
    % but also write the standard location as a comment
    fprintf(fid,['ratio = ' num2str(sArgs.ratio) ' \n']);
    fprintf(fid,'!include "%s"\n',[templateFolder 'gle_template_' sArgs.template '.txt']);
    if ~copyfile([templateFolder 'gle_template_' sArgs.template '.txt'],parentFolder)
        ita_verbose_info(['Tried to copy the template file from ' templateFolder ' to ' parentFolder ', but did not succeed. Using default template location'],0);
        templateStr = [templateFolder 'gle_template_' sArgs.template '.txt'];
    else
        templateStr = ['..' filesep 'gle_template_' sArgs.template '.txt'];
    end
    fprintf(fid,'include "%s"\n\n',templateStr);
    
    if ~isempty(sArgs.graph_size)
        linewidth = 14.7; %#ok<NASGU> %Latex default linewidth
        if all(isnumeric(sArgs.graph_size))
            graph_size = sArgs.graph_size;
        elseif ischar(sArgs.graph_size)
            graph_size = eval(lower(sArgs.graph_size));
        elseif iscellstr(sArgs.graph_size)
            if numel(sArgs.graph_size) == 1
                graph_size = eval(lower(sArgs.graph_size{1}));
            elseif numel(sArgs.graph_size) == 2
                graph_size(1) = eval(lower(sArgs.graph_size{1}));
                graph_size(2) = eval(lower(sArgs.graph_size{2}));
            end
        end
        if numel(graph_size) == 1
            graph_size(2) = graph_size(1) * 20.984/29.6774; % A4 size
        end
        if contourMode
            graph_size = repmat(max(graph_size),[1,2]);
        end
        fprintf(fid,'graphWidth = %4.2f\n',graph_size(1));
        fprintf(fid,'graphHeight = %4.2f\n',graph_size(2));
    end
    % from here on, the variables graphWidth and graphHeight are set, either from the
    % template file or overridden by user in the previous block
    fprintf(fid,'size graphWidth graphHeight\n');
    
    % some latex packages
    fprintf(fid,'begin texpreamble\n');
    fprintf(fid,'\t\\usepackage[utf8]{inputenc}\n');
    fprintf(fid,'\t\\usepackage{graphicx,amsmath,amssymb,units}\n');
    fprintf(fid,'end texpreamble\n');
    fprintf(fid,'set texlabels 1\n');
    % scale is needed to have the possibility to change the font size
    fprintf(fid,'set texscale scale\n');
    % the standard tex font
    fprintf(fid,'set font texcmr\n');
    % how to connect lines in line plots
    fprintf(fid,'set join bevel\n\n');
    
    %% some plot stuff
    if prod([cols,rows]) > 1
        % Determine Subplot Increments
        DeltaX = ['graphWidth/' num2str(cols)];
        DeltaY = ['graphHeight/' num2str(rows)];
        XPos   = '0';
        YPos   = ['graphHeight-' DeltaY];
    else
        DeltaX = 'graphWidth';
        DeltaY = 'graphHeight';
    end
    
    %% Generate Subplots
    chdr = get(axesHandles,'Children');
    RowIndex = 1;
    ColIndex = 1;
    files = {};
    nContour = 0;
    for iGraph = 1:Ngraphs
        if ~iscell(chdr)
            chdr = {chdr};
        end
        % initialize subplot graph
        if prod([cols,rows]) > 1
            fprintf(fid,'amove %s %s\n',XPos,YPos);
        end
        % differentiate between plot types
        % standard line plot
        plotType = get(chdr{iGraph},'Type');
        if any(strcmpi(plotType,'line') | strcmpi(plotType,'scatter')) && ~(any(strcmpi(plotType,'bar')) || any(strcmpi(plotType,'patch'))) % workaround for bar plots
            files = [files gle_makeplot(fid,axesHandles(iGraph),chdr{iGraph}(strcmpi(plotType,'line') | strcmpi(plotType,'scatter')),PlotLegends{iGraph},DeltaX,DeltaY,iGraph,sArgs,plotType)];
            
            % bar graphs (toolbox bar plots use patches)
        elseif any(strcmpi(plotType,'bar')) || any(strcmpi(plotType,'patch')) || any(strcmpi(plotType,'histogram')) || (any(strcmpi(plotType,'hggroup')) && any(isprop(chdr{iGraph},'BarLayout'))) % rsc - bar plot are hggroup but have a BarLayout Property
            chdrIdx = logical(strcmpi(plotType,'bar') + strcmpi(plotType,'patch')+ strcmpi(plotType,'hggroup'));
            files = [files gle_makeplot(fid,axesHandles(iGraph),chdr{iGraph}(chdrIdx),PlotLegends{iGraph},DeltaX,DeltaY,iGraph,sArgs,'bar')]; 
            
            % Errorbar
        elseif (any(strcmpi(plotType,'hggroup')) && any(isprop(chdr{iGraph},'LData'))) || any(strcmpi(plotType,'errorbar')) % rsc - errorbar plots are hggroup but have a LData Property
            % ToDo - RSC
            chdrIdx = logical(strcmpi(plotType,'errorbar') + strcmpi(plotType,'bar') + strcmpi(plotType,'patch')+ strcmpi(plotType,'hggroup'));
            files = [files gle_makeplot(fid,axesHandles(iGraph),chdr{iGraph}(chdrIdx),PlotLegends{iGraph},DeltaX,DeltaY,iGraph,sArgs,'errorbar')]; 
            
            % 2D contour plot
        elseif any(strcmpi(plotType,'hggroup')) || any(strcmpi(plotType,'surface')) || any(strcmpi(plotType,'contour'))
            chdrIdx = logical(strcmpi(plotType,'hggroup') + strcmpi(plotType,'surface') + strcmpi(plotType,'contour'));
            files = [files gle_contourplot(fid,axesHandles(iGraph),chdr{iGraph}(chdrIdx),DeltaX,DeltaY,iGraph,plotType,sArgs)];
            % subfunction to create jet colormap, but just once
            if nContour == 0
                if strcmpi(sArgs.palette,'palette_axes')
                    make_colormap(fid,axesHandles(iGraph));
                else
                    make_jet_colormap(fid);
                end
            end
            nContour = nContour + 1;
            
            % image plot
        elseif any(strcmpi(plotType,'image'))
            files = [files gle_imageplot(fid,axesHandles(iGraph),chdr{iGraph}(strcmpi(plotType,'image')),DeltaX,DeltaY,iGraph,sArgs)]; 
            % subfunction to create jet colormap, but just once
            if nContour == 0
                if strcmpi(sArgs.palette,'palette_axes')
                    make_colormap(fid,axesHandles(iGraph));
                else
                    make_jet_colormap(fid);
                end
            end
            nContour = nContour + 1;
            % 3D surface plot
            %         elseif (strcmpi(plotType,'surface'))
            % so far only in 2D see above
        else
            error([thisFuncStr 'unknown plot type']);
        end
        
        if prod([cols,rows]) > 1
            % index to next subplot
            if (ColIndex < cols)
                ColIndex = ColIndex+1;
                XPos = [XPos '+' DeltaX]; 
            else
                RowIndex = RowIndex+1;
                ColIndex = 1;
                XPos = '0';
                YPos = [YPos '-' DeltaY]; 
            end
        end
    end
    fclose(fid);
    
    %% Generate PDF
    if ~isempty(sArgs.output)
        gle_options = ['-dpi ' num2str(sArgs.dpi)];
        if sArgs.tex
            gle_options = [gle_options ' -texincprefix ' sArgs.texincprefix ' -inc '];
        end
        sArgs.output = strrep(sArgs.output, ' ', ' -d '); % allows multiple output formats at once
        if isunix
            systemcall = sprintf(['gle ' gle_options ' -d ' sArgs.output ' %s'],GLE_File);
            %             systemcall = sprintf(['x=${0##*/} \n x=$(echo $x|sed ''s/.command/.gle/g'') \ngle ' gle_options ' -d ' sArgs.output ' $x']);
            Batch_File = [sArgs.fileName '.sh'];
        else
            GLE_File = ['"' GLE_File '"'];
            systemcall = ['"gle.exe" ' gle_options ' -d ' sArgs.output ' ' GLE_File];
            Batch_File = [sArgs.fileName '.bat'];
        end
        
        [status, output] = system(systemcall);
        
        if ~isempty(sArgs.font_size)
            correct_font_size(sArgs);
        end
        
        if ispc
            systemcall_win = regexprep(systemcall,'\\','\\\\');
            fid = fopen(Batch_File,'wt');
            fprintf(fid,systemcall_win);
            fclose(fid);
        else
            fid = fopen(Batch_File,'wt');
            fprintf(fid,systemcall);
            fclose(fid);
        end
        
        
        if ismac %pdi: generate a nice command file for double click later on
            
            fid = fopen([sArgs.fileName '.command'],'wt');
            fprintf(fid,['cd "`dirname "$0"`"\n' systemcall]);
            fclose(fid);
            system(['chmod +x ' sArgs.fileName '.command']);
        end
        
        if status == 0
            ita_verbose_info(sprintf([thisFuncStr 'PDF GENERATED!! \nYour output file was saved to ' ...
                '%s.\n'],[GLE_File(1:end-3) sArgs.output]),1);
            % delete .dat and .csv files
            if sArgs.cleanup
                for i = 1:numel(files)
                    delete(files{i});
                end
            end
        else
            ita_verbose_info(sprintf([thisFuncStr 'Failed to generate output file. \nThe GLE output ' ...
                'follows.\n']));
            fprintf(output);
        end
    end
    cd(comeFrom);
catch theError
    cd(comeFrom);
    ita_verbose_info([thisFuncStr 'an error occurred (line ' num2str(theError.stack(1).line) ') during the export process, the problem is: '],0);
    rethrow(theError);
end

if ita_preferences('plotcursors')
    try
        ita_plottools_cursors('on');
    catch errmsg
        ita_verbose_info('Could not turn cursors on, reason is',0);
        disp(errmsg.message);
    end
end

%end function
end

%% subfunctions
% meta info for line and bar and errorbar plots
function files = gle_makeplot(fid,axh,chdr,plotLegend,DeltaX,DeltaY,n,sArgs,plot_type)

Nplots = length(chdr);
% somehow matlab flips the data order for multiple plots
if Nplots > 1
    chdr = flipud(chdr);
    plot_type = flipud(plot_type);
end
% gather subplot-specific data
x_data = get(chdr,'XData');
y_data = get(chdr,'YData');

if ~iscell(x_data)
    x_data = {x_data(:).'};
end

if ~iscell(y_data)
    y_data = {y_data(:).'};
end

if ~iscell(plot_type)
    plot_type = {plot_type};
end

if numel(plot_type) == 1 && Nplots > 1
    plot_type = repmat(plot_type,[Nplots 1]);
end

errup = cell(Nplots,1);
errdown = cell(Nplots,1);
for i = 1:Nplots
    if strcmpi(plot_type{i},'bar')
        if size(x_data{i},1) > 1
            x_data{i} = x_data{i}(2,:);
        end
        if size(y_data{i},1) > 1
            y_data{i} = y_data{i}(2,:);
        end
    end
    
    if strcmpi(plot_type{i},'errorbar')
        errup{i} = get(chdr(i),'UData');
        errdown{i} = get(chdr(i),'LData');
%         if ~iscell(errup)
%             errup = {errup};
%         end
%         if ~iscell(errdown)
%             errdown = {errdown};
%         end
    end
end

x_scale = get(axh,'XScale');
y_scale = get(axh,'YScale');
x_grid = get(axh,'XGrid');
y_grid = get(axh,'YGrid');
plot_title =  get(get(axh,'Title'),'String');
x_label = get(get(axh,'XLabel'),'String');
y_label = get(get(axh,'YLabel'),'String');
x_lim = get(axh,'XLim');
y_lim = get(axh,'YLim');
x_tick = get(axh,'XTick');
x_ticklabel = get(axh,'XTickLabel');
y_tick = get(axh,'YTick');
y_ticklabel = get(axh,'YTickLabel');

if ~iscell(x_ticklabel)
    x_ticklabel = cellstr(x_ticklabel);
end

if ~iscell(y_ticklabel)
    y_ticklabel = cellstr(y_ticklabel);
end

% for ITA ticks and ticklabels
use_ids_x = [];
for i = 1:size(x_ticklabel)
    if ~isempty(char(x_ticklabel(i)))
        use_ids_x = [use_ids_x, i]; 
    end
end

x_tick = x_tick(use_ids_x);
x_ticklabel = x_ticklabel(use_ids_x);

use_ids_y = [];
for i = 1:size(y_ticklabel)
    if ~isempty(char(y_ticklabel(i)))
        use_ids_y = [use_ids_y, i]; 
    end
end

y_tick = y_tick(use_ids_y);
y_ticklabel = y_ticklabel(use_ids_y);

x_ticklabel = x_ticklabel(x_tick>=x_lim(1));
x_tick = x_tick(x_tick>=x_lim(1));
x_ticklabel = x_ticklabel(x_tick<=x_lim(2));
x_tick = x_tick(x_tick<=x_lim(2));

y_ticklabel = y_ticklabel(y_tick>=y_lim(1));
y_tick = y_tick(y_tick>=y_lim(1));
y_ticklabel = y_ticklabel(y_tick<=y_lim(2));
y_tick = y_tick(y_tick<=y_lim(2));

%% gather legend strings
if isempty(plotLegend)
    keys = '';
else
    keys = plotLegend;
end

scaling_factor = sArgs.font_scale;

%% write some axis and label settings
% these settings will now come from the template as variables
fprintf(fid,'set alabeldist axisLabelDist\n');
fprintf(fid,'set atitledist axisTitleDist\n');
fprintf(fid,'set alabelscale axisLabelScale*%5.3f\n',scaling_factor);
fprintf(fid,'set atitlescale axisTitleScale*%5.3f\n',scaling_factor);
fprintf(fid,'set titlescale titleScale*%5.3f\n\n',scaling_factor);

plotName = ['plot' num2str(n,'%.2d')];
fprintf(fid,'begin name %s\n',plotName);
fprintf(fid,'begin graph\n');
fprintf(fid,'\tsize %s %s\n',DeltaX,DeltaY);
% how to scale the axes
fprintf(fid,'\thscale auto\n');
fprintf(fid,'\tvscale auto\n');

%% write CSV data files
precision_string = '%2.5e';
files = cell(1,Nplots);
for i = 1:Nplots
    % Map log to lin for bar plots
    if strcmp(x_scale,'log') && strcmpi(plot_type{i},'bar') %Log scale does not work for bar plots in gle
        x_scale = 'lin';
        x_tick = log2(x_tick);
        x_lim = log2(x_lim);
        x_data = cellfun(@log2,x_data,'UniformOutput',false);
        N = size(x_data{1},2);
        bar_width = (max(x_lim)-min(x_lim))./ (N+1) ./ (Nplots+1);
        % have to correct the positions
        % MATLAB uses xpositions for each bar, GLE only one position for all
        if Nplots == 1
            x_data = cellfun(@plus,x_data,{bar_width},'UniformOutput',false);
        else
            if rem(Nplots,2) % odd
                x_data = cellfun(@plus,repmat(x_data(floor(Nplots/2)+1),[Nplots,1]),repmat({bar_width/2},[Nplots,1]),'UniformOutput',false);
            else % eve
                x_data = {(x_data{Nplots/2} + x_data{Nplots/2+1})./2};
                x_data = cellfun(@plus,repmat(x_data,[Nplots,1]),repmat({bar_width/2},[Nplots,1]),'UniformOutput',false);
            end
        end
    else
        N = size(x_data{1},2);
        bar_width = (max(x_lim)-min(x_lim))./ (N+1) ./ (Nplots+1);
    end
    
    CSV_FileName = ['subplot' num2str(n) 'p' num2str(i) '.csv'];
    DatFileName = CSV_FileName;
    files(i) = {DatFileName};
    if strcmpi(plot_type,'errorbar')
        M = [x_data{i}(:) y_data{i}(:) errdown{i}(:) errup{i}(:)];
    else
        M = [x_data{i}(:) y_data{i}(:)];
    end
    try
        ita_dlmwrite(DatFileName,M,'precision',precision_string);
    catch theException
        ita_verbose_info([mfilename ' ita_dlmwrite failed, using builtin routine!'],0);
        disp(theException.message);
        dlmwrite(DatFileName,M,'precision',precision_string);
    end
    
    fprintf(fid,'\tdata "%s"\n',CSV_FileName);
end

% place title and axis labels
if ~isempty(plot_title)
    if iscell(plot_title)
        plot_title = cell2mat(plot_title);
    end
    fprintf(fid,'\ttitle "%s" dist titleDist\n',test_for_tex(plot_title));
end
if ~isempty(x_label)
    if iscell(x_label)
        newXLabel = test_for_tex(x_label{1});
    else
        newXLabel = test_for_tex(x_label);
    end
    fprintf(fid,'\txtitle "%s" dist axisTitleDist\n',newXLabel);
end
if ~isempty(y_label)
    if iscell(y_label)
        newYLabel = test_for_tex(y_label{1});
    else
        newYLabel = test_for_tex(y_label);
    end
    fprintf(fid,'\tytitle "%s" dist axisTitleDist\n',newYLabel);
end

%% specify x-axis limits, scale, and grid
gle_xaxis = sprintf('\txaxis min %d max %d\n',x_lim);
if strcmp(x_scale,'log')
    gle_xaxis = sprintf(strcat(gle_xaxis(1:length(gle_xaxis)-1),' log\n'));
end
if strcmp(x_grid,'on')
    fprintf(fid,'\txticks lstyle 4 lwidth 0.001\n');
    fprintf(fid,'\txsubticks lstyle 4 lwidth 0.001\n');
    gle_xaxis = sprintf(strcat(gle_xaxis(1:length(gle_xaxis)-1),' grid\n'));
end
fprintf(fid,gle_xaxis);
fprintf(fid,'\txside lwidth axisWidth\n');
fprintf(fid,'\tx2axis off\n');

x_tickStr      = mat2str(x_tick(:).');
x_ticklabelStr = [];
for i = 1:numel(x_ticklabel)
    x_ticklabelStr = [x_ticklabelStr ' "' x_ticklabel{i} '"']; 
end
fprintf(fid,'\txplaces %s\n',x_tickStr(2:end-1));
fprintf(fid,'\txnames%s\n',x_ticklabelStr);
fprintf(fid,'\txlabels dist axisLabelDist\n');

%% specify y-axis limits, scale, and grid
gle_yaxis = sprintf('\tyaxis min %d max %d\n',y_lim);
if strcmp(y_scale,'log')
    gle_yaxis = sprintf(strcat(gle_yaxis(1:length(gle_yaxis)-1),' log\n'));
end
if strcmp(y_grid,'on')
    fprintf(fid,'\tyticks lstyle 4 lwidth 0.001\n');
    fprintf(fid,'\tysubticks lstyle 4 lwidth 0.001\n');
    gle_yaxis = sprintf(strcat(gle_yaxis(1:length(gle_yaxis)-1),' grid\n'));
end
fprintf(fid,gle_yaxis);
fprintf(fid,'\tyside lwidth axisWidth\n');
fprintf(fid,'\ty2axis off\n');

y_tickStr      = mat2str(y_tick(:).');
y_ticklabelStr = [];
for i = 1:numel(y_ticklabel)
    y_ticklabelStr = [y_ticklabelStr ' "' y_ticklabel{i} '"']; 
end
fprintf(fid,'\typlaces %s\n',y_tickStr(2:end-1));
fprintf(fid,'\tynames%s\n',y_ticklabelStr);
fprintf(fid,'\tylabels dist axisLabelDist\n');

%% here come the actual plots
marker     = cell(numel(chdr),1);
line_width = cell(numel(chdr),1);
line_color = cell(numel(chdr),1);
line_style = cell(numel(chdr),1);
for i = 1:Nplots
    if strcmpi(plot_type{i},'line') || strcmpi(plot_type{i},'errorbar')
        % gather line-specific data
        marker{i} = get(chdr(i),'marker');
        line_width{i} = get(chdr(i),'LineWidth');
        line_color{i} = get(chdr(i),'Color');
        line_style{i} = get(chdr(i),'LineStyle');
    elseif strcmpi(plot_type{i},'scatter')
        marker{i}     = get(chdr(i),'marker');
        line_width{i} = 0;
        line_color{i} = chdr(i).CData;
        line_style{i} = 'none';
    else
        line_color = get(chdr,'FaceColor');
        if ~iscell(line_color)
            line_color = {line_color};
        end
        colors = colormap;
        colors = colors(1:floor(size(colors,1)/Nplots):end,:);
        if strcmpi(line_color{i},'flat') % pdi: why is is flat ???
            line_color(i) = {colors(end-i+1,:)};
        end
        line_style{i} = '-';
        line_width{i} = '1';
    end
end

if ~iscell(line_style)
    line_style = {line_style};
end
if ~iscell(line_color)
    line_color = {line_color};
end
if ~iscell(line_width)
    line_width = {line_width};
end
if ~iscell(marker)
    marker = {marker};
end

%% line or bar plot
for i = 1:Nplots
    % line
    if strcmpi(plot_type{i},'line')
        % generate plot command(s) (i.e. generate the d# commands)
        lineCommand = 'line';
        if sArgs.stem
            lineCommand = [lineCommand ' impulses'];
        end
        
        if sArgs.blackandwhite
            fprintf(fid,gle_lineplot_cmd(i,[0 0 0],i, ...
                line_width{i},marker{i},lineCommand));
        else
            fprintf(fid,gle_lineplot_cmd(i,line_color{i},line_style{i}, ...
                line_width{i},marker{i},lineCommand));
        end
        if sArgs.fill
            fprintf(fid,gle_lineplot_fill(i,line_color{i}));
        end
    % scatter     
    elseif strcmpi(plot_type{i},'scatter')
        % generate plot command(s) (i.e. generate the d# commands)
        lineCommand = '';
        if sArgs.stem
            lineCommand = [lineCommand ' impulses'];
        end
        if sArgs.blackandwhite
            fprintf(fid,gle_lineplot_cmd(i,[0 0 0],i, ...
                0,marker{i},lineCommand));
        else
            fprintf(fid,gle_lineplot_cmd(i,line_color{i},line_style{i}, ...
                0,marker{i},lineCommand));
        end
        if sArgs.fill
            fprintf(fid,gle_lineplot_fill(i,line_color{i}));
        end
    %bar
    elseif strcmpi(plot_type{i},'bar')
        fprintf(fid,gle_barplot_cmd(Nplots,line_color, bar_width, x_scale));
        line_width(i) = {6*2*bar_width* Nplots};
    %errorbar
    elseif strcmpi(plot_type,'errorbar')
        % generate plot command(s) (i.e. generate the d# commands)
        if sArgs.blackandwhite
            fprintf(fid,gle_errorbar_cmd((i-1)*3+1,[0 0 0],i, ...
                line_width{i},marker{i}));
        else
            fprintf(fid,gle_errorbar_cmd((i-1)*3+1,line_color{i},line_style{i}, ...
                line_width{i},marker{i}));
        end
    end
end

% terminate current subplot
fprintf(fid,'end graph\n');
fprintf(fid,'end name\n\n');

% begin a new legend (key)
if ~isempty(keys)
    fprintf(fid,'begin key\n');
    fprintf(fid,'\thei keyHei*%5.3f\n',scaling_factor); %pdi:april2013 scale the legend/key fontsize
    fprintf(fid,'\tdist keyDist\n');
    fprintf(fid,'\tmargins keyMargins keyMargins\n');
    fprintf(fid,'\tboxcolor 1\n');
    fprintf(fid,'\tllen keyLineLength\n');
    fprintf(fid,'\tcoldist keyColDist\n');
    fprintf(fid,'\tcompact\n');
    % where the legend should be placed (t(op)l(eft),tr,bl,br etc.)
    fprintf(fid,'\tposition %s\n',sArgs.legend_position);
    
    for i = 1:min(numel(keys), numel(line_color)) % works for any number of legend entries
        % use several columns for large number of keys
        if Nplots > 4 && ismember(i,4:3:13)
            fprintf(fid,'\tseparator\n');
        end
        if sArgs.blackandwhite %nice black and white, with thick lines
            fwrite(fid,gle_key_cmd([0 0 0],i, ...
                max(line_width{i}*6,0.06),marker{i},test_for_tex(keys{i})),'char');
        else
            fwrite(fid,gle_key_cmd(line_color{i},line_style{i}, ...
                line_width{i},marker{i},test_for_tex(keys{i})),'char');
        end
    end
    
    % end the legend (key)
    fprintf(fid,'end key\n\n');
end

%% toolbox logo
if ita_preferences('toolboxlogo')
    factor = 10;
    logo_size = 2*factor*ita_preferences('logosize');
    logo_position = [0 0];
    fprintf(fid,'amove %d %d\n',logo_position(1),logo_position(2));
    fprintf(fid,'begin name toolbox_logo\n');
    fprintf(fid,'\tbitmap "%s" %d %d\n',which('ita_toolbox_logo_wbg.png'),logo_size,0.21*3/4*logo_size);
    fprintf(fid,'end name\n');
end

end

% function for line plots
function d_line = gle_lineplot_cmd(l,line_color,line_style,line_width,marker,lineCommand)
% This function is used to convert MATLAB parameters into a GLE
% plot command.  It returns a "d" command line for each plot.

% line color.
gle_line_color = sprintf('rgb255(%d,%d,%d)',round(line_color*255));
% line width relative to 2 in matlab
gle_line_width = line_width/2;
% then multiply with the lineWidth variable from the template
gle_line_width_str = ['lineWidth*' num2str(gle_line_width,'%1.2f')];
% line style.
if isnumeric(line_style) %pdi: directly set line style number
    gle_line_style = line_style;
else
    switch line_style
        case ':'
            gle_line_style = 2;
        case '-'
            gle_line_style = 1;
        case '-.'
            gle_line_style = 6;
        case '--'
            gle_line_style = 3;
        case 'none'
            gle_line_style = [];
        otherwise
            gle_line_style = 1;
    end
end
% marker.

switch marker
    case '+'
        gle_marker = 'plus';
    case '*'
        gle_marker = 'asterisk';
    case 'o'
        gle_marker = 'wcircle';
    case 'x'
        gle_marker = 'cross';
    case {'^','v'}
        gle_marker = 'wtriangle';
    case 's'
        gle_marker = 'wsquare';
    case 'd'
        gle_marker = 'wdiamond';
    case '.'
        gle_marker = 'dot';
    case 'none'
        gle_marker = '';
    otherwise
        gle_marker = marker;
end
% Generate "d#" line command
if isempty(gle_line_style) % marker with no line
    d_line = sprintf('\td%d marker %s msize markerSize color %s\n',l,gle_marker, ...
        gle_line_color);
elseif isempty(gle_marker) % line with no marker
    d_line = sprintf(['\td%d %s lstyle %d color %s lwidth ' ...
        '%s\n'],l,lineCommand,gle_line_style,gle_line_color, ...
        gle_line_width_str);
else % line with marker
    d_line = sprintf(['\td%d %s lstyle %d color %s lwidth ' ...
        '%s marker %s msize markerSize\n'],l,lineCommand,gle_line_style, ...
        gle_line_color,gle_line_width_str,gle_marker);
end
end


function d_line = gle_lineplot_fill(l,line_color)
    gle_fill_color = sprintf('rgba255(%d,%d,%d,80)',round(line_color*255));
    d_line = sprintf('\tfill x1,d%d color %s\n',l,gle_fill_color);

end


% function for bar plots
function bar_line = gle_barplot_cmd(N_plots,line_color,bar_width,x_scale)
% This function is used to convert MATLAB parameters into a GLE
% bar plot command.  It returns a "bar" command line for each plot.

bar_line = sprintf('\tbar ');
bar_color_fill_string = ' fill ';
% line color.
for l = 1:N_plots
    if l > 1
        bar_line = [bar_line sprintf(',d%d',l)]; 
        bar_color_fill_string = [bar_color_fill_string ',' sprintf('rgb255(%d,%d,%d)',round(line_color{l}*255))]; 
    else
        bar_line = [bar_line sprintf('d%d',l)]; 
        bar_color_fill_string = [bar_color_fill_string sprintf('rgb255(%d,%d,%d)',round(line_color{l}*255))]; 
    end
end

bar_color_color_string = ' color ';
% line color.
for l = 1:N_plots
    if l > 1
        bar_color_color_string = [bar_color_color_string ',' sprintf('rgb255(%d,%d,%d)',round(line_color{l}*255))]; %#ok<*AGROW>
        %         bar_color_color_string = [bar_color_color_string ',' sprintf('rgb255(%d,%d,%d)',round(line_color{l}*255))]; %#ok<AGROW>
    else
        bar_color_color_string = [bar_color_color_string sprintf('rgb255(%d,%d,%d)',round(line_color{l}*255))];
        %         bar_color_color_string = [bar_color_color_string sprintf('rgb255(%d,%d,%d)',round(line_color{l}*255))]; %#ok<AGROW>
    end
end
if strcmpi(x_scale,'log')
    bar_dist = bar_width;
else
    bar_dist = bar_width; %pdi: bug-fix for non-Toolbox bar plots!
end
bar_line = sprintf([bar_line ' width %6.4f dist %6.4f' bar_color_fill_string bar_color_color_string '\n'],bar_width,bar_dist);
end

% function for error plots
function d_line = gle_errorbar_cmd(l,line_color,line_style,line_width,marker)
% This function is used to convert MATLAB parameters into a GLE
% plot command.  It returns a "d" command line for each plot.

% line color.
gle_line_color = sprintf('rgb255(%d,%d,%d)',round(line_color*255));
% line width relative to 2 in matlab
gle_line_width = line_width/2;
% then multiply with the lineWidth variable from the template
gle_line_width_str = ['lineWidth*' num2str(gle_line_width,'%1.2f')];
% line style.
if isnumeric(line_style) %pdi: directly set line style number
    gle_line_style = line_style;
else
    switch line_style
        case ':'
            gle_line_style = 6;
        case '-'
            gle_line_style = 1;
        case '-.'
            gle_line_style = 8;
        case '--'
            gle_line_style = 3;
        case 'none'
            gle_line_style = [];
        otherwise
            gle_line_style = 1;
    end
end
% marker.
switch marker
    case '+'
        gle_marker = 'plus';
    case '*'
        gle_marker = 'asterisk';
    case 'o'
        gle_marker = 'wcircle';
    case 'x'
        gle_marker = 'cross';
    case {'^','v'}
        gle_marker = 'wtriangle';
    case 's'
        gle_marker = 'wsquare';
    case 'd'
        gle_marker = 'wdiamond';
    case '.'
        gle_marker = 'dot';
    case 'none'
        gle_marker = '';
    otherwise
        gle_marker = marker;
end

% Generate "d#" line command
if isempty(gle_line_style) % marker with no line
    d_line = sprintf('\td%d errup d%d errdown d%d marker %s msize markerSize lwidth %s errwidth %1.2f color %s\n',l,l+1,l+2,gle_marker, gle_line_width_str, gle_line_width/10, gle_line_color);
elseif isempty(gle_marker) % line with no marker
    d_line = sprintf('\td%d errup d%d errdown d%d line lstyle %d color %s lwidth %s errwidth %1.2f\n',l,l+1,l+2,gle_line_style,gle_line_color, gle_line_width_str, gle_line_width/10);
else % line with marker
    d_line = sprintf('\td%d errup d%d errdown d%d line lstyle %d color %s lwidth %s errwidth %1.2f marker %s msize markerSize\n',l,l+1,l+2,gle_line_style, gle_line_color,gle_line_width_str, gle_line_width/10,gle_marker);
end
end

% function for the legend (called key in GLE) for line and bar plots
function key_line = gle_key_cmd(line_color,line_style,line_width,marker,key)
%% gle_key_cmd
% This function is used to convert MATLAB parameters into a GLE
% key command.  It returns a "key" command line for each plot.

% line color.
gle_line_color = sprintf('rgb255(%d,%d,%d)',round(line_color*255));
% line width relative to 2 in matlab
gle_line_width = line_width/2;
% then multiply with the lineWidth variable from the template
gle_line_width_str = ['lineWidth*' num2str(gle_line_width,'%1.2f')];
% line style.
if isnumeric(line_style)
    gle_line_style = line_style;
else
    switch line_style
        case ':'
            gle_line_style = 2;
        case '-'
            gle_line_style = 1;
        case '-.'
            gle_line_style = 6;
        case '--'
            gle_line_style = 3;
        case 'none'
            gle_line_style = [];
        otherwise
            gle_line_style = 1;
    end
end
% marker
if ~isempty(marker)
    switch marker
        case '+'
            gle_marker = 'plus';
        case '*'
            gle_marker = 'asterisk';
        case 'o'
            gle_marker = 'wcircle';
        case 'x'
            gle_marker = 'cross';
        case {'^','v'}
            gle_marker = 'wtriangle';
        case 's'
            gle_marker = 'wsquare';
        case 'd'
            gle_marker = 'wdiamond';
        case '.'
            gle_marker = 'dot';
        case 'none'
            gle_marker = '';
        otherwise
            gle_marker = marker;
    end
else
    gle_marker = '';
end

% Add key if present
if ~isempty(key)
    if iscell(key)
        key = key{:};
    end
end

% Generate "text" line command
if isempty(gle_line_style) && isempty(gle_marker)
    key_line = sprintf('\ttext "%s" color %s\n',key, gle_line_color);
elseif isempty(gle_line_style) % marker with no line
    key_line = sprintf('\ttext "%s" marker %s msize markerSize lwidth %s color %s\n',key,gle_marker, gle_line_width_str, gle_line_color);
elseif isempty(gle_marker) % line with no marker
    key_line = sprintf('\ttext "%s" line lstyle %d color %s lwidth %s\n',key,...
        gle_line_style,gle_line_color, gle_line_width_str);
else % line with marker
    key_line = sprintf('\ttext "%s" line lstyle %d color %s lwidth %s marker %s msize markerSize\n',key,...
        gle_line_style, gle_line_color,gle_line_width_str,gle_marker);
end
end

% function for 2D contour plots
function files = gle_contourplot(fid,axh,chdr,DeltaX,DeltaY,n,plotType,sArgs)
%% gather subplot-specific data
if strcmpi(plotType,'hggroup') || strcmpi(plotType,'contour')
    z_data = get(chdr,'ZData');
    if isempty(z_data) % pdi: try bugfix for simple 2D plots with scatter
        z_data = get(chdr,'CData').';
    end
else
    z_data = get(chdr,'CData').';
end

z_data(isnan(z_data)) = 0;
z_data(isinf(z_data)) = sign(z_data(isinf(z_data))).*10000;
x_data = flipud(get(chdr,'XData'));
y_data = flipud(get(chdr,'YData'));
plot_title =  get(get(axh,'Title'),'String');
x_label = get(get(axh,'XLabel'),'String');
y_label = get(get(axh,'YLabel'),'String');
x_lim = get(axh,'XLim');
y_lim = get(axh,'YLim');
clim  = get(axh,'CLim');
x_tick = get(axh,'XTick');
x_ticklabel = cellstr(get(axh,'XTickLabel'));
y_tick = get(axh,'YTick');
y_ticklabel = cellstr(get(axh,'YTickLabel'));

if isprop(chdr,'LevelStep')
    levelStep = get(chdr,'LevelStep');
else
    levelStep = (max(clim)-min(clim))/100;
end

scaling_factor = sArgs.font_scale;

% try to downscale
% z_data = z_data([1 2:5:end],:);
% x_data = x_data([1 2:5:end]);

%% start to write axis and label settings
% need this for colormaps
fprintf(fid,'include "color.gle"\n');
% label, tick and title sizes
fprintf(fid,'set alabelscale axisLabelScale\n');
fprintf(fid,'set atitlescale axisTitleScale\n');
fprintf(fid,'set titlescale titleScale\n\n');

%% write data file
zdata_FileName = ['subplot' num2str(n) '.z'];
files = {zdata_FileName};
if strcmpi(get(axh,'XScale'),'log') % workaround for logarithmic xaxis in contour plots, pretty dirty but it works
    x_tick = log2(x_tick);
    x_lim  = log2(x_lim);
    x_data = log2(flipud(x_data));
    x_data(isinf(x_data)) = sign(x_data(isinf(x_data))).*10000;
    y_data = flipud(y_data);
    lim_a  = min(x_data(:));
    lim_b  = max(x_data(:));
    dx     = (lim_b - lim_a)/numel(x_data);
    
    [X,Y] = meshgrid(x_data,y_data);
    M = [reshape(X.',numel(x_data)*numel(y_data),1),reshape(Y.',numel(x_data)*numel(y_data),1),reshape(z_data,numel(x_data)*numel(y_data),1)];
    data_fileName = [zdata_FileName(1:end-1) 'dat'];
    ita_dlmwrite(data_fileName,M,' ');
    
    fprintf(fid,'begin fitz\n');
    fprintf(fid,'\tdata "%s"\n',data_fileName);
    fprintf(fid,'\tx from %d to %d step %d\n',lim_a,lim_b,dx);
    fprintf(fid,'\ty from %d to %d step %d\n',min(y_data(:)),max(y_data(:)),mean(diff(unique(y_data(:)))));
    fprintf(fid,'\tncontour %d\n',min(abs(round(diff(clim)/levelStep)),10));
    fprintf(fid,'end fitz\n');
else
    fid2 = fopen(zdata_FileName,'wt');
    fprintf(fid2,'! nx %d  ny %d    xmin %4.2f  xmax %4.2f  ymin %4.2f  ymax %4.2f\n',...
        size(z_data,1),size(z_data,2),x_lim(1),x_lim(2),y_lim(1),y_lim(2));
    fclose(fid2);
    ita_dlmwrite(zdata_FileName,z_data.','-append','precision','%10.5f');
end

% contour part
fprintf(fid,'begin contour\n');
fprintf(fid,'\tdata "%s"\n',zdata_FileName);
fprintf(fid,'\tvalues from %d to %d step %d\n',clim(1),clim(2),levelStep);
fprintf(fid,'end contour\n');

%% the actual plot
fprintf(fid,'begin graph\n');
fprintf(fid,'\tsize %s %s\n',DeltaX,DeltaY);
% fprintf(fid,'\tdata "%s"\n',[zdata_FileName(1:end-2) '-cdata.dat']);
% better for equal plots
fprintf(fid,'\thscale %4.2f\n', 1-0.3*scaling_factor);
fprintf(fid,'\tvscale %4.2f\n', 1-0.3*scaling_factor);

% place title and axis labels
if ~isempty(plot_title)
    fprintf(fid,'\ttitle "%s" dist titleDist\n',test_for_tex(plot_title));
end
if ~isempty(x_label)
    fprintf(fid,'\txtitle "%s" dist axisTitleDist\n',test_for_tex(x_label));
end
if ~isempty(y_label)
    fprintf(fid,'\tytitle "%s" dist axisTitleDist\n',test_for_tex(y_label));
end
% specify x-axis limits, scale, and grid
gle_xaxis = sprintf('\txaxis min %d max %d nticks 4\n',x_lim);
% if strcmp(x_scale,'log')
%     gle_xaxis = sprintf(strcat(gle_xaxis(1:length(gle_xaxis)-1),' log\n'));
% end
fprintf(fid,gle_xaxis);
fprintf(fid,'\txticks off\n');
fprintf(fid,'\txsubticks off\n');

% for ITA ticks and ticklabels
use_ids = [];
for i = 1:size(x_ticklabel)
    if ~isempty(char(x_ticklabel(i)))
        use_ids = [use_ids, i]; 
    end
end
x_tick = x_tick(use_ids);
x_ticklabel = x_ticklabel(use_ids);
if iscell(x_data)
    x_data = x_data{1};
end
x_ticklabel = x_ticklabel(x_tick>=max(x_lim(1),min(x_data(:))));
x_tick = x_tick(x_tick>=max(x_lim(1),min(x_data(:))));
x_ticklabel = x_ticklabel(x_tick<=min(x_lim(2),max(x_data(:))));
x_tick = x_tick(x_tick<=min(x_lim(2),max(x_data(:))));
x_tickStr      = mat2str(x_tick(:).');
x_ticklabelStr = [];
for i = 1:numel(x_ticklabel)
    x_ticklabelStr = [x_ticklabelStr ' "' x_ticklabel{i} '"']; 
end
fprintf(fid,'\txplaces %s\n',x_tickStr(2:end-1));
fprintf(fid,'\txnames%s\n',x_ticklabelStr);
fprintf(fid,'\txlabels dist axisLabelDist\n');

% specify y-axis limits, scale, and grid
gle_yaxis = sprintf('\tyaxis min %d max %d nticks 4\n',y_lim);
% if strcmp(y_scale,'log')
%     gle_yaxis = sprintf(strcat(gle_yaxis(1:length(gle_yaxis)-1),' log\n'));
% end
fprintf(fid,gle_yaxis);
fprintf(fid,'\tyticks off\n');
fprintf(fid,'\tysubticks off\n');

% for ITA ticks and ticklabels
use_ids = [];
for i = 1:size(y_ticklabel)
    if ~isempty(char(y_ticklabel(i)))
        use_ids = [use_ids, i]; 
    end
end
y_tick = y_tick(use_ids);
y_ticklabel = y_ticklabel(use_ids);
if iscell(y_data)
    y_data = y_data{1};
end
y_ticklabel = y_ticklabel(y_tick>=max(y_lim(1),min(y_data(:))));
y_tick = y_tick(y_tick>=max(y_lim(1),min(y_data(:))));
y_ticklabel = y_ticklabel(y_tick<=min(y_lim(2),max(y_data(:))));
y_tick = y_tick(y_tick<=min(y_lim(2),max(y_data(:))));
y_tickStr      = mat2str(y_tick(:).');
y_ticklabelStr = [];
for i = 1:numel(y_ticklabel)
    y_ticklabelStr = [y_ticklabelStr ' "' y_ticklabel{i} '"']; 
end
fprintf(fid,'\typlaces %s\n',y_tickStr(2:end-1));
fprintf(fid,'\tynames%s\n',y_ticklabelStr);
fprintf(fid,'\tylabels dist axisLabelDist\n');

% create the contour plot
% resolution 250x250, colormap jet (see subfunction)
%fprintf(fid,'\tcolormap "%s" 250 250 zmin %4.2f zmax %4.2f palette palette_jet\n',zdata_FileName,clim(1),clim(2));
% create the contour plot
%fprintf(fid, '\txres = %4.4f/2.54*%s \n', sArgs.dpi, DeltaX);
%fprintf(fid, '\tyres = %4.4f/2.54*%s \n', sArgs.dpi, DeltaY);
%yres = sArgs.dpi/2.54*DeltaY; %numel(x_data);

palette = sArgs.palette;
if ~strcmpi(palette,'gray')
    fprintf(fid,'\tcolormap "%s" %s %s zmin %4.4f zmax %4.4f palette %s \n',zdata_FileName,'200','200',clim(1),clim(2),palette);
else
    fprintf(fid,'\tcolormap "%s" %s %s zmin %4.4f zmax %4.4f \n',zdata_FileName,'200','200',clim(1),clim(2));
end
% terminate plot
fprintf(fid,'end graph\n\n');

% place a colorbar on the right of the plot
fprintf(fid,'set hei keyHei\n');
fprintf(fid,'amove xg(xgmax)+colorbarDist yg(ygmin)\n');
fprintf(fid,'color_range_vertical zmin %d zmax %d zstep %d pixels 100 palette %s format "fix 1"\n',clim(1),clim(2),abs(clim(1)-clim(2))/10,palette);
%fprintf(fid,'color_range_vertical %d %d %d width 0.4 palette palette_jet pixels %d format "fix 0"\n',clim(1),clim(2),abs(round(diff(clim)/5)),abs(round(diff(clim)/levelStep)));

% set back to default
fprintf(fid,'set hei %d\n',0.3633);
end

% function for image plots
function files = gle_imageplot(fid,axh,chdr,DeltaX,DeltaY,n,sArgs)

%% gather subplot-specific data
x_data = flipud(get(chdr,'XData'));
y_data = flipud(get(chdr,'YData'));
if isprop(chdr,'ZData')
    z_data = get(chdr,'ZData');
else
    z_data = get(chdr,'CData').';
    z_data(isnan(z_data)) = 0;
    % z_data = (z_data *0.70)+0.15;
end
z_data(isinf(z_data)) = sign(z_data(isinf(z_data))).*10000;
plot_title =  get(get(axh,'Title'),'String');
x_label = get(get(axh,'XLabel'),'String');
y_label = get(get(axh,'YLabel'),'String');
x_lim = get(axh,'XLim');
y_lim = get(axh,'YLim');
clim  = get(axh,'CLim');
x_tick = get(axh,'XTick');
x_ticklabel = cellstr(get(axh,'XTickLabel'));
y_tick = get(axh,'YTick');
y_ticklabel = cellstr(get(axh,'YTickLabel'));

%% start to write some axis and label settings
% need this for colormaps
fprintf(fid,'include "color.gle"\n');

scaling_factor = sArgs.font_scale;
fprintf(fid,'set alabelscale axisLabelScale*%5.3f\n',scaling_factor);
fprintf(fid,'set atitlescale axisTitleScale*%5.3f\n',scaling_factor);
fprintf(fid,'set titlescale titleScale*%5.3f\n\n',scaling_factor);

%% write data file
zdata_FileName = ['subplot' num2str(n) '.z'];
files = {zdata_FileName};
fid2 = fopen(zdata_FileName,'wt');
fprintf(fid2,'! nx %d  ny %d    xmin %4.2f  xmax %4.2f  ymin %4.2f  ymax %4.2f\n',...
    size(z_data,1),size(z_data,2),x_lim(1),x_lim(2),y_lim(1),y_lim(2));
fclose(fid2);
ita_dlmwrite(zdata_FileName,z_data.','-append','precision','%10.5f');

%% the actual plot
fprintf(fid,'begin graph\n');
fprintf(fid,'\tsize %s %s\n',DeltaX,DeltaY);
% fprintf(fid,'\tdata "%s"\n',[zdata_FileName(1:end-2) '-cdata.dat']);
% better for equal plots
fprintf(fid,'\thscale %4.2f\n', 1-0.22*scaling_factor);
fprintf(fid,'\tvscale %4.2f\n', 1-0.22*scaling_factor);

% place title and axis labels
if ~isempty(plot_title)
    fprintf(fid,'\ttitle "%s" dist titleDist\n',test_for_tex(plot_title));
end
if ~isempty(x_label)
    fprintf(fid,'\txtitle "%s" dist axisTitleDist\n',test_for_tex(x_label));
end
if ~isempty(y_label)
    fprintf(fid,'\tytitle "%s" dist axisTitleDist\n',test_for_tex(y_label));
end
% specify x-axis limits, scale, and grid
fprintf(fid,'\txaxis min %d max %d nticks 4\n',x_lim);
%fprintf(fid,'\txticks off\n');
fprintf(fid,'\txticks lstyle 4 lwidth 0.001\n');
fprintf(fid,'\txsubticks off\n');

% for ITA ticks and ticklabels
use_ids = [];
for i = 1:size(x_ticklabel)
    if ~isempty(char(x_ticklabel(i)))
        use_ids = [use_ids, i]; 
    end
end
x_tick = x_tick(use_ids);
x_ticklabel = x_ticklabel(use_ids);
if iscell(x_data)
    x_data = x_data{1};
end
x_ticklabel = x_ticklabel(x_tick>=max(x_lim(1),min(x_data(:))));
x_tick = x_tick(x_tick>=max(x_lim(1),min(x_data(:))));
x_ticklabel = x_ticklabel(x_tick<=min(x_lim(2),max(x_data(:))));
x_tick = x_tick(x_tick<=min(x_lim(2),max(x_data(:))));
x_tickStr      = mat2str(x_tick(:).');
x_ticklabelStr = [];
for i = 1:numel(x_ticklabel)
    x_ticklabelStr = [x_ticklabelStr ' "' x_ticklabel{i} '"']; 
end
fprintf(fid,'\txplaces %s\n',x_tickStr(2:end-1));
fprintf(fid,'\txnames%s\n',x_ticklabelStr);
fprintf(fid,'\txlabels dist axisLabelDist\n');


% specify y-axis limits, scale, and grid
fprintf(fid,'\tyaxis min %d max %d nticks 4\n',y_lim);
%fprintf(fid,'\tyticks off\n');
fprintf(fid,'\tyticks lstyle 4 lwidth 0.001\n');
fprintf(fid,'\tysubticks off\n');

% for ITA ticks and ticklabels
use_ids = [];
for i = 1:size(y_ticklabel)
    if ~isempty(char(y_ticklabel(i)))
        use_ids = [use_ids, i]; 
    end
end
y_tick = y_tick(use_ids);
y_ticklabel = y_ticklabel(use_ids);
if iscell(y_data)
    y_data = y_data{1};
end
y_ticklabel = y_ticklabel(y_tick>=max(y_lim(1),min(y_data(:))));
y_tick = y_tick(y_tick>=max(y_lim(1),min(y_data(:))));
y_ticklabel = y_ticklabel(y_tick<=min(y_lim(2),max(y_data(:))));
y_tick = y_tick(y_tick<=min(y_lim(2),max(y_data(:))));
y_tickStr      = mat2str(y_tick(:).');
y_ticklabelStr = [];
for i = 1:numel(y_ticklabel)
    y_ticklabelStr = [y_ticklabelStr ' "' y_ticklabel{i} '"']; 
end
fprintf(fid,'\typlaces %s\n',y_tickStr(2:end-1));
fprintf(fid,'\tynames%s\n',y_ticklabelStr);
fprintf(fid,'\tylabels dist axisLabelDist\n');


% create the contour plot
%fprintf(fid, '\txres = %4.4f/2.54*%s \n', sArgs.dpi, DeltaX);
%fprintf(fid, '\tyres = %4.4f/2.54*%s \n', sArgs.dpi, DeltaY);
%yres = sArgs.dpi/2.54*DeltaY; %numel(x_data);

palette = sArgs.palette;
if ~strcmpi(palette,'gray')
    fprintf(fid,'\tcolormap "%s" %s %s zmin %4.4f zmax %4.4f palette %s \n',zdata_FileName,'xres','yres',clim(1),clim(2),palette);
else
    fprintf(fid,'\tcolormap "%s" %s %s zmin %4.4f zmax %4.4f \n',zdata_FileName,'xres','yres',clim(1),clim(2));
end

%fprintf(fid,'\tcolormap "%s" 250 250 zmin %4.2f zmax %4.2f \n',zdata_FileName,clim(1),clim(2)); %Grey scale
% terminate plot
fprintf(fid,'end graph\n\n');

% place a colorbar on the right of the plot
fprintf(fid,'set hei keyHei\n');
fprintf(fid,'amove xg(xgmax)+colorbarDist yg(ygmin)\n');
fprintf(fid,'color_range_vertical zmin %d zmax %d zstep %d pixels 100 palette %s format "fix 1"\n',clim(1),clim(2),abs(clim(1)-clim(2))/10,palette);
%fprintf(fid,'color_range_vertical %d %d %d width 5 palette gray format "fix 2"\n',clim(1),clim(2),.20); %Grey scale

% set back to default
fprintf(fid,'set hei %d\n',0.3633);
end

% helpfunction to automatically change into math mode in latex
function outString = test_for_tex(inString)

texSymbols = {'\','_','^','>','<'};

for i = 1:numel(texSymbols)
    tmp = strfind(inString,texSymbols{i});
    while ~isempty(tmp)
        wspaces = strfind(inString,' ');
        lastwspace = wspaces(find(wspaces < tmp(1),1,'last'));
        if isempty(lastwspace)
            lastwspace = 0;
        end
        nextwspace = wspaces(find(wspaces > tmp(1),1,'first'));
        if isempty(nextwspace)
            inString = [inString ' ']; 
            nextwspace = length(inString);
        end
        tmp = tmp(tmp > nextwspace) + 2;
        inString = [inString(1:lastwspace) '$' inString(lastwspace+1:nextwspace-1) '$' inString(nextwspace:end)];
    end
end
outString = inString;
% outString = strrep(inString,'\rho','\\rho'); % preserve escape characters
outString = strrep(outString,'%','\%'); % those are not comments
outString = regexprep(outString,'\$+','$'); % repace multiple math symbols
outString = strrep(outString,'$ $','~'); % repace double math symbols

end

% helpfunction to create the jet colormap commands
function make_jet_colormap(fid)

fprintf(fid,'sub palette_jet z\n');
fprintf(fid,'\t! the matlab jet colormap\n');
fprintf(fid,'\tlocal r = 0\n');
fprintf(fid,'\tlocal g = 0\n');
fprintf(fid,'\tlocal b = 0\n');
fprintf(fid,'\t!RED\n');
fprintf(fid,'\tif (z > 0.375) and (z <= 0.625)  then r = (z-0.375)*4\n');
fprintf(fid,'\tif (z > 0.625) and (z <= 0.875)  then r = 1\n');
fprintf(fid,'\tif (z > 0.875)                   then r = 1-4*(z-0.875)\n');
fprintf(fid,'\t! GREEN\n');
fprintf(fid,'\tif (z > 0.125) and (z <= 0.375)  then g = (z-0.125)*4\n');
fprintf(fid,'\tif (z > 0.375) and (z <= 0.625)  then g = 1\n');
fprintf(fid,'\tif (z > 0.625) and (z <= 0.8438) then g = 1-4*(z-0.625)\n');
fprintf(fid,'\t! BLUE\n');
fprintf(fid,'\tif (z <= 0.125)                  then b = 0.5+4*z\n');
fprintf(fid,'\tif (z >  0.125) and (z <= 0.375) then b = 1\n');
fprintf(fid,'\tif (z >  0.375) and (z <= 0.625) then b = 1-4*(z-0.375)\n');
fprintf(fid,'\treturn rgb(r,g,b)\n');
fprintf(fid,'end sub\n\n');

fprintf(fid,'sub palette_artemis z\n');
fprintf(fid,'\t	! the artemis colormap\n');
fprintf(fid,'\t	local r = 0\n');
fprintf(fid,'\t	local g = 0\n');
fprintf(fid,'\t	local b = 0\n');
fprintf(fid,'\t	!RED\n');
fprintf(fid,'\t	if (z <= 0.1905)  then r = 0\n');
fprintf(fid,'\t	if (z > 0.1905) and (z <= 0.3968)  then r = (z-0.1905)/(0.3967-0.1905)\n');
fprintf(fid,'\t	if (z > 0.3968)  then r = 1\n');
fprintf(fid,'\t	! GREEN\n');
fprintf(fid,'\t	if (z <= 0.6032)  then g = 0\n');
fprintf(fid,'\t	if (z > 0.6032) and (z <= 0.8095)  then g = (z-0.6032)/(0.8095-0.6032)\n');
fprintf(fid,'\t	if (z > 0.8095)  then g = 1\n');
fprintf(fid,'\t	! BLUE\n');
fprintf(fid,'\t	if (z <= 0.1905)  then b = (z-0)/(0.1905-0)\n');
fprintf(fid,'\t	if (z > 0.1905) and (z <= 0.3968)  then b = 1\n');
fprintf(fid,'\t	if (z > 0.3968) and (z <=  0.6032)  then b = (0.6032-z)/(0.6032-0.3968)\n');
fprintf(fid,'\t	if (z > 0.6032) and (z <= 0.8095)  then b = 0\n');
fprintf(fid,'\t	if (z > 0.8095)  then b = (z-0.8095)/(1-0.8095)\n');
fprintf(fid,'\t	return rgb(r,g,b)\n');
fprintf(fid,'end sub\n\n');
end

function make_colormap(fid,axh)
x = linspace(0,1,64);

rgb = colormap(axh);

fprintf(fid,'sub palette_axes z\n');
fprintf(fid,'\t ! the current axes colormap\n');
fprintf(fid,'\t local r = 0\n');
fprintf(fid,'\t local g = 0\n');
fprintf(fid,'\t local b = 0\n');

fprintf(fid,'\t	if (z <= %4.4f) then \n', x(1));
fprintf(fid,'\t\t r = %4.4f\n',rgb(1,1));
fprintf(fid,'\t\t g = %4.4f\n',rgb(1,2));
fprintf(fid,'\t\t b = %4.4f\n',rgb(1,3));
fprintf(fid,'\t	end if \n\n');

for idx = 2:(numel(x))
    fprintf(fid,'\t	if (z > %4.4f) and (z <= %4.4f) then\n', x(idx-1),x(idx));
    fprintf(fid,'\t\t r = (z-%4.8f) * %4.8f + %4.8f \n',x(idx-1),(rgb(idx,1)-rgb(idx-1,1))/(x(idx)-x(idx-1)),rgb(idx-1,1));
    fprintf(fid,'\t\t g = (z-%4.8f) * %4.8f + %4.8f \n',x(idx-1),(rgb(idx,2)-rgb(idx-1,2))/(x(idx)-x(idx-1)),rgb(idx-1,2));
    fprintf(fid,'\t\t b = (z-%4.8f) * %4.8f + %4.8f \n',x(idx-1),(rgb(idx,3)-rgb(idx-1,3))/(x(idx)-x(idx-1)),rgb(idx-1,3));
    %fprintf(fid,'\t\t r = %4.4f\n',rgb(idx,1));
    %fprintf(fid,'\t\t g = %4.4f\n',rgb(idx,2));
    %fprintf(fid,'\t\t b = %4.4f\n',rgb(idx,3));
    fprintf(fid,'\t	end if \n\n');
end

fprintf(fid,'\t	if (z > %4.4f) then\n', x(end));
fprintf(fid,'\t\t r = %4.4f\n',rgb(end,1));
fprintf(fid,'\t\t g = %4.4f\n',rgb(end,2));
fprintf(fid,'\t\t b = %4.4f\n',rgb(end,3));
fprintf(fid,'\t	end if \n\n');


fprintf(fid,'\t	return rgb(r,g,b)\n');
fprintf(fid,'end sub\n\n');


end


% help function to set font size
function correct_font_size(sArgs)

fid = fopen([sArgs.fileName '.inc'],'r+');
text = textscan(fid,'%s');
frewind(fid);
text = text{1};

if isscalar(sArgs.font_size)
    warning('Assuming pt as units') %#ok<WNTAG>
    size = [num2str(sArgs.font_size) 'pt'];
else
    size = sArgs.font_size;
end
fontSize = ['\fontsize{' size '}{0}\selectfont'];

for idx = 1:length(text)
    aux = text{idx};
    k = strfind(aux,'\scalebox');
    
    if k
        p = strfind(aux(k:end), '}')+k;
        aux = [aux(1:k-1) fontSize aux(p:end)];
        k = strfind(aux,'\tiny');
        if k; aux(k:k+5) = []; end
        k = strfind(aux,'\scriptsize');
        if k; aux(k:k+10) = []; end
        k = strfind(aux,'\footnotesize');
        if k; aux(k:k+12) = []; end
        k = strfind(aux,'\small');
        if k; aux(k:k+5) = []; end
        k = strfind(aux,'\normalsize');
        if k; aux(k:k+10) = []; end
        k = strfind(aux,'\large');
        if k; aux(k:k+5) = []; end
        k = strfind(aux,'\Large');
        if k; aux(k:k+5) = []; end
        k = strfind(aux,'\LARGE');
        if k; aux(k:k+5) = []; end
        k = strfind(aux,'\huge');
        if k; aux(k:k+4) = []; end
        k = strfind(aux,'\Huge');
        if k; aux(k:k+4) = []; end
        
    end
    fprintf(fid,'%s\n',aux);
end

pause(.1)
fclose(fid);
end
