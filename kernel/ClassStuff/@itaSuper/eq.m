function varargout = eq(varargin)
% checks itaSuper objects for equality

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(2,2);
ao1 = varargin{1};
ao2 = varargin{2};
if all(size(ao1.data) == size(ao2.data))
    maxAbsError = max(max(abs(ao1.data - ao2.data)));
    if numel(maxAbsError) == 0
        varargout{1} = true;
        return;        
    end
    relerror = maxAbsError ./ max(max(abs(ao1.data)));
    
    if relerror > 1e-15 || isnan(relerror) || isinf(relerror)
        result = false;
    else
        result = true;
    end
else
    result = false;
    ita_verbose_info(['different size of data ( [' num2str(size(ao1.data)) '] vs [' num2str(size(ao2.data)) ']) '],1)
end
varargout{1} = result;
end