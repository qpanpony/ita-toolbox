function [ ] = daffv15_write_metadata( fid, metadata )
%DAFF_WRITE_METADATA Write a DAFF metadata block into DAFF binary file
%
% fid       File handle
% metadata  N-lenght structure with field names 'name', 'value' and
%           'datatype' ('BOOL' == 0, 'INT' == 1, 'FLOAT' == 2, 'STRING' == 3)
%
% Note: also accepts old format (struct with key/value pairs that will be
% converted automatically using daffv15_medata_addKey() )
%
% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% This file is part of OpenDAFF, http://www.opendaff.org
%
    
    % Only structures are allowed
    if ~isstruct( metadata )
        error( 'Metadata must be a structure' );
    end
    
    nkeys = length( metadata );
    
    % Check old metadata format and convert (for convenience)
    if nkeys == 1
        metadata_new_format = [];
        metadata_fieldnames = fieldnames( metadata );
        for i=1:length(metadata_fieldnames)
            name = metadata_fieldnames{i};
            eval([' value = metadata.' name ]);
            type = '';
            
            % Logical scalar (DAFF_BOOL)
            if islogical(value) && isscalar(value)
                type = 'BOOL';
                datatype = 0;
            end

            % Integer scalar (DAFF_INT)
            if isinteger(value) && isfinite(value) && isreal(value) && isscalar(value)
                type = 'INT';
                datatype = 1;
            end

            % Floating point scalar (DAFF_FLOAT)
            if isfloat(value) && isfinite(value) && isreal(value) && isscalar(value)
                type = 'FLOAT';
                datatype = 2;
            end        

            % String (DAFF_STRING)
            if ischar( value )
                type = 'STRING';
                datatype = 3;
            end
            
            if isempty( type )
                error( 'Unsupported datatype %s for key ''%s'' in metadata', class( value ), name );
            end
            
            %metadata_new_format = daffv15_metadata_addKey( metadata_new_format, name, type, value );
            metadata_new_format(i).name = name;
            metadata_new_format(i).datatype = datatype;
            metadata_new_format(i).value = value;
        end
        
        metadata = metadata_new_format;
    end        
        
    nkeys = length( metadata );
    
    % Number of keys
    fwrite( fid, nkeys, 'int32' );
        
    % Write each metadata struct entry
    for i=1:nkeys
        
        name = metadata(i).name;
        value = metadata(i).value;
        datatype = metadata(i).datatype;
        
        % Bool
        if datatype == 0
            fwrite(fid, 0, 'int32');
            fwrite(fid, name, 'char');
            fwrite(fid, 0, 'char');
            if (value == true)
                fwrite(fid, 1, 'int32');
            else
                fwrite(fid, 0, 'int32');
            end
        end
        
        % Integer scalar (DAFF_INT)
        if datatype == 1
            fwrite(fid, 1, 'int32');
            fwrite(fid, name, 'char');
            fwrite(fid, 0, 'char');
            fwrite(fid, value, 'int32');  
        end
        
        % Floating point scalar (DAFF_FLOAT)
        if datatype == 2
            fwrite(fid, 2, 'int32');
            fwrite(fid, name, 'char');
            fwrite(fid, 0, 'char');
            fwrite(fid, value, 'double');
        end
        
        % String (DAFF_STRING)
        if datatype == 3
            fwrite(fid, 3, 'int32');
            fwrite(fid, name, 'char');
            fwrite(fid, 0, 'char');
            fwrite(fid, value, 'char');
            fwrite(fid, 0, 'char');
        end
      
        if datatype > 3
            error( 'Unsupported datatype %s for key ''%s'' in metadata', class( value ), name );
        end
    end
end
