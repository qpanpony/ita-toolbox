function [ metadata ] = daffv15_metadata_addKey( metadata_in, keyname, datatype, value)
%DAFF_METADATA_ADDKEY Adds another key to a DAFF metadata struct
%   TODO:
%   ITAToolbox schauen
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

     if (~isempty(metadata_in))
         if (~isstruct(metadata_in))
             error( 'Input metadata is not empty and not a struct' )
         end;
        metadata = metadata_in;
     else
         metadata = struct();
     end
     
     keyname(ismember(keyname,' ')) = '_';
     keyname(ismember(keyname,',.:;!')) = [];
     
    if (~ischar(keyname))
        error('Key %s name must be a string', keyname )
    end;
    
    % Keynames are case-insensitive (convert to upper case)
    keyname = upper(keyname);
    
    % Test wheather a key of the given name already exists
    if isfield( metadata, keyname )
        error(['Key ''' keyname ''' already exists']);
    end
    
   if (~ischar(datatype))
       error(['Datatype must be a string'])
   end
   
   switch (upper(datatype))
       case 'BOOL'
           if (~islogical(value))
               error(['[' mfilename '] Value must be logical for boolean keys'])
           end; 
           metadata.(keyname) = boolean( value );
           
       case 'INT'
           if (~isfinite(value)), error(['[' mfilename '] Value must be finite']); end; 
           if (~isreal(value)), error(['[' mfilename '] Value must be real']); end; 
           if (value ~= ceil(value)), error(['[' mfilename '] Value must be an integer number for integer keys']); end; 
           metadata.(keyname) = int32(value);
           
       case 'FLOAT'
           if (~isfinite(value)), error(['[' mfilename '] Value must be finite']); end; 
           if (~isreal(value)), error(['[' mfilename '] Value must be real']); end;  
           metadata.(keyname) = double(value);            
           
       case 'STRING'
           if (~ischar(value)), error(['[' mfilename '] Value must be a string for string keys']); end;
           metadata.(keyname) = char(value);                
   end
end
