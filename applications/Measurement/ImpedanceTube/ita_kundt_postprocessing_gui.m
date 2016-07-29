function varargout = ita_kundt_postprocessing_gui(varargin)

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

  %ITA_KUNDT_POSTPROCESSING_GUI - GUI for calculations in Kundts Tube
  %
  %UNDER CONSTRUCTION TODO HUHU
  %
  %  Syntax:
  %   ita_kundt_postprocessing_gui()
  %
  %   Uses ita_kundt_postprocessingm2 and ita_dataselect_gui
  


  % Author: Ruth Herbertz -- Email: herbertz@akustik.rwth-aachen.de
  % Created:  20-oct-2010 

%% Get ITA Toolbox preferences and Function String


idx = 1;
pList{idx}.description = 'Data Select';
pList{idx}.datatype    = 'text';
idx = idx+1;


pList{idx}.description = 'Select Data'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Select raw from your current directory'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'char_result_button'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.callback    = 'ita_dataselect_gui()';

idx = idx+1;
pList{idx}.datatype    = 'line';

%% Number of Smooth Repetetions
idx = idx+1;
pList{idx}.description = 'Options';
pList{idx}.datatype    = 'text';

idx = idx+1;
pList{idx}.description = 'Number Of Smooth Repetitions';
pList{idx}.helptext    = 'Name of the probe';
pList{idx}.datatype    = 'int';
pList{idx}.default    = '5';

idx = idx+1;
pList{idx}.description = 'Remove Bad Measurements'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Removes results that make no sense'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = true; %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'Plot Single Windows'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Plots every line in a single window'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = false; %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'Plot All'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Plots every single measurement'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = false; %default value, could also be empty, otherwise it has to be of the datatype specified above


idx = idx+1;
pList{idx}.description = 'Plot Mean'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Plots the mean of all measurements belonging to one material'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = true; %default value, could also be empty, otherwise it has to be of the datatype specified above

idx = idx+1;
pList{idx}.description = 'Plot Std'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Plots the Standardvariation(if Plot Mean is true)'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = true;

idx = idx+1;
pList{idx}.description = 'Export Text-File'; %this text will be shown in the GUI
pList{idx}.helptext    = 'Writes a txt-File named "results.txt"'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
pList{idx}.default     = true;
idx = idx+1;
pList{idx}.datatype    = 'line';



%% Button
idx = idx+1;
pList{idx}.description = 'Plot '; %this text will be shown in the GUI
pList{idx}.helptext    = 'Plots '; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.datatype    = 'simple_button'; %based on this type a different row of elements has to be drawn in the GUI
pList{idx}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{idx}.callback    = @ita_kundt_postprocessingm2;

%idx = idx+1;
%pList{idx}.description = 'Plot All Mean'; %this text will be shown in the GUI
%pList{idx}.helptext    = 'Plots Mean out of clever named files above, only functions with naming like test1, test2 etc.'; %this text should be shown when the mouse moves over the textfield for the description
%pList{idx}.datatype    = 'simple_button'; %based on this type a different row of elements has to be drawn in the GUI
%pList{idx}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
%pList{idx}.callback    = @ita_kundt_postprocessingm2;

 varargout = ita_parametric_GUI(pList,'Kundt_Postprocessingm2','wait','off');
% ita_kundt_postprocessingm2
persistent hFig
if ~isempty(hFig) && ishandle(hFig) && strcmpi(get(hFig,'Name'),'Kundt_Postprocessing')
   close(hFig) 
end




end
