%% RAVEN simulation: Example to start an acoustic animation script from MATLAB
% Author: las@akustik.rwth-aachen.de
% date:     2019/06/25
%
% Example script to configure and run an acoustic animation.
% Running an acoustic animation is more efficient if operated from a batch
% script instead of this matlab script (see bin64\runAnimationTest.bat)
%
%
% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% set raven base path if not installed in default directory
ravenBasePath = 'C:\ITASoftware\Raven\';

% load raven project test file for acoustic animation 
animationRPFfile = [ ravenBasePath 'RavenInput\Animation\AnimationTest.rpf' ];  
animationMatlabObject = itaRavenProject(animationRPFfile);  % to modify simulation settings

%% load and modify acoustic animation settings file
animationSettings = [ ravenBasePath 'RavenInput\Animation\AnimationTest.ini' ];
animationSettingsFile = IniConfig();
animationSettingsFile.ReadFile(animationSettings);  % load the settings file to the matlab workspace to modify configuration

% example settings
animationSettingsFile.SetValues('AcousticAnimation', 'blockSize',              1024);   % set blocksize length to 1024
animationSettingsFile.SetValues('AcousticAnimation', 'overlap',                0.2);    % set block overlap to 20%
animationSettingsFile.SetValues('AcousticAnimation', 'rayTracingUpdateRadius', 0.35);    % change to ray tracing update to 35 cm

% change path to source position file. Note: if relative paths are used,
% paths are relative to the raven binary, not relative to current your matlab path
% Info: Format creating files for receiver and source positions
%       time	 posx posy poz 		viewx viewy viewz 	upx upy upz
animationSettingsFile.SetValues('AcousticAnimation', 'sourcePositionFile','..\RavenInput\Animation\AnimationTestSource.ini');  

% save acoustic animation settings file
animationSettingsFile.WriteFile(animationSettings);


%% run animation script. 
% Note: The acoustic animation script uses a special binary to run the simulation (bin64/RavenConsoleAcousticAnimation64)
prevPath = pwd;
cd([ravenBasePath 'bin64\']);
dos([ 'RavenConsoleAcousticAnimation64.exe "' animationRPFfile '" -acousticanimation "' animationSettings '"' ],'-echo');
cd(prevPath);

%% check / play results
animationMatlabObject.openOutputFolder
outputFilePath=animationSettingsFile.GetValues('AcousticAnimation','outputSignal');
outputFile=ita_read([ravenBasePath outputFilePath(4:end) ]);
outputFile.play