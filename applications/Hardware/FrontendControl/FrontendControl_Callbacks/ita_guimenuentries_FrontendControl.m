function itamenu = ita_guimenuentries_FrontendControl()
% Defines GUI menu entries for FrontendControl app

% <ITA-Toolbox>
% This file is part of the application FrontendControl for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


idx = 1; % Add to end of list
itamenu{idx}.type = 'submenu';
itamenu{idx}.text = 'Frontend Control';
itamenu{idx}.parent = 'Applications';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Robo Control';
itamenu{idx}.parent = 'Frontend Control';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'ModulITA Control';
itamenu{idx}.parent = 'Frontend Control';

idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Aurelio Control';
itamenu{idx}.parent = 'Frontend Control';

end