function itamenu = ita_guimenuentries_roomacoustics()
% ITA_GUIMENUENTRIES_ROOMACOUSTICS - Defines Room Acoustics menu entries

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


idx = 1; % Add to end of list
itamenu{idx}.type = 'submenu';
itamenu{idx}.text = 'Room Acoustics';
itamenu{idx}.parent = 'Applications';


% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'ISO 3382 - Measurement';
% itamenu{idx}.parent = 'Room Acoustics';

% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'Impulse Start Detection';
% itamenu{idx}.parent = 'Room Acoustics';
% itamenu{idx}.separator = true;

% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'Fractional Octave Bands';
% itamenu{idx}.parent = 'Room Acoustics';

% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'IR end Detect';
% itamenu{idx}.parent = 'Room Acoustics';

% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'Energy Decay Curve - Schroeder Backwards Integration';
% itamenu{idx}.parent = 'Room Acoustics';

% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'Reverberation Time';
% itamenu{idx}.parent = 'Room Acoustics';


% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'Interaural Cross Correlation';
% itamenu{idx}.parent = 'Room Acoustics';
% 
% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'Lateral Fraction';
% itamenu{idx}.parent = 'Room Acoustics';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Room Acoustic';
itamenu{idx}.parent = 'Room Acoustics';
itamenu{idx}.separator = true;

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Room Acoustic Default Parameters';
itamenu{idx}.parent = 'Room Acoustics';

% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'Reverberation Chamber Absorption Coefficient';
% itamenu{idx}.parent = 'Room Acoustics';

% idx = idx+1;
% itamenu{idx}.type   = 'function';
% itamenu{idx}.text   = 'Sound Power';
% itamenu{idx}.parent = 'Room Acoustics';

end