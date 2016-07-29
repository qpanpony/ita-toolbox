function varargout = ita_listeningtest_localization_block(varargin)
%ITA_LISTENINGTEST_LOCALIZATION_BLOCK - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_listeningtest_localization_block(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_listeningtest_localization_block(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_listeningtest_localization_block">doc ita_listeningtest_localization_block</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  28-Nov-2013 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details

% sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
% [input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 

    %% generate stimulus files
    stimulusData = itaListeningTestStimulus;
    
    stimulusData.UseHRTF = 1;
    stimulusData.UseHeadphoneEquilization = 1;
    stimulusData.HRTFFile = 'data/HRTF_1.ita';
    stimulusData.HeadphoneEquilizationFile = 'data/HPTF_1_mean_smooth.ita';
    stimulusData.StimulusFile = 'data/pulsedNoise.ita';

    
    %% some more options
    azimuthDirections = [10, 0, -10, 170, 180, 190, 10, 0, -10, 170, 180, 190, 10, 0, -10, 170, 180, 190 ];
    elevationDirections = [100, 100, 100, 100, 100, 100, 90, 90, 90, 90, 90, 90, 80, 80, 80, 80, 80, 80];
    blockWidth = [5, 5, 5, 5, 5, 5,5, 5, 5, 5, 5, 5, 5, 5, 5,5, 5, 5];
    blockAdditionalWidth = [5, 5, 5, 5, 5, 5,5, 5, 5, 5, 5, 5, 5, 5, 5,5, 5, 5];
%     azimuthDirections = [0, 45, 90, 135, 180, -135, -90, -45, 0, 45, 90, 135, 180, -135, -90, -45,0, 45, 90, 135, 180, -135, -90, -45 ];
%     elevationDirections = [135, 135, 135, 135, 135, 135, 135, 135,    90, 90, 90, 90, 90, 90, 90, 90,  45, 45, 45, 45, 45, 45, 45, 45];
%  
%     blockWidth = [5, 5, 5, 5, 5, 5,5, 5, 5, 5, 5, 5, 5, 5,5, 5,5, 5, 5, 5, 5, 5,5, 5]*2;
%     blockAdditionalWidth = [5, 5, 5, 5, 5, 5,5, 5,5, 5, 5, 5, 5, 5,5, 5,5, 5, 5, 5, 5, 5,5, 5]*3;
    
    trainingRounds = 3;
    testRounds = 3;
    
    %% gui init
    javaGUI = itaListeningTestGUI;
    javaGUI.mGLMode = 1;
    javaGUI.setBlocks(azimuthDirections,elevationDirections,blockWidth,blockAdditionalWidth);
    javaGUI.setDynamicAlphaMode(1);
    
    
    
    %% get the simuli
    trainingIndeces = randi(length(azimuthDirections),1,trainingRounds);
    
    
    %% training
    javaGUI.showAndStopTillUserReady();
    for index = 1:trainingRounds
        azimuth = azimuthDirections(trainingIndeces(index));
        elevation = elevationDirections(trainingIndeces(index));
        stimulus = stimulusData.getStimulusForDirection(azimuth,elevation);
    
        [trainingResults(index)] = javaGUI.startSingleTraining(azimuth,elevation,stimulus);
    end
    javaGUI.fullReset();
    
    %% test
    javaGUI.showAndStopTillUserReady();
    for index = 1:testRounds
        azimuth = azimuthDirections(trainingIndeces(index));
        elevation = elevationDirections(trainingIndeces(index));
        stimulus = stimulusData.getStimulusForDirection(azimuth,elevation);
        [results(index)] = javaGUI.startSingleListeningTest(180,90,stimulus);
    end

    %% clean up
    javaGUI.closeGUI();
    clear javaGUI

end