function data = bindb_queryrows( query, rows )
% Synopsis:
%   data = bindb_queryrows( query, rows )
% Description:
%   Uses the open bindb database connection for a query and fetches rows of data. 
% Parameters:
%   (string) query
%	The sql query that is executed.
%   (int) rows
%	The amount of rows that will be fetched.
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
fetchcurs = fetch(curs, rows);
data = fetchcurs.Data;
end
