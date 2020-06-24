function [ directivity_id ] = load_directivity( obj, directivity_path, directivity_id_user )
%load_directivity loads a directivity and returns the id

[ ~, directivity_id, directivity_file_ext ] = fileparts( directivity_path );
if nargin >= 3
   directivity_id = directivity_id_user;
end

if strcmpi( directivity_file_ext, '.daff' )
    obj.directivity_db.( directivity_id ) = DAFF( directivity_path );
else
    error( 'Could not load directivity, unrecognized file extension "%s"', directivity_file_ext )
end

end
