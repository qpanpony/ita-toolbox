function disp(this)
% Display number of stored orientations and used coordinate system
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

disp(['    size(nPoints) = [' num2str(size(this.mOrient,2)) ']'])
disp(['    coordSystem = ''' this.mCoordSystem ''''])
end
