function ita_read_doubleclick(varargin)
%ITA_READ_DOUBLECLICK - Reads audio files when icon is double clicked
%  This function will be called when the user double click over a
%  recognizable audio file.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_read_doubleclick">doc ita_read_doubleclick</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  27-Nov-2009 

result = ita_read(varargin{:});
[junk, name, junk] = fileparts(varargin{1});  %#ok<NASGU,ASGLU>
ita_setinbase(name,result);

ita_verbose_info(['Variable: ' name ' has been exported to your workspace'],1);

end