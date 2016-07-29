function [ output_args ] = compile( fileName )
%COMPILE Summary of this function goes here
%   Detailed explanation goes here

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


jPath = fullfile(matlabroot,'java','jarext');
cp = [pwd pathsep fullfile(jPath,'jogl.jar') pathsep fullfile(jPath,'gluegen-rt.jar')];
% add jinput to the path
cp = [cp pathsep [pwd '/jinput/jinput.jar']];
cmd = ['javac -d . -cp ''' cp ''' ' fileName ''];
system(cmd,'-echo')
% javaaddpath(pwd)

% jar
% cmd = ['jar cvf testMatlabInterface.jar TestFunction.class'];
% system(cmd,'-echo');
end

