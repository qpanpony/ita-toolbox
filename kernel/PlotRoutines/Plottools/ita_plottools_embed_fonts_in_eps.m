function ita_plottools_embed_fonts_in_eps( figname,fontUwant)
%ITA_PLOTTOOLS_EMBED_FONTS_IN_EPS - embed specific font in eps
% ( figname,fontUwant)
% Based on the function printeps.m from J. Aumentado (4/20/05)
%
% ******************************************
% Modified by Sebastian Fingerhuth Nov. 2008
% ******************************************
%
% EXAMPLE:
% embed_fonts_in_eps (0, 'FileName', 'Arial');
%
%
% Please!!! use a Font Name as gs (ghostscript) can interpret
% I mean: 'Times Roman' ~= 'Times-Roman'
% Try and error will help!
% Please fill this file, as you know new font names.
% fontUwant can be one of this list:
%   LMSans10-Bold
%   Arial
%   ....
% You will also need to embed the fonts (some) everytime you want a new
% font.
% Write the embeded font into a .mat file using
% fid = fopen('FONT_Arial.txt','r');
% FONT_Definition = fread(fid,'*char').';
% save FONT_Arial FONT_Definition
% fclose fid

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


mlabfontlist = {'AvantGarde-Book','Helvetica','Courier','Bookman-Light',...
    'Times-Roman','NewCenturySchlbk-Roman','ZapfChancery-MediumItalic'...
    'Palatino-Roman'};

% read in the EPS file
figfilestr = [figname '.eps'];
fid = fopen(figfilestr,'r');
ff = char(fread(fid))';
fclose(fid);

actualfont = fontUwant;

% Replace the fonts. This is means: If in the eps appears Helvetica it will
% be replaced with actualfont
for k = 1:length(mlabfontlist)
    ff = strrep(ff,mlabfontlist{k},actualfont);
end

% Read the file, with the EMBED info
load(['FONT_' fontUwant '.mat'])
ff = strrep(ff,'%%BeginProlog',['%%BeginProlog ', ff(24),  FONT_Definition]);

% open the file up and overwrite it
fid = fopen(figfilestr,'w');
fprintf(fid,'%s',ff);
fclose(fid);