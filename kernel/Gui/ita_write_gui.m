function varargout = ita_write_gui(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


ele = 1;
pList{ele}.description = 'itaAudio';
pList{ele}.helptext    = 'What do you want to save?';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';

ele = 2;
pList{ele}.datatype    = 'line';

ele = 3;
pList{ele}.description = 'FileName';
pList{ele}.helptext    = 'Where do you want to save?';
pList{ele}.datatype    = 'setfile';
pList{ele}.filter      = '*.ita; *.spk; *.dat; *.wav; *.mp3';
pList{ele}.default     = ita_preferences('DataPath');

pList = ita_parametric_GUI(pList,'ita_write');

if isempty(pList)
    return
else
    ita_write(pList{1},pList{2});
end

end