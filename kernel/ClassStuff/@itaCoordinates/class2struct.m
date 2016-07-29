function result = class2struct(this)
%Convert to struct that can be read by the constructor

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

result.classname = class(this);
result.classrevision = this.classrevision;
result.coordsystem = this.mCoordSystem;
result.coord = this.mCoord;
end