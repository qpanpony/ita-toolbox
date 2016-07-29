function bindb_update()
% Synopsis:
%   bindb_update()
% Description:
%   Updates all rooms and fields and stores the in the global data struct.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Get rooms
bindb_room_get();
bindb_room_store();

% Get fields
bindb_fields_get();
bindb_fields_store();

% Get new versions
for index = 1:length(bindb_data.Measurements)
   lver = bindb_data.Measurements{index}.Version;
   over = bindb_queryrowsmat(['SELECT `Version` FROM `Measurements` WHERE `M_ID`=' num2str(bindb_data.Measurements{index}.ID)], 1);
   if ~strcmp(over, 'No Data') && over > lver
       waitfor(bindb_gui_measurement_newversion(bindb_data.Measurements{index}));
   end
end

% Read measurements
bindb_measurement_get();
    
% Update timestamp
bindb_data.Timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');

