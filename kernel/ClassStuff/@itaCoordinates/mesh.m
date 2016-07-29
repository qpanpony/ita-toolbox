function varargout = mesh(this, varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

dt = DelaunayTri(this.cart);
hFig = tetramesh(dt,varargin{:});
axis equal vis3d
if nargout
    varargout = {hFig};
else
    varargout = {};
end
end