function test_ita_parametric_GUI

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


clear pList
idx = 0;

idx = idx+1;
pList{idx}.description = 'Numerator spectrum'; %this text will be shown in the GUI
pList{idx}.helptext    = 'This is the spectrum on top'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'itaAudio'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = 'a'; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.defaultchannels  = 1:3; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.class  = 'itaAudio'; %specify class of objects (default itaSuper, use itaAudio to get only itaAudios)

idx = idx+1;
pList{idx}.datatype    = 'line'; %just draw a simple line

%the following two are firstly optional - these are not returning any
%values, just used to help the user

idx = idx+1;
pList{idx}.description = 'showInfo'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Show some verbose Info'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = true; %default value, could also be empty, otherwise it has to be of the datatype specified aboveidx = idx+1;

pList{3}.datatype    = 'line'; %just draw a simple line


idx = idx+1;
pList{idx}.description = 'Test String'; %this text will be shown in the GUI
pList{idx}.helptext    = 'This value specifies the maximum for the limitation, some kind of regularization'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = 'hallo'; %default value, could also be empty, otherwise it has to be of the datatype specified above


idx = idx+1;
pList{idx}.description = 'Just a simple text'; %this text will be shown in the GUI
pList{idx}.datatype    = 'text'; %only show text
pList{idx}.color       = [0 0.5 1];

pList{5}.description = 'Test String'; %this text will be shown in the GUI
pList{5}.helptext    = 'This value specifies the maximum for the limitation, some kind of regularization'; %this text should be shown when the mouse moves over the textfield for the description
pList{5}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
pList{5}.default     = 'hallo'; %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'Limiter'; %this text will be shown in the GUI
pList{idx}.helptext    = 'This value specifies the maximum for the limitation, some kind of regularization'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = 100; %default value, could also be empty, otherwise it has to be of the datatype specified above


pList{6}.description = 'Just a simple text'; %this text will be shown in the GUI
pList{6}.datatype    = 'text'; %only show text
pList{6}.color       = [0 0.5 1];


idx = idx+1;
pList{idx}.description = 'MIsc+spectrum'; %this text will be shown in the GUI
pList{idx}.helptext    = 'This is the spectrum for nothing'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'itaAudio'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = 1; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.color       = [0 1 1];

idx = idx+1;
pList{idx}.description = 'Preferences'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Call ita_preferences'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'simple_button'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.callback    = 'ita_preferences';
pList{idx}.buttonname  = 'Preferences'; %this is optional

idx = idx+1;
pList{idx}.description = 'select channels'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Call ita_preferences'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'int_result_button'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.callback    = 'ita_channelselect_GUI';

idx = idx+1;
pList{idx}.description = 'dev id channels'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Call ita_preferences'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'char_result_button'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.callback    = 'ita_portaudio_deviceID2string(1)';

idx = idx+1;
pList{idx}.description = 'select mode'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select Rohrbert Output'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.list        = 'Abs|Ref|Imp|Adm|Tau|SI|Allrefl|All';
pList{idx}.default     = 'Allrefl'; %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'select a number'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select some number'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'int_popup'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.list        = [1 3 5 7 29 673];
pList{idx}.default     = 7; %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'Path to your thing'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select your special path'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'path'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.filter    = ''; %Filter
pList{idx}.default     = pwd; %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'Long int field'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select your special int_long'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'int_long'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = [100 0 50 60 40];

idx = idx+1;
pList{idx}.description = 'Long char field'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select your special int_long'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'char_long'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = 'long char';

idx = idx+1;
pList{idx}.description = 'Save Result as'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select var to save result'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = '';

idx = idx+1;
pList{idx}.description = 'Path to your file'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select your special path'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'getfile'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.filter    = '*.m'; %Filter
pList{idx}.default     = which('ita_preferences'); %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'Path to save something'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select your special path'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'setfile'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.filter    = '*.ita; *.spk; *.dat'; %Filter
pList{idx}.default     = [pwd filesep 'test.tmp']; %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'This is simple text'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select your simple text'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.text        = ['Here comes more text, and color also work now!']; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.datatype    = 'simple_text';
pList{idx}.color       = [0 0.5 1];

idx = idx+1;
pList{idx}.description = 'Write something'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Write what you want'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'textfield';
pList{idx}.default     = 'Here goes lots of text';
pList{idx}.height      = 3; % Height (in number of GUI element rows)

idx = idx+1;
pList{idx}.description = 'This is simple text'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select your simple text'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'slider';
pList{idx}.range       = [0 1];
pList{idx}.default     = [0];

name = 'ita_add';

%% Call GUI
a = ita_generate('noise',1,44100,16);
a = ita_merge(ita_merge(a,a),ita_merge(a,a));

b = ita_generate('noise',2,44100,16);
    

[pOutList1 po2] = ita_parametric_GUI(pList,name,'wait','off','return_handles',true); % RSC - No user entry on test ita_all! If you use this function for debuging etc make a local copy!
close(gcf);
end