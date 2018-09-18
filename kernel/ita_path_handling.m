function varargout = ita_path_handling(varargin)
% handle the ITA-toolbox paths in MATLAB
%
% This function is not supposed to get triggered directly
% ita_generate_documentation needs a pathList not pathStr
%
% CALL: ita_path_handling
%       pathStr = ita_path_handling
%       [pathStr pathList] = ita_path_handling
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Settings
if nargin > 0
    error('There should not be any input arguments to ita_path_handling');
end
ignoreList  = {'.git','.svn','private','tmp','prop-base','props','text-base','template','doc','helpers'};

%% toolbox prefix string
fullpath = ita_toolbox_path();
fullPathParts = regexp(fullpath,filesep,'split');
prefixToolbox = fullPathParts{end};
pathStr = genpath(fullpath);
addpath(fullpath)

%% path handling
outpathList    = regexp(pathStr,pathsep,'split');
outpathList    = outpathList(~cellfun(@isempty,outpathList)); % kick out empty entries

% kick out ignore entries
for idx=1:numel(ignoreList)
   ignoreEntries = cellfun(@strfind,outpathList,repmat(ignoreList(idx),1,numel(outpathList)),'UniformOutput',false);
   validIdx = cellfun(@isempty,ignoreEntries);
   outpathList = outpathList(validIdx); 
end

% remove first pathsep
if ~isempty(outpathList)
    ita_delete_toolboxpaths;
    warnstate = warning('off','MATLAB:dispatcher:pathWarning'); %RSC: quiet
    addpath(outpathList{:})
    warning(warnstate);
end

%% Save the path list if possible
ita_verbose_info('ita_path_handling::Saving path list to your users pathdef.m...',1);
upath = userpath();
if isempty(upath)
    userpath('reset');
end
if isempty(userpath())
    ita_verbose_info('Oh Lord! I cannot set your userpath. Please check if the default directory exists or manually try saving your path variable.', 0);
else
    save_state = savepath(fullfile(upath, 'pathdef.m'));
    if save_state == 1
        ita_verbose_info('Oh Lord! I could not write to your users pathdef.m', 0);
    end
end

if nargout
    outpathStr = [];
    prefixToolboxIdx = strfind(fullpath,prefixToolbox);
    for idx = 1:numel(outpathList)
        outpathStr = [outpathStr pathsep outpathList{idx}]; %#ok<AGROW>
        outpathList{idx} = outpathList{idx}(prefixToolboxIdx:end);
    end
    
    varargout{1}=outpathStr(2:end);
    if nargout == 2
        varargout{2}=outpathList;
    end
end
