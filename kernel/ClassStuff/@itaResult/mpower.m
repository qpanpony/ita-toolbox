function varargout = mpower(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if isa(varargin{1},'itaAudio') && any(isTime(varargin{1}))
    error('itaResult.mpower:your signals are not in the freq domain, use operator .^ instead!');
end
varargout{1} = mpower@itaSuper(varargin{:});
end