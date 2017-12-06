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
%           'force' (false)     : force a new update on the commit id
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

persistent oldArgs;
persistent oldID;

sArgs.branch = 'master';
sArgs.path = '';
sArgs.force = 0;

sArgs = ita_parse_arguments(sArgs,varargin);


if ~isempty(oldID)
    if isequaln(oldArgs,sArgs)
        if ~sArgs.force
            commitID = oldID;
            return;
        end
    end
end

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
        commitID = strrep(commitID,'[\n\r]+','');
    else
        ita_verbose_info(sprintf('Git Hash Failed: %s',commitID), 1);
        commitID = '0';
    end
    cd(workingDir);
    
    oldID = commitID;
    oldArgs = sArgs;
catch e
   cd(workingDir); 
end



end
