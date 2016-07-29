function itamenu = ita_guimenuentries_nonlinear()
% Defines Combinedsimulation GUI menu entries

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


idx = 1; % Add to end of list
itamenu{idx}.type = 'submenu';
itamenu{idx}.text = 'Nonlinearities';
itamenu{idx}.parent = 'Applications';


idx = idx+1;
itamenu{idx}.type   = 'function';
itamenu{idx}.text   = 'Polynomial Series';
itamenu{idx}.parent = 'Nonlinearities';


end