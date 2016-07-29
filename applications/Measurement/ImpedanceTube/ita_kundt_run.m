function varargout = ita_kundt_run(hObject, eventdata)
%ITA_KUNDT_RUN - Only for use by ita_kundt_gui

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(2,2);
name = get(hObject,'String');

%% Get probe name
fighandle = get(hObject,'Parent');
allHandles = get(fighandle,'UserData');
probename = get(allHandles{1}.ProbeName,'String');

%% Run measurement
MS = ita_getfrombase('Kundt_Measurement_Setup');
disp(['Probename: ' probename]);
disp(['Mikrofon:  ' name]);

result = MS.run;
result = ita_split(result,1); % ToDo - Can that be smarter?
result.channelNames{1} = name;
result.comment = probename;

thisfar = ita_getfrombase('Kundt_Raw_Data');

if ~isempty(thisfar)
    % Seperate the channels we want to keep
    [trash, thisfar] = ita_split(thisfar,name);
    
    % Merge
    if ~isempty(thisfar) && thisfar.nChannels > 0
        result = ita_merge(result,thisfar);
    else
        % Do nothing result = result;
    end
end

% Sort Channels
result = ita_sort_channels(result);

% Store in base workspace
ita_setinbase('Kundt_Raw_Data',result);

end