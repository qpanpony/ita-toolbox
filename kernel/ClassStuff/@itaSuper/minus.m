function varargout = minus(varargin)
% operation: minus

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(2,2);
if ~isa(varargin{1},'itaSuper')
    a = -varargin{2};
    b =  varargin{1};
else
    a =  varargin{1};
    b = -varargin{2};
end
 varargout{1} = plus(a, b, 'writeMinusInMetaData');

end