function [ output_args ] = ita_listeningtest_guiTest( input_args )
%ITA_LISTENINGTEST_GUITEST Summary of this function goes here
%   Detailed explanation goes here
    javaGUI = itaListeningTestGUI;
    javaGUI.mGLMode = 0;
    %javaGUI.mFullscreen = 1;
    % activate tracker
    javaGUI.mUserTracker = 0;
    
    javaGUI.setControllerLimits(0,180);
    abort = javaGUI.showAndStopTillUserReady();
    javaGUI.mTrainingResolution = 10;

    azimuthDirections = [0, 45, 90, 135, 180, 225, -90, -45, 0, 0, 180, 180];
    elevationDirections = [90, 90, 90, 90, 90, 90, 90, 90, 110, 60, 110, 60];
    
    for index = 1:length(azimuthDirections)
        results = javaGUI.startSingleTraining(azimuthDirections(index),elevationDirections(index),itaAudio());
    end
end
