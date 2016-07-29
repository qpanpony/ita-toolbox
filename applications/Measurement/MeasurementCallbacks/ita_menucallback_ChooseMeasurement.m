function ita_menucallback_ChooseMeasurement(hObject, eventdata) %#ok<INUSD>
% nice GUI to show all MS

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% ask for current ms - or generate a new one
MS = ita_guisupport_measurement_get_global_MS; %#ok<NASGU>

%% get all ms
list_of_var = evalin('base','whos'); % list of workspace variables
MSlist = [];
for idx  = 1:numel(list_of_var)
    if evalin('base',['isa(' list_of_var(idx).name ',''itaMSRecord'');'])
        %         disp([list_of_var(idx).name ' added']); % only for checking        
        MSlist{end+1} = list_of_var(idx).name; %#ok<AGROW>
    end
end

listStr = '';
for idx = 1:numel(MSlist)
    listStr = [listStr MSlist{idx} '|']; %#ok<AGROW>
end
listStr(end) = [];

%% get name of current MS
actMS = ita_getfrombase('actMS');

%% gui stuff
pList = [];
ele = 1;
pList{ele}.description = 'Choose Measurement Setup'; %this text will be shown in the GUI
pList{ele}.helptext    = 'Select the Measurement Setup you want to edit, or work with'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.list        = listStr;
pList{ele}.default     = actMS; %default value, could also be empty, otherwise it has to be of the datatype specified above

actMS = ita_parametric_GUI(pList,'Choose a MeasurementSetup');

ita_setinbase('actMS', actMS{1});

end