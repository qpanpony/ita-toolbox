function bindb_admin_dropsqltables()
% Synopsis:
%   bindb_admin_dropsqltables()
% Description:
%   Remove the entire table structure from the bindb database. This function
%   requires AdminMode. Use 'help bindb_setadmin' for more information.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data

if ~bindb_data.Settings.AdminMode
    bindb_addlog('Drop sql tables', 'AdminMode is required to run this function', 1);
    return;
end

Messages = '';

% Measurements
cmd = 'DROP TABLE `Measurements`';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

% Responses
cmd = 'DROP TABLE `Responses`';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

% Sources
cmd = 'DROP TABLE `Sources`';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

% Rooms
cmd = 'DROP TABLE `Rooms`';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

% Fields
cmd = 'DROP TABLE `Fields`';
curs = bindb_exec(cmd);
if length(curs.Message) > 0
    Messages = [Messages curs.Message ', '];
end

if length(Messages > 0)
    bindb_addlog('Create sql tables', Messages(1:end-2), 1);
end

