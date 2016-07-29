function ita_ChooseMeasurement_gui()

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

list = ita_getfrombase('MSlist');
actMS = ita_getfrombase('actMS');


listStr = '';
for idx = 1:numel(list)
    listStr = [listStr '|' list{idx}]; %#ok<AGROW>
end
%listStr(end) = [];


%% gui stuff
pList = [];
ele = 1;
pList{ele}.description = 'Choose actual Measurement Setup'; %this text will be shown in the GUI
pList{ele}.helptext    = 'Select the Measurement whitch You want tu edit, or work with'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.list        = listStr;
pList{ele}.default     = actMS; %default value, could also be empty, otherwise it has to be of the datatype specified above

actMS = ita_parametric_GUI(pList,'Choose a MeasurementSetup');

ita_setinbase('actMS', actMS(1));

end