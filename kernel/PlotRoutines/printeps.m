function printeps(fignum, figname)
%PRINTEPS - (fignum, figname)
% this is a simple function that overrides Matlab's desire to call all
% fonts 'Helvetica' in an exported .eps file. This is particularly annoying
% if you import your file into Illustrator and find that not only do you
% NOT have 'Helvetica', but that in substituting for it, your subscripts
% have moved a mile away and things otherwise just don't look 'right.'
% It is suggested that you set your default font in a
% startup file to something that you actually have on your system. For
% instance, if you purchased the Helvetica family straight from Adobe,
% set(0, 'DefaultAxesFontName', 'HelveticaLTStd-Roman');
% the whole point of this is that when you generate a figure in Matlab,
% you'd like your exported file to be as close a representation of that
% figure as possible.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Note: This is a global change of font in the file. That is, any text you
% add via text() and title() commands will end up in the default axes font.
% this is because there is no easy way to parse out the fonts of these
% objects in the .eps file for replacement.
%
%
% EXAMPLE:
% set(0, 'DefaultAxesFontName', 'Arial');   %replace fontname with something
%                                           %you have
% figure(1);clf;fplot(@tanh,[-5,5]);        %plot something
% printeps(1,'test');                       %print the contents of figure 1
%                                           %to test.eps.
% figfilestr = [figname '.eps'];

% Author: Pascal Dietrich, pdi@akustik.rwth-aachen.de

[path,filename] = fileparts(figname);
actualDir = pwd;
cd(path);
figfilestr = fullfile( path, [filename, '.eps']);
eval(['print -depsc2 -f' num2str(fignum) ' ' filename '.eps;']);
cd(actualDir);

if ispc
    % now read in the file
    fid = fopen(figfilestr);
    ff  = char(fread(fid))';
    fclose(fid);
    
    %get the actual font
    figure(fignum);
    ita_verbose_info(['This font is used in the .eps written by MATLAB: ' get(gca,'FontName')],1);
    actualfont = 'Times';
    
    %these are the only allowed fonts in MatLab and so we have to weed them out
    %and replace them:
    mlabfontlist = {'AvantGarde','Helvetica-Narrow','Times-Roman','Bookman',...
        'NewCenturySchlbk','ZapfChancery','Courier','Palatino','ZapfDingbats',...
        'Helvetica'};%,'Symbol'};
    
    for k = 1:length(mlabfontlist)
        ff = strrep(ff,mlabfontlist{k},actualfont);
    end
    
    % open the file up and overwrite it
    fid = fopen(figfilestr,'w');
    fprintf(fid,'%s',ff);
    fclose(fid);
end



