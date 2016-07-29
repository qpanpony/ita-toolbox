function varargout = eq(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

dataEqual = eq@itaSuper(varargin{:});
domainsEqual = isTime(varargin{1}) == isTime(varargin{2});
if domainsEqual
    if isTime(varargin{1})
            abscissaEqual = isequal(varargin{1}.timeVector, varargin{2}.timeVector);
    else
            abscissaEqual = isequal(varargin{1}.freqVector, varargin{2}.freqVector);
    end    
    if ~abscissaEqual
        ita_verbose_info('not equal: itaResults with different abscissas',1)
    end
else
    abscissaEqual = false;
    ita_verbose_info('not equal: itaResults with different dimensions',1)
end
varargout{1} = (dataEqual && abscissaEqual && domainsEqual);
end