function this = repmat(this,n) 
% Repmat for itaCoordinates

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

this.mCoord = repmat(this.mCoord,[n,1]);

end
