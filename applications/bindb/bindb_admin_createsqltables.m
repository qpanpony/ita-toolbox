function bindb_admin_createsqltables()
% Synopsis:
%   bindb_admin_createsqltables()
% Description:
%   Create the entire table structure for the bindb database. This function
%   requires AdminMode. Use 'help bindb_setadmin' for more information.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data

if ~bindb_data.Settings.AdminMode
    bindb_addlog('Create sql tables', 'AdminMode is required to run this function', 1);
    return;
end

Messages = '';

% Measurements
cmd = 'CREATE TABLE `Measurements` ( `M_ID` int(11) NOT NULL AUTO_INCREMENT, `O_ID` int(11) NOT NULL, `Date` date NOT NULL, `Version` int(11) NOT NULL, `Author` text NOT NULL, `Comment` text, `Humidity` double NOT NULL, `Volume` double NOT NULL, `Temperature` double NOT NULL, PRIMARY KEY (`M_ID`) ) ENGINE=InnoDB  DEFAULT CHARSET=latin1';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

% Responses
cmd = 'CREATE TABLE `Responses` ( `R_ID` int(11) NOT NULL AUTO_INCREMENT, `M_ID` int(11) NOT NULL, `X` double NOT NULL, `Y` double NOT NULL, `Height` double NOT NULL, `Description` text, `Hardware` text NOT NULL, PRIMARY KEY (`R_ID`) ) ENGINE=InnoDB  DEFAULT CHARSET=latin1'; 
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

% Sources
cmd = 'CREATE TABLE `Sources` ( `S_ID` int(11) NOT NULL AUTO_INCREMENT, `M_ID` int(11) NOT NULL, `X` double NOT NULL, `Y` double NOT NULL, `Height` double NOT NULL, `Description` text, `Hardware` text NOT NULL, PRIMARY KEY (`S_ID`) ) ENGINE=InnoDB  DEFAULT CHARSET=latin1';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

% Rooms
cmd = 'CREATE TABLE `Rooms` ( `O_ID` int(11) NOT NULL AUTO_INCREMENT, `Name` text NOT NULL, `Description` text, `Layout` text NOT NULL, PRIMARY KEY (`O_ID`) ) ENGINE=InnoDB  DEFAULT CHARSET=latin1';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

% Fields
cmd = 'CREATE TABLE `Fields` ( `Name` text NOT NULL, `Description` text NOT NULL, `Type` int(11) NOT NULL, `Values` text ) ENGINE=InnoDB DEFAULT CHARSET=latin1';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

if length(Messages > 0)
    bindb_addlog('Create sql tables', Messages(1:end-2), 1);
end
