function ita_savethisplot(varargin)
%ITA_SAVETHISPLOT - Saves current plot as figure
%  This function save the specified plot as .eps and .png with File GUI
%  Furthermore, it uses eps2pdf if installed to generate the PDF output.
%
%   Call: ita_savethisplot() - gcf is used
%   Call: ita_savethisplot(hfig) - hfig is figure handle
%   Call: ita_savethisplot(filename)
%   Call: ita_savethisplot(hfig,filename)
%   Call: ita_savethisplot('all',filename) - save all figures
%   Call: ita_savethisplot(hfig,filename,options) using options:
%
%   Options (default):
%           nocrop (false)  : do not crop figure automatically
%           resolution ([]) : overrides default resolution for bitmaps
%
%   See also ita_plot_dat_dB, ita_plot_spk, printeps.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_savethisplot">doc ita_savethisplot</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Modified: 29-May-2008


%% Verbose and Function String
thisFuncStr  = [upper(mfilename) ':'];

%% Check input arguments
sArgs = struct('pos1_hfig','handle','pos2_filename','string','nocrop',false,'resolution',[],'backgroundColor',[1 1 1],'withGhostscript',ita_preferences('isGhostscriptInstalled'));

%% read filename and folder
if nargin == 0 || (nargin == 1 && any(ishandle(varargin{1})))
    if nargin && ishandle(varargin{1})
        hfig = varargin{1};
    else
        hfig = gcf;
    end
    % user prompt for filename
    try %
        newFileStr = getappdata(hfig,'Filename');
    catch %#ok<CTCH>
        newFileStr = 'saved_plot';
    end
    
    if isempty(newFileStr)
        newFileStr = 'saved_plot';
    end
    
    [xx, newFileStr, xxx] = fileparts(newFileStr); %#ok<NASGU,ASGLU>
    
    [filename, filedir, filteridx] = uiputfile( ...
        {'*.eps;*.pdf;*.png;*.bmp;*.jpg;*tif;*.fig','All Graphic Files (*.eps,*.pdf,*.png,*.bmp,*.jpg,*.tif,*.fig)';...
        '*.eps','Encapsulated PostScript (*.eps)';...
        '*.pdf','Portable Document Format (*.pdf)';...
        '*.png','Portable Network Graphic (*.png)';...
        '*.bmp','Bitmap Graphic (*.bmp)';...
        '*.jpg','JPEG Graphic (*.jpg)';...
        '*.tif','Tagged Image File Format (*.tif)';...
        '*.fig','Matlab Figure (*.fig)';...
        '*.*','All Files (*.*)'},...
        'Save as',newFileStr);
    if ~filename
        return;
    end
    [p1, p2, pext] = fileparts(filename); %#ok<ASGLU>
    if isempty(pext)
        %if no fileext, try to guess from filter index in GUI
        switch filteridx
            case 2
                pext = 'eps';
            case 3
                pext = 'pdf';
            case 4
                pext = 'png';
            case 5
                pext = 'bmp';
            case 6
                pext = 'jpg';
            case 7
                pext = 'tif';
            case 8
                pext = 'fig';
        end
        filename = [p2 '.' pext];
    end
    
elseif nargin == 1 && ischar(varargin{1})
    % only filename given
    [filedir, filename, filetype] = fileparts(varargin{1});
    hfig = gcf;
    filename = [filename filetype];
    
elseif nargin == 2
    % both figure handle and filename given
    [filedir, filename, filetype] = fileparts(varargin{2});
    if isempty(filedir)
        filedir  = cd;
    end
    if strcmpi(varargin{1},'all')
        figure_list = sort(findobj(0,'type','figure'));
        nFigures = length(figure_list);
        for iFig = 1:nFigures
            filename_list{iFig} = [filedir filesep filename '_fig',num2str(figure_list(iFig)),filetype]; %#ok<AGROW>
            ita_savethisplot(figure_list(iFig),filename_list{iFig});
        end
        return;
    else
        if ishandle(varargin{1})
            hfig = varargin{1}; 
        else
            hfig = gcf;
            ita_verbose_info('Invalid figure handle.',1)
        end
        filename = [filename filetype]; %restore complete filename
    end
else
    % new mode using parse_arguments function
    [hfig,filename,sArgs] = ita_parse_arguments(sArgs,varargin);
    [filedir, filename, filetype] = fileparts(filename);
    filename = [filename filetype]; %restore complete filename
end

if isempty(filedir)
    filedir  = cd;
end

%% split filename and extension
[filedir_old, filename, fileext] = fileparts(filename); %#ok<ASGLU>

possibleExtensions = {'','.eps','.pdf','.png','.bmp','.tif','.jpg','.fig'};

if ~any(ismember(fileext,possibleExtensions))
    ita_verbose_info([thisFuncStr 'do not know that file extension: ' fileext ', but I will do my best!'],1);
    fileext = '';
end

if ~exist(filedir,'dir')
    mkdir(filedir);
end

%% delete spaces in filename
filename(filename == ' ') = '_';

%% Background color
if ita_preferences('blackbackground')
    ita_whitebg([1 1 1]) %whithout changing colororder
end

%% switch off cursors
try %#ok<TRYNC> % not all plots have cursors
    ita_plottools_cursors('off');
end

%% export
if sArgs.withGhostscript % use export_fig
    % build extension export string
    if ~iscell(fileext)
        fileext = {fileext};
    end
    exportExt = unique(fileext(ismember(fileext,possibleExtensions)));
    % if it's empty, take everything
    if isempty(exportExt) || any(strcmpi(exportExt,''))
        exportExt = possibleExtensions(2:end);
    end
    exportExt = exportExt(~strcmpi(exportExt,'.fig')); % fig will be handled by Matlab
    exportStr = '';
    for iExt = 1:numel(exportExt)
        exportStr = [exportStr ', ''-' exportExt{iExt}(2:end) '''']; %#ok<AGROW>
    end
    
    % export using external package export_fig
    if ~isempty(exportStr)
        % store the background color and restore it afterwards
        oldColor = get(hfig,'Color');
        set(hfig,'Color',sArgs.backgroundColor);
        exportCommand = ['export_fig(''' fullfile(filedir, filename) '''' exportStr];
        if sArgs.nocrop
            exportCommand = [exportCommand ',''-nocrop'''];
        end
        if ~isempty(sArgs.resolution) && sArgs.resolution ~= get(0,'ScreenPixelsPerInch')
            exportCommand = [exportCommand ',''-r' num2str(sArgs.resolution) ''''];
        end
        
        eval([exportCommand ');']);
        % now restore the color
        set(hfig,'Color',oldColor);
    end
else % use MATLAB
    
    figurePosition = get(hfig, 'position');
    set(hfig, 'paperUnits', 'points', 'papersize', figurePosition(3:4), 'paperPosition', [ 0 0 figurePosition(3:4)]);
    
    % EPS
    if any(strcmpi(fileext,{'.eps',''}))
        print('-depsc', fullfile(filedir, [filename '.eps']));
    end
    
    % PDF
    if any(strcmpi(fileext,{'.pdf',''}))
        print('-dpdf',fullfile(filedir, [filename '.pdf']));
    end
    
    % PNG
    if any(strcmpi(fileext,{'.png',''}))
        if ~isempty(sArgs.resolution) && sArgs.resolution ~= get(0,'ScreenPixelsPerInch')
            resolutionString = ['-r' num2str(sArgs.resolution)];
        else
            resolutionString = '-r300';
        end
        print(hfig, '-dpng',resolutionString,fullfile(filedir, [filename '.png']))
    end
    
    % BMP
    if any(strcmpi(fileext,{'.bmp',''}))
        print('-dbmp',fullfile(filedir, [filename '.bmp']));
    end
    
    % TIFF
    if any(strcmpi(fileext,{'.tif',''}))
        print('-dtiff',fullfile(filedir, [filename '.tif']));
    end
    
    % TIFF
    if any(strcmpi(fileext,{'.jpg',''}))
        print('-djpeg',fullfile(filedir, [filename '.jpg']));
    end
    
%     % EMF
%     if any(strcmpi(fileext,{'.emf',''}))
%         saveas(hfig , fullfile(filedir, [filename '.emf']) , 'emf');%save as emf
%     end    
end

%% matlab figure
if any(strcmpi(fileext,{'.fig',''}))
    %get rid of callback functions first
    if ita_preferences('blackbackground') %change back
        ita_whitebg([0 0 0]) %whithout changing colororder
    end
    WinDownFcn = get(hfig,'WindowButtonDownFcn');
    set(hfig,'WindowButtonDownFcn','');
    ButDownFcn = get(hfig,'ButtonDownFcn');
    set(hfig,'ButtonDownFcn','');
    
    saveas(hfig , fullfile(filedir, [filename '.fig']) , 'fig'); % save as matlab fig
    
    %save back callback functions
    set(hfig,'WindowButtonDownFcn',WinDownFcn);
    set(hfig,'ButtonDownFcn',ButDownFcn);
end

%% Get old settings back
if ita_preferences('blackbackground') %change back
    ita_whitebg([0 0 0]) %whithout changing colororder
end

%% switch cursors back on
if ita_preferences('plotcursors')
    ita_plottools_cursors('on');
end

end % function