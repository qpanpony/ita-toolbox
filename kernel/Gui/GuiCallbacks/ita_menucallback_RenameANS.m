function ita_menucallback_RenameANS(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


ele = 1;
pList{ele}.description = 'Current itaAudio (ANS)';
pList{ele}.helptext    = 'Rename this itaAudio';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';

ele = 2;
pList{ele}.description = 'New variable name';
pList{ele}.helptext    = 'Rename this itaAudio';
pList{ele}.datatype    = 'itaAudioResult';
pList{ele}.default     = '';

pList = ita_parametric_GUI(pList,'Rename current itaAudio variable');

if ~isempty(pList)
    ita_setinbase(pList{2},pList{1});
end


end