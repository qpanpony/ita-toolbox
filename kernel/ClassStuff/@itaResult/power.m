function varargout = power(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if any(isFreq(varargin{1}))
    error('itaResult.power:your signals are not in the time domain, use operator ^ instead!');
end
varargout = {power@itaSuper(varargin{:})};
end