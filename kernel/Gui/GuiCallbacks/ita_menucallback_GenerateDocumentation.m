function ita_menucallback_GenerateDocumentation(hObject, eventdata)
% opens the ita_generate_documentation.m

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

handle = helpdlg('Generating documentation. This might take several minutes.');
ita_generate_documentation();

if ishandle(handle)
    close(handle)
end
end