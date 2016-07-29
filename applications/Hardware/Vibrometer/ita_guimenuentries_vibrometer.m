function itamenu = ita_guimenuentries_vibrometer()
% ITA_GUIMENUENTRIES_VIBROMETER - create gui menu entries for laser
% vibrometer

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    idx = 1;
    itamenu{idx}.type   = 'submenu';
    itamenu{idx}.text   = 'Laser Vibrometer';
    itamenu{idx}.parent = 'Applications';
    
%     idx = idx+1;
%     itamenu{idx}.type   = 'function';
%     itamenu{idx}.text   = 'Laser Hardware Settings';
%     itamenu{idx}.parent = 'Laser Vibrometer';
    
end