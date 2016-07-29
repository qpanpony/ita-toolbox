function ita_listeningtest_javaSetup
%ita_listeningtest_javaSetup Setups the matlab project management
% for the installation, several additions have to be made.
% firstly, the javaclasspath.txt file needs to hold the path to the java
% files
%
%  Syntax: ita_listeningtest_javaSetup
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_">doc ita_</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created: 07-Jan-2015 


%% matlab version
switch version ( '-release' )
    case {'2014a' '2014b'}
        disp('Installing...');
        javaVersion = 7;
    otherwise
        disp('Only 2014a and 2014b tested at the moment');
        return
end  


%% javaclasspath
% first, get the path of the bin directory
path = mfilename('fullpath');

folder = strrep(path,'\','/');     
C = strsplit(folder,'/');
projectDir = strjoin(C(1:end-1),'/');
projectDir = [projectDir '/java/bin/java' num2str(javaVersion)];


if ispc
    userPath = userpath;
    filePath = userPath(1:end-1);
else
    filePath = prefdir;
end


fileHandle = fopen([filePath  '/javaclasspath.txt'],'a');
fwrite(fileHandle,sprintf('\n%s \n',projectDir));
fclose(fileHandle);

%TODO: Copy the jinput.dlls to matlab/bin

disp('Setup complete: Copy java/bin/jinput/jinput.dlls to matlab/bin to complete. Restart Matlab to use the gui');

end

