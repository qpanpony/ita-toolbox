function varargout = plus(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(2,3);
if ~isa(varargin{1},'itaResult')
    a = varargin{2};
    b = varargin{1};
else
    a = varargin{1};
    b = varargin{2};
    if isa(b,'itaResult')
        domainTypeA = a.domain;
        domainTypeB = b.domain;
        
        if domainTypeA ~= domainTypeB
            error('itaResult.plus:objects are not in the same domain!');
        end
    end
end
if nargin == 3 % use plus to calculate minus
    varargout{1} = plus@itaSuper(a,b, varargin{3});
else
    varargout{1} = plus@itaSuper(a,b);
end
end