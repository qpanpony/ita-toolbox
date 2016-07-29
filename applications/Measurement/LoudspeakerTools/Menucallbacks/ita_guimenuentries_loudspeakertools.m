function itamenu = ita_guimenuentries_loudspeakertools()
% Defines Combinedsimulation GUI menu entries

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


idx = 1; % Add to end of list
itamenu{idx}.type = 'submenu';
itamenu{idx}.text = 'Loudspeaker Tools';
itamenu{idx}.parent = 'Applications';


idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Thiele Small Parameters';
itamenu{idx}.parent = 'Loudspeaker Tools';


idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Freefield Response';
itamenu{idx}.parent = 'Loudspeaker Tools';


idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Combine Nearfield and Farfield Measurements';
itamenu{idx}.parent = 'Loudspeaker Tools';


idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'THD';
itamenu{idx}.parent = 'Loudspeaker Tools';

end