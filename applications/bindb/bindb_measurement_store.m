function bindb_measurement_store()
% Synopsis:
%   bindb_measurement_store
% Description:
%   Save all outbox measurements in the localdata folder.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;


% Get rooms outbox
measurements_outbox_data = bindb_data.Measurements_Outbox;
    
% Save to localdata    
save(bindb_filepath('localdata', 'measurements.mat'), 'measurements_outbox_data');
    
% Add log entry
if isempty(measurements_outbox_data)
    bindb_addlog('measurement store', [num2str(size(measurements_outbox_data, 1)) ' measurements stored in outbox'], 0);
else
    bindb_addlog('measurement store', 'no measurements stored in outbox', 0);
end