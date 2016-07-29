function this = sph2cart(this)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if strcmp(this.mCoordSystem,'sph')
    r = this.mCoord(:,1);
    theta = this.mCoord(:,2);
    phi = this.mCoord(:,3);
    % apply builtin transformation
    [x,y,z] = sph2cart(phi, pi/2 - theta, r);
    this.mCoord = [x y z];
    this.mCoordSystem = 'cart';
end
end
