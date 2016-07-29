function varargout = ita_remove_registry_entry(varargin)
%ITA_REMOVE_REGISTRY_ENTRY - Remove MS Windows reg entries
%  This function is the counterpart to ita_set_registry_entry() and 
%  removes all entries, which have been set before.
%
%  Syntax: ita_remove_registry_entry()
%
%   See also ita_set_registry_entry.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_remove_registry_entry">doc ita_remove_registry_entry</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 25-Sep-2008 


%% Get ITA Toolbox preferences
% mpo: batch commenting of: "Mode % global variable is loaded very fast" 
verboseMode = ita_preferences('verboseMode'); % mpo, batch replacement, 15-04-2009

%% Call reg file

a = which('ita_toolbox_clear_entries.reg');

eval(['!' a]);

if verboseMode, disp('The ITA Toolbox entries from the Windows Registry have been removed.'), end

%end function
end