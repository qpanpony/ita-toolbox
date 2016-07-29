function varargout =  bar(this,varargin)
%normal bar plot

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

levels = ita_spk2frequencybands(this);
if nargout == 1
    varargout{1} = levels;
else
    if nargin  == 1
        levels.bar;
    else
        %     levels.bar(varargin(:));
        levels.bar(varargin{:});
    end
end
end