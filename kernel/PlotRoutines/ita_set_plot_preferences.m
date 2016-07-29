function default = ita_set_plot_preferences

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% get matlab defaults
default.color_table = get(0,'DefaultAxesColorOrder');
default.font_size   = get(0,'defaultaxesfontsize');

if ~isempty(ita_preferences('colorTableName'))
    colorTableMatrix = ita_plottools_colortable(ita_preferences('colorTableName'));
    set(0,'DefaultAxesColorOrder',colorTableMatrix)
%   cprintf('blue','ita toolbox color table is loaded. \n')
end
if ~isempty(ita_preferences('fontsize'))
    set(0,'defaultaxesfontsize',ita_preferences('fontsize'));
%   cprintf('blue','ita toolbox font size is loaded. \n')
end