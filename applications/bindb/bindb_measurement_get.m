function bindb_measurement_get()
% Synopsis:
%   bindb_measurement_get( load, outbox )
% Description:
%   Load all local measurements into the global data struct.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Get list of local measurements
mmtlist = dir(fullfile(bindb_data.Settings.MeasurementsPath, '*.mat'));

% Load measurements
measurements_data = cell(0, 1);
for index = 1:length(mmtlist)
    load(bindb_filepath('measurements', mmtlist(index).name));
    measurements_data{end+1} = measurement;
end
    
% Store in global data struct
bindb_data.Measurements = measurements_data;
    
% Add log entry
if ~isempty(measurements_data)
    bindb_addlog('measurement get', [num2str(size(measurements_data, 1)) ' measurements loaded'], 0);
else
    bindb_addlog('measurement get', 'no measurements loaded', 0);
end
