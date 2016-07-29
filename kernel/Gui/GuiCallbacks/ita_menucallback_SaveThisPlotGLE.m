function ita_menucallback_SaveThisPlotGLE(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

ita_savethisplot_gle('fgh', ita_guisupport_getParentFigure(hObject))
end