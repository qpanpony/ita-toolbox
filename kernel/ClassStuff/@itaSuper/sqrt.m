function varargout = sqrt(varargin)
%calculate sqrt of internal data, in current domain

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(1,1);
isfreq = isFreq(varargin{1});
for ind = 1:numel(varargin{1})
    if isfreq(ind)
        varargout{1}(ind) = mpower(varargin{1}(ind),0.5);
    else
        varargout{1}(ind) = power(varargin{1}(ind),0.5);
    end        
end

end