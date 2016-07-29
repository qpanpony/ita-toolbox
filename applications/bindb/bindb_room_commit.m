function [ success, id ] = bindb_room_commit( name, description, layout, outbox )
% Synopsis:
%   [ success, id] = bindb_room_commit( name, description, layout, outbox )
% Description:
%   Commits the given room to the server or stores in the outbox.
% Parameters:
%   (string) name
%	The name of room that will be comitted.
%   (string) description
%	The description of room that will be comitted.
%   (string) layout
%	The layout of room that will be comitted.
%   (bool) outbox
%	If true, the measurement will be stored in the outbox on error.
% Returns:
%   (int) id
%	The new id of the room.
%   (int) success
%	Can have three values,
%   1   the room was stored
%   2   the room was saved in the outbox
%   0   an error ocurred.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Default id
id = -1;

if bindb_isonline()
    try  
        % Add room to database
        exec(bindb_data.sqlConn, ['INSERT INTO `Rooms` (`Name`, `Description`, `Layout`) VALUES (''' name ''', ''' description ''', ''' layout ''')']);
        id = bindb_queryrowsmat('SELECT LAST_INSERT_ID()', 1);
        
        % Load and save current rooms
        bindb_room_get();
        bindb_room_store();
  
        % Successfully published
        success = 1;
    catch
        if outbox       
            % Add room to global data
            room.ID = bindb_nextlocalid('room');
            room.Name = name;
            room.Description = description;
            room.Layout = layout;    
            bindb_data.Rooms_Outbox(end+1) = room;

            % save current rooms
            bindb_room_store();

            % Successfully stored
            success = 2;
        else
            success = 0;
        end
    end     
else
    if outbox     
        % Add room to global data
        room.ID = bindb_nextlocalid('room');
        room.Name = name;
        room.Description = description;
        room.Layout = layout;    
        bindb_data.Rooms_Outbox(end+1) = room;

        % save current rooms
        bindb_room_store();

        % Successfully stored
        success = 2;
    else
       success = 0; 
    end
end