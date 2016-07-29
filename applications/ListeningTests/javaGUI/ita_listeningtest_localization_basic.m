function varargout = ita_listeningtest_localization_basic(varargin)
%ITA_LISTENINGTEST_LOCALIZATION_BASIC - +++ Short Description here +++
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
%   audioObjOut = ita_listeningtest_localization_basic(audioObjIn)
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


%%
    global javaGUI;
    %% generate stimulus files
    stimulusData = itaListeningTestStimulus;
    
    stimulusData.UseHRTF = 1;
    stimulusData.UseHeadphoneEquilization = 0;
    stimulusData.HRTFFile = 'data/HRTF_dummy.ita';
    stimulusData.HeadphoneEquilizationFile = 'data/HPTF_1_mean_smooth.ita';
    stimulusData.StimulusFile = 'data/pulsedNoise.ita';

    
    trainingRounds = 3;
    testRounds = 3;
    
    %% gui init
    javaGUI = itaListeningTestGUI;
    javaGUI.mGLMode = 0;
    
    % activate tracker
    javaGUI.mUserTracker = 0;
    
    javaGUI.setControllerLimits(00,100);
    
    azimuthDirections = [45, 0, -45, 225, 180, 135, 45, 0, -45, 225, 180, 135, 45, 0, -45, 225, 180, 135];
    elevationDirections = [110, 110, 110, 110, 110, 110, 90, 90, 90, 90, 90, 90, 70, 70, 70, 70, 70, 70];

    
    %% get the simuli
    trainingIndeces = randi(length(azimuthDirections),1,trainingRounds);
    trainingResolutions = round(trainingRounds:-1:1);
    
    %% training
    abort = javaGUI.showAndStopTillUserReady();                                                                                                                     
    if (abort == 1)                                                                                                                                                  
        cleanUp();                                                                                                                                                
        return;                                                                                                                                                
    end 
    for index = 1:trainingRounds
        azimuth = azimuthDirections(trainingIndeces(index));
        elevation = elevationDirections(trainingIndeces(index));
        stimulus = stimulusData.getStimulusForDirection(azimuth,elevation);
        javaGUI.mTrainingResolution = trainingResolutions(index);
        trainingResults{index} = javaGUI.startSingleTraining(azimuth,elevation,stimulus);
        if (trainingResults{index}.abort == 1)                                                                                                                    
            cleanUp();                                                                                                                                               
            return;                                                                                                                                                  
        end  
    end
    javaGUI.fullReset();
    
    %% test
    abort = javaGUI.showAndStopTillUserReady();                                                                                                                     
    if (abort == 1)                                                                                                                                                  
      cleanUp();                                                                                                                                                
      return;                                                                                                                                                
    end 
    for index = 1:testRounds
        azimuth = azimuthDirections(trainingIndeces(index));
        elevation = elevationDirections(trainingIndeces(index));
        stimulus = stimulusData.getStimulusForDirection(azimuth,elevation);
        [results{index}] = javaGUI.startSingleListeningTest(180,90,stimulus);
        if (results{index}.abort == 1)                                                                                                                    
            cleanUp();                                                                                                                                               
            return;                                                                                                                                                  
        end  
    end

    %% clean up
    javaGUI.closeGUI();
    clear javaGUI
    
    varargout{1} = trainingResults;
    varargout{2} = results;

end

function cleanUp()
     global javaGUI;                                                                                                                                                 
     javaGUI.closeGUI();
     clear javaGUI;                                                                                                                                               
 end   
