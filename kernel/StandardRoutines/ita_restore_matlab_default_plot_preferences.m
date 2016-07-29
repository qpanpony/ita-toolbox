function ita_restore_matlab_default_plot_preferences(default)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% get matlab defaults
set(0,'DefaultAxesColorOrder',default.color_table)
set(0,'defaultaxesfontsize',default.font_size)
