function bindb_measurement_save( measurement )
% Synopsis:
%   bindb_measurement_save( measurement )
% Description:
%   Saves a measurement to the local machine.
% Parameters:
%   (bindb_measurement) measurement
%	The measurement that will be saved.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Build file name
name = sprintf('%s [%d], %s - %s.mat', datestr(measurement.Timestamp, 'yyyy-mm-dd'), measurement.ID, measurement.Author, measurement.Room.Name);

% Save measurement
save(bindb_filepath('measurements', name), 'measurement');
end

