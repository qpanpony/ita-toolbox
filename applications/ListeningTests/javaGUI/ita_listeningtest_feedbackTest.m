function [ output_args ] = ita_listeningtest_feedbackTest( input_args )
%ITA_LISTENINGTEST_FEEDBACKTEST Summary of this function goes here
%   Detailed explanation goes here

javaGUI = itaListeningTestGUI;

% upper and lower limit for sphere
javaGUI.setControllerLimits(0,180);

% trainAzimuth,trainElevation,userAzimuth,userElevation,timeout in seconds
javaGUI.showFeedbackAndWait(20,90,0,80,5)

javaGUI.setViewAzimuthAngle(80);

%different direction and time
javaGUI.showFeedbackAndWait(20,90,10,80,5)




end

