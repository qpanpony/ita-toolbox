pList = [];

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

ele = numel(pList)+1;
pList{ele}.datatype    = 'text';
pList{ele}.description = ['File Settings'];

ele = numel(pList)+1;
pList{ele}.description = 'Input Folder'; %this text will be shown in the GUI
pList{ele}.helptext    = 'Select your input folder'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'path'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.filter      = ''; %Filter
pList{ele}.default     = pwd; %default value, could also be empty, otherwise it has to be of the datatype specified above

ele = numel(pList)+1;
pList{ele}.description = 'Output folder'; %this text will be shown in the GUI
pList{ele}.helptext    = 'Select your output folder. Leave blank -> subdirectory batch_processor will be created'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'path'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.filter      = ''; %Filter
pList{ele}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above

ele = numel(pList)+1;
pList{ele}.description = ['File Mask']; %this text will be shown in the GUI
pList{ele}.helptext    = 'Only use the files of this description'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = '*.ita'; %default value, could also be empty, otherwise it has to be of the datatype specified above

ele = numel(pList)+1;
pList{ele}.description = ['Save File Format']; %this text will be shown in the GUI
pList{ele}.helptext    = 'save in this file format'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = 'ita'; %default value, could also be empty, otherwise it has to be of the datatype specified above

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

ele = numel(pList)+1;
pList{ele}.datatype    = 'text';
pList{ele}.description = ['Script'];

ele = numel(pList)+1;
pList{ele}.description = ['Script']; %this text will be shown in the GUI
pList{ele}.helptext    = 'Filename of your script. Will be created if not existent'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
authorStr = ita_preferences('AuthorStr');
authorStr = authorStr(isstrprop(authorStr,'alpha'));
pList{ele}.default     = [ 'test_' authorStr '_batch.m']; %default value, could also be empty, otherwise it has to be of the datatype specified above

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';
  
%% call GUI
pList = ita_parametric_GUI(pList,['ita_batch_processor']);

%% check arguments
if isempty(pList)
    return;
end

sArgs.inputfolder   = pList{1};
sArgs.outputfolder  = pList{2};
sArgs.filemask      = pList{3};
sArgs.saveformat    = pList{4};
sArgs.scriptname    = pList{5};

if ~exist(sArgs.scriptname,'file')
    cd (sArgs.inputfolder)
    copyfile(which('testBatchScript.m'),sArgs.scriptname);
end
edit(sArgs.scriptname)

f = warndlg('Ready to run the batch NOW?','ita_batch_processor');
uiwait(f);

ita_batch_processor(sArgs.scriptname,'inputfolder',sArgs.inputfolder,'outputfolder',sArgs.outputfolder,'filemask',sArgs.filemask,'saveformat',sArgs.saveformat);
