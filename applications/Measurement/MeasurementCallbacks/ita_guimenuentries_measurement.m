function itamenu = ita_guimenuentries_measurement()
% ITA_GUIMENUENTRIES_MEASUREMENT - Defines Measurement Menu entries

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


idx = 1;
itamenu{idx}.type   = 'submenu';
itamenu{idx}.text   = 'Measurement';
itamenu{idx}.parent = '';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'New Measurement Setup';
itamenu{idx}.parent = 'Measurement';
%itamenu{idx}.separator = true;

idx = idx+1;
itamenu{idx}.type   = 'function'; % evtl Varlist
itamenu{idx}.text   = 'Choose Measurement';
itamenu{idx}.parent = 'Measurement';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Edit Measurement';
itamenu{idx}.parent = 'Measurement';
%itamenu{idx}.separator = true

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Calibrate Measurement';
itamenu{idx}.parent = 'Measurement';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Run Measurement';
itamenu{idx}.parent = 'Measurement';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Run Measurement 2File';
itamenu{idx}.parent = 'Measurement';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Measuring Station Preferences';
itamenu{idx}.parent = 'Measurement';
itamenu{idx}.separator = true;

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'New Measuring Station';
itamenu{idx}.parent = 'Measurement';
end