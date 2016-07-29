function varargout = ifft(varargin)
% does not do anything, just checks the domain

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if all(isTime(varargin{:}))
    varargout = varargin;
else
    error('%s:this is an itaResult, it cannot be transformed to another domain (current domain is frequency)!','ITARESULT');
end
    
    