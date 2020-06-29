function [ directivity_id ] = load_directivity( obj, directivity_path, directivity_id_user, delay_samples )
%load_directivity loads a directivity and returns the id

[ ~, directivity_id, directivity_file_ext ] = fileparts( directivity_path );
if nargin >= 3
   directivity_id = directivity_id_user;
end

if nargin < 4
   delay_samples = 0;
   delay_samples_autodetect = true;
else
   delay_samples_autodetect = false;
end

if strcmpi( directivity_file_ext, '.daff' )
    
    % DAFF
    
    obj.directivity_db.( directivity_id ).data = DAFF( directivity_path );
    
    if delay_samples_autodetect
        mddata = obj.directivity_db.( directivity_id ).data.metadata;
        for m = 1:numel( mddata )
            mditem = mddata( m );
            if strcmpi( mditem.name, 'delay_samples' )
                delay_samples = mditem.value;
            end
        end
    end
    
    obj.directivity_db.( directivity_id ).delay_samples = delay_samples;
    
else
    
    error( 'Could not load directivity, unrecognized file extension "%s"', directivity_file_ext )
    
end

obj.directivity_db.( directivity_id ).eq_type = 'none';

end
