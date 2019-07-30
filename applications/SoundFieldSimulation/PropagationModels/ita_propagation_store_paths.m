function ita_propagation_store_paths( pps_struct, json_file_path, auto_overwrite )
%
% ita_store_propagation_paths Exports propagation path list
% from a Matlab struct into a JSON formatted text file
%
%
    if ~isfield( pps_struct, 'class' )
        error( 'Could not export propagation path list, struct is missing field "class"' )
    end
    
    assert( strcmpi( pps_struct.class, 'propagation_path_list' ) )

    if nargin < 3
        auto_overwrite = true;
    end
    
    json_txt = jsonencode( pps_struct );
    
    if exist( json_file_path, 'file' ) && ~auto_overwrite
        error( 'Refused to overwrite file %s', json_file_path )
    end
    
    fid = fopen( json_file_path, 'w' );
    fprintf( fid, '%s\n', json_txt );
    fclose( fid );
    
end
