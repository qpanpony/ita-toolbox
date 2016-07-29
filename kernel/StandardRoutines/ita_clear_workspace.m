function ita_clear_workspace(varargin)
%ITA_CLEAR_WORKSPACE - Clear all itaAudios from base workspace
%   
%   Call: ita_clear_workspace()
%         ita_clear_workspace(Options)
%
%   Options (default):
%         'filter' ('') - Clear only var that include this substring
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_clear_workspace">doc ita_clear_workspace</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% narginchk(1,1);
sArgs        = struct('filter','');
sArgs = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back 
[List, varStruct ,CellList] = ita_guisupport_getworkspacelist;

for idx = 1:size(CellList,1)
    if isempty(sArgs.filter) || any(strmatch(CellList{idx,1},sArgs.filter))
        evalin('base',['clear ' CellList{idx,1}]);
    end
end


end