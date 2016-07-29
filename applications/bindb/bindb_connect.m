function [ sqlstatus, ftpstatus ] = bindb_connect()
% Synopsis:
%   [ sqlstatus, ftpstatus ] = bindb_connect()
% Description:
%   Connect to the database and the fileserver. The connections are stored
%   in the global bindb_data variable.
% Returns:
%   (int) sqlstatus
%	True if connection to the database was successfull.
%   (int) ftpstatus
%	True if connection to the fileserver was successfull.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Declare globals
global bindb_data;

% Quit if no global data
if exist('bindb_data', 'var') == 0
    error('No global data found. Run bindb command first.');
end

% Connection data
sqlhost = 'verdi.akustik.rwth-aachen.de:3306';
sqldb = 'bindb';
sqluser = 'bindb';
sqlpass = '28Km,ag1B.W';
if isunix
    % Mount first
     !mkdir /Volumes/Bindb
     !mount -t smbfs  //verdi/Bindb /Volumes/Bindb
    irpath = '/Volumes/Bindb';
else
    irpath = '\\verdi\Bindb';
end

% Add log entry
bindb_addlog('system', 'manual connect', 0);

% Skip if already connected to sql
if (isempty(bindb_data.sqlConn) == 0) && isconnection(bindb_data.sqlConn)
    bindb_addlog('database', 'already connected to database', 0);
    sqlstatus = 1;
else
    % Set connection timeout
    logintimeout(5);

    % Connect to database
    bindb_data.sqlConn = database(sqldb, sqluser, sqlpass, ...
       'com.mysql.jdbc.Driver', ...
       ['jdbc:mysql://' sqlhost '/' sqldb]);
   
    % Define default return format
    setdbprefs('DataReturnFormat','cellarray');

    % Get connection status
    sqlstatus = isconnection(bindb_data.sqlConn);

    % Add log entry
    if sqlstatus == 1
        bindb_addlog('database', 'database connection successfull', 0);
    else
        bindb_addlog('database', bindb_data.sqlConn.Message, 1);
    end
end

% Check existence of file dir
bindb_data.ImpulseResponsePath = irpath;
if exist(irpath, 'dir')
    ftpstatus = 1;
    bindb_addlog('filestorage', 'filestorage connection successfull', 0);
else
    ftpstatus = 0;
    bindb_addlog('filestorage', 'can''t find filestorage', 1);
end
