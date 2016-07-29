disp('*********** Uninstalling ITA-Toolbox for MATLAB *******************')

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

close all;
try
    ita_preferences('reset');
end
ita_delete_toolboxpaths;
disp('************************** DONE ! *********************************')