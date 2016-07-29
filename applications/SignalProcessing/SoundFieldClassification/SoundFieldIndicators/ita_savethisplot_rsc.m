function varargout = ita_savethisplot_rsc(varargin)
%ITA_SAVETHISPLOT_RSC - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_savethisplot_rsc(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_savethisplot_rsc(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_savethisplot_rsc">doc ita_savethisplot_rsc</a>

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  22-Nov-2010


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('handle',gcf,'filename','','graphsize',[],'dpi',300);
sArgs = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back

if isempty(sArgs.filename)
    sArgs.filename = ['saved_plot' datestr(now,'yyyy-mmm-dd_HH-MM-SS')];
end

linewidth = 14.7;
if isempty(sArgs.graphsize)
    graphsize = get(sArgs.handle,'PaperSize');
elseif all(isnumeric(sArgs.graphsize))
    graphsize = sArgs.graphsize;
elseif iscellstr(sArgs.graphsize)
    if numel(sArgs.graphsize) == 1
        graphsize = eval(lower(sArgs.graphsize{1}));
    elseif numel(sArgs.graphsize) == 2
        graphsize(1) = eval(lower(sArgs.graphsize{1}));
        graphsize(2) = eval(lower(sArgs.graphsize{2}));
    end
end

if numel(graphsize) == 1
    graphsize(2) = graphsize(1) * 20.984/29.6774;
end

set(sArgs.handle,'Units','centimeters');
set(sArgs.handle,'PaperSize',graphsize);
%set(sArgs.handle,'PaperPosition',[0 0 graphsize(1) graphsize(2)]);
set(sArgs.handle,'Position',[0 0 graphsize(1) graphsize(2)]);
set(sArgs.handle,'PaperPositionMode','auto');



renderer = get(sArgs.handle,'Renderer');

warnstate = warning('OFF', 'MATLAB:hg:surface:RGBCDataNotSupported');
matlabfrag(sArgs.filename,'handle',sArgs.handle,'renderer',renderer,'dpi',sArgs.dpi);
warning(warnstate);


s = fopen([sArgs.filename '_preview.tex'],'w');
fprintf(s,'%s\n','\documentclass{article} ');
fprintf(s,'%s\n','\usepackage{pstool} ');
fprintf(s,'%s\n','\begin{document} ');
%fprintf(s,'%s\n','\centering ');
fprintf(s,'%s\n','\pagestyle{empty} ');
%fprintf(s,'%s\n',['\psfragfig*[width=\' lower(sArgs.graphsize{1}) ']{' sArgs.filename '} ']);
fprintf(s,'%s\n',['\psfragfig*{' sArgs.filename '} ']);
fprintf(s,'%s\n','\end{document}');


fclose(s);


latexstr = ['pdflatex -shell-escape ' [sArgs.filename '_preview.tex']]; 

system(latexstr);

system(['pdfcrop --margins ''1 1 1 1'' ' sArgs.filename '_preview.pdf ' sArgs.filename '_preview.pdf']);
system(['convert -density ' int2str(sArgs.dpi) ' ' sArgs.filename '_preview.pdf ' sArgs.filename '_.png']);

delete([sArgs.filename '_preview.*']);
%end function
end