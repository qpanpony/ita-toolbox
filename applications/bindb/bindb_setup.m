function bindb_setup()
% Synopsis:
%   bindb_setup() or bindb_setup for console
% Description:
%   This functuin adds all paths needed to run bindb. It also loads your
%   settings and localadata.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Check driver
if ~bindb_driver_check()
    % Display hint
    fprintf('No driver entries found in the classpath.txt!\nClearing workspace to write dynamic classpath entry...\n<a href="matlab:bindb_driver_install()">Install driver</a> to skip this in the future.\n');
    
    % Add to dynamic classpath
    javaaddpath(which('mysql-connector-java-5.1.19-bin.jar'));
end

% Register globals
global bindb_data;

% Get path for setup file (again - javaaddpath kills the workspace)
localpath = fileparts(which('bindb_setup.m'));

% Create global data struct if inexistent
if ~exist(fullfile(localpath, 'localdata', 'system.mat'), 'file')
    % Connections
    bindb_data.sqlConn = [];
    
    % Network folder
    bindb_data.ImpulseResponsePath = [];
    
    % Rooms
    bindb_data.Rooms = struct('ID', {}, 'Name', {}, 'Description', {}, 'Layout', {});
    bindb_data.Rooms_Outbox = struct('ID', {}, 'Name', {}, 'Description', {}, 'Layout', {});
    
    % Fields
    bindb_data.Fields = struct('Name', {}, 'Description', {}, 'Type', {}, 'Values', {});
    
    % Measurements
    bindb_data.Measurements = cell(0, 1);
    bindb_data.Measurements_Outbox = cell(0, 1);
    
    % Timestamp
    bindb_data.Timestamp = datestr(now, 'dd. mmm. yyyy HH:MM');

    % Log
    bindb_data.Log = cell(0, 3);

    % Settings    
    bindb_data.Settings.BindbPath = localpath;
    bindb_data.Settings.MeasurementsPath = fullfile(localpath, 'measurements');    
    bindb_data.Settings.AdminMode = 0;    
    bindb_data.Settings.KeepLog = 0;   
    bindb_data.Settings.AutoUpdate = 0;  
    
    % Add log
    bindb_addlog('system', 'localdata created', 0);
    
    % store localdata
    bindb_store();
else
    % Load system data
    load(fullfile(localpath, 'localdata', 'system.mat'));

    % Store to global data struct
    bindb_data = data;
    
    % Update bindb path (now you can copy all files from a friend and it
    % works on your machine)
    bindb_data.Settings.BindbPath = localpath;
    
    % Load rooms
    filepath = bindb_filepath('localdata', 'rooms.mat');
    if exist(filepath, 'file')
        load(bindb_filepath('localdata', 'rooms.mat'));
        bindb_data.Rooms = rooms_data;
        bindb_data.Rooms_Outbox = rooms_outbox_data;
    end
    
    % Load outbox measurements
    filepath = bindb_filepath('localdata', 'measurements.mat');
    if exist(filepath, 'file')
        load(bindb_filepath('localdata', 'measurements.mat'));
        bindb_data.Measurements_Outbox = measurements_outbox_data;
    end
    
        
    % Check measurements path
    if ~exist(bindb_data.Settings.MeasurementsPath, 'file')
        bindb_data.Settings.MeasurementsPath = fullfile(bindb_data.Settings.BindbPath, 'measurements');
    end
    
    % Load local measurements
    bindb_measurement_get();
    
    % Load fields
    filepath = bindb_filepath('localdata', 'fields.mat');
    if exist(filepath, 'file')
        load(bindb_filepath('localdata', 'fields.mat'));
        bindb_data.Fields = fields_data;
    end
end

% Add to searchpath
addpath(localpath);

% Display tips
fprintf('List of commands:\n<a href="matlab:bindb">bindb</a>           \trun the bindb manager\n<a href="matlab:bindb_connect">bindb_connect</a>   \tconnect to bindb database\n<a href="matlab:bindb_disconnect">bindb_disconnect</a>\tterminate connection to bindb database\n<a href="matlab:bindb_mmtcommit">bindb_mmtcommit</a> \tCommit local measurements\nUse ''bindb_measurement_commit(mmt)'' to commit the bindb_measurement mmt to the database.\n');
