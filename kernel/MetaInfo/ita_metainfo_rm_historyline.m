function varargout = ita_metainfo_rm_historyline(varargin)
%ita_header_rm_historyline - Remove History information
%  This function removes all history information
%
%  Syntax: audioObj = ita_metainfo_rm_historyline(audioObj)
%  Syntax: audioObj = ita_metainfo_rm_historyline(audioObj, 3) - delete last 3 entries
%  Syntax: audioObj = ita_metainfo_rm_historyline(audioObj,'all')- delete all entries
%
%   See also ita_make_header
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_header_rm_historyline">doc ita_header_rm_historyline</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 25-Sep-2008

%% Initialization
% Number of Input Arguments
narginchk(1,2);
% Find Audio Data

h = varargin{1};

delete_all = 0;
rm_number = 1;
if nargin == 2
    if isnumeric(varargin{2})
        rm_number = varargin{2};
    elseif isequal(lower(varargin{2}),'all')
        delete_all = 1;
    end
end

%% Add the history line
if length(h.history) == 1 || delete_all
    h.history = {};
else
    h.history = {h.history{1:(end-rm_number)}};
end

%% Find output parameters
varargout(1) = {h};

%end function
end