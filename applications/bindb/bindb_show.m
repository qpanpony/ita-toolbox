function bindb_show( measurement )
% Synopsis:
%   bindb_show( measurement )
% Description:
%   Show the room usage of the given measurement.
% Parameters:
%   (bindb_measurement) measurement
%	The measurement that will be described.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register gloals
global bindb_data;

% Check if bindb is initialized
if isfield(bindb_data, 'Settings')
    bindb_gui_show(measurement);
else
    fprintf(1, 'bindb is not initialized, run <a href="matlab:bindb_setup">bindb_setup</a> first\n');
end
