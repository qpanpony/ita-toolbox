function varargout = horzcat(varargin)

%Concatenates elements horizontally

% <ITA-Toolbox>
% This file is part of the application Meshing for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

varargout = {vertcat(varargin{:})};
end