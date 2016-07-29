function this = flip_half_sphere(this)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

    this.theta = mod(pi-this.theta,2*pi);
    this.phi = mod(2*pi-this.phi,2*pi);

end