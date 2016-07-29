function varargout = minus(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(2,2);
if ~isa(varargin{1},'itaResult')
    a = -varargin{2};
    b = -varargin{1};
else
    a = varargin{1};
    b = varargin{2};
    if isa(b,'itaResult')
        domainTypeA = a.domain;
        domainTypeB = b.domain;
        
        if domainTypeA ~= domainTypeB
            error('itaResult.minus:objects are not in the same domain!');
        end
    end
end
varargout{1} = minus@itaSuper(a, b);
end