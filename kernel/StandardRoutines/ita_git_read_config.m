function userInfo = ita_git_read_config
%ITA_GIT_READ_CONFIG - Get name and email from git config
%  This function reads the git config and tries to find the username and
%  the users email from the local git config. If either one of them are not
%  found, the global git config will be used.
%
%  Syntax:
%   userInfo = ita_git_read_config()
%
%  See also:
%   ita_preferences
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_git_read_config">doc ita_git_read_config</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  24-Nov-2016 

workingDir = pwd;
cd(ita_toolbox_path)

% This will only work if git bash bindings are installed.
% TODO: check TortoiseGit command line version
[userName,userMail,statusName,statusMail] = read_config_with_bindings();

if statusName ~= 0 || statusMail ~= 0
    % Do not use ita_verbose_info here, as it will result in an infinite
    % loop because of an ita_preferences call
	disp('Either git was not found on your machine or your username and e-mail are not set in the configuration. You can set them manually using ita_preferences.');
	userName = [];
	userMail = [];
end
cd(workingDir);
userInfo.AuthorStr = strcat(userName);
userInfo.EmailStr = strcat(userMail);

end


function [userName,userMail,statusName,statusMail] = read_config_with_bindings()

[statusName,userName] = system('git config --local user.name');
[statusMail,userMail] = system('git config --local user.email');

if statusName ~= 0 
    [statusName,userName] = system('git config --global user.name');
end
if statusMail ~= 0
    [statusMail,userMail] = system('git config --global user.email');
    disp('I took your E-Mail from the global git configuration');
end

end
