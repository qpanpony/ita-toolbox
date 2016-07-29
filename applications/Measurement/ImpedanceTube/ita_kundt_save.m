function varargout = ita_kundt_save(varargin)
%ITA_KUNDT_SAVE - used by ita_kundt_gui

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

hObject = varargin{1};

%% Initialization and Input Parsing
kundtsetup = ita_getfrombase('Kundt_Kundt_Setup');

result.saverawdata = true;
result.saveresult = true;
result.savesetup = true;

%% Get probe name
fighandle = get(hObject,'Parent');
allHandles = get(fighandle,'UserData');
probename = get(allHandles{1}.ProbeName,'String');
projectpath = get(allHandles{1}.DataPath,'String');

%% Save
if ~isempty(kundtsetup)
    if kundtsetup.saverawdata
        result = ita_getfrombase('Kundt_Raw_Data');
        if ~isempty(result)
            filename = [projectpath filesep ita_guisupport_removewhitespaces(probename) '_raw.ita'];
            ita_write(result,filename);
        else
            disp('Raw_Data not found')
        end
    end
    if kundtsetup.saveresult
        result = ita_getfrombase('Kundt_Result');
        if ~isempty(result)
            filename = [projectpath filesep ita_guisupport_removewhitespaces(probename) '_result.ita'];
            ita_write(result,filename);
            else
            disp('Result not found')
        end
    end
    if kundtsetup.savesetup
        Kundt_Kundt_Setup = ita_getfrombase('Kundt_Kundt_Setup');
        Kundt_Measurement_Setup = ita_getfrombase('Kundt_Measurement_Setup');
        filename = [projectpath filesep ita_guisupport_removewhitespaces(probename) '_setup.mat'];
        save(filename,'Kundt_Kundt_Setup','Kundt_Measurement_Setup');        
    end
end


%end function
end