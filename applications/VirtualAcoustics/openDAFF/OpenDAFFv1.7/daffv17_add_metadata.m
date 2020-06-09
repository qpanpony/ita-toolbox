%
%  OpenDAFF
%

function [ metadata ] = daffv17_add_metadata( metadata, keyname, datatype, value, override )
%DAFF_METADATA_ADDKEY Adds another key to a DAFF metadata struct
%   TODO:
%   ITAToolbox schauen
%
    if (~isempty(metadata))
        if (~isstruct(metadata)), error(['[' mfilename '] Wrong datatype for metadata']); end;
    else
        metadata = struct('name', {}, 'datatype', {}, 'value', {});
    end
    
    if (~ischar(keyname)), error(['[' mfilename '] Key name must be a string']); end;
    
    if nargin < 5
        override = false;
    end
    
    % Keynames are case-insensitive (convert to upper case)
    keyname = upper(keyname);
        
    % Test wheather a key of the given name already exists
    if any(strcmp({metadata(:).name}, keyname)) && ~override
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
           
       otherwise
           error( [ 'Unrecognized value type "' datatype '", use BOOL INT FLOAT or STRING' ] );		   
   end
end
