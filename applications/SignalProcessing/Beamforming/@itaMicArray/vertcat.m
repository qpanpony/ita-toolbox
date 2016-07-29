function varargout = vertcat(varargin)

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

result = vertcat@itaMeshNodes(varargin{:});
tmpWeights = varargin{1}.w(:);
varargin(1) = [];
while numel(varargin) > 0
    tmpWeights = [tmpWeights(:); varargin{1}.w(:)];
    varargin(1) = [];
end
% make sure the sum of the weights is 1
result.w = tmpWeights./(sum(tmpWeights(:)));
varargout = {result};
end
