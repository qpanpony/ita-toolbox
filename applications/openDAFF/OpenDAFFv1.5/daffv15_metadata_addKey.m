function [ metadata ] = daffv15_metadata_addKey(metadata, keyname, datatype, value)
%DAFF_METADATA_ADDKEY Adds another key to a DAFF metadata struct
%   TODO:
%   ITAToolbox schauen
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    if (~isempty(metadata))
        if (~isstruct(metadata)), error(['[' mfilename '] Wrong datatype for metadata']); end;
    else
        metadata = struct('name', {}, 'datatype', {}, 'value', {});
    end
    
    if (~ischar(keyname)), error(['[' mfilename '] Key name must be a string']); end;
    
    % Keynames are case-insensitive (convert to upper case)
    keyname = upper(keyname);
    
    % Test wheather a key of the given name already exists
    if any(strcmp({metadata(:).name}, keyname))
        error(['[' mfilename '] Key ''' keyname ''' already exists']);
    end
    
   if (~ischar(datatype)), error(['[' mfilename '] Datatype must be a string']); end;
   
   switch (upper(datatype))
       case 'BOOL'
           if (~islogical(value)), error(['[' mfilename '] Value must be logical for boolean keys']); end; 
           metadata(end+1) = struct('name', keyname, 'datatype', 0, 'value', value);
           
       case 'INT'
           if (~isfinite(value)), error(['[' mfilename '] Value must be finite']); end; 
           if (~isreal(value)), error(['[' mfilename '] Value must be real']); end; 
           if (value ~= ceil(value)), error(['[' mfilename '] Value must be an integer number for integer keys']); end; 
           metadata(end+1) = struct('name', keyname, 'datatype', 1, 'value', int32(value));    
           
       case 'FLOAT'
           if (~isfinite(value)), error(['[' mfilename '] Value must be finite']); end; 
           if (~isreal(value)), error(['[' mfilename '] Value must be real']); end; 
           metadata(end+1) = struct('name', keyname, 'datatype', 2, 'value', double(value));                 
           
       case 'STRING'
           if (~ischar(value)), error(['[' mfilename '] Value must be a string for string keys']); end; 
           metadata(end+1) = struct('name', keyname, 'datatype', 3, 'value', value);                 
   end
end
