function varargout = ifft(varargin)
% normalized IFFT

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% writing to varargin ensures identical dimensions for in- and output
for ind = 1:numel(varargin{1})
    varargin{1}(ind) = ita_ifft(varargin{1}(ind));
end
varargout{1} = varargin{1};