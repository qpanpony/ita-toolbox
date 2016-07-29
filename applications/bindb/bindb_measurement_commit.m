function [ success, id ] = bindb_measurement_commit( mmt, outbox )
% Synopsis:
%   [ success, id ] = bindb_measurement_commit( measurement, outbox )
% Description:
%   Commits the given emasurement to the server or stores in the outbox.
% Parameters:
%   (struct) measurement
%	The measurement that will be committed. Run bindb_measurementstruct()
%	to get an empty measurement struct.
%   (bool) outbox
%	If true, the measurement will be stored in the outbox if offline.
% Returns:
%   (int) success
%	Can have three values,
%   1   the measurement was stored
%   2   the measurement was saved in the outbox
%   0   an error ocurred.
%   (int) id
%	id of the measurement that was commited. Returns 0 if success is not 1.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

success = 0;
id = 0;

if bindb_isonline() 
    % Create Field strings
    fields = '';
    values = '';
    if length(bindb_data.Fields) > 0
        for index = 1:size(mmt.Data, 1)-3
            fields = [fields ', `' mmt.Data{index+3, 1} '`'];
            if(isempty(mmt.Data{index+3, 2}))
               values = [values ', NULL']; 
            elseif isnumeric(mmt.Data{index+3, 2})
                values = [values ', ' num2str(mmt.Data{index+3, 2})];
            else
                values = [values ', ''' mmt.Data{index+3, 2} ''''];
            end
        end
    end
    
    % Save measurement
    cmd = ['INSERT INTO `Measurements` (`O_ID`, `Date`, `Version`, `Author`, `Comment`, `Humidity`, `Volume`, `Temperature`' fields ') VALUES (' num2str(mmt.Room.ID) ', ''' mmt.Timestamp ''', ' num2str(mmt.Version) ', ''' mmt.Author ''', ''' mmt.Comment ''', ' num2str(mmt.Data{1, 2}) ', ' num2str(mmt.Data{2, 2}) ', ' num2str(mmt.Data{3, 2}) values ')'];
    bindb_exec(cmd);
    mmt.ID = bindb_queryrowsmat('SELECT LAST_INSERT_ID()', 1);            
    id = mmt.ID;
            
    % Save responses
    for hwindex = 1:length(mmt.Microphones)  
        bindb_exec(['INSERT INTO `Responses` (`M_ID`, `X`, `Y`, `Height`, `Description`, `Hardware`) VALUES (' num2str(mmt.ID) ', ' num2str(mmt.Microphones(hwindex).Location.X) ', ' num2str(mmt.Microphones(hwindex).Location.Y) ', ' num2str(mmt.Microphones(hwindex).Location.Height) ', ''' mmt.Microphones(hwindex).Location.Description ''', ''' mmt.Microphones(hwindex).Hardware ''')']);             
        mmt.Microphones(hwindex).ID = bindb_queryrowsmat('SELECT LAST_INSERT_ID()', 1);
            
        % Save rir to network folder or outbox
        RIR = mmt.Microphones(hwindex).ImpulseResponse;             
        try
            save(bindb_fileidpath('rir', mmt.Microphones(hwindex).ID), 'RIR');                   
        catch
            save(bindb_fileidpath('outbox', mmt.Microphones(hwindex).ID), 'RIR');
                
            % Add log
            bindb_addlog('System', 'failed to store impulse response in filestorage', 1);
        end
    end
    
    % Save sources
    for hwindex = 1:length(mmt.Sources)     
        bindb_exec(['INSERT INTO `Sources` (`M_ID`, `X`, `Y`, `Height`, `Description`, `Hardware`) VALUES (' num2str(mmt.ID) ', ' num2str(mmt.Sources(hwindex).Location.X) ', ' num2str(mmt.Sources(hwindex).Location.Y) ', ' num2str(mmt.Sources(hwindex).Location.Height) ', ''' mmt.Sources(hwindex).Location.Description ''', ''' mmt.Sources(hwindex).Hardware ''')']);      
        mmt.Sources(hwindex).ID = bindb_queryrowsmat('SELECT LAST_INSERT_ID()', 1);
    end  
    
    % Save local
    bindb_measurement_save(mmt);     
       
    % Add new measurement
    bindb_data.Measurements{end+1} = mmt;
    
    % Successfully published
    success = 1;
elseif outbox
    % Add measurements to measurements outbox
    mmt.ID = bindb_nextlocalid('measurement');
    bindb_data.Measurements_Outbox{end+1} = mmt;

    % Save outbox
    bindb_measurement_store();  
    
    % Successfully stored
    success = 2;
end