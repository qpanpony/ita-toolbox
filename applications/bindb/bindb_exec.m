function success = bindb_exec( query )
% Synopsis:
%   success = bindb_exec( query )
% Description:
%   Uses the open bindb database connection to execute a query.
% Parameters:
%   (string) query
%	The sql query that is executed.
% Returns:
%   (cell array) data
%	The result of the query.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Declare globals
global bindb_data;

% Execute query
success = exec(bindb_data.sqlConn, query);