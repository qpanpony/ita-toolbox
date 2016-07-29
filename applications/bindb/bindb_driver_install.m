function bindb_driver_install()
% Synopsis:
%   bindb_driver_install()
% Description:
%   Writes all driver entries to the classpath.txt that are needed for a
%   connection to the bindb server.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Do not duplicate entries
if bindb_driver_check()
    fprintf('Driver is already installed.\n');
    return;
end

% Get classpath entries
entries = ['\r\n# Java classpath entries for bindb database connection\r\n' strrep(which('mysql-connector-java-5.1.19-bin.jar'), '\', '\\')];

% Get classpath path
filepath = fullfile(matlabroot, 'toolbox', 'local', 'classpath.txt');

% Add driver to classpath
fid = fopen(filepath, 'a');
fprintf(fid, entries);
fclose(fid);

% Print restart hint
fprintf('Restart Matlab to avtivate the driver.\n<a href="matlab:exit">Exit now</a>\n');