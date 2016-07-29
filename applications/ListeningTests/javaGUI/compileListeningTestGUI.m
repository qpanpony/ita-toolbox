function [ output_args ] = compileListeningTestGUI( input_args )
%COMPILETESTPACKAGEJRI Summary of this function goes here
%   Detailed explanation goes here

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

compile('ita/listeningTestGUI/ColorClass.java');
compile('ita/listeningTestGUI/MatlabEventWrapper.java');
compile('ita/listeningTestGUI/MarkedStruct.java');
compile('ita/listeningTestGUI/abstractInput.java');
compile('ita/listeningTestGUI/MouseInput.java');
compile('ita/listeningTestGUI/KeyboardInput.java');
compile('ita/listeningTestGUI/ControllerInput.java');
compile('ita/listeningTestGUI/InputEvent.java');
compile('ita/listeningTestGUI/MainGLWindowBasis.java');
compile('ita/listeningTestGUI/BasisGLMode.java');
compile('ita/listeningTestGUI/BlockGLMode.java');
compile('ita/listeningTestGUI/ListeningTestMain.java');


end

