cd(fileparts(which(mfilename))); %change the current folder

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


tutorialName = mfilename;
% cut '_compileDocument' from the full name of this m-file
tutorialName =strrep(tutorialName, '_compileDocument_', '_');

web(publish(tutorialName,struct('evalCode',false,'outputDir',pwd)));
