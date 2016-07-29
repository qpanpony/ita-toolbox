function online = bindb_isonline()
% Synopsis:
%   online = bindb_isonline()
% Description:
%   Validates the connection and returns the result.
% Returns:
%   (logical) online
%	True, if conenction is open, false otherwise.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Declare globals
global bindb_data;

if isfield(bindb_data, 'Settings') && ~isempty(bindb_data.sqlConn) && isconnection(bindb_data.sqlConn)
    online = true;
else
    online = false;    
end

