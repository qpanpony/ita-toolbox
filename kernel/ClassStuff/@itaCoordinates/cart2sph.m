function this = cart2sph(this)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if strcmp(this.mCoordSystem,'cart')
    x = this.mCoord(:,1);
    y = this.mCoord(:,2);
    z = this.mCoord(:,3);
    % apply builtin transformation
    [phiMod, thetaMod, r] =  cart2sph(x,y,z);
    % phi = 0..2*pi
    % theta = 0..pi
    phi = mod(phiMod, 2*pi);
    theta = pi/2 - thetaMod;
    this.mCoord = [r theta phi];
    this.mCoordSystem = 'sph';
end
end
