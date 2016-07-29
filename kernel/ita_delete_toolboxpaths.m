function [] = ita_delete_toolboxpaths(varargin)
% delete all ITA-Toolbox paths in MATLAB

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% get current path list
x = pwd;
cd (ita_toolbox_path())
cd ..
pathStr  = [path() pathsep];
tokenStr = regexp(pathStr,pathsep,'split');
tbPath      = ita_toolbox_path;
paths2delete = tokenStr(~cellfun(@isempty,strfind(tokenStr,tbPath)));

if ~isempty(paths2delete)
    rmpath(paths2delete{:})
end
savepath();

cd(x);

