function varargout = ita_plottools_change_font_in_eps(varargin)
%ITA_PLOTTOOLS_CHANGE_FONT_IN_EPS - Change font in an EPS-File
%  This function changes known fonts written by MATLAB to the new font
%  specified. File attributes and dates will change!
%
%  Syntax:
%   ita_plottools_change_font_in_eps(filename) - Use Times for substitution
%   ita_plottools_change_font_in_eps(filename,font) - use font specified
%   ita_plottools_change_font_in_eps(filename_in, filename_out,font)
%               create new EPS-File with name specified
%
%  Example:
%   ita_plottools_change_font_in_eps('hans.eps')
%
%   See also: ita_savethisplot
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plottools_change_font_in_eps">doc ita_plottools_change_font_in_eps</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: dietrich  -- Email: pdi@akustik.rwth-aachen.de
% Created:  06-Aug-2009 

%% Initialization and Input Parsing
narginchk(1,3);

filename_in  = varargin{1};
font_name    = 'Times';
filename_out = filename_in;
if nargin == 2
    font_name    = varargin{2};
elseif nargin == 3
    font_name    = varargin{3};
    filename_out = varargin{2};
end

disp(['Using font: ''' font_name ''' for substitution.'])

%% Open and substitute font
% now read in the file
fid = fopen(filename_in);
ff  = fread(fid,'char')';
fclose(fid);

%these are the only allowed fonts in MatLab and so we have to weed them out
%and replace them:
mlabfontlist = {'Arial','AvantGarde','Helvetica-Narrow','Times','Times-Roman','Bookman',...
    'NewCenturySchlbk','ZapfChancery','Courier','Palatino','ZapfDingbats',...
    'Helvetica','Symbol'};

for k = 1:length(mlabfontlist)
    ff = strrep(ff,mlabfontlist{k},font_name);
end

% open the file up and overwrite it
fid = fopen(filename_out,'w');
fprintf(fid,'%s',ff);
fclose(fid);

%end function
end