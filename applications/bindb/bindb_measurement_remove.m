function success = bindb_measurement_remove( id )
% Synopsis:
%   success = bindb_measurement_remove( id )
% Description:
%   Remove the measurement with given id from database and filestorage
% Parameters:
%   (int) id
%	The id of the measurement.
% Returns:
%   (bool) success
%	States if the operation was successfull.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Set default success
success = true;

% Remove database entries
try    
    bindb_exec(['DELETE FROM `Measurements` WHERE `M_ID`=' num2str(id)]);
    bindb_exec(['DELETE FROM `Sources` WHERE `M_ID`=' num2str(id)]);
    data = bindb_query(['SELECT R_ID FROM `Responses` WHERE `M_ID`=' num2str(id)]);
    for index = 1:length(data)
       delete(bindb_fileidpath('rir', data{index})); 
    end
    bindb_exec(['DELETE FROM `Responses` WHERE `M_ID`=' num2str(id)]);
catch err
    bindb_addlog('remove measurement', err.message, 1);
    success = false;
end

