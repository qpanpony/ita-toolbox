function ita_setinbase(varargin)
%ITA_SETINBASE - Save a variable in the base workspace
% If the variable is an itaAudio
%
%  Syntax:
%   ita_setinbase(namev, value) - set var with that name and value
%   
%   
%   See also: ita_getfrombase.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_setinbase">doc ita_setinbase</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009 

%% Initialization and Input Parsing
narginchk(2,2);

[path, name, fileExt] = fileparts(varargin{1}); 
                        %BMA: To assure that only file name will be used.
name = ita_guisupport_removewhitespaces(name);
name = genvarname(name); %use genvarname to make sure it can exist as matlab variable

value = varargin{2};


%% Assign to workspace
try 
    assignin('base',name,value);   
catch %#ok<CTCH>
    ita_verbose_info(['Var ''' name ''' could not be set'],1);
end

end