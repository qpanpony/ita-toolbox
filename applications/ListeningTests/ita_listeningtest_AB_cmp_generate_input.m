function ltData = ita_listeningtest_AB_cmp_generate_input()

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%%% INITIALIZATION OF GUI INPUT DATA
br = sprintf('\n');

% General parameters
ltData.figureName        = 'Listening Test';
ltData.introText         = [ 'Herzlich Willkommen zum Hörversuch' br br ...
                             'Im Rahmen dieses Hörversuches bekommen sie Paare von raumakustischen Auralisation' br ...
                             'vorgespielt, wobei Sie für jedes Paar entscheiden sollen, welche Auralisation realistischer klingt.' br br ...
                             'Sie können zusätzlich angeben anhand welcher Diskriminierungsmerkmale sie Ihre Entscheidung getroffen haben.'];
ltData.introButtonString = 'Hörversuch starten';

ltData.doPracticeRun     = true;
ltData.practiceRunText   = ['Vor Beginn des eigentlichen Hörversuches, ' br ...
                            'werden Ihnen nun alle Signale des Paarvergleiches einmalig vorgespielt.' br br ...
                            'Nach dem Vorspielen aller Signale können einzelne durch Anklicken nochmals abgespielt werden.'];

ltData.compareQuestion   = 'Welcher der beiden dargebotenen Stimuli klingt realistischer';

% attribute parameters
ltData.useAttributes     = true;
ltData.attributes        = {'Lokalisation', 'Halligkeit' 'Artefakte'};
ltData.attribQuestion    = 'Anhand welcher Merkmale wurde die Entscheidung getroffen?';

% sound files
ltData.soundList         = {[ ita_toolbox_path '\applications\ListeningTests\TestFiles\flatnoise.wav' ], ...
                            [ ita_toolbox_path '\applications\ListeningTests\TestFiles\pinknoise.wav' ], ...
                            [ ita_toolbox_path '\applications\ListeningTests\TestFiles\impulsetrain.wav' ], ...
                            [ ita_toolbox_path '\applications\ListeningTests\TestFiles\sinus.wav' ]};
ltData.nSounds           = numel(ltData.soundList);                       

ltData.endText           = 'Danke für die Teilnahme am Hörversuch.';
ltData.showProgress      = true;

% play parameters                       
ltData.pauseBetween      = 0.5;
ltData.ABrepetitions     = 1;
ltData.playBackAmpFactor = 1;
ltData.frameSize = 4096; % FrameSize must be even!!!!
ltData.nFadeFrames = 2;
ltData.fadeType = 'inoutFade';   % 'inoutFade' or 'xfade'

% save results
ltData.savePath          = 'E:\EigeneDateien_ITA\Tmp\HV_Test';
ltData.writeLogFile      = true;
