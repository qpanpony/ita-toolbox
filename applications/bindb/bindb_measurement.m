classdef bindb_measurement < handle
    %BINDB_MEASUREMENT Contains all information of a single measurement
    %including room layout and impulse responses.
    %   Properties:
    %       ID (int)     
    %       Author (string)
    %       Comment (string)
    %       Timestamp (string)
    %       Version (int)
    %       Room (struct)
    %         Room.ID (int)
    %         Room.Name (string)
    %         Room.Description (string)
    %         Room.Layout (string) Nonreadable form, use 'bindb_show(mmt)' to
    %                              viewroom layout of measurement mmt
    %       Data (cell-array) First column contains the names, second column
    %                        the data
    %       Microphones (struct-array)
    %         Microphones.ID (int)    
    %         Microphones.Location (struct)    
    %           Microphones.Location.X (int)
    %           Microphones.Location.Y (int)
    %           Microphones.Location.Height (int)
    %           Microphones.Location.Description (string)
    %         Microphones.Hardware (string)
    %         Microphones.ImpulseResponse (itaAudio)
    %       Sources (struct-array)
    %         Sources.ID (int)
    %         Sources.Location (struct)    
    %           Sources.Location.X (int)
    %           Sources.Location.Y (int)
    %           Sources.Location.Height (int)
    %           Sources.Location.Description (string)
    %         Sources.Hardware (string)
    %   Functions:
    %       Show() Display the room usage of this measurement.
    %       Commit() Commit the local changes to the server.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    
    properties (SetAccess = public)
        ID
        Author
        Comment
        Timestamp
        Version
        Room = struct('ID', {}, 'Name', {}, 'Description', {}, 'Layout', {});
        Data = cell(0, 2);
        Microphones = struct('ID', {}, 'Location', struct('X', {}, 'Y', {}, 'Height', {}, 'Description', {}), 'Hardware', {}, 'ImpulseResponse', {});
        Sources = struct('ID', {}, 'Location', struct('X', {}, 'Y', {}, 'Height', {}, 'Description', {}), 'Hardware', {});
    end
    
    methods
        function mmt = bindb_measurement(ID, Author, Comment, Timestamp, Version)
           mmt.ID = ID;
           mmt.Author = Author;
           mmt.Comment = Comment;
           mmt.Timestamp = Timestamp;
           mmt.Version = Version;
        end
        function addData (mmt, Name, Value)
            % Fix NULL from mysql
            if isnumeric(Value)
                if isnan(Value)
                    Value = [];
                end
            elseif strcmp(Value, 'null')
                Value = '';
            end
                
            mmt.Data(end+1, 1:2) = { Name, Value };
        end
        function addHardware (mmt, type, Hardware)
            if strcmp(type, 'source')
                mmt.Sources(end+1) = Hardware;
            else
                mmt.Microphones(end+1) = Hardware;
            end
        end
        function disp(mmt)
            fprintf(1, 'bindb measurement\n\tAuthor:\t\t%s\n\tRoom:\t\t%s\n\tTimestamp:\t%s\t\tVersion:\t%d\n\tComment:\n%s\n\nactions\n\t<a href="matlab:bindb_show(%s)">Show room usage</a>\n\t<a href="matlab:bindb_mmtcommit(%s)">Commit changes</a>\n', mmt.Author, mmt.Room.Name, mmt.Timestamp, mmt.Version, sprintf(mmt.Comment), inputname(1), inputname(1));
        end
        function Show(mmt)
            bindb_show(mmt);
        end
        function Commit(mmt)
            bindb_mmtcommit(mmt);
        end
    end
    
end

