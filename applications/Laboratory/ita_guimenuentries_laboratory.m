function itamenu = ita_guimenuentries_laboratory()
% ITA_GUIMENUENTRIES_LABORATORY - gui menu entries for lab

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

idx = 1;
itamenu{idx}.type   = 'submenu';
itamenu{idx}.text   = 'Laboratory';
itamenu{idx}.parent = '';

%% Versuch 0
idx = idx+1;
itamenu{idx}.type   = 'submenu';
itamenu{idx}.text   = 'V0';
itamenu{idx}.parent = 'Laboratory';

%% Versuch 1
idx = idx+1;
itamenu{idx}.type   = 'submenu';
itamenu{idx}.text   = 'V1';
itamenu{idx}.parent = 'Laboratory';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Nachhall mit Rauschen';
itamenu{idx}.parent = 'V1';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Messsetup Editieren';
itamenu{idx}.parent = 'V1';
itamenu{idx}.separator = true;

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Messung starten';
itamenu{idx}.parent = 'V1';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Bandfiltern';
itamenu{idx}.parent = 'V1';
itamenu{idx}.separator = true;

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'EDC';
itamenu{idx}.parent = 'V1';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'T30';
itamenu{idx}.parent = 'V1';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Komplette Messung';
itamenu{idx}.parent = 'V1';
itamenu{idx}.separator = true;

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Kalibrierung';
itamenu{idx}.parent = 'V1';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Messung Schallleistung';
itamenu{idx}.parent = 'V1';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Oktaven und Schalleistung';
itamenu{idx}.parent = 'V1';

% %% Versuch 2
% idx = idx+1;
% itamenu{idx}.type   = 'submenu';
% itamenu{idx}.text   = 'V2';
% itamenu{idx}.parent = 'Laboratory';

%% Versuch 3
idx = idx+1;
itamenu{idx}.type   = 'submenu';
itamenu{idx}.text   = 'V3';
itamenu{idx}.parent = 'Laboratory';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Kundt''s Tube';
itamenu{idx}.parent = 'V3';

%% Versuch 5
idx = idx+1;
itamenu{idx}.type   = 'submenu';
itamenu{idx}.text   = 'V5';
itamenu{idx}.parent = 'Laboratory';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Ortskurve Festgebremst';
itamenu{idx}.parent = 'V5';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Ortskurve ohne Gehaeuse';
itamenu{idx}.parent = 'V5';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Ortskurve hohe Resonanz';
itamenu{idx}.parent = 'V5';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Ortskurve mit Gehaeuse (Ungedaempft)';
itamenu{idx}.parent = 'V5';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Ortskurve mit Gehaeuse (Gedaempft)';
itamenu{idx}.parent = 'V5';

end