function [ varargout ] = comet3(this,varargin )

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

[hFig, frames] = PlotComet_3D(this.x, this.y, this.z, varargin{:});
if nargout
   varargout = {hFig,frames};
else
    varargout = {};
end

end

