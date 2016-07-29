function ita_menucallback_ImpulseStartDetection(hObject, event)
%ita_time_shift(); 

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

ita_setinbase('ANS',ita_time_shift(ita_getfrombase,'30dB'));
ita_getfrombase;
end