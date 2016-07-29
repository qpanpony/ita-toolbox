function  test_ita_loudness()

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>



% test for the external mex file
if exist(['DIN45631.' mexext],'file') ~= 3
    comeFrom = pwd;
    cd([fileparts(which(mfilename)) filesep 'private' filesep ]);
    mex DIN45631.c
    cd(comeFrom);
end

pink = ita_generate('pinknoise', 122,44100,13);
pink.channelUnits = {'Pa'};

%% use fft
[N NS] = ita_loudness(pink,'SoundFieldType','free', 'mode', 'fft');

% according to DIN 45631: 95.09 soneGF
if abs((95.09 -N.value)/95.09) > 0.05
    error('Something went wrong. Result wrong!')
end

%% use filter
[N NS] = ita_loudness(pink,'SoundFieldType','free', 'mode', 'filter');

% according to DIN 45631: 95.09 soneGF
if abs((95.09 -N.value)/95.09) > 0.05
    error('Something went wrong. Result wrong!')
end





% %% TEST DIN WITHOUT FILTER
% calcN = zeros(1,7);
% sollN = [32 16 8 4 2 1 0.4];;
% for iTest = 1:7
%     L = 100 - iTest*10;
%     LT = [zeros(1,12) L-80   L-60  L-40  L-20   L L-20 L-40  L-60  L-80 zeros(1,7)];
%     [calcN(iTest) NS] = DIN45631(LT, 0);
% end
% 

    



