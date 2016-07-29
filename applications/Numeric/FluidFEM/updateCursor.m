function output_txt = updateCursor(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


pos = get(event_obj,'Position');
output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};

% ModeSolve: set(handles.freqSlide,'UserData',ModeSolveData);

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
    try
        handlesGUI = guidata(gcbo); % hole die handels von der gui
        fig = get(handlesGUI.figure1);
        if strcmp(fig.Name,'ita_GUIModeSolve')
            ModeSolve = get(handlesGUI.freqSlide,'UserData');
        elseif strcmp(fig.Name,'resultPlot')
            ModeSolve =  get(handlesGUI.nodeList,'UserData'); % dort stehen dann auch die meshdaten
        end
        posID = find( (ModeSolve.coord.cart(:,1)==pos(1)) & (ModeSolve.coord.cart(:,2)==pos(2)) & (ModeSolve.coord.cart(:,3)==pos(3)), 1); % suche nach den gewählten koordinaten
        if ~isempty(posID)
            output_txt{end+1} = ['ID: ',num2str(ModeSolve.coord.ID(posID),4)]; % ID nummer
        end
       
    end
end
