function varargout = ita_toolbox_path(varargin)
%ITA_TOOLBOX_PATH - Return the path of the Toolbox
%  This function returns a path string of the ITA Toolbox root
%
%  Syntax:
%   pathString = ita_toolbox_path()
%   ita_toolbox_path('dev') - Path to developer part of the toolbox
%   ita_toolbox_path('kernel') - Path to the kernel of the toolbox
%
%
%   See also: ita_toolbox_setup.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_toolbox_path">doc ita_toolbox_path</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  18-Jun-2009

%% Initialization and Input Parsing
narginchk(0,1);

%% path
if nargin == 0
    result = fileparts(which('ita_toolbox_setup.m'));
elseif nargin == 1 && strcmpi(varargin{1},'kernel')
    result = [fileparts(which('ita_toolbox_setup.m')) filesep 'kernel'];
    if ~isdir(result)
        %result =  ita_toolbox_path();
    end
end

if isdir(result)
    result = cd(cd(result));
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    disp(result)
else
    % Write Data
    varargout(1) = {result};
end

%end function
end