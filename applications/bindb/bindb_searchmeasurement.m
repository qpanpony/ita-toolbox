function found = bindb_searchmeasurement( id )
% Synopsis:
%   found = bindb_searchmeasurement( id )
% Description:
%   Search local machine for measurement by response id.
% Parameters:
%   (int) id
%	id of the response included in the measurement.
% Returns:
%   (bool) found
%	True, if a measurement was found.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Default
found = false;

% Search measurements
for index = 1:size(bindb_data.Measurements, 1)
    if bindb_data.Measurements{index, 9}.ID == id
        found = true;
        return;
    end
end

