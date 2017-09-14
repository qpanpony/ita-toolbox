function commitID = ita_git_getMasterCommitHash
%ITA_GIT_GETMASTERCOMMITHASH - Get hash of last used master commit
%  This function reads the git config and returns the hash of the last
%  commit in the master branch
%  The function is used in the to record the toolbox commit
%  which was used to create the ita file
%
%  Syntax:
%   commitID = ita_git_getMasterCommitHash()
%
%  See also:
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_git_read_config">doc ita_git_read_config</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  13-Sep-2017


commitID = '';
try
    workingDir = pwd;
    cd(ita_toolbox_path)
    [~,commitID] = system('git merge-base master HEAD');
    commitID = strrep(commitID,sprintf('\n'),'');
    cd(workingDir);
catch e
    
end



end
