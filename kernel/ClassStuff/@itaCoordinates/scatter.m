function varargout = scatter(this, varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

hFig = scatter3(this.x, this.y, this.z, varargin{:});
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal vis3d
if nargout
   varargout = {hFig};
else
    varargout = {};
end

end