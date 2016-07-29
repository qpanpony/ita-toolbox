function test_ita_backwardcompatibility
% %Should test if we are still able to read and work with old MF files 
% 

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

a = ita_read(which('AD22-1.SPK'));
% 
% close(f1);
% close(f2);
end