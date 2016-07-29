function varargout = transpose(varargin)
% does not do anything, just checks the domain

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if all(isTime(varargin{:}))
    varargout = varargin;
else
    error('%s:this result is not in the time domain!','ITARESULT');
end