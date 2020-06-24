function load_paths( obj, json_file_path )

json_txt = fileread( json_file_path );
json_struct = jsondecode( json_txt );

if ~isfield( json_struct, 'class' )
    error( 'Could not import propagation path list from file %f, structure is missing field "class"', json_file_path )
end
assert( strcmpi( json_struct.class, 'propagation_path_list' ) || strcmpi( json_struct.class, 'PropagationPathList' ) )

if ~isfield( json_struct, 'propagation_paths' )
    error( 'Could not import propagation path list from file %f, structure is missing field "propagation_paths"', json_file_path )
end

obj.pps = json_struct.propagation_paths;

end
