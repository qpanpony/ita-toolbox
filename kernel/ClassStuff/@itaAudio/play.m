function play(this)
%just play time signal with soundcard

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if this.nChannels == 0
   disp('No data for playback'); 
   return;
end
if exist('ita_portaudio.m','file')
    ita_portaudio(this);
else
    sound(this.time, this.samplingRate);
end