function ita_menucallback_DeleteCurrentObject(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

name = ita_inuse;

% TODO, delete a global Variable
evalin('base', ['clear ' name]);
end