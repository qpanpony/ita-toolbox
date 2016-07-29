function index = bindb_findmeasurement( id )
% Synopsis:
%   index = bindb_hasmeasurement( id )
% Description:
%   Search local machine for measurement by response id.
% Parameters:
%   (int) id
%	id of the response included in the measurement.
% Returns:
%   (int) index
%	-1 if no measurement with given response id found, Otherwise the index
%	of the measurement in the global data struct.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Default
index = -1;

% Search measurements
for i = 1:length(bindb_data.Measurements)
    if bindb_data.Measurements{i}.ID == id
        index = i;
        return;
    end
end

