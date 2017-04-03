function test_ita_portaudio

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% test if playrec works in general, only if it's there
if exist('playrec','file')
		a = playrec('isInitialised');
end

%% also test portaudio monitor
ita_portaudio_monitor('init',[2 3]);
ita_portaudio_monitor('update',[-0 0 0 0 0].');
ita_portaudio_monitor('update',[-60 -20 -80 -30 -20].');

end