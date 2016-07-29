function [ pListout ] = ita_laboratory_V2_gui()
%Gives an input GUI to fill in the material and the thickness

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>



%% setup Gui
clear pList
idx = 0;

%Group / 1
idx = idx+1;
pList{idx}.description = 'Group'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Put in groupnumber for the filename'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = 1; %default value, could also be empty, otherwise it has to be of the datatype specified above

%Material / 2
idx = idx+1;
pList{idx}.description = 'Material'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select the material you put between both rooms'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.list        = 'MDF|Aluminium|Messing|Doppelwand|Oeffnung';
pList{idx}.default     = 'MDF'; %default value, could also be empty, otherwise it has to be of the datatype specified above

%Thickness / 3
idx = idx+1;
pList{idx}.description = 'Thickness in mm'; %this text will be shown in the GUI
pList{idx}.helptext    = 'This value is for the size of the material in millimeters'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = '10'; %default value, could also be empty, otherwise it has to be of the datatype specified above

% Density / 4
idx = idx+1;
pList{idx}.description = 'Plate Density'; %this text will be shown in the GUI
pList{idx}.helptext    = 'This value is for the density of the plate '; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = '618'; %default value, could also be empty, otherwise it has to be of the datatype specified above

% Youngs Modulus / 5
idx = idx+1;
pList{idx}.description = 'Youngs Modulus'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Youngs Modulus for the plate'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = '3.2e9'; %default value, could also be empty, otherwise it has to be of the datatype specified above


%Safe-path / 6
idx = idx+1;
pList{idx}.description = 'Path to your thing'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select your special path'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'path'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.filter    = ''; %Filter
pList{idx}.default     = pwd; %default value, could also be empty, otherwise it has to be of the datatype specified above
idx = idx+1;

% Line
pList{idx}.datatype    = 'line'; %just draw a simple line'
idx = idx+1;

%fftDegree / 7
pList{idx}.description = 'FFT-Degree'; %this text will be shown in the GUI
pList{idx}.helptext    = 'How long to measure?'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = 16; %default value, could also be empty, otherwise it has to be of the datatype specified above
idx = idx+1;

%sourcePositions / 8
pList{idx}.description = 'No. of Source Positions'; %this text will be shown in the GUI
pList{idx}.helptext    = 'How many source positions?'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = 1; %default value, could also be empty, otherwise it has to be of the datatype specified above

pListout = ita_parametric_GUI(pList,'Laboratory_V2','wait','on','return_handles',true);
end

