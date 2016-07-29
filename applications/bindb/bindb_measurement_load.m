function [mmt, success] = bindb_measurement_load( id )
% Synopsis:
%   mmt = bindb_measurement_load( id )
% Description:
%   Load measurement from database and filestorage
% Parameters:
%   (int) id
%	The id of the measurement.
% Returns:
%   (bindb_measurement) mmt
%	The loaded measurement if operation successfull.
%   (bool) success
%	States if the operation was successfull.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

try
    % Get measurement data        
    sqldata = bindb_query(['SELECT * FROM `Measurements` INNER JOIN `Rooms` ON `Rooms`.`O_ID`=`Measurements`.`O_ID` WHERE `Measurements`.`M_ID`=' num2str(id)]);         
    mmt = bindb_measurement( sqldata{1, 1}, sqldata{1, 5}, sqldata{1, 6}, sqldata{1, 3}, sqldata{1, 4});              
    mmt.addData('Humidity', sqldata{1, 7});
    mmt.addData('Volume', sqldata{1, 8});
    mmt.addData('Temperature', sqldata{1, 9});
    for index = 1:length(bindb_data.Fields)
        mmt.addData( bindb_data.Fields(index).Name, sqldata{1, 9 + index} );
    end
    % Get room data        
    sqldata = bindb_query(['SELECT * FROM `Rooms` WHERE `Rooms`.`O_ID`=' num2str(sqldata{1, 2}) ]); 
    mmt.Room(1).ID = sqldata{1, 1};
    mmt.Room(1).Name = sqldata{1, 2};
    mmt.Room(1).Description = sqldata{1, 3};
    mmt.Room(1).Layout = sqldata{1, 4};
    % Get responses
    sqldata = bindb_query(['SELECT `R_ID`, `X`, `Y`, `Height`, `Description`, `Hardware` FROM `Responses` WHERE `Responses`.`M_ID`=' num2str(id)]);
    % Read response
    for index=1:size(sqldata, 1)
        hwm.ID = sqldata{index, 1}; 
        hwm.Location.X = sqldata{index, 2};
        hwm.Location.Y = sqldata{index, 3};
        hwm.Location.Height = sqldata{index, 4};
        hwm.Location.Description = sqldata{index, 5};            
        hwm.Hardware = sqldata{index, 6};
        hwm.ImpulseResponse = [];   
        % Get impulse response
        try
            if exist(bindb_folderpath('rir'), 'dir')
                if exist(bindb_fileidpath('rir', hwm.ID), 'file')
                    load(bindb_fileidpath('rir', hwm.ID));
                    hwm.ImpulseResponse = RIR;  
                else
                    bindb_addlog('measurement search', 'measurement has no impulse response', 0);
                end
            else
                bindb_addlog('measurement search', 'no connection to filestorage', 1);                    
            end
        catch err           
            bindb_addlog('measurement search', err.message, 1);                    
        end
        mmt.addHardware('mic', hwm);       
    end
    
    % Get measurement sources
    sqldata = bindb_query(['SELECT `S_ID`, `X`, `Y`, `Height`, `Description`, `Hardware` FROM `Sources` WHERE `Sources`.`M_ID`=' num2str(id)]);
    % Read sources
    for index=1:size(sqldata, 1)
        hws.ID = sqldata{index, 1};             
        hws.Location.X = sqldata{index, 2};
        hws.Location.Y = sqldata{index, 3};
        hws.Location.Height = sqldata{index, 4};
        hws.Location.Description = sqldata{index, 5};
        hws.Hardware = sqldata{index, 6};
        mmt.addHardware('source', hws);        
    end    
    success = true;
catch
    success = false;
end
