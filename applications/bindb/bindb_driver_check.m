function status = bindb_driver_check()
% Synopsis:
%   bindb_driver_check()
% Description:
%   Searches the classpath.txt for the driver entries needed for a
%   connection to the bindb server.
% Returns:
%   (bool) status
%	True, if driver entries exist.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Get classpath path
filepath = fullfile(matlabroot, 'toolbox', 'local', 'classpath.txt');

% Read classpath file
fid = fopen(filepath, 'r');
lines = textscan(fid, '%s');
lines = lines{1};
fclose(fid);

% Default status
status = false;

% Find driver
driverentry = which('mysql-connector-java-5.1.19-bin.jar');
for index = fliplr(1:length(lines))
    if strcmp(lines{index}, driverentry)
        status = true;
        return;
    end
end