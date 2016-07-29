function varargout = vertcat(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

coordSystem = varargin{1}.mCoordSystem;
result = varargin{1};
varargin(1) = [];
while numel(varargin) > 0    
    result.(coordSystem) = [result.(coordSystem); varargin{1}.(coordSystem)];
    varargin(1) = [];
end
varargout = {result};
end