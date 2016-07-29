ccx;

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% Measurement Setup
load('MS_HRTF.mat');

%% Load predifined grid
load grid_5x5.mat;

%% Italian Setup
italian = itaItalian;
italian.dataPath = 'I:\HRTF\Hoertnix_oben';
italian.diaryFile = ['\\Verdi\Scharrer\italianLog' datestr(now,30) '.txt'];
italian.defaultArmSpeed = 0.5;
italian.defaultTurntableSpeed = 3;
italian.measurementSetup = MS; % From file
italian.measurementSetup.averages = 1;
italian.measurementPositions = grid; % From file

%% Prepare Italian
italian.initialize;
italian.referenceMove;

%% Run measurement
italian.run;

