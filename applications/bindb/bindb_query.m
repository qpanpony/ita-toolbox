function data = bindb_query( query )
% Synopsis:
%   data = bindb_query( query )
% Description:
%   Uses the open bindb database connection for a query and fetches data. 
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
curs = exec(bindb_data.sqlConn, query);

% Fetch data
fetchcurs = fetch(curs);
data = fetchcurs.Data;
end
