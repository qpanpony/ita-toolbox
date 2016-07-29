function ita_menucallback_domainselect(hObject, eventdata)
% Callback routine for click on a var in the menu list

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

newdomain = get(hObject,'Label');
ita_guisupport_currentdomain(newdomain) % Set selected domain


% menu reset selection
topmenu = get(hObject,'Parent'); % Top menu

listofsubs = get(topmenu,'Children');

% % % for idx = 1:numel(listofsubs)
% % %    Label = get(listofsubs(idx),'Label');
% % %    if strcmpi(Label,newdomain)
% % %        set(listofsubs(idx),'Checked','on');
% % %    else
% % %        set(listofsubs(idx),'Checked','off');
% % %    end
% % % end

% avoid loop
% update check sign of cuurrent domain
idxActive = strcmpi(get(listofsubs,'Label'), newdomain);
set(listofsubs(idxActive),'Checked','on');
set(listofsubs(~idxActive),'Checked','off');

% update plot 
ita_guisupport_updateGUI(ita_guisupport_getParentFigure(hObject))

end