function commitID = ita_git_getMasterCommitHash(varargin)
%ITA_GIT_GETMASTERCOMMITHASH - Get hash of last used master commit
%  This function reads the git config and returns the hash of the last
%  commit in the master branch
%  The function is used in the to record the toolbox commit
%  which was used to create (or load) the ita file (called from itaSuper
%  constructor)
%
%  Syntax:
%   commitID = ita_git_getMasterCommitHash()
%   commitID = ita_git_getMasterCommitHash('path','.','branch','test')
%
%   Options (default):
%           'branch' (master)  : the branch of the returned commit id
%           'path' (ita_toolbox_path)      : the path of the repository
%
%
%  See also:
%       itaSuper.init
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_git_read_config">doc ita_git_read_config</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  13-Sep-2017


sArgs.branch = 'master';
sArgs.path = '';

sArgs = ita_parse_arguments(sArgs,varargin);

if isempty(sArgs.path)
    repPath = ita_toolbox_path;
else
   repPath = sArgs.path; 
end

commitID = '';
try
    workingDir = pwd;
    cd(repPath)
    [status,commitID] = system(sprintf('git merge-base %s HEAD',sArgs.branch));
    if status == 0
        commitID = strrep(commitID,newline,'');
    else
        ita_verbose_info(sprintf('Git Hash Failed: %s',commitID), 1);
        commitID = '';
    end
    cd(workingDir);
catch e
    
end



end
