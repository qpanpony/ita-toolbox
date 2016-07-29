function varargout = uminus(varargin)
%negate; -1 * Obj

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


narginchk(1,1);
a = varargin{1};
%% Negate
for idx = 1:numel(a)
    domain = a(idx).domain; %get the domain
    a(idx).(domain) = - a(idx).(domain); %do the minus operation
    %% Add history line
    a(idx) = ita_metainfo_add_historyline(a(idx),'itaSuper.uminus',a(idx));
end
varargout{1} = a;
end