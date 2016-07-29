

% <ITA-Toolbox>
% This file is part of the application Microflown for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Environmental parameters
temp = 20; % change according to measured values
humid = 0.50; % change according to measured values

[c,rho0] = ita_constants({'c','rho_0'},'T',temp,'phi',humid);

